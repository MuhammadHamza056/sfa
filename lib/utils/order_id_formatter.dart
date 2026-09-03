/// `orderNumber`/order id from the API can fall back to the raw Mongo
/// ObjectId (24 hex chars) when the guide's shorter order number isn't
/// populated — every screen that shows one to the customer truncates to the
/// last 4 characters instead of the full id.
class OrderIdFormatter {
  OrderIdFormatter._();

  static String shorten(String id) {
    return id.length > 4 ? id.substring(id.length - 4) : id;
  }
}
