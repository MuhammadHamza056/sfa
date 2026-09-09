import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/network/api_result.dart';
import 'ai_models.dart';

/// M95 from the guide.
class AiRepository {
  AiRepository(this._client);

  final ApiClient _client;

  /// M95: AI Fashion Stylist assistant.
  ///
  /// The one-shot REST turn. The streaming gateway (`AiSocketService`) is
  /// the normal path; `AiChatNotifier` falls back to this when the socket
  /// is down, trading streaming and conversation continuity — this endpoint
  /// takes no conversation id — for an answer that arrives at all.
  Future<ApiResult<AiChatReply>> sendMessage(String message) {
    return _client.post<AiChatReply>(
      ApiEndpoints.aiChat,
      data: {'message': message},
      fromJson: (data) => AiChatReply.fromJson(data as Map<String, dynamic>),
    );
  }

  /// Replays a stored conversation so reopening the chat resumes the thread.
  Future<ApiResult<AiConversationHistory>> fetchHistory(String conversationId) {
    return _client.get<AiConversationHistory>(
      ApiEndpoints.aiConversationMessages(conversationId),
      fromJson: (data) =>
          AiConversationHistory.fromResponse(data, conversationId),
    );
  }
}
