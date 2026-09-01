/// M43 — reverse-geocode response.
class GeocodeResult {
  final String formattedAddress;
  final String city;
  final String district;

  const GeocodeResult({
    required this.formattedAddress,
    required this.city,
    required this.district,
  });

  factory GeocodeResult.fromJson(Map<String, dynamic> json) {
    return GeocodeResult(
      formattedAddress: json['formattedAddress']?.toString() ?? '',
      city: json['city']?.toString() ?? '',
      district: json['district']?.toString() ?? '',
    );
  }
}
