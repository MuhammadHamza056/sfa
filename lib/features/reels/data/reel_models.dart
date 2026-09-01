import '../../../core/models/localized_text.dart';

class ReelBrand {
  final String id;
  final String name;
  final String? logo;

  const ReelBrand({required this.id, required this.name, this.logo});

  factory ReelBrand.fromJson(Map<String, dynamic> json) {
    return ReelBrand(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      logo: json['logo'] as String?,
    );
  }
}

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
    return ReelTaggedProduct(
      id: json['id']?.toString() ?? '',
      name: LocalizedText.fromJson(json['name'] as Map<String, dynamic>? ?? const {}),
      priceFils: (json['priceFils'] as num?)?.toInt() ?? 0,
      currency: json['currency'] as String? ?? 'SAR',
      image: json['image']?.toString() ?? '',
    );
  }
}

/// M68 — matches the guide's response example exactly.
class Reel {
  final String id;
  final String videoUrl;
  final String thumbnailUrl;
  final String description;
  final int likesCount;
  final int savesCount;
  final bool isLiked;
  final bool isSaved;
  final ReelBrand? brand;
  final ReelTaggedProduct? taggedProduct;

  const Reel({
    required this.id,
    required this.videoUrl,
    required this.thumbnailUrl,
    this.description = '',
    this.likesCount = 0,
    this.savesCount = 0,
    this.isLiked = false,
    this.isSaved = false,
    this.brand,
    this.taggedProduct,
  });

  Reel copyWith({bool? isLiked, int? likesCount, bool? isSaved, int? savesCount}) {
    return Reel(
      id: id,
      videoUrl: videoUrl,
      thumbnailUrl: thumbnailUrl,
      description: description,
      likesCount: likesCount ?? this.likesCount,
      savesCount: savesCount ?? this.savesCount,
      isLiked: isLiked ?? this.isLiked,
      isSaved: isSaved ?? this.isSaved,
      brand: brand,
      taggedProduct: taggedProduct,
    );
  }

  factory Reel.fromJson(Map<String, dynamic> json) {
    return Reel(
      id: json['id']?.toString() ?? '',
      videoUrl: json['videoUrl']?.toString() ?? '',
      thumbnailUrl: json['thumbnailUrl']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      likesCount: (json['likesCount'] as num?)?.toInt() ?? 0,
      savesCount: (json['savesCount'] as num?)?.toInt() ?? 0,
      isLiked: json['isLiked'] as bool? ?? false,
      isSaved: json['isSaved'] as bool? ?? false,
      brand: json['brand'] is Map<String, dynamic>
          ? ReelBrand.fromJson(json['brand'] as Map<String, dynamic>)
          : null,
      taggedProduct: json['taggedProduct'] is Map<String, dynamic>
          ? ReelTaggedProduct.fromJson(json['taggedProduct'] as Map<String, dynamic>)
          : null,
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
