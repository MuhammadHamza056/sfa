/// The `{ "ar": "...", "en": "..." }` bilingual object used throughout the
/// SAFA API for any user-facing text (product names, category names, CMS
/// content, ...).
class LocalizedText {
  final String ar;
  final String en;

  const LocalizedText({required this.ar, required this.en});

  factory LocalizedText.fromJson(Map<String, dynamic> json) {
    return LocalizedText(
      ar: json['ar']?.toString() ?? '',
      en: json['en']?.toString() ?? '',
    );
  }

  String resolve(bool isAr) => isAr ? ar : en;
}
