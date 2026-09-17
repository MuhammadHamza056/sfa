import 'dart:ui';

import '../../../core/localization/app_localizations.dart';
import '../../../utils/currency_formatter.dart';
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
    final isAr = localeNotifier.value.languageCode == 'ar';
    final name = json['name'];
    final priceFils = (json['priceFils'] as num?)?.toInt();
    final images = json['images'] as List?;
    return WishlistItemEntry(
      // Items come back with `_id`, not `productId`/`itemId` — needed for
      // both `DELETE /wishlists/:id/items/:productId` and the product-detail
      // push, so it has to be hedged the same way the other entry types are.
      productId: (json['productId'] ?? json['itemId'] ?? json['_id'] ?? json['id'])?.toString() ?? '',
      brandName: json['brandName']?.toString() ?? '',
      name: name is Map
          ? ((isAr ? name['ar'] : name['en']) ?? name['ar'] ?? name['en'] ?? '').toString()
          : (name?.toString() ?? ''),
      price: priceFils != null
          ? CurrencyFormatter.fromHalalas(priceFils, isAr: isAr)
          : (json['price']?.toString() ?? ''),
      imageUrl: (images != null && images.isNotEmpty)
          ? images.first.toString()
          : (json['image']?.toString() ?? json['imageUrl']?.toString() ?? ''),
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
    // The list endpoint has no top-level `coverImages`/`images` — instead
    // each embedded item carries its own `images` list, so the card's
    // cover strip is built from the first image of each item.
    final topLevelImages = (json['coverImages'] as List? ?? json['images'] as List? ?? const [])
        .map((v) => v.toString())
        .toList();
    final itemImages = (json['items'] as List? ?? const [])
        .map((item) => (item as Map<String, dynamic>)['images'] as List?)
        .where((images) => images != null && images.isNotEmpty)
        .map((images) => images!.first.toString())
        .toList();

    return WishlistSummary(
      // Hedged across key spellings the way `WishlistItemEntry` already is —
      // an empty id here both breaks the `/wishlist-detail/:id` push and
      // makes `POST /wishlists//items` silently wrong.
      id: (json['id'] ?? json['_id'] ?? json['wishlistId'])?.toString() ?? '',
      title: (json['title'] ?? json['name'])?.toString() ?? '',
      itemCount: (json['itemCount'] as num?)?.toInt() ?? (json['count'] as num?)?.toInt() ?? 0,
      coverImages: topLevelImages.isNotEmpty ? topLevelImages : itemImages,
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
