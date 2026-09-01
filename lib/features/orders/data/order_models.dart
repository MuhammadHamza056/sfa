import '../../../core/models/localized_text.dart';

class OrderLineItem {
  final LocalizedText name;
  final int quantity;
  final String image;

  const OrderLineItem({required this.name, required this.quantity, required this.image});

  factory OrderLineItem.fromJson(Map<String, dynamic> json) {
    return OrderLineItem(
      name: LocalizedText.fromJson(json['name'] as Map<String, dynamic>? ?? const {}),
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      image: json['image']?.toString() ?? '',
    );
  }
}

/// M50 — matches the guide's response example exactly.
class Order {
  final String id;
  final String orderNumber;
  final DateTime? createdAt;
  final String status;
  final int totalFils;
  final String currency;
  final List<OrderLineItem> items;

  const Order({
    required this.id,
    required this.orderNumber,
    this.createdAt,
    required this.status,
    required this.totalFils,
    this.currency = 'SAR',
    this.items = const [],
  });

  /// The guide's statuses read as an active/completed split even though it
  /// doesn't enumerate the full set; anything not obviously terminal is
  /// treated as "current" so an unrecognized status still shows up somewhere.
  bool get isActive => !{
        'DELIVERED',
        'COMPLETED',
        'CANCELLED',
        'CANCELED',
        'REFUNDED',
      }.contains(status.toUpperCase());

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id']?.toString() ?? '',
      orderNumber: json['orderNumber']?.toString() ?? '',
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? ''),
      status: json['status']?.toString() ?? '',
      totalFils: (json['totalFils'] as num?)?.toInt() ?? 0,
      currency: json['currency'] as String? ?? 'SAR',
      items: (json['items'] as List? ?? const [])
          .map((v) => OrderLineItem.fromJson(v as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// One item within [OrderDetail] (M51) — richer than the list's
/// [OrderLineItem]: carries price/variant/brand so the detail screen
/// doesn't need a second product lookup.
class OrderDetailItem {
  final String itemId;
  final LocalizedText name;
  final int quantity;
  final int priceFils;
  final String? selectedSize;
  final String? selectedColor;
  final String image;
  final String? brandName;

  const OrderDetailItem({
    required this.itemId,
    required this.name,
    required this.quantity,
    required this.priceFils,
    this.selectedSize,
    this.selectedColor,
    required this.image,
    this.brandName,
  });

  factory OrderDetailItem.fromJson(Map<String, dynamic> json) {
    return OrderDetailItem(
      itemId: json['itemId']?.toString() ?? '',
      name: LocalizedText.fromJson(json['name'] as Map<String, dynamic>? ?? const {}),
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      priceFils: (json['priceFils'] as num?)?.toInt() ?? 0,
      selectedSize: json['selectedSize'] as String?,
      selectedColor: json['selectedColor'] as String?,
      image: json['image']?.toString() ?? '',
      brandName: (json['brand'] as Map<String, dynamic>?)?['name'] as String?,
    );
  }
}

class OrderShippingAddress {
  final String city;
  final String district;
  final String street;
  final String recipientName;
  final String phone;

  const OrderShippingAddress({
    required this.city,
    required this.district,
    required this.street,
    required this.recipientName,
    required this.phone,
  });

  factory OrderShippingAddress.fromJson(Map<String, dynamic> json) {
    return OrderShippingAddress(
      city: json['city']?.toString() ?? '',
      district: json['district']?.toString() ?? '',
      street: json['street']?.toString() ?? '',
      recipientName: json['recipientName']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
    );
  }
}

/// M51 — matches the guide's response example exactly.
class OrderDetail {
  final String id;
  final String orderNumber;
  final String status;
  final DateTime? createdAt;
  final List<OrderDetailItem> items;
  final int subtotalFils;
  final int discountFils;
  final int deliveryFeeFils;
  final int taxFils;
  final int totalFils;
  final String currency;
  final String deliveryMethod;
  final OrderShippingAddress? shippingAddress;

  const OrderDetail({
    required this.id,
    required this.orderNumber,
    required this.status,
    this.createdAt,
    this.items = const [],
    required this.subtotalFils,
    required this.discountFils,
    required this.deliveryFeeFils,
    required this.taxFils,
    required this.totalFils,
    this.currency = 'SAR',
    this.deliveryMethod = 'DELIVERY',
    this.shippingAddress,
  });

  factory OrderDetail.fromJson(Map<String, dynamic> json) {
    return OrderDetail(
      id: json['id']?.toString() ?? '',
      orderNumber: json['orderNumber']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? ''),
      items: (json['items'] as List? ?? const [])
          .map((v) => OrderDetailItem.fromJson(v as Map<String, dynamic>))
          .toList(),
      subtotalFils: (json['subtotalFils'] as num?)?.toInt() ?? 0,
      discountFils: (json['discountFils'] as num?)?.toInt() ?? 0,
      deliveryFeeFils: (json['deliveryFeeFils'] as num?)?.toInt() ?? 0,
      taxFils: (json['taxFils'] as num?)?.toInt() ?? 0,
      totalFils: (json['totalFils'] as num?)?.toInt() ?? 0,
      currency: json['currency'] as String? ?? 'SAR',
      deliveryMethod: json['deliveryMethod'] as String? ?? 'DELIVERY',
      shippingAddress: json['shippingAddress'] is Map<String, dynamic>
          ? OrderShippingAddress.fromJson(json['shippingAddress'] as Map<String, dynamic>)
          : null,
    );
  }
}

class OrderTrackingStep {
  final String status;
  final String label;
  final bool completed;
  final DateTime? timestamp;

  const OrderTrackingStep({
    required this.status,
    required this.label,
    required this.completed,
    this.timestamp,
  });

  factory OrderTrackingStep.fromJson(Map<String, dynamic> json) {
    return OrderTrackingStep(
      status: json['status']?.toString() ?? '',
      label: json['label']?.toString() ?? '',
      completed: json['completed'] as bool? ?? false,
      timestamp: json['timestamp'] == null
          ? null
          : DateTime.tryParse(json['timestamp'].toString()),
    );
  }
}

class OrderDriver {
  final String name;
  final String phone;

  const OrderDriver({required this.name, required this.phone});

  factory OrderDriver.fromJson(Map<String, dynamic> json) {
    return OrderDriver(
      name: json['name']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
    );
  }
}

/// M52/M61 — matches the guide's response example exactly.
class OrderTracking {
  final String orderNumber;
  final String currentStatus;
  final List<OrderTrackingStep> timeline;
  final OrderDriver? driver;

  const OrderTracking({
    required this.orderNumber,
    required this.currentStatus,
    this.timeline = const [],
    this.driver,
  });

  factory OrderTracking.fromJson(Map<String, dynamic> json) {
    return OrderTracking(
      orderNumber: json['orderNumber']?.toString() ?? '',
      currentStatus: json['currentStatus']?.toString() ?? '',
      timeline: (json['timeline'] as List? ?? const [])
          .map((v) => OrderTrackingStep.fromJson(v as Map<String, dynamic>))
          .toList(),
      driver: json['driver'] is Map<String, dynamic>
          ? OrderDriver.fromJson(json['driver'] as Map<String, dynamic>)
          : null,
    );
  }
}

/// M55 — the guide gives no response example; modeled after [OrderDetailItem]
/// with an `eligible`/reason flag since "returnable" implies some items may
/// be excluded (already-refunded, past window, ...).
class ReturnableItem {
  final String itemId;
  final LocalizedText name;
  final int quantity;
  final String image;
  final bool eligible;
  final String? reason;

  const ReturnableItem({
    required this.itemId,
    required this.name,
    required this.quantity,
    required this.image,
    this.eligible = true,
    this.reason,
  });

  factory ReturnableItem.fromJson(Map<String, dynamic> json) {
    return ReturnableItem(
      itemId: json['itemId']?.toString() ?? '',
      name: LocalizedText.fromJson(json['name'] as Map<String, dynamic>? ?? const {}),
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      image: json['image']?.toString() ?? '',
      eligible: json['eligible'] as bool? ?? true,
      reason: json['reason'] as String?,
    );
  }
}

/// M60 — the guide gives no response example ("Customer order counter
/// metrics"); field names inferred from the categories the app's own
/// notifications-screen mock data already used.
class OrderStatistics {
  final int totalOrders;
  final int activeOrders;
  final int completedOrders;
  final int cancelledOrders;

  const OrderStatistics({
    this.totalOrders = 0,
    this.activeOrders = 0,
    this.completedOrders = 0,
    this.cancelledOrders = 0,
  });

  factory OrderStatistics.fromJson(Map<String, dynamic> json) {
    return OrderStatistics(
      totalOrders: (json['totalOrders'] as num?)?.toInt() ?? 0,
      activeOrders: (json['activeOrders'] as num?)?.toInt() ?? 0,
      completedOrders: (json['completedOrders'] as num?)?.toInt() ?? 0,
      cancelledOrders: (json['cancelledOrders'] as num?)?.toInt() ?? 0,
    );
  }
}

/// M61 — matches the guide's response example exactly.
class DeliveryInfo {
  final String driverName;
  final String phoneNumber;
  final String? vehicleInfo;

  const DeliveryInfo({required this.driverName, required this.phoneNumber, this.vehicleInfo});

  factory DeliveryInfo.fromJson(Map<String, dynamic> json) {
    return DeliveryInfo(
      driverName: json['driverName']?.toString() ?? '',
      phoneNumber: json['phoneNumber']?.toString() ?? '',
      vehicleInfo: json['vehicleInfo'] as String?,
    );
  }
}

class OrdersPage {
  final List<Order> items;
  final int total;
  final int page;
  final int totalPages;

  const OrdersPage({
    required this.items,
    required this.total,
    required this.page,
    required this.totalPages,
  });

  factory OrdersPage.fromJson(Map<String, dynamic> json) {
    return OrdersPage(
      items: (json['items'] as List? ?? const [])
          .map((v) => Order.fromJson(v as Map<String, dynamic>))
          .toList(),
      total: (json['total'] as num?)?.toInt() ?? 0,
      page: (json['page'] as num?)?.toInt() ?? 1,
      totalPages: (json['totalPages'] as num?)?.toInt() ?? 1,
    );
  }
}
