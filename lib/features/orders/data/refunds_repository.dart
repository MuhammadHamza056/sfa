import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/network/api_result.dart';
import 'refund_models.dart';

/// M56-M59 from the guide.
class RefundsRepository {
  RefundsRepository(this._client);

  final ApiClient _client;

  /// M56: List official return reasons
  Future<ApiResult<List<RefundReason>>> getReasons() {
    return _client.get<List<RefundReason>>(
      ApiEndpoints.refundReasons,
      fromJson: (data) {
        final raw = data is Map<String, dynamic> && data['items'] is List
            ? data['items'] as List
            : (data is List ? data : const []);
        return raw.map((v) => RefundReason.fromJson(v as Map<String, dynamic>)).toList();
      },
    );
  }

  /// M57: Submit return / refund request. The guide's body is just
  /// `{reason, items}` — the comment/images/bank-detail fields from the
  /// previous guide revision were dropped, so they're no longer sent
  /// (some NestJS DTOs reject unlisted fields outright).
  Future<ApiResult<RefundSubmitResult>> submitRefundRequest({
    required String orderId,
    required String reason,
    required List<Map<String, dynamic>> items,
  }) {
    return _client.post<RefundSubmitResult>(
      ApiEndpoints.orderRefundRequest(orderId),
      data: {'reason': reason, 'items': items},
      fromJson: (data) => RefundSubmitResult.fromJson(data as Map<String, dynamic>),
    );
  }

  /// M58: Get refund request detail & progress
  Future<ApiResult<RefundDetail>> getRefundDetail(String id) {
    return _client.get<RefundDetail>(
      ApiEndpoints.refundDetail(id),
      fromJson: (data) => RefundDetail.fromJson(data as Map<String, dynamic>),
    );
  }

  /// M59: Get items in refund request
  Future<ApiResult<List<RefundItem>>> getRefundItems(String id) {
    return _client.get<List<RefundItem>>(
      ApiEndpoints.refundItems(id),
      fromJson: (data) {
        final raw = data is Map<String, dynamic> && data['items'] is List
            ? data['items'] as List
            : (data is List ? data : const []);
        return raw.map((v) => RefundItem.fromJson(v as Map<String, dynamic>)).toList();
      },
    );
  }
}
