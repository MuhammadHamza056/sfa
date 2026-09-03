import '../../../core/models/localized_text.dart';

/// Mirrors the backend's `ReelStatus` enum (`reels.schema.ts`). The public
/// feed only ever surfaces `APPROVED` reels, but the field is parsed for
/// fidelity with the schema.
enum ReelStatus {
  pending,
  approved,
  rejected;

  static ReelStatus fromJson(String? value) {
    switch (value) {
      case 'APPROVED':
        return ReelStatus.approved;
      case 'REJECTED':
        return ReelStatus.rejected;
      default:
        return ReelStatus.pending;
    }
  }
}

/// Vendor info as it appears when the backend populates `vendorId`. When the
/// API instead sends back a bare id string, [Reel.brand] is null.
class ReelBrand {
  final String id;
  final LocalizedText name;
  final String? logo;

  const ReelBrand({required this.id, required this.name, this.logo});

  factory ReelBrand.fromJson(Map<String, dynamic> json) {
    return ReelBrand(
      id: (json['_id'] ?? json['id'])?.toString() ?? '',
      name: LocalizedText.fromDynamic(json['name']),
      logo: json['logo'] as String?,
    );
  }
}

/// Product info as it appears when the backend populates `productId`. When
/// the API instead sends back a bare id string, [Reel.taggedProduct] is null.
class ReelTaggedProduct {
  final String id;
  final LocalizedText name;
  final int priceFils;
  final String currency;
  final String image;

  const ReelTaggedProduct({
    required this.id,
    required this.name,
    required this.priceFils,
    this.currency = 'SAR',
    required this.image,
  });

  factory ReelTaggedProduct.fromJson(Map<String, dynamic> json) {
    final images = json['images'] as List?;
    return ReelTaggedProduct(
      id: (json['_id'] ?? json['id'])?.toString() ?? '',
      name: LocalizedText.fromDynamic(json['name']),
      priceFils: (json['priceFils'] as num?)?.toInt() ?? 0,
      currency: json['currency'] as String? ?? 'SAR',
      image:
          json['image']?.toString() ??
          (images != null && images.isNotEmpty ? images.first.toString() : ''),
    );
  }
}

/// Matches the `Reel` mongoose schema (`reels.schema.ts`, collection
/// `reels`) returned by `GET /reels`.
///
/// `vendorId`/`productId` are plain id strings unless the backend populates
/// them, in which case [brand]/[taggedProduct] are also filled in from the
/// same field. `isLiked`/`isSaved` aren't in the schema itself (that's
/// tracked server-side via `likedBy`/`savedBy`) but mirror the shape the
/// like/save toggle endpoints (M69/M70) already return for the current user.
class Reel {
  final String id;
  final String vendorId;
  final String? productId;
  final String videoUrl;
  final String thumbnailUrl;
  final String title;
  final String description;
  final List<String> tags;
  final ReelStatus status;
  final int likesCount;
  final int savesCount;
  final int viewsCount;
  final bool isLiked;
  final bool isSaved;
  final bool isActive;
  final DateTime? createdAt;
  final ReelBrand? brand;
  final ReelTaggedProduct? taggedProduct;

  const Reel({
    required this.id,
    required this.vendorId,
    this.productId,
    required this.videoUrl,
    required this.thumbnailUrl,
    required this.title,
    this.description = '',
    this.tags = const [],
    this.status = ReelStatus.pending,
    this.likesCount = 0,
    this.savesCount = 0,
    this.viewsCount = 0,
    this.isLiked = false,
    this.isSaved = false,
    this.isActive = true,
    this.createdAt,
    this.brand,
    this.taggedProduct,
  });

  Reel copyWith({
    bool? isLiked,
    int? likesCount,
    bool? isSaved,
    int? savesCount,
  }) {
    return Reel(
      id: id,
      vendorId: vendorId,
      productId: productId,
      videoUrl: videoUrl,
      thumbnailUrl: thumbnailUrl,
      title: title,
      description: description,
      tags: tags,
      status: status,
      likesCount: likesCount ?? this.likesCount,
      savesCount: savesCount ?? this.savesCount,
      viewsCount: viewsCount,
      isLiked: isLiked ?? this.isLiked,
      isSaved: isSaved ?? this.isSaved,
      isActive: isActive,
      createdAt: createdAt,
      brand: brand,
      taggedProduct: taggedProduct,
    );
  }

  factory Reel.fromJson(Map<String, dynamic> json) {
    final vendorRaw = json['vendorId'];
    final productRaw = json['productId'];
    return Reel(
      id: (json['_id'] ?? json['id'])?.toString() ?? '',
      vendorId: vendorRaw is Map<String, dynamic>
          ? (vendorRaw['_id'] ?? vendorRaw['id'])?.toString() ?? ''
          : vendorRaw?.toString() ?? '',
      productId: productRaw is Map<String, dynamic>
          ? (productRaw['_id'] ?? productRaw['id'])?.toString()
          : productRaw?.toString(),
      videoUrl: json['videoUrl']?.toString() ?? '',
      thumbnailUrl: json['thumbnailUrl']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      tags: (json['tags'] as List? ?? const [])
          .map((v) => v.toString())
          .toList(),
      status: ReelStatus.fromJson(json['status']?.toString()),
      likesCount: (json['likesCount'] as num?)?.toInt() ?? 0,
      savesCount: (json['savesCount'] as num?)?.toInt() ?? 0,
      viewsCount: (json['viewsCount'] as num?)?.toInt() ?? 0,
      isLiked: json['isLiked'] as bool? ?? false,
      isSaved: json['isSaved'] as bool? ?? false,
      isActive: json['isActive'] as bool? ?? true,
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? ''),
      brand: vendorRaw is Map<String, dynamic>
          ? ReelBrand.fromJson(vendorRaw)
          : null,
      taggedProduct: productRaw is Map<String, dynamic>
          ? ReelTaggedProduct.fromJson(productRaw)
          : null,
    );
  }
}

/// `GET /reels` response envelope — `{ items, total, page, limit, totalPages }`.
class ReelsPage {
  final List<Reel> items;
  final int total;
  final int page;
  final int limit;
  final int totalPages;

  const ReelsPage({
    required this.items,
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
  });

  factory ReelsPage.fromJson(Map<String, dynamic> json) {
    return ReelsPage(
      items: (json['items'] as List? ?? const [])
          .map((v) => Reel.fromJson(v as Map<String, dynamic>))
          .toList(),
      total: (json['total'] as num?)?.toInt() ?? 0,
      page: (json['page'] as num?)?.toInt() ?? 1,
      limit: (json['limit'] as num?)?.toInt() ?? 10,
      totalPages: (json['totalPages'] as num?)?.toInt() ?? 0,
    );
  }
}

/// Compact "2.4K" style count used by the sidebar like button — the guide
/// returns a raw int, but the design shows abbreviated counts.
String formatReelCount(int count) {
  if (count >= 1000000) return '${(count / 1000000).toStringAsFixed(1)}M';
  if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}K';
  return '$count';
}
