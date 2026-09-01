import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../data/ai_models.dart';
import '../data/ai_repository.dart';

final aiRepositoryProvider = Provider<AiRepository>((ref) {
  return AiRepository(ApiClient.instance);
});

class AiChatState {
  final List<AiChatMessage> messages;
  final bool isSending;

  const AiChatState({this.messages = const [], this.isSending = false});

  AiChatState copyWith({List<AiChatMessage>? messages, bool? isSending}) {
    return AiChatState(
      messages: messages ?? this.messages,
      isSending: isSending ?? this.isSending,
    );
  }
}

/// M95. In-memory only — the guide has no endpoint to persist/load chat
/// history, so the conversation resets each time the screen is reopened.
class AiChatNotifier extends AutoDisposeNotifier<AiChatState> {
  AiRepository get _repository => ref.read(aiRepositoryProvider);

  @override
  AiChatState build() => const AiChatState();

  Future<void> send(String message) async {
    final trimmed = message.trim();
    if (trimmed.isEmpty || state.isSending) return;

    state = state.copyWith(
      messages: [...state.messages, AiChatMessage(role: ChatRole.user, text: trimmed)],
      isSending: true,
    );

    final result = await _repository.sendMessage(trimmed);
    result.when(
      success: (reply) {
        state = state.copyWith(
          messages: [
            ...state.messages,
            AiChatMessage(
              role: ChatRole.assistant,
              text: reply.reply,
              recommendedProducts: reply.recommendedProducts,
            ),
          ],
          isSending: false,
        );
      },
      failure: (error) {
        state = state.copyWith(
          messages: [
            ...state.messages,
            AiChatMessage(role: ChatRole.assistant, text: error.message),
          ],
          isSending: false,
        );
      },
    );
  }
}

final aiChatProvider = NotifierProvider.autoDispose<AiChatNotifier, AiChatState>(
  AiChatNotifier.new,
);
