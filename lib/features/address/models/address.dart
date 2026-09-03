/// M40-M42 — a saved delivery address. The API only ever hands back plain
/// user-entered text (no bilingual objects here, unlike catalog content),
/// so display is language-independent.
///
/// Field set matches the backend's Kuwait-style address DTO
/// (governorate/area/block/houseNumber) — `recipientName`, `phone`,
/// `city`, `district`, `building` are rejected by the API and must not be
/// sent.
class Address {
  final String id;
  final String name;
  final String contactNumber;
  final String governorate;
  final String area;
  final String block;
  final String street;
  final String houseNumber;
  final double latitude;
  final double longitude;
  final bool isDefault;

  const Address({
    required this.id,
    required this.name,
    required this.contactNumber,
    required this.governorate,
    required this.area,
    required this.block,
    required this.street,
    required this.houseNumber,
    this.latitude = 0,
    this.longitude = 0,
    this.isDefault = false,
  });

  String get line1 => houseNumber.isEmpty ? street : '$street، $houseNumber';
  String get line2 => area.isEmpty ? governorate : '$area، $governorate';

  /// `latitude`/`longitude` default to 0 when the backend didn't send real
  /// coordinates — used to decide whether a map pin would be meaningful.
  bool get hasLocation => latitude != 0 || longitude != 0;

  /// Best-effort mapping onto the checkout confirm endpoint's
  /// `shippingAddress` shape (`fullName/phone/city/district/street/
  /// buildingNo`), which doesn't match this app's Kuwait-style saved
  /// address fields 1:1 — verify against the real API guide if orders are
  /// rejected.
  Map<String, dynamic> toShippingAddressJson() => {
    'fullName': name,
    'phone': contactNumber,
    'city': governorate,
    'district': area,
    'street': street,
    'buildingNo': houseNumber,
    'latitude': latitude,
    'longitude': longitude,
  };

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: (json['id'] ?? json['_id'])?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      contactNumber: json['contactNumber']?.toString() ?? '',
      governorate: json['governorate']?.toString() ?? '',
      area: json['area']?.toString() ?? '',
      block: json['block']?.toString() ?? '',
      street: json['street']?.toString() ?? '',
      houseNumber: json['houseNumber']?.toString() ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0,
      isDefault: json['isDefault'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'contactNumber': contactNumber,
    'governorate': governorate,
    'area': area,
    'block': block,
    'street': street,
    'houseNumber': houseNumber,
    'latitude': latitude,
    'longitude': longitude,
    'isDefault': isDefault,
  };

  Address copyWith({
    String? name,
    String? contactNumber,
    String? governorate,
    String? area,
    String? block,
    String? street,
    String? houseNumber,
    double? latitude,
    double? longitude,
    bool? isDefault,
  }) {
    return Address(
      id: id,
      name: name ?? this.name,
      contactNumber: contactNumber ?? this.contactNumber,
      governorate: governorate ?? this.governorate,
      area: area ?? this.area,
      block: block ?? this.block,
      street: street ?? this.street,
      houseNumber: houseNumber ?? this.houseNumber,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}
