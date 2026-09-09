import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

import '../hive_services.dart';
import 'app_config.dart';
import 'realtime_events.dart';

/// The app's single Socket.IO connection to the SAFA gateway.
///
/// The gateway authenticates the handshake with the same JWT the REST API
/// uses and then drops the socket into the caller's identity rooms
/// (`user:<id>`, `driver:<id>`), so every event this class exposes is
/// already scoped to the signed-in user — there is nothing to filter
/// client-side except the per-delivery tracking stream.
///
/// Lifecycle mirrors the session, not the widget tree: [connect] runs at
/// launch (when a token is already stored) and after every sign-in,
/// [reconnect] after a token refresh — the JWT is baked into the handshake,
/// so a refreshed token only takes effect on a new one — and [disconnect]
/// on sign-out. Streams are broadcast and live as long as the singleton, so
/// listeners can come and go with the screens that own them.
class SocketService {
  SocketService._internal();

  static final SocketService instance = SocketService._internal();

  io.Socket? _socket;

  /// The JWT the live handshake was made with, so [connect] can tell a
  /// redundant call (same session) from one that has to rebuild the socket.
  String? _handshakeToken;

  final _connection = StreamController<bool>.broadcast();
  final _orderUpdates = StreamController<RealtimeOrderUpdate>.broadcast();
  final _notifications = StreamController<Map<String, dynamic>>.broadcast();
  final _driverLocations = StreamController<DriverLocation>.broadcast();

  /// Deliveries the app has asked to follow. Kept so the subscriptions can
  /// be replayed after a reconnect — rooms are per-socket, so a dropped
  /// connection silently stops the GPS pings otherwise.
  final Set<String> _trackedDeliveries = {};

  /// Gateway events owned by a feature rather than modelled here
  /// (`ai:stream:*`, ...). They are held in this registry instead of being
  /// bound straight to the socket because [_teardown] disposes the socket —
  /// and every listener on it — whenever the handshake has to be remade for
  /// a refreshed token. Replaying the registry on rebuild is what keeps an
  /// open AI chat from going silent after a refresh.
  final List<_FeatureBinding> _featureBindings = [];

  bool get isConnected => _socket?.connected ?? false;

  /// Emits on every connect/disconnect, starting with the current state so
  /// a widget that subscribes late still renders the right indicator.
  Stream<bool> get connectionState async* {
    yield isConnected;
    yield* _connection.stream;
  }

  /// `order:status_updated`
  Stream<RealtimeOrderUpdate> get orderUpdates => _orderUpdates.stream;

  /// `notification:new`, raw — the notifications feature owns the parsing.
  Stream<Map<String, dynamic>> get notifications => _notifications.stream;

  /// `delivery:location` / `tracking:location`, across all subscriptions.
  Stream<DriverLocation> get driverLocations => _driverLocations.stream;

  /// Opens the connection for the stored session. No-op while signed out,
  /// and no-op when a socket for this very token is already up, so callers
  /// (launch, sign-in, resume) can fire it defensively.
  void connect() {
    final token = SecureStorage.getAccessToken();
    if (token == null || token.isEmpty) {
      disconnect();
      return;
    }
    if (_socket != null && _handshakeToken == token) {
      if (!isConnected) _socket!.connect();
      return;
    }

    _teardown();
    _handshakeToken = token;

    // The token goes in both `auth` and `query`: the gateway reads the
    // handshake auth payload, while the polling fallback carries it in the
    // query string.
    final socket = io.io(
      AppConfig.socketUrl,
      io.OptionBuilder()
          .setTransports(['websocket', 'polling'])
          .enableAutoConnect()
          .enableReconnection()
          .setReconnectionDelay(2000)
          .setAuth({'token': token})
          .setQuery({'token': token})
          .build(),
    );
    _socket = socket;

    socket.onConnect((_) {
      debugPrint('🟢 [SocketService] connected: ${socket.id}');
      _connection.add(true);
      // Re-enter the tracking rooms this session had before the drop.
      for (final deliveryId in _trackedDeliveries) {
        socket.emit('tracking:subscribe', {'deliveryId': deliveryId});
      }
    });

    socket.onDisconnect((reason) {
      debugPrint('🔴 [SocketService] disconnected: $reason');
      _connection.add(false);
    });

    socket.onConnectError((error) {
      debugPrint('⚠️ [SocketService] connect error: $error');
      _connection.add(false);
    });

    socket.on('order:status_updated', (data) {
      final json = _asMap(data);
      if (json == null) return;
      _orderUpdates.add(RealtimeOrderUpdate.fromJson(json));
    });

    socket.on('notification:new', (data) {
      final json = _asMap(data);
      if (json == null) return;
      _notifications.add(json);
    });

    // Both spellings are handled here, once, rather than per subscription:
    // registering the handler inside [subscribeToTracking] would stack a
    // duplicate listener for every screen visit.
    for (final event in const ['delivery:location', 'tracking:location']) {
      socket.on(event, (data) {
        final json = _asMap(data);
        if (json == null) return;
        final location = DriverLocation.fromJson(json);
        if (location != null) _driverLocations.add(location);
      });
    }

    for (final binding in _featureBindings) {
      socket.on(binding.event, binding.wrapper);
    }
  }

  /// Subscribes [handler] to a gateway event this class does not model
  /// itself, decoding the payload the same way the built-in events do.
  /// The subscription survives reconnects and token refreshes; pair every
  /// call with [removeHandler] when the listening feature goes away.
  void addHandler(
    String event,
    void Function(Map<String, dynamic> payload) handler,
  ) {
    final alreadyBound = _featureBindings
        .any((b) => b.event == event && b.handler == handler);
    if (alreadyBound) return;
    final binding = _FeatureBinding(event, handler);
    _featureBindings.add(binding);
    _socket?.on(event, binding.wrapper);
  }

  void removeHandler(
    String event,
    void Function(Map<String, dynamic> payload) handler,
  ) {
    final index = _featureBindings
        .indexWhere((b) => b.event == event && b.handler == handler);
    if (index < 0) return;
    final binding = _featureBindings.removeAt(index);
    // Detaching by closure, not by event name: another feature may still be
    // listening to the same event, and `off(event)` alone would unbind it too.
    _socket?.off(event, binding.wrapper);
  }

  /// Sends a feature event to the gateway. Emitted while the socket is down
  /// the packet is buffered by socket.io and flushed on reconnect, so
  /// callers still need their own timeout to notice a connection that never
  /// comes back.
  void emitEvent(String event, Map<String, dynamic> payload) {
    _socket?.emit(event, payload);
  }

  /// Rebuilds the connection so the handshake picks up a new access token
  /// (after a refresh). Cheap when nothing changed — [connect] bails out.
  void reconnect() {
    final token = SecureStorage.getAccessToken();
    if (token != _handshakeToken) _teardown();
    connect();
  }

  /// Follows one delivery's GPS feed. Pings arrive on [driverLocations];
  /// pair every call with [unsubscribeFromTracking] when the screen closes.
  void subscribeToTracking(String deliveryId) {
    if (deliveryId.isEmpty) return;
    _trackedDeliveries.add(deliveryId);
    _socket?.emit('tracking:subscribe', {'deliveryId': deliveryId});
  }

  void unsubscribeFromTracking(String deliveryId) {
    _trackedDeliveries.remove(deliveryId);
    _socket?.emit('tracking:unsubscribe', {'deliveryId': deliveryId});
  }

  /// Driver role only — reports the courier's position while a run is
  /// active. The gateway fans it out to the customers tracking that
  /// delivery, so a customer build never calls this.
  void sendDriverLocation({required double lat, required double lng}) {
    _socket?.emit('location:update', {'lat': lat, 'lng': lng});
  }

  /// Drops the connection and forgets the session's tracking rooms. Safe to
  /// call when nothing is connected.
  void disconnect() {
    if (_socket == null) return;
    // Unlike [_teardown], this ends the session: the rooms belong to the
    // user who just signed out, so they must not be replayed.
    _trackedDeliveries.clear();
    _featureBindings.clear();
    _teardown();
    _connection.add(false);
  }

  /// Disposes the live socket while keeping [_trackedDeliveries], so a
  /// rebuild triggered by a token refresh re-enters the same rooms and an
  /// open tracking map doesn't go silent.
  void _teardown() {
    _handshakeToken = null;
    final socket = _socket;
    _socket = null;
    // `dispose` already disconnects and drops every listener.
    socket?.dispose();
  }

  /// socket.io hands the payload through untyped: a JSON object arrives as
  /// `Map<String, dynamic>` on some transports and `Map<dynamic, dynamic>`
  /// on others, an ack-style event wraps it in a single-element list, and a
  /// server that emits a pre-encoded body sends a String. All four are the
  /// same event as far as callers are concerned.
  static Map<String, dynamic>? _asMap(dynamic data) {
    if (data is Map) {
      return data.map((key, value) => MapEntry(key.toString(), value));
    }
    if (data is List) {
      return data.isEmpty ? null : _asMap(data.first);
    }
    if (data is String) {
      try {
        return _asMap(jsonDecode(data));
      } catch (_) {
        return null;
      }
    }
    return null;
  }
}

/// One feature's subscription to a gateway event.
///
/// [wrapper] is the closure actually handed to socket.io. It is built once
/// and kept so the binding can be re-attached to a rebuilt socket and
/// detached again individually — a fresh closure per attach would leak the
/// old listener on the next reconnect.
class _FeatureBinding {
  _FeatureBinding(this.event, this.handler) {
    wrapper = _receive;
  }

  final String event;
  final void Function(Map<String, dynamic> payload) handler;

  /// Assigned once, because `off` unbinds by equality: handing socket.io a
  /// fresh tear-off on every attach would leave the old listener in place.
  late final void Function(dynamic data) wrapper;

  void _receive(dynamic data) {
    final json = SocketService._asMap(data);
    if (json != null) handler(json);
  }
}
