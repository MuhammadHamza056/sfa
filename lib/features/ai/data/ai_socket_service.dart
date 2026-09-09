import 'dart:async';

import '../../../core/network/socket_service.dart';
import 'ai_stream_events.dart';

/// The AI assistant's half of the Socket.IO gateway.
///
/// This deliberately does **not** open its own connection. The app already
/// holds one authenticated socket to this very gateway ([SocketService],
/// opened on sign-in and rebuilt on token refresh), and a second handshake
/// to the same host would duplicate the auth round-trip and the identity
/// rooms while needing its own token-refresh lifecycle. Riding the shared
/// socket means the AI stream is live exactly when the rest of the app's
/// real-time features are.
///
/// Instances are per-conversation-screen: [dispose] detaches the handlers,
/// so closing the chat stops the listening without touching the connection
/// other features depend on.
class AiSocketService {
  AiSocketService(this._socket) {
    _bind('ai:stream:start', (json) => _start.add(AiStreamStart.fromJson(json)));
    _bind('ai:stream:chunk', (json) => _chunk.add(AiStreamChunk.fromJson(json)));
    _bind('ai:stream:products',
        (json) => _products.add(AiStreamProducts.fromJson(json)));
    _bind('ai:stream:done', (json) => _done.add(AiStreamDone.fromJson(json)));
    _bind('ai:stream:error', (json) => _error.add(AiStreamError.fromJson(json)));
  }

  final SocketService _socket;

  final _start = StreamController<AiStreamStart>.broadcast();
  final _chunk = StreamController<AiStreamChunk>.broadcast();
  final _products = StreamController<AiStreamProducts>.broadcast();
  final _done = StreamController<AiStreamDone>.broadcast();
  final _error = StreamController<AiStreamError>.broadcast();

  /// Handlers registered on the shared socket, kept so [dispose] can take
  /// exactly these back off it.
  final Map<String, void Function(Map<String, dynamic>)> _handlers = {};

  Stream<AiStreamStart> get onStart => _start.stream;
  Stream<AiStreamChunk> get onChunk => _chunk.stream;
  Stream<AiStreamProducts> get onProducts => _products.stream;
  Stream<AiStreamDone> get onDone => _done.stream;
  Stream<AiStreamError> get onError => _error.stream;

  /// Whether the shared socket is up. False here means an emitted message
  /// is buffered rather than sent, so the caller should show a reconnecting
  /// state instead of a normal "thinking" one.
  bool get isConnected => _socket.isConnected;

  Stream<bool> get connectionState => _socket.connectionState;

  /// Sends one turn. [conversationId] is null only for the first message of
  /// a new conversation — the gateway mints the id and returns it on
  /// `ai:stream:start`.
  void sendMessage({
    required String message,
    required String locale,
    String? conversationId,
    int? maxBudgetFils,
  }) {
    _socket.emitEvent('ai:message:send', {
      'message': message,
      'locale': locale,
      if (conversationId != null && conversationId.isNotEmpty)
        'conversationId': conversationId,
      'maxBudgetFils': ?maxBudgetFils,
    });
  }

  void _bind(String event, void Function(Map<String, dynamic>) handler) {
    _handlers[event] = handler;
    _socket.addHandler(event, handler);
  }

  void dispose() {
    _handlers.forEach(_socket.removeHandler);
    _handlers.clear();
    _start.close();
    _chunk.close();
    _products.close();
    _done.close();
    _error.close();
  }
}
