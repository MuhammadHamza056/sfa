/// Backends in this project have shipped booleans as `true`, `"true"` and
/// `1` depending on the endpoint. Returns `null` — meaning "not present" —
/// for anything unrecognised, which callers treat differently from `false`.
bool? readJsonBool(Object? value) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  if (value is String) {
    final normalized = value.toLowerCase();
    if (normalized == 'true' || normalized == '1') return true;
    if (normalized == 'false' || normalized == '0') return false;
  }
  return null;
}
