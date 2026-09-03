import '../../../core/models/localized_text.dart';

/// The guide's statuses read as an active/completed split even though it
/// doesn't enumerate the full set; anything not obviously terminal is
/// treated as "current" so an unrecognized status still shows up somewhere.
const _terminalOrderStatuses = {
  'DELIVERED',
  'COMPLETED',
  'CANCELLED',
  'CANCELED',
  'REFUNDED',
};

/// Response of `send-delivery-otp` — mirrors auth's `OtpRequestResult`.
/// Non-production backends echo the OTP straight back (`debugOtp`) so the
/// delivery-OTP screen can prefill it without a real SMS.
class DeliveryOtpRequestResult {
  final int? expiresInSeconds;
  final String? debugOtp;

  const DeliveryOtpRequestResult({this.expiresInSeconds, this.debugOtp});

  factory DeliveryOtpRequestResult.fromJson(Map<String, dynamic> json) {
    return DeliveryOtpRequestResult(
      expiresInSeconds: (json['otpExpiresInSeconds'] as num?)?.toInt(),
      debugOtp: json['otp']?.toString(),
    );
  }
}

class OrderLineItem {
  final LocalizedText name;
  final int quantity;
  final String image;

  const OrderLineItem({required this.name, required this.quantity, required this.image});

  factory OrderLineItem.fromJson(Map<String, dynamic> json) {
    return OrderLineItem(
      name: LocalizedText.fromJson(json['name'] as Map<String, dynamic>? ?? const {}),
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      image: (json['image'] ?? json['imageUrl'])?.toString() ?? '',
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

  bool get isActive => !_terminalOrderStatuses.contains(status.toUpperCase());

  factory Order.fromJson(Map<String, dynamic> json) {
    final id = (json['_id'] ?? json['id'])?.toString() ?? '';
    return Order(
      id: id,
      orderNumber: json['orderNumber']?.toString() ?? id,
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
      image: (json['image'] ?? json['imageUrl'])?.toString() ?? '',
      brandName: (json['brand'] as Map<String, dynamic>?)?['name'] as String?,
    );
  }
}

class OrderShippingAddress {
  final String city;
  final String district;
  final String block;
  final String street;
  final String houseNumber;
  final String recipientName;
  final String phone;

  const OrderShippingAddress({
    required this.city,
    required this.district,
    this.block = '',
    required this.street,
    this.houseNumber = '',
    required this.recipientName,
    required this.phone,
  });

  /// The guide's example used flat `city`/`district`/`recipientName`/`phone`,
  /// but the real API nests the full address under the order's `addressId`
  /// (despite the name, it's the populated address object, not just an id)
  /// with `governorate`/`area`/`name`/`contactNumber` instead.
  factory OrderShippingAddress.fromJson(Map<String, dynamic> json) {
    return OrderShippingAddress(
      city: (json['city'] ?? json['governorate'])?.toString() ?? '',
      district: (json['district'] ?? json['area'])?.toString() ?? '',
      block: json['block']?.toString() ?? '',
      street: json['street']?.toString() ?? '',
      houseNumber: json['houseNumber']?.toString() ?? '',
      recipientName: (json['recipientName'] ?? json['name'])?.toString() ?? '',
      phone: (json['phone'] ?? json['contactNumber'])?.toString() ?? '',
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

  bool get isActive => !_terminalOrderStatuses.contains(status.toUpperCase());

  factory OrderDetail.fromJson(Map<String, dynamic> json) {
    final id = (json['_id'] ?? json['id'])?.toString() ?? '';
    // The real API has no `orderNumber` field at all, so fall back to the
    // order id (mirrors CheckoutConfirmResult.fromJson's same fallback).
    final orderNumber = json['orderNumber']?.toString() ?? id;
    // `shippingAddress` was the guide's field name; the real API nests the
    // populated address object under `addressId` instead.
    final rawAddress = json['shippingAddress'] ?? json['addressId'];
    return OrderDetail(
      id: id,
      orderNumber: orderNumber,
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
      shippingAddress: rawAddress is Map<String, dynamic>
          ? OrderShippingAddress.fromJson(rawAddress)
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
    final status = json['status']?.toString() ?? '';
    return OrderTrackingStep(
      status: status,
      // The real API sends only `status`/`completed`/`current` per step —
      // no `label` — so humanize the status as a fallback display string.
      label: json['label']?.toString() ?? _humanizeStatus(status),
      completed: json['completed'] as bool? ?? false,
      timestamp: json['timestamp'] == null
          ? null
          : DateTime.tryParse(json['timestamp'].toString()),
    );
  }
}

String _humanizeStatus(String status) {
  if (status.isEmpty) return status;
  return status
      .split('_')
      .map((w) => w.isEmpty ? w : w[0].toUpperCase() + w.substring(1))
      .join(' ');
}

class OrderDriver {
  final String name;
  final String phone;

  const OrderDriver({required this.name, required this.phone});

  factory OrderDriver.fromJson(Map<String, dynamic> json) {
    return OrderDriver(
      name: (json['name'] ?? json['driverName'])?.toString() ?? '',
      phone: (json['phone'] ?? json['phoneNumber'])?.toString() ?? '',
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
    // The real API nests the timeline under `steps` (not `timeline`) and
    // reports the order under `orderId`/`status` (not `orderNumber`/
    // `currentStatus`) — see the sample response pasted while debugging the
    // tracking screen showing an empty timeline.
    final rawSteps = (json['timeline'] ?? json['steps']) as List? ?? const [];
    final rawDriver = json['driver'] ?? json['delivery'];
    return OrderTracking(
      orderNumber: (json['orderNumber'] ?? json['orderId'])?.toString() ?? '',
      currentStatus: (json['currentStatus'] ?? json['status'])?.toString() ?? '',
      timeline: rawSteps
          .map((v) => OrderTrackingStep.fromJson(v as Map<String, dynamic>))
          .toList(),
      driver: rawDriver is Map<String, dynamic>
          ? OrderDriver.fromJson(rawDriver)
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
