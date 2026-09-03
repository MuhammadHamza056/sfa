import 'dart:ui';

import '../../../core/models/localized_text.dart';

Color? colorFromHex(String? hex) {
  if (hex == null || hex.isEmpty) return null;
  var value = hex.replaceFirst('#', '');
  if (value.length == 6) value = 'FF$value';
  final parsed = int.tryParse(value, radix: 16);
  return parsed == null ? null : Color(parsed);
}

class CartAddon {
  final String addonId;
  final LocalizedText? name;
  final int priceFils;
  final int quantity;

  const CartAddon({
    required this.addonId,
    this.name,
    this.priceFils = 0,
    this.quantity = 1,
  });

  factory CartAddon.fromJson(Map<String, dynamic> json) {
    return CartAddon(
      addonId: json['addonId']?.toString() ?? '',
      name: json['name'] is Map<String, dynamic>
          ? LocalizedText.fromJson(json['name'] as Map<String, dynamic>)
          : null,
      priceFils: (json['priceFils'] as num?)?.toInt() ?? 0,
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
    );
  }
}

/// One `GET /cart` line. The guide doesn't publish an exact response shape
/// for M27/M36, so this is inferred from M28's request body and the
/// Fils-suffixed money convention used everywhere else — parsing is
/// defensive (every field falls back safely) so a real backend that names
/// things slightly differently still degrades instead of crashing.
class CartLineItem {
  final String id;
  final String productId;
  final LocalizedText name;
  final String imageUrl;
  final String? brandName;
  final int priceFils;
  final int quantity;
  final String? selectedSize;
  final String? selectedColor;
  final List<CartAddon> addons;
  final int itemTotalFils;

  const CartLineItem({
    required this.id,
    required this.productId,
    required this.name,
    required this.imageUrl,
    this.brandName,
    required this.priceFils,
    required this.quantity,
    this.selectedSize,
    this.selectedColor,
    this.addons = const [],
    required this.itemTotalFils,
  });

  Color? get colorValue => colorFromHex(selectedColor);

  /// [brandNameOverride] covers the real API's shape, where the vendor/
  /// brand name lives one level up on the vendor group, not on the line
  /// item itself — see [CartData.fromJson].
  factory CartLineItem.fromJson(Map<String, dynamic> json, {String? brandNameOverride}) {
    final priceFils = (json['priceFils'] as num?)?.toInt() ?? 0;
    final quantity = (json['quantity'] as num?)?.toInt() ?? 1;
    final images = json['images'] as List?;
    return CartLineItem(
      id: (json['cartItemId'] ?? json['id'])?.toString() ?? '',
      productId: (json['productId'] ?? json['itemId'])?.toString() ?? '',
      name: LocalizedText.fromDynamic(json['name']),
      imageUrl: json['imageUrl']?.toString() ??
          json['image']?.toString() ??
          (images != null && images.isNotEmpty ? images.first.toString() : ''),
      brandName: brandNameOverride ??
          (json['brand'] as Map<String, dynamic>?)?['name'] as String? ??
          json['brandName'] as String?,
      priceFils: priceFils,
      quantity: quantity,
      selectedSize: json['selectedSize'] as String?,
      selectedColor: json['selectedColor'] as String?,
      addons: ((json['addons'] ?? json['selectedAddons']) as List? ?? const [])
          .map((v) => CartAddon.fromJson(v as Map<String, dynamic>))
          .toList(),
      itemTotalFils: (json['lineTotalFils'] as num?)?.toInt() ??
          (json['itemTotalFils'] as num?)?.toInt() ??
          priceFils * quantity,
    );
  }
}

/// M27/M28-M35 — the full cart, refreshed after every mutation since each
/// of those endpoints hands back the updated cart.
class CartData {
  final List<CartLineItem> items;
  final int itemsCount;
  final int subtotalFils;
  final String currency;
  final bool giftWrap;
  final String? giftMessage;
  final String? couponCode;
  final int discountFils;
  final int pointsRedeemed;
  final int pointsDiscountFils;
  final int totalFils;

  const CartData({
    this.items = const [],
    this.itemsCount = 0,
    this.subtotalFils = 0,
    this.currency = 'SAR',
    this.giftWrap = false,
    this.giftMessage,
    this.couponCode,
    this.discountFils = 0,
    this.pointsRedeemed = 0,
    this.pointsDiscountFils = 0,
    this.totalFils = 0,
  });

  bool get isEmpty => items.isEmpty;

  factory CartData.fromJson(Map<String, dynamic> json) {
    // The real API groups lines by vendor/branch: `data.vendors[].items[]`,
    // each vendor carrying its own `subtotalFils` and the cart as a whole
    // carrying `grandTotalFils` — there is no flat `data.items[]`. Flatten
    // that here so the rest of the app can keep treating the cart as one
    // simple line list, and fall back to a flat `items` shape for safety.
    final vendors = json['vendors'] as List?;
    final List<CartLineItem> items;
    if (vendors != null) {
      items = vendors.expand((vendorJson) {
        final vendor = vendorJson as Map<String, dynamic>;
        final vendorName = LocalizedText.fromDynamic(vendor['vendorName']);
        return (vendor['items'] as List? ?? const []).map(
          (v) => CartLineItem.fromJson(
            v as Map<String, dynamic>,
            brandNameOverride: vendorName.en,
          ),
        );
      }).toList();
    } else {
      items = (json['items'] as List? ?? const [])
          .map((v) => CartLineItem.fromJson(v as Map<String, dynamic>))
          .toList();
    }

    final subtotalFils = (json['subtotalFils'] as num?)?.toInt() ??
        items.fold<int>(0, (sum, i) => sum + i.itemTotalFils);
    final discountFils = (json['discountFils'] as num?)?.toInt() ?? 0;
    final pointsDiscountFils = (json['pointsDiscountFils'] as num?)?.toInt() ?? 0;
    return CartData(
      items: items,
      itemsCount: (json['itemsCount'] as num?)?.toInt() ??
          items.fold<int>(0, (sum, i) => sum + i.quantity),
      subtotalFils: subtotalFils,
      currency: json['currency'] as String? ?? 'SAR',
      giftWrap: json['giftWrap'] as bool? ?? false,
      giftMessage: json['giftMessage'] as String?,
      couponCode: json['couponCode'] as String?,
      discountFils: discountFils,
      pointsRedeemed: (json['pointsRedeemed'] as num?)?.toInt() ?? 0,
      pointsDiscountFils: pointsDiscountFils,
      totalFils: (json['grandTotalFils'] as num?)?.toInt() ??
          (json['totalFils'] as num?)?.toInt() ??
          (subtotalFils - discountFils - pointsDiscountFils),
    );
  }
}

/// M36 — same money breakdown as M38's checkout preview, minus the
/// address-dependent delivery fee/tax/ETA.
class CartTotals {
  final int subtotalFils;
  final int discountFils;
  final int pointsDiscountFils;
  final int totalFils;
  final int itemsCount;
  final String currency;

  const CartTotals({
    required this.subtotalFils,
    required this.discountFils,
    required this.pointsDiscountFils,
    required this.totalFils,
    required this.itemsCount,
    this.currency = 'SAR',
  });

  factory CartTotals.fromJson(Map<String, dynamic> json) {
    return CartTotals(
      subtotalFils: (json['subtotalFils'] as num?)?.toInt() ?? 0,
      discountFils: (json['discountFils'] as num?)?.toInt() ?? 0,
      pointsDiscountFils: (json['pointsDiscountFils'] as num?)?.toInt() ?? 0,
      totalFils: (json['totalFils'] as num?)?.toInt() ?? 0,
      itemsCount: (json['itemsCount'] as num?)?.toInt() ?? 0,
      currency: json['currency'] as String? ?? 'SAR',
    );
  }
}
