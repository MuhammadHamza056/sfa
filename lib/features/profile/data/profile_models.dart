import '../../../core/models/localized_text.dart';

/// M73 — matches the guide's response example: flat `phoneNumber` +
/// `countryCode` fields (not a nested `phone` object like most other
/// endpoints use), plus `avatar` and `dob`.
class ProfileData {
  final String id;
  final String name;
  final String? email;
  final String? avatarUrl;
  final String? phone;
  final String? dob;

  const ProfileData({
    required this.id,
    required this.name,
    this.email,
    this.avatarUrl,
    this.phone,
    this.dob,
  });

  factory ProfileData.fromJson(Map<String, dynamic> json) {
    final nestedPhone = json['phone'];
    final countryCode = json['countryCode']?.toString();
    final phoneNumber = json['phoneNumber']?.toString();
    final flatPhone = (countryCode != null && phoneNumber != null)
        ? '$countryCode$phoneNumber'
        : phoneNumber;
    return ProfileData(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      email: json['email'] as String?,
      avatarUrl: json['avatar']?.toString() ?? json['avatarUrl']?.toString(),
      phone: nestedPhone is Map
          ? nestedPhone['fullNumber']?.toString()
          : (flatPhone ?? nestedPhone?.toString()),
      dob: json['dob'] as String?,
    );
  }
}

/// M74 — matches the guide's response example exactly.
class MembershipData {
  final String tier;
  final LocalizedText tierName;
  final int pointsBalance;
  final int pointsValueFils;
  final bool freeDeliveryEligible;
  final double pointsMultiplier;
  final int nextTierPoints;

  const MembershipData({
    required this.tier,
    required this.tierName,
    required this.pointsBalance,
    required this.pointsValueFils,
    this.freeDeliveryEligible = false,
    this.pointsMultiplier = 1,
    this.nextTierPoints = 0,
  });

  /// Progress toward [nextTierPoints], clamped to a sane 0-1 range for a
  /// progress bar.
  double get progress =>
      nextTierPoints <= 0 ? 1 : (pointsBalance / nextTierPoints).clamp(0, 1);

  factory MembershipData.fromJson(Map<String, dynamic> json) {
    return MembershipData(
      tier: json['tier']?.toString() ?? '',
      tierName: LocalizedText.fromJson(json['tierName'] as Map<String, dynamic>? ?? const {}),
      pointsBalance: (json['pointsBalance'] as num?)?.toInt() ?? 0,
      pointsValueFils: (json['pointsValueFils'] as num?)?.toInt() ?? 0,
      freeDeliveryEligible: json['freeDeliveryEligible'] as bool? ?? false,
      pointsMultiplier: (json['pointsMultiplier'] as num?)?.toDouble() ?? 1,
      nextTierPoints: (json['nextTierPoints'] as num?)?.toInt() ?? 0,
    );
  }
}
