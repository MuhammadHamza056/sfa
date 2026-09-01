/// M97 — the guide gives no response example ("Customer notifications
/// list"); modeled after the mock data the app already had (title/body/
/// time/icon) plus the id/isRead/createdAt convention used elsewhere.
class AppNotification {
  final String id;
  final String title;
  final String body;
  final bool isRead;
  final DateTime? createdAt;
  final String? type;

  const AppNotification({
    required this.id,
    required this.title,
    required this.body,
    this.isRead = false,
    this.createdAt,
    this.type,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      body: json['body']?.toString() ?? json['message']?.toString() ?? '',
      isRead: json['isRead'] as bool? ?? json['read'] as bool? ?? false,
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? ''),
      type: json['type'] as String?,
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
