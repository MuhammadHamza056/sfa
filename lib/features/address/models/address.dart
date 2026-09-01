/// M40-M42 — a saved delivery address. The API only ever hands back plain
/// user-entered text (no bilingual objects here, unlike catalog content),
/// so display is language-independent.
class Address {
  final String id;
  final String name;
  final String recipientName;
  final String phoneNumber;
  final String city;
  final String district;
  final String street;
  final String building;
  final double? latitude;
  final double? longitude;
  final bool isDefault;

  const Address({
    required this.id,
    required this.name,
    required this.recipientName,
    required this.phoneNumber,
    required this.city,
    required this.district,
    required this.street,
    required this.building,
    this.latitude,
    this.longitude,
    this.isDefault = false,
  });

  String get line1 => building.isEmpty ? street : '$street، $building';
  String get line2 => district.isEmpty ? city : '$district، $city';

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      recipientName: json['recipientName']?.toString() ?? '',
      phoneNumber: (json['phone'] ?? json['phoneNumber'])?.toString() ?? '',
      city: json['city']?.toString() ?? '',
      district: json['district']?.toString() ?? '',
      street: json['street']?.toString() ?? '',
      building: json['building']?.toString() ?? '',
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      isDefault: json['isDefault'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'recipientName': recipientName,
    'phone': phoneNumber,
    'city': city,
    'district': district,
    'street': street,
    'building': building,
    if (latitude != null) 'latitude': latitude,
    if (longitude != null) 'longitude': longitude,
    'isDefault': isDefault,
  };

  Address copyWith({
    String? name,
    String? recipientName,
    String? phoneNumber,
    String? city,
    String? district,
    String? street,
    String? building,
    double? latitude,
    double? longitude,
    bool? isDefault,
  }) {
    return Address(
      id: id,
      name: name ?? this.name,
      recipientName: recipientName ?? this.recipientName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      city: city ?? this.city,
      district: district ?? this.district,
      street: street ?? this.street,
      building: building ?? this.building,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}
