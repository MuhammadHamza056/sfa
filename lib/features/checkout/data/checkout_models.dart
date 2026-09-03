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

/// M38 — the real response nests the money breakdown under `data.totals`
/// (not flattened onto `data` itself), e.g.:
/// `{cart:{...}, address:null, totals:{subtotalFils,...,grandTotalFils,
/// giftWrapFeeFils,currency}}`. `totals` falls back to the top-level map so
/// a flatter response shape still parses. Accepted payment methods aren't
/// sourced from here anymore — see `MyFatoorahPaymentMethod` /
/// `/payments/methods/myfatoorah`, which prices them against this preview's
/// `totalFils`.
class CheckoutPreview {
  final int subtotalFils;
  final int discountFils;
  final int pointsDiscountFils;
  final int deliveryFeeFils;
  final int giftWrapFeeFils;
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
    this.giftWrapFeeFils = 0,
    this.taxFils = 0,
    required this.totalFils,
    this.currency = 'SAR',
    this.itemsCount = 0,
    this.estimatedDelivery,
  });

  factory CheckoutPreview.fromJson(Map<String, dynamic> json) {
    final totals = json['totals'] as Map<String, dynamic>? ?? json;
    return CheckoutPreview(
      subtotalFils: (totals['subtotalFils'] as num?)?.toInt() ?? 0,
      discountFils: (totals['discountFils'] as num?)?.toInt() ?? 0,
      pointsDiscountFils: (totals['pointsDiscountFils'] as num?)?.toInt() ?? 0,
      deliveryFeeFils: (totals['deliveryFeeFils'] as num?)?.toInt() ?? 0,
      giftWrapFeeFils: (totals['giftWrapFeeFils'] as num?)?.toInt() ?? 0,
      taxFils: (totals['taxFils'] as num?)?.toInt() ?? 0,
      totalFils: (totals['grandTotalFils'] as num?)?.toInt() ??
          (totals['totalFils'] as num?)?.toInt() ??
          0,
      currency: totals['currency'] as String? ?? 'SAR',
      itemsCount: (json['itemsCount'] as num?)?.toInt() ?? 0,
      estimatedDelivery: json['estimatedDelivery'] as String?,
    );
  }
}

/// M39 — the real response nests the created order(s) under `data.orders`
/// (one per vendor) alongside a top-level `grandTotalFils`, e.g.
/// `{orders:[{_id,totalFils,paymentMethod,paymentStatus,...}],
/// grandTotalFils}` — not the flat `orderId`/`orderNumber`/`totalFils` the
/// guide's example implied. There's no separate order-number field, so it
/// falls back to the order id. Multi-vendor carts create multiple orders;
/// only the first is tracked here since checkout only pays for one at a
/// time today.
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
    final orders = json['orders'] as List?;
    final firstOrder =
        orders != null && orders.isNotEmpty ? orders.first as Map<String, dynamic> : null;
    final orderId = (firstOrder?['_id'] ?? firstOrder?['id'] ?? json['orderId'])?.toString() ?? '';
    return CheckoutConfirmResult(
      orderId: orderId,
      orderNumber: (json['orderNumber'] ?? firstOrder?['orderNumber'])?.toString() ?? orderId,
      totalFils: (json['grandTotalFils'] as num?)?.toInt() ??
          (firstOrder?['totalFils'] as num?)?.toInt() ??
          (json['totalFils'] as num?)?.toInt() ??
          0,
      paymentUrl: json['paymentUrl'] as String?,
    );
  }
}
