class Address {
  final String id;
  final String titleAr;
  final String titleEn;
  final String line1Ar;
  final String line1En;
  final String line2Ar;
  final String line2En;
  final String phone;

  const Address({
    required this.id,
    required this.titleAr,
    required this.titleEn,
    required this.line1Ar,
    required this.line1En,
    required this.line2Ar,
    required this.line2En,
    required this.phone,
  });

  String title(bool isAr) => isAr ? titleAr : titleEn;
  String line1(bool isAr) => isAr ? line1Ar : line1En;
  String line2(bool isAr) => isAr ? line2Ar : line2En;

  Address copyWith({
    String? titleAr,
    String? titleEn,
    String? line1Ar,
    String? line1En,
    String? line2Ar,
    String? line2En,
    String? phone,
  }) {
    return Address(
      id: id,
      titleAr: titleAr ?? this.titleAr,
      titleEn: titleEn ?? this.titleEn,
      line1Ar: line1Ar ?? this.line1Ar,
      line1En: line1En ?? this.line1En,
      line2Ar: line2Ar ?? this.line2Ar,
      line2En: line2En ?? this.line2En,
      phone: phone ?? this.phone,
    );
  }
}
