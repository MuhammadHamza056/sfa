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

  /// Some endpoints (e.g. vendor/brand `name`) send a plain string instead
  /// of the usual `{ar, en}` object; fall back to using it for both locales
  /// rather than crashing the `Map` cast.
  factory LocalizedText.fromDynamic(dynamic value) {
    if (value is Map<String, dynamic>) return LocalizedText.fromJson(value);
    if (value is String) return LocalizedText(ar: value, en: value);
    return const LocalizedText(ar: '', en: '');
  }

  String resolve(bool isAr) => isAr ? ar : en;
}
