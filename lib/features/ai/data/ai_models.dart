import '../../../core/models/localized_text.dart';

class AiRecommendedProduct {
  final String id;
  final LocalizedText name;
  final int priceFils;
  final String image;

  const AiRecommendedProduct({
    required this.id,
    required this.name,
    required this.priceFils,
    required this.image,
  });

  factory AiRecommendedProduct.fromJson(Map<String, dynamic> json) {
    return AiRecommendedProduct(
      id: json['id']?.toString() ?? '',
      name: LocalizedText.fromJson(json['name'] as Map<String, dynamic>? ?? const {}),
      priceFils: (json['priceFils'] as num?)?.toInt() ?? 0,
      image: json['image']?.toString() ?? '',
    );
  }
}

/// M95 — matches the guide's response example exactly.
class AiChatReply {
  final String reply;
  final List<AiRecommendedProduct> recommendedProducts;

  const AiChatReply({required this.reply, this.recommendedProducts = const []});

  factory AiChatReply.fromJson(Map<String, dynamic> json) {
    return AiChatReply(
      reply: json['reply']?.toString() ?? '',
      recommendedProducts: (json['recommendedProducts'] as List? ?? const [])
          .map((v) => AiRecommendedProduct.fromJson(v as Map<String, dynamic>))
          .toList(),
    );
  }
}

enum ChatRole { user, assistant }

class AiChatMessage {
  final ChatRole role;
  final String text;
  final List<AiRecommendedProduct> recommendedProducts;

  const AiChatMessage({
    required this.role,
    required this.text,
    this.recommendedProducts = const [],
  });
}
