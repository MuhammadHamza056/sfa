import '../../../core/models/localized_text.dart';

/// M37 — the guide gives no response example ("Saudi 13 regions and
/// cities"); modeled as an id + bilingual name, with an optional nested
/// city list since regions naturally group cities.
class Region {
  final String id;
  final LocalizedText name;
  final List<LocalizedText> cities;

  const Region({required this.id, required this.name, this.cities = const []});

  factory Region.fromJson(Map<String, dynamic> json) {
    return Region(
      id: json['id']?.toString() ?? '',
      name: LocalizedText.fromJson(json['name'] as Map<String, dynamic>? ?? const {}),
      cities: (json['cities'] as List? ?? const [])
          .map((v) => v is Map<String, dynamic>
              ? LocalizedText.fromJson(v)
              : LocalizedText(ar: v.toString(), en: v.toString()))
          .toList(),
    );
  }
}

/// M38 — matches the guide's response example exactly.
class CheckoutPreview {
  final int subtotalFils;
  final int discountFils;
  final int pointsDiscountFils;
  final int deliveryFeeFils;
  final int taxFils;
  final int totalFils;
  final String currency;
  final int itemsCount;
  final String? estimatedDelivery;

  const CheckoutPreview({
    required this.subtotalFils,
    required this.discountFils,
    required this.pointsDiscountFils,
    required this.deliveryFeeFils,
    required this.taxFils,
    required this.totalFils,
    this.currency = 'SAR',
    this.itemsCount = 0,
    this.estimatedDelivery,
  });

  factory CheckoutPreview.fromJson(Map<String, dynamic> json) {
    return CheckoutPreview(
      subtotalFils: (json['subtotalFils'] as num?)?.toInt() ?? 0,
      discountFils: (json['discountFils'] as num?)?.toInt() ?? 0,
      pointsDiscountFils: (json['pointsDiscountFils'] as num?)?.toInt() ?? 0,
      deliveryFeeFils: (json['deliveryFeeFils'] as num?)?.toInt() ?? 0,
      taxFils: (json['taxFils'] as num?)?.toInt() ?? 0,
      totalFils: (json['totalFils'] as num?)?.toInt() ?? 0,
      currency: json['currency'] as String? ?? 'SAR',
      itemsCount: (json['itemsCount'] as num?)?.toInt() ?? 0,
      estimatedDelivery: json['estimatedDelivery'] as String?,
    );
  }
}

/// M39 — matches the guide's response example exactly.
class CheckoutConfirmResult {
  final String orderId;
  final String orderNumber;
  final int totalFils;
  final String? paymentUrl;

  const CheckoutConfirmResult({
    required this.orderId,
    required this.orderNumber,
    required this.totalFils,
    this.paymentUrl,
  });

  factory CheckoutConfirmResult.fromJson(Map<String, dynamic> json) {
    return CheckoutConfirmResult(
      orderId: json['orderId']?.toString() ?? '',
      orderNumber: json['orderNumber']?.toString() ?? '',
      totalFils: (json['totalFils'] as num?)?.toInt() ?? 0,
      paymentUrl: json['paymentUrl'] as String?,
    );
  }
}
