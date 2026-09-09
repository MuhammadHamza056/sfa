/// Payloads pushed over the Socket.IO gateway (see the SAFA real-time
/// integration guide). Kept next to [SocketService] rather than in a
/// feature folder because a socket event can address any feature.
///
/// Every `fromJson` is deliberately lenient about key names: the gateway
/// re-emits Mongo documents in some events (`_id`) and hand-built payloads
/// in others (`orderId`), so both spellings are accepted.
library;

/// `order:status_updated` — an order moved to a new stage.
class RealtimeOrderUpdate {
  final String orderId;
  final String orderNumber;
  final String status;
  final String? paymentStatus;
  final DateTime? updatedAt;

  const RealtimeOrderUpdate({
    required this.orderId,
    required this.orderNumber,
    required this.status,
    this.paymentStatus,
    this.updatedAt,
  });

  factory RealtimeOrderUpdate.fromJson(Map<String, dynamic> json) {
    return RealtimeOrderUpdate(
      orderId: (json['orderId'] ?? json['_id'] ?? json['id'])?.toString() ?? '',
      orderNumber: (json['orderNumber'] ?? json['number'])?.toString() ?? '',
      status: (json['status'] ?? json['orderStatus'])?.toString() ?? '',
      paymentStatus: json['paymentStatus']?.toString(),
      updatedAt: DateTime.tryParse(json['updatedAt']?.toString() ?? ''),
    );
  }
}

/// `delivery:location` / `tracking:location` — one GPS ping from a courier.
///
/// [deliveryId] is nullable because the gateway only echoes it back on some
/// builds; a ping without it is assumed to belong to whatever delivery the
/// socket is currently subscribed to.
class DriverLocation {
  final String? deliveryId;
  final double lat;
  final double lng;
  final DateTime receivedAt;

  DriverLocation({
    required this.lat,
    required this.lng,
    this.deliveryId,
    DateTime? receivedAt,
  }) : receivedAt = receivedAt ?? DateTime.now();

  /// Returns null when the payload carries no usable coordinate pair, so a
  /// malformed ping is dropped instead of jumping the map marker to (0, 0).
  static DriverLocation? fromJson(Map<String, dynamic> json) {
    final lat = _toDouble(json['lat'] ?? json['latitude']);
    final lng = _toDouble(json['lng'] ?? json['lon'] ?? json['longitude']);
    if (lat == null || lng == null) return null;
    return DriverLocation(
      lat: lat,
      lng: lng,
      deliveryId: (json['deliveryId'] ?? json['delivery'] ?? json['_id'])
          ?.toString(),
    );
  }

  static double? _toDouble(Object? value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }
}
