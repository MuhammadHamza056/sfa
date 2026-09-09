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

  /// Lenient about key spelling because the same product reaches the app by
  /// two routes: the REST reply (`{id, name, priceFils, image}`) and the
  /// gateway's `ai:stream:*` payloads, which re-emit trimmed Mongo
  /// documents (`_id`, `images: [...]`). `name` may also arrive as a plain
  /// string rather than the usual `{ar, en}` pair.
  factory AiRecommendedProduct.fromJson(Map<String, dynamic> json) {
    return AiRecommendedProduct(
      id: (json['id'] ?? json['_id'] ?? json['productId'])?.toString() ?? '',
      name: LocalizedText.fromDynamic(json['name'] ?? json['title']),
      priceFils: _priceFils(json),
      image: _image(json),
    );
  }

  /// `priceFils` is the documented field; `price` is only read as a
  /// fallback and is assumed to be in fils too, since every price the API
  /// sends is a minor-unit integer.
  static int _priceFils(Map<String, dynamic> json) {
    final value = json['priceFils'] ?? json['salePriceFils'] ?? json['price'];
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static String _image(Map<String, dynamic> json) {
    final single = json['image'] ?? json['imageUrl'] ?? json['thumbnail'];
    if (single is String && single.isNotEmpty) return single;
    final images = json['images'];
    if (images is List && images.isNotEmpty) {
      final first = images.first;
      if (first is String) return first;
      if (first is Map) return (first['url'] ?? first['image'])?.toString() ?? '';
    }
    return '';
  }

  static List<AiRecommendedProduct> listFrom(Object? value) {
    if (value is! List) return const [];
    return value
        .whereType<Map>()
        .map((v) => AiRecommendedProduct.fromJson(
              v.map((key, val) => MapEntry(key.toString(), val)),
            ))
        .toList();
  }
}

/// M95 — the one-shot REST reply, still used as the fallback path when the
/// socket is unavailable.
class AiChatReply {
  final String reply;
  final List<AiRecommendedProduct> recommendedProducts;

  const AiChatReply({required this.reply, this.recommendedProducts = const []});

  factory AiChatReply.fromJson(Map<String, dynamic> json) {
    return AiChatReply(
      reply: json['reply']?.toString() ?? '',
      recommendedProducts:
          AiRecommendedProduct.listFrom(json['recommendedProducts']),
    );
  }
}

enum ChatRole { user, assistant }

/// Why a turn failed. The kind rather than a message is stored on the
/// message so the thread can be localized at render time — only [server]
/// carries text of its own, and even that may be empty.
enum AiChatErrorKind { none, server, timeout, offline }

class AiChatMessage {
  /// The server's id for this message, once it has one. Null while a
  /// message is still local — an optimistic user bubble before
  /// `ai:stream:start` names it, or an assistant bubble mid-stream.
  final String? id;
  final ChatRole role;
  final String text;
  final List<AiRecommendedProduct> recommendedProducts;

  /// True between `ai:stream:start` and `ai:stream:done`, i.e. while chunks
  /// are still landing in [text]. Drives the typing cursor.
  final bool isStreaming;

  /// Set when this turn failed, so the breakage is rendered in the thread
  /// — next to the question that caused it — instead of in a snackbar.
  final AiChatErrorKind errorKind;

  bool get isError => errorKind != AiChatErrorKind.none;

  const AiChatMessage({
    required this.role,
    required this.text,
    this.id,
    this.recommendedProducts = const [],
    this.isStreaming = false,
    this.errorKind = AiChatErrorKind.none,
  });

  /// Server-persisted message, as returned by the conversation history
  /// endpoint. Anything the thread replays is by definition finished, so
  /// [isStreaming] stays false.
  factory AiChatMessage.fromJson(Map<String, dynamic> json) {
    final role = (json['role'] ?? json['sender'])?.toString().toLowerCase();
    return AiChatMessage(
      id: (json['id'] ?? json['_id'] ?? json['messageId'])?.toString(),
      role: role == 'user' ? ChatRole.user : ChatRole.assistant,
      text: (json['content'] ?? json['text'] ?? json['message'])?.toString() ?? '',
      recommendedProducts: AiRecommendedProduct.listFrom(
        json['recommendedProducts'] ?? json['products'],
      ),
    );
  }

  AiChatMessage copyWith({
    String? id,
    String? text,
    List<AiRecommendedProduct>? recommendedProducts,
    bool? isStreaming,
    AiChatErrorKind? errorKind,
  }) {
    return AiChatMessage(
      role: role,
      id: id ?? this.id,
      text: text ?? this.text,
      recommendedProducts: recommendedProducts ?? this.recommendedProducts,
      isStreaming: isStreaming ?? this.isStreaming,
      errorKind: errorKind ?? this.errorKind,
    );
  }
}

/// One page of a stored conversation.
class AiConversationHistory {
  final String conversationId;
  final List<AiChatMessage> messages;

  const AiConversationHistory({
    required this.conversationId,
    this.messages = const [],
  });

  factory AiConversationHistory.fromJson(Map<String, dynamic> json) {
    // The thread arrives either as a bare list or wrapped in an object
    // alongside the conversation it belongs to.
    final raw = json['messages'] ?? json['items'] ?? json['data'];
    return AiConversationHistory(
      conversationId:
          (json['conversationId'] ?? json['_id'] ?? json['id'])?.toString() ?? '',
      messages: raw is List
          ? raw
              .whereType<Map>()
              .map((v) => AiChatMessage.fromJson(
                    v.map((key, val) => MapEntry(key.toString(), val)),
                  ))
              .toList()
          : const [],
    );
  }

  static AiConversationHistory fromResponse(dynamic data, String fallbackId) {
    if (data is List) {
      return AiConversationHistory(
        conversationId: fallbackId,
        messages: data
            .whereType<Map>()
            .map((v) => AiChatMessage.fromJson(
                  v.map((key, val) => MapEntry(key.toString(), val)),
                ))
            .toList(),
      );
    }
    if (data is Map) {
      final json = data.map((key, val) => MapEntry(key.toString(), val));
      final history = AiConversationHistory.fromJson(json);
      return history.conversationId.isEmpty
          ? AiConversationHistory(
              conversationId: fallbackId,
              messages: history.messages,
            )
          : history;
    }
    return AiConversationHistory(conversationId: fallbackId);
  }
}
