/// Payloads the gateway pushes while the assistant answers one turn, in the
/// order they arrive: `start`, then any number of `chunk`s interleaved with
/// an optional `products`, then exactly one of `done` or `error`.
///
/// Kept beside [AiSocketService] rather than in `ai_models.dart` for the
/// same reason `realtime_events.dart` sits beside `SocketService`: these
/// describe the wire, not the chat thread the UI renders.
library;

import 'ai_models.dart';

/// `ai:stream:start` — the turn was accepted and a reply is coming.
class AiStreamStart {
  final String conversationId;

  /// Server id assigned to the message the user just sent, which lets the
  /// optimistic bubble stop being purely local.
  final String? userMessageId;

  const AiStreamStart({required this.conversationId, this.userMessageId});

  factory AiStreamStart.fromJson(Map<String, dynamic> json) {
    return AiStreamStart(
      conversationId: json['conversationId']?.toString() ?? '',
      userMessageId:
          (json['userMessageId'] ?? json['messageId'])?.toString(),
    );
  }
}

/// `ai:stream:chunk` — one token slice to append to the open bubble.
class AiStreamChunk {
  final String conversationId;
  final String delta;

  const AiStreamChunk({required this.conversationId, required this.delta});

  factory AiStreamChunk.fromJson(Map<String, dynamic> json) {
    return AiStreamChunk(
      conversationId: json['conversationId']?.toString() ?? '',
      // `delta` is the documented key; `content`/`text` are tolerated so a
      // gateway rename doesn't silently render an empty reply.
      delta: (json['delta'] ?? json['content'] ?? json['text'])?.toString() ?? '',
    );
  }
}

/// `ai:stream:products` — recommendations resolved mid-answer, so the cards
/// can appear before the prose finishes.
class AiStreamProducts {
  final String conversationId;
  final List<AiRecommendedProduct> products;

  const AiStreamProducts({
    required this.conversationId,
    this.products = const [],
  });

  factory AiStreamProducts.fromJson(Map<String, dynamic> json) {
    return AiStreamProducts(
      conversationId: json['conversationId']?.toString() ?? '',
      products: AiRecommendedProduct.listFrom(
        json['products'] ?? json['recommendedProducts'],
      ),
    );
  }
}

/// `ai:stream:done` — the turn is finished.
///
/// [fullReply] is the authoritative text: the accumulated chunks should
/// match it, but replacing rather than trusting the accumulation means a
/// dropped chunk doesn't leave a hole in the final bubble.
class AiStreamDone {
  final String conversationId;
  final String? messageId;
  final String fullReply;
  final List<AiRecommendedProduct> products;

  const AiStreamDone({
    required this.conversationId,
    required this.fullReply,
    this.messageId,
    this.products = const [],
  });

  factory AiStreamDone.fromJson(Map<String, dynamic> json) {
    return AiStreamDone(
      conversationId: json['conversationId']?.toString() ?? '',
      messageId: (json['messageId'] ?? json['id'])?.toString(),
      fullReply: (json['fullReply'] ?? json['reply'] ?? '').toString(),
      products: AiRecommendedProduct.listFrom(
        json['products'] ?? json['recommendedProducts'],
      ),
    );
  }
}

/// `ai:stream:error` — the turn failed; nothing further will arrive for it.
class AiStreamError {
  /// Empty when the gateway fails before a conversation exists, in which
  /// case the error belongs to whichever turn is currently open.
  final String conversationId;
  final String message;

  const AiStreamError({required this.conversationId, required this.message});

  factory AiStreamError.fromJson(Map<String, dynamic> json) {
    final raw = json['error'] ?? json['message'];
    return AiStreamError(
      conversationId: json['conversationId']?.toString() ?? '',
      // `error` is sometimes an object (`{message, code}`) rather than a string.
      message: raw is Map
          ? (raw['message'] ?? raw['error'])?.toString() ?? ''
          : raw?.toString() ?? '',
    );
  }
}
