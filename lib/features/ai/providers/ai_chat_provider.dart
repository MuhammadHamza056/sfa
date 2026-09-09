import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/hive_services.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/network/api_client.dart';
import '../../../core/providers/realtime_providers.dart';
import '../data/ai_models.dart';
import '../data/ai_repository.dart';
import '../data/ai_socket_service.dart';
import '../data/ai_stream_events.dart';

final aiRepositoryProvider = Provider<AiRepository>((ref) {
  return AiRepository(ApiClient.instance);
});

/// Rides the app's shared gateway connection; disposed with the chat screen
/// so the `ai:stream:*` handlers come off the socket when nobody is looking
/// at them.
final aiSocketServiceProvider = Provider.autoDispose<AiSocketService>((ref) {
  final service = AiSocketService(ref.watch(socketServiceProvider));
  ref.onDispose(service.dispose);
  return service;
});

class AiChatState {
  final List<AiChatMessage> messages;

  /// A turn is open: emitted to the gateway, not yet closed by `done` or
  /// `error`. Note this stays true *while* chunks stream in, so the UI
  /// should key its "thinking" spinner off the placeholder bubble being
  /// empty rather than off this alone.
  final bool isSending;

  final bool isLoadingHistory;

  /// Null until the gateway names the conversation on the first
  /// `ai:stream:start`, or until a stored id is restored at build.
  final String? conversationId;

  const AiChatState({
    this.messages = const [],
    this.isSending = false,
    this.isLoadingHistory = false,
    this.conversationId,
  });

  AiChatState copyWith({
    List<AiChatMessage>? messages,
    bool? isSending,
    bool? isLoadingHistory,
    String? conversationId,
  }) {
    return AiChatState(
      messages: messages ?? this.messages,
      isSending: isSending ?? this.isSending,
      isLoadingHistory: isLoadingHistory ?? this.isLoadingHistory,
      conversationId: conversationId ?? this.conversationId,
    );
  }
}

/// M95, streaming. One turn is in flight at a time: [send] is a no-op while
/// [AiChatState.isSending], which keeps the "open assistant bubble" the
/// chunk handlers append to unambiguous — it is always the last message.
class AiChatNotifier extends AutoDisposeNotifier<AiChatState> {
  /// Set from [Ref.onDispose]. Riverpod throws on a state write after
  /// disposal, and every write here is reached from a socket callback or a
  /// timer that can outlive the screen by a frame.
  bool _disposed = false;

  Timer? _watchdog;

  /// Text of the turn in flight, so a failed turn can be retried without
  /// the user retyping it.
  String? _lastSent;

  /// The gateway can go quiet without an `ai:stream:error` — a dropped
  /// socket, or an upstream OpenAI stall. Reset on every inbound event, so
  /// this measures silence rather than total turn length.
  static const Duration _idleTimeout = Duration(seconds: 30);

  AiRepository get _repository => ref.read(aiRepositoryProvider);

  @override
  AiChatState build() {
    final socket = ref.watch(aiSocketServiceProvider);

    final subscriptions = <StreamSubscription<Object>>[
      socket.onStart.listen(_onStart),
      socket.onChunk.listen(_onChunk),
      socket.onProducts.listen(_onProducts),
      socket.onDone.listen(_onDone),
      socket.onError.listen(_onError),
    ];

    ref.onDispose(() {
      _disposed = true;
      _watchdog?.cancel();
      for (final subscription in subscriptions) {
        subscription.cancel();
      }
    });

    final storedId = SecureStorage.getAiConversationId();
    if (storedId != null && storedId.isNotEmpty) {
      // Fire-and-forget: the thread fills in when it arrives, and a failure
      // just leaves the user on an empty (but usable) chat.
      Future.microtask(() => _restoreHistory(storedId));
      return AiChatState(conversationId: storedId, isLoadingHistory: true);
    }
    return const AiChatState();
  }

  Future<void> _restoreHistory(String conversationId) async {
    final result = await _repository.fetchHistory(conversationId);
    if (_disposed) return;
    result.when(
      success: (history) {
        // A turn started while history was loading wins: dropping the
        // user's just-sent message to splice in an older thread would look
        // like the app ate it.
        if (state.isSending || state.messages.isNotEmpty) {
          state = state.copyWith(isLoadingHistory: false);
          return;
        }
        state = state.copyWith(
          messages: history.messages,
          isLoadingHistory: false,
        );
      },
      failure: (_) {
        // The stored id is stale (conversation expired or belongs to a
        // signed-out account) — start clean rather than stranding every
        // future turn on an id the backend rejects.
        SecureStorage.putAiConversationId(null);
        state = AiChatState(messages: state.messages, isSending: state.isSending);
      },
    );
  }

  /// Sends one turn. [locale] defaults to the app's current language, which
  /// is what the assistant answers in.
  void send(String message, {String? locale, int? maxBudgetFils}) {
    final trimmed = message.trim();
    if (trimmed.isEmpty || state.isSending) return;

    _lastSent = trimmed;
    state = state.copyWith(
      messages: [
        ...state.messages,
        AiChatMessage(role: ChatRole.user, text: trimmed),
        // The placeholder the chunks stream into. It is appended up front
        // so the typing indicator appears in the thread, in position,
        // before the first token lands.
        const AiChatMessage(
          role: ChatRole.assistant,
          text: '',
          isStreaming: true,
        ),
      ],
      isSending: true,
    );

    final socket = ref.read(aiSocketServiceProvider);
    if (!socket.isConnected) {
      // socket.io would buffer the emit and flush it on reconnect, which on
      // a genuinely dead connection means the user waits out the watchdog
      // for nothing. The REST turn answers now instead — without streaming,
      // and without conversation continuity, since that endpoint takes no
      // conversation id.
      _sendOverRest(trimmed);
      return;
    }

    socket.sendMessage(
      message: trimmed,
      locale: locale ?? localeNotifier.value.languageCode,
      conversationId: state.conversationId,
      maxBudgetFils: maxBudgetFils,
    );
    _restartWatchdog();
  }

  Future<void> _sendOverRest(String message) async {
    final result = await _repository.sendMessage(message);
    if (_disposed) return;
    result.when(
      success: (reply) => _updateOpenReply(
        (open) => open.copyWith(
          text: reply.reply,
          recommendedProducts: reply.recommendedProducts,
          isStreaming: false,
        ),
        isSending: false,
      ),
      failure: (error) => _fail(AiChatErrorKind.server, error.message),
    );
  }

  /// Re-sends the turn that failed, replacing its error bubble.
  void retryLast() {
    final message = _lastSent;
    if (message == null || state.isSending) return;
    final messages = [...state.messages];
    // Drop the failed assistant bubble and the user bubble [send] re-adds.
    if (messages.isNotEmpty && messages.last.role == ChatRole.assistant) {
      messages.removeLast();
    }
    if (messages.isNotEmpty && messages.last.role == ChatRole.user) {
      messages.removeLast();
    }
    state = state.copyWith(messages: messages);
    send(message);
  }

  /// Forgets the thread on both sides of the app: the visible messages and
  /// the id that would otherwise resume it on the next open.
  void startNewConversation() {
    if (state.isSending) return;
    SecureStorage.putAiConversationId(null);
    _lastSent = null;
    state = const AiChatState();
  }

  void _onStart(AiStreamStart event) {
    if (!_accepts(event.conversationId)) return;
    _restartWatchdog();
    _adoptConversation(event.conversationId);
    final userMessageId = event.userMessageId;
    if (userMessageId == null) return;
    // Name the optimistic user bubble now that the server has an id for it.
    final messages = [...state.messages];
    final index = messages.lastIndexWhere((m) => m.role == ChatRole.user);
    if (index < 0 || messages[index].id != null) return;
    messages[index] = messages[index].copyWith(id: userMessageId);
    state = state.copyWith(messages: messages);
  }

  void _onChunk(AiStreamChunk event) {
    if (!_accepts(event.conversationId) || event.delta.isEmpty) return;
    _restartWatchdog();
    _updateOpenReply((open) => open.copyWith(text: open.text + event.delta));
  }

  void _onProducts(AiStreamProducts event) {
    if (!_accepts(event.conversationId) || event.products.isEmpty) return;
    _restartWatchdog();
    _updateOpenReply((open) => open.copyWith(recommendedProducts: event.products));
  }

  void _onDone(AiStreamDone event) {
    if (!_accepts(event.conversationId)) return;
    _watchdog?.cancel();
    _adoptConversation(event.conversationId);
    _updateOpenReply(
      (open) => open.copyWith(
        id: event.messageId,
        // `fullReply` is authoritative — preferring it over the accumulated
        // chunks means a dropped chunk doesn't leave a hole in the bubble.
        // It is only ignored when absent, which some gateways do on the
        // grounds that the client already has every delta.
        text: event.fullReply.isNotEmpty ? event.fullReply : open.text,
        recommendedProducts: event.products.isNotEmpty
            ? event.products
            : open.recommendedProducts,
        isStreaming: false,
      ),
      isSending: false,
    );
  }

  void _onError(AiStreamError event) {
    if (!_accepts(event.conversationId)) return;
    _fail(AiChatErrorKind.server, event.message);
  }

  /// Whether an event belongs to the turn currently on screen. Events for
  /// another conversation are ignored; the gateway sends no `conversationId`
  /// on some errors, and none exists at all on the very first turn, so an
  /// empty id is always accepted.
  bool _accepts(String conversationId) {
    if (_disposed || !state.isSending) return false;
    if (conversationId.isEmpty) return true;
    final current = state.conversationId;
    return current == null || current.isEmpty || current == conversationId;
  }

  void _adoptConversation(String conversationId) {
    if (conversationId.isEmpty || conversationId == state.conversationId) return;
    state = state.copyWith(conversationId: conversationId);
    SecureStorage.putAiConversationId(conversationId);
  }

  /// Rewrites the open assistant bubble — always the last message while a
  /// turn is in flight, since [send] refuses to start a second one.
  void _updateOpenReply(
    AiChatMessage Function(AiChatMessage open) update, {
    bool? isSending,
  }) {
    if (_disposed) return;
    final messages = [...state.messages];
    final index = messages.lastIndexWhere(
      (m) => m.role == ChatRole.assistant && m.isStreaming,
    );
    if (index < 0) return;
    messages[index] = update(messages[index]);
    state = state.copyWith(messages: messages, isSending: isSending);
  }

  void _restartWatchdog() {
    _watchdog?.cancel();
    _watchdog = Timer(_idleTimeout, () {
      if (_disposed || !state.isSending) return;
      // socket.io buffers an emit made while the connection is down, so a
      // silent turn means either a stalled stream or a socket that never
      // came back — worth telling apart in the message the user sees.
      final connected = ref.read(aiSocketServiceProvider).isConnected;
      _fail(connected ? AiChatErrorKind.timeout : AiChatErrorKind.offline, '');
    });
  }

  void _fail(AiChatErrorKind kind, String message) {
    _watchdog?.cancel();
    _updateOpenReply(
      (open) => open.copyWith(
        // Partial text is kept: a stream that broke halfway still answered
        // half the question, and dropping it looks like data loss.
        text: message.isNotEmpty && open.text.isEmpty ? message : open.text,
        isStreaming: false,
        errorKind: kind,
      ),
      isSending: false,
    );
  }
}

final aiChatProvider = NotifierProvider.autoDispose<AiChatNotifier, AiChatState>(
  AiChatNotifier.new,
);
