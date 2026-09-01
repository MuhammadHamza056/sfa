import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/network/api_result.dart';
import 'delivery_models.dart';

/// Section 16 from the guide: on-demand door-to-door courier delivery. No
/// response example is given, so this returns the raw decoded body — wrap
/// it in a typed model once a screen needs specific fields from it.
class DeliveryRepository {
  DeliveryRepository(this._client);

  final ApiClient _client;

  /// 1. Create Courier Delivery Order
  Future<ApiResult<Map<String, dynamic>>> createDelivery(CourierDeliveryRequest request) {
    return _client.post<Map<String, dynamic>>(
      ApiEndpoints.deliveries,
      data: request.toJson(),
      fromJson: (data) => data as Map<String, dynamic>,
    );
  }

  /// 2. Pay for Delivery Order
  Future<ApiResult<Map<String, dynamic>>> checkoutDelivery(
    String deliveryId, {
    required String paymentMethod,
  }) {
    return _client.post<Map<String, dynamic>>(
      ApiEndpoints.deliveryCheckout(deliveryId),
      data: {'paymentMethod': paymentMethod},
      fromJson: (data) => data as Map<String, dynamic>,
    );
  }

  /// 3. Compare Logistics Companies Fares
  Future<ApiResult<Map<String, dynamic>>> compareCompanies(CourierDeliveryRequest request) {
    return _client.post<Map<String, dynamic>>(
      ApiEndpoints.deliveryCompareCompanies,
      data: request.toJson(),
      fromJson: (data) => data as Map<String, dynamic>,
    );
  }

  /// Part 1's M26: Delivery fare & time estimate
  Future<ApiResult<Map<String, dynamic>>> getDeliveryEstimate({
    Map<String, dynamic>? queryParameters,
  }) {
    return _client.get<Map<String, dynamic>>(
      ApiEndpoints.deliveryEstimate,
      queryParameters: queryParameters,
      fromJson: (data) => data as Map<String, dynamic>,
    );
  }
}
