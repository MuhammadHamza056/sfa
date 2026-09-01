import 'dart:ui';

import '../../cart/data/cart_models.dart' show colorFromHex;

/// M85/M87 — the guide gives no response example for either; item fields
/// are inferred from the M28 cart-item convention (`itemId`,
/// `selectedSize`, `selectedColor`) since a wishlist entry is the same
/// "product + chosen variant" shape as a cart line.
class WishlistItemEntry {
  final String productId;
  final String brandName;
  final String name;
  final String price;
  final String imageUrl;
  final String? selectedColor;
  final String? selectedSize;

  const WishlistItemEntry({
    required this.productId,
    required this.brandName,
    required this.name,
    required this.price,
    required this.imageUrl,
    this.selectedColor,
    this.selectedSize,
  });

  Color? get colorValue => colorFromHex(selectedColor);

  factory WishlistItemEntry.fromJson(Map<String, dynamic> json) {
    final name = json['name'];
    return WishlistItemEntry(
      productId: (json['productId'] ?? json['itemId'] ?? json['id'])?.toString() ?? '',
      brandName: json['brandName']?.toString() ?? '',
      name: name is Map ? (name['ar'] ?? name['en'] ?? '').toString() : (name?.toString() ?? ''),
      price: json['price']?.toString() ?? '',
      imageUrl: json['image']?.toString() ?? json['imageUrl']?.toString() ?? '',
      selectedColor: json['selectedColor'] as String?,
      selectedSize: json['selectedSize'] as String?,
    );
  }
}

class WishlistSummary {
  final String id;
  final String title;
  final int itemCount;
  final List<String> coverImages;
  final String ownerName;
  final String ownerAvatar;

  const WishlistSummary({
    required this.id,
    required this.title,
    this.itemCount = 0,
    this.coverImages = const [],
    this.ownerName = '',
    this.ownerAvatar = '',
  });

  factory WishlistSummary.fromJson(Map<String, dynamic> json) {
    return WishlistSummary(
      id: json['id']?.toString() ?? '',
      title: (json['title'] ?? json['name'])?.toString() ?? '',
      itemCount: (json['itemCount'] as num?)?.toInt() ?? (json['count'] as num?)?.toInt() ?? 0,
      coverImages: (json['coverImages'] as List? ?? json['images'] as List? ?? const [])
          .map((v) => v.toString())
          .toList(),
      ownerName: json['ownerName']?.toString() ?? json['addedByName']?.toString() ?? '',
      ownerAvatar: json['ownerAvatar']?.toString() ?? json['avatarUrl']?.toString() ?? '',
    );
  }
}

class WishlistDetail {
  final String id;
  final String title;
  final String ownerName;
  final String ownerAvatar;
  final List<WishlistItemEntry> items;

  const WishlistDetail({
    required this.id,
    required this.title,
    this.ownerName = '',
    this.ownerAvatar = '',
    this.items = const [],
  });

  factory WishlistDetail.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'] as List? ?? const [];
    return WishlistDetail(
      id: json['id']?.toString() ?? '',
      title: (json['title'] ?? json['name'])?.toString() ?? '',
      ownerName: json['ownerName']?.toString() ?? json['addedByName']?.toString() ?? '',
      ownerAvatar: json['ownerAvatar']?.toString() ?? json['avatarUrl']?.toString() ?? '',
      items: rawItems.map((v) => WishlistItemEntry.fromJson(v as Map<String, dynamic>)).toList(),
    );
  }
}

/// M90 — matches the guide's response example exactly.
class WishlistShareResult {
  final String shareUrl;
  final String token;

  const WishlistShareResult({required this.shareUrl, required this.token});

  factory WishlistShareResult.fromJson(Map<String, dynamic> json) {
    return WishlistShareResult(
      shareUrl: json['shareUrl']?.toString() ?? '',
      token: json['token']?.toString() ?? '',
    );
  }
}
