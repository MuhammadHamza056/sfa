import '../../../core/models/localized_text.dart';

/// M56 — matches the guide's response example exactly.
class RefundReason {
  final String code;
  final LocalizedText name;

  const RefundReason({required this.code, required this.name});

  factory RefundReason.fromJson(Map<String, dynamic> json) {
    return RefundReason(
      code: json['code']?.toString() ?? '',
      name: LocalizedText.fromJson(json['name'] as Map<String, dynamic>? ?? const {}),
    );
  }
}

/// M57 — the real backend returns the whole refund document (`_id`,
/// `targetId`, `amountFils`, `status`, ...), not the guide's documented
/// `{refundId, status}` shape, so `_id`/`id` is read as a fallback.
class RefundSubmitResult {
  final String refundId;
  final String status;

  const RefundSubmitResult({required this.refundId, required this.status});

  factory RefundSubmitResult.fromJson(Map<String, dynamic> json) {
    return RefundSubmitResult(
      refundId: (json['refundId'] ?? json['_id'] ?? json['id'])?.toString() ?? '',
      status: json['status']?.toString() ?? 'PENDING',
    );
  }
}

/// M59 — the guide gives no response example; modeled after the M57
/// request body plus the id/name/image convention used elsewhere.
class RefundItem {
  final String itemId;
  final LocalizedText name;
  final int quantity;
  final String image;
  final int priceFils;

  const RefundItem({
    required this.itemId,
    required this.name,
    required this.quantity,
    required this.image,
    this.priceFils = 0,
  });

  factory RefundItem.fromJson(Map<String, dynamic> json) {
    return RefundItem(
      itemId: json['itemId']?.toString() ?? '',
      name: LocalizedText.fromJson(json['name'] as Map<String, dynamic>? ?? const {}),
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      image: json['image']?.toString() ?? '',
      priceFils: (json['priceFils'] as num?)?.toInt() ?? 0,
    );
  }
}

/// M58 — matches the guide's response example exactly. Note items are
/// NOT embedded here (unlike the first pass at this model) — they're a
/// separate call, M59 (`GET /refunds/:id/items`).
class RefundDetail {
  final String id;
  final String orderId;
  final String status;
  final String? reason;
  final int refundAmountFils;
  final DateTime? createdAt;

  const RefundDetail({
    required this.id,
    required this.orderId,
    required this.status,
    this.reason,
    this.refundAmountFils = 0,
    this.createdAt,
  });

  /// No documented status timeline for refunds (unlike orders' M52) — this
  /// ordered stage list is the best-faith inference from the
  /// three-milestone UI the app already had (processing → received →
  /// refunded), matched loosely against whatever status string comes back.
  /// `APPROVED` (the guide's own example status) is included.
  static const stages = [
    'REQUESTED',
    'PENDING',
    'PROCESSING',
    'RECEIVED',
    'APPROVED',
    'COMPLETED',
    'REFUNDED',
  ];

  int get stageIndex {
    final normalized = status.toUpperCase();
    final index = stages.indexOf(normalized);
    return index == -1 ? 0 : index;
  }

  factory RefundDetail.fromJson(Map<String, dynamic> json) {
    return RefundDetail(
      id: (json['_id'] ?? json['id'])?.toString() ?? '',
      orderId: (json['orderId'] ?? json['targetId'])?.toString() ?? '',
      status: json['status']?.toString() ?? 'PENDING',
      reason: json['reason'] as String?,
      refundAmountFils:
          (json['refundAmountFils'] as num?)?.toInt() ?? (json['amountFils'] as num?)?.toInt() ?? 0,
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? ''),
    );
  }
}
