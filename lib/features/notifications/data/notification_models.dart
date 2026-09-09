/// M97 — the guide gives no response example ("Customer notifications
/// list"); modeled after the mock data the app already had (title/body/
/// time/icon) plus the id/isRead/createdAt convention used elsewhere.
///
/// The same shape arrives over the socket as `notification:new` (see the
/// real-time guide), which spells the id `_id` and carries the extra
/// `category` / `referenceType` / `referenceId` triple — all optional here,
/// so one parser covers both sources.
class AppNotification {
  final String id;
  final String title;
  final String body;
  final bool isRead;
  final DateTime? createdAt;
  final String? type;

  /// What the notification is about (`orders`, `promotions`, …) and what it
  /// points at — used to route a tap to the right screen.
  final String? referenceType;
  final String? referenceId;

  const AppNotification({
    required this.id,
    required this.title,
    required this.body,
    this.isRead = false,
    this.createdAt,
    this.type,
    this.referenceType,
    this.referenceId,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: (json['id'] ?? json['_id'])?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      body: json['body']?.toString() ?? json['message']?.toString() ?? '',
      isRead: json['isRead'] as bool? ?? json['read'] as bool? ?? false,
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? ''),
      // The socket payload calls it `category`; the REST list calls it
      // `type`. Both feed the same icon lookup.
      type: (json['type'] ?? json['category'])?.toString(),
      referenceType: json['referenceType']?.toString(),
      referenceId: json['referenceId']?.toString(),
    );
  }

  AppNotification copyWith({bool? isRead}) {
    return AppNotification(
      id: id,
      title: title,
      body: body,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt,
      type: type,
      referenceType: referenceType,
      referenceId: referenceId,
    );
  }
}

/// M99 — the guide gives no response example ("Promotional offers
/// notifications").
class OfferNotification {
  final String id;
  final String title;
  final String? badgeText;
  final String? imageUrl;

  const OfferNotification({
    required this.id,
    required this.title,
    this.badgeText,
    this.imageUrl,
  });

  factory OfferNotification.fromJson(Map<String, dynamic> json) {
    return OfferNotification(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      badgeText: json['badgeText'] as String?,
      imageUrl: json['image']?.toString() ?? json['imageUrl']?.toString(),
    );
  }
}
