import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/network/api_result.dart';
import 'order_models.dart';

/// M49-M50 from the guide.
class OrdersRepository {
  OrdersRepository(this._client);

  final ApiClient _client;

  /// M50: List customer orders (history & active)
  Future<ApiResult<OrdersPage>> getOrders({
    int page = 1,
    int limit = 10,
    String? status,
  }) {
    return _client.get<OrdersPage>(
      ApiEndpoints.orders,
      queryParameters: {
        'page': page,
        'limit': limit,
        if (status != null) 'status': status,
      },
      fromJson: (data) {
        if (data is Map<String, dynamic> && data.containsKey('items')) {
          return OrdersPage.fromJson(data);
        }
        final items = data is List
            ? data.map((v) => Order.fromJson(v as Map<String, dynamic>)).toList()
            : <Order>[];
        return OrdersPage(items: items, total: items.length, page: 1, totalPages: 1);
      },
    );
  }

  // M49 no longer exists as a standalone endpoint in the revised guide —
  // "Place Order" is now explicitly routed through M39
  // (`POST /checkout/create-order`, see CheckoutRepository.confirmCheckout)
  // rather than a direct single-item `/orders` POST.

  /// M51: Order details & customer summary
  Future<ApiResult<OrderDetail>> getOrderDetail(String id) {
    return _client.get<OrderDetail>(
      ApiEndpoints.orderDetail(id),
      fromJson: (data) => OrderDetail.fromJson(data as Map<String, dynamic>),
    );
  }

  /// M52/M62: Multi-stage status progression timeline
  Future<ApiResult<OrderTracking>> getOrderTracking(String id) {
    return _client.get<OrderTracking>(
      ApiEndpoints.orderTracking(id),
      fromJson: (data) => OrderTracking.fromJson(data as Map<String, dynamic>),
    );
  }

  /// M53: Cancel order before fulfillment
  Future<ApiResult<void>> cancelOrder(String id, {required String reason}) {
    return _client.post<void>(
      ApiEndpoints.orderCancel(id),
      data: {'reason': reason},
      fromJson: (_) {},
    );
  }

  /// M54/M63: Sends an OTP to the customer to confirm delivery receipt.
  Future<ApiResult<DeliveryOtpRequestResult>> sendDeliveryOtp(String id) {
    return _client.post<DeliveryOtpRequestResult>(
      ApiEndpoints.orderSendDeliveryOtp(id),
      fromJson: (data) => DeliveryOtpRequestResult.fromJson(
        data as Map<String, dynamic>? ?? const {},
      ),
    );
  }

  /// M54/M63: Verifies the delivery OTP and confirms receipt.
  Future<ApiResult<void>> verifyDeliveryOtp(String id, {required String otp}) {
    return _client.post<void>(
      ApiEndpoints.orderVerifyDeliveryOtp(id),
      data: {'otp': otp},
      fromJson: (_) {},
    );
  }

  /// M61: Assigned delivery driver info
  Future<ApiResult<DeliveryInfo>> getDeliveryInfo(String id) {
    return _client.get<DeliveryInfo>(
      ApiEndpoints.orderDeliveryInfo(id),
      fromJson: (data) => DeliveryInfo.fromJson(data as Map<String, dynamic>),
    );
  }

  /// M60: Customer order counter metrics
  Future<ApiResult<OrderStatistics>> getStatistics() {
    return _client.get<OrderStatistics>(
      ApiEndpoints.orderStatistics,
      fromJson: (data) => OrderStatistics.fromJson(data as Map<String, dynamic>),
    );
  }

  /// M55: Get eligible items for refund
  Future<ApiResult<List<ReturnableItem>>> getReturnableItems(String id) {
    return _client.get<List<ReturnableItem>>(
      ApiEndpoints.orderReturnableItems(id),
      fromJson: (data) {
        final raw = data is Map<String, dynamic> && data['items'] is List
            ? data['items'] as List
            : (data is List ? data : const []);
        return raw.map((v) => ReturnableItem.fromJson(v as Map<String, dynamic>)).toList();
      },
    );
  }
}
