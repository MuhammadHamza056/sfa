/// Money on the SAFA API is always Halalas (integer, `100 Halalas = 1 SAR`).
/// This is the single place that turns Halalas into the display string
/// every product/cart/order screen shows.
class CurrencyFormatter {
  CurrencyFormatter._();

  static String fromHalalas(int halalas, {required bool isAr}) {
    final sar = halalas / 100.0;
    return '${sar.toStringAsFixed(2)} ${isAr ? 'ر.س' : 'SAR'}';
  }
}
