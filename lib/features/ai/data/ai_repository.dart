import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/network/api_result.dart';
import 'ai_models.dart';

/// M95 from the guide.
class AiRepository {
  AiRepository(this._client);

  final ApiClient _client;

  /// M95: AI Fashion Stylist assistant
  Future<ApiResult<AiChatReply>> sendMessage(String message) {
    return _client.post<AiChatReply>(
      ApiEndpoints.aiChat,
      data: {'message': message},
      fromJson: (data) => AiChatReply.fromJson(data as Map<String, dynamic>),
    );
  }
}
