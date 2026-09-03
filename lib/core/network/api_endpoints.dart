/// Endpoint paths from the SAFA Mobile API Integration Guide, relative to
/// [AppConfig.baseUrl] (which already carries the `/api/v1` prefix).
///
/// Grouped and numbered (M01-M50, M51-M99) to match the guide's master
/// index, so a path here can be traced straight back to its spec entry.
/// The guide was revised after the first integration pass — several paths
/// and body shapes changed (noted inline where it matters); these
/// constants reflect the current (revised) guide.
class ApiEndpoints {
  ApiEndpoints._();

  // Section 1: Authentication & Session Management (M01-M11)
  static const String otpSend = '/auth/otp/send';
  static const String otpVerify = '/auth/otp/verify';
  static const String otpResend = '/auth/otp/resend';
  static const String login = '/auth/login/email';
  static const String register = '/auth/register';
  static const String googleSignIn = '/auth/oauth/google';
  static const String appleSignIn = '/auth/oauth/apple';
  static const String logout = '/auth/logout';
  static const String refreshToken = '/auth/refresh-token';
  static const String forgotPasswordRequest = '/auth/password/forgot';
  static const String forgotPasswordReset = '/auth/password/reset';

  // Section 2: Home Feed, Discovery & Saudi Brands Catalog (M12-M26)
  static const String homeFeed = '/home/feed';
  static const String categories = '/categories';
  static String categoryDetail(String id) => '/categories/$id';
  static const String categoryBanners = '/categories/banners';
  static const String search = '/search';
  static const String products = '/products';
  static String productDetail(String id) => '/products/$id';
  static String productVariants(String id) => '/products/$id/variants';
  static String productStock(String id) => '/products/$id/stock';
  static String relatedProducts(String id) => '/products/$id/related';
  static const String productSearch = '/products/search';
  static const String productFilters = '/products/filters';
  static const String brands = '/brands';
  static String brandDetail(String id) => '/brands/$id';
  static String brandProducts(String id) => '/brands/$id/products';
  static const String brandCategories = '/brands/categories';
  static String brandsByCategory(String categoryId) =>
      '/brands/category/$categoryId';
  static const String contentDeliveryTerms = '/content/delivery-terms';
  static const String contentAbout = '/content/about';
  static const String contentTerms = '/content/terms';
  static const String contentFaq = '/content/faq';
  static const String contentContact = '/content/contact';
  static const String deliveryEstimate = '/delivery/estimate';

  // Section 3: Shopping Cart, Discounts & Checkout Preview (M27-M39)
  static const String cart = '/cart';
  static const String cartItems = '/cart/items';
  static String cartItem(String itemId) => '/cart/items/$itemId';
  static String cartItemFavorite(String itemId) =>
      '/cart/items/$itemId/favorite';
  static const String cartCoupon = '/cart/coupon';
  static const String cartGiftWrap = '/cart/gift-wrap';
  static const String cartRedeemPoints = '/cart/redeem-points';
  static const String cartTotals = '/cart/totals';
  static const String regions = '/regions';
  static const String checkoutSummary = '/checkout/summary';
  static const String checkoutPreview = '/checkout/preview';
  static const String checkoutCreateOrder = '/checkout/create-order';

  // Section 4: Address Book & Geocoding (M40-M43, M77-M81)
  static const String addresses = '/addresses';
  static String addressDetail(String id) => '/addresses/$id';
  static String addressDefault(String id) => '/addresses/$id/default';
  static const String addressGeocode = '/addresses/geocode';

  // Section 5: Payments & Gateways (M44-M48)
  static const String paymentMethods = '/payments/methods';
  static const String paymentInitiate = '/payments/methods/initiate';
  static const String paymentMyFatoorah = '/payments/methods/myfatoorah';
  static String paymentDelete(String id) => '/payments/methods/$id';
  static String paymentSetDefault(String id) => '/payments/methods/$id/default';

  // Section 6: Order Creation & Order Listing (M49-M50)
  static const String orders = '/orders';

  // Section 7: Order Details, Tracking Timeline & Receipts (M51-M55, M60-M63)
  static String orderDetail(String id) => '/orders/$id';
  static String orderTracking(String id) => '/orders/$id/tracking';
  static String orderCancel(String id) => '/orders/$id/cancel';
  static String orderSendDeliveryOtp(String id) =>
      '/orders/$id/send-delivery-otp';
  static String orderVerifyDeliveryOtp(String id) =>
      '/orders/$id/verify-delivery-otp';
  static String orderReturnableItems(String id) => '/orders/$id/returnable-items';
  static const String orderStatistics = '/orders/statistics';
  static String orderDeliveryInfo(String id) => '/orders/$id/delivery';

  // Section 8: Returns, Refunds & Milestone Status (M56-M59)
  static const String refundReasons = '/refunds/reasons';
  static String orderRefundRequest(String orderId) => '/orders/$orderId/refund-request';
  static String refundDetail(String id) => '/refunds/$id';
  static String refundItems(String id) => '/refunds/$id/items';

  // Section 9: Verified Product Reviews & Rating Breakdown (M64-M67)
  static String productReviews(String productId) => '/products/$productId/reviews';
  static String productReviewsSummary(String productId) =>
      '/products/$productId/reviews/summary';
  static String reviewHelpful(String reviewId) => '/reviews/$reviewId/helpful';

  // Section 10: Social Commerce Reels & Video Feed (M68-M72)
  static const String reels = '/reels';
  static String reelLike(String id) => '/reels/$id/like';
  static String reelSave(String id) => '/reels/$id/save';
  static String reelShare(String id) => '/reels/$id/share';
  static String reelProduct(String id) => '/reels/$id/product';

  // Section 11: Customer Profile, Membership Tier & Settings (M73-M76)
  static const String myProfile = '/users/me/profile';
  static const String myMembership = '/users/me/membership';
  static const String myPreferences = '/users/me/preferences';

  // Section 12: Favorites & Collaborative Shared Wishlists (M82-M91)
  static const String favorites = '/favorites';
  static String favoriteDetail(String productId) => '/favorites/$productId';
  static const String wishlists = '/wishlists';
  static String wishlistDetail(String id) => '/wishlists/$id';
  static String wishlistItems(String id) => '/wishlists/$id/items';
  static String wishlistItemDetail(String id, String productId) =>
      '/wishlists/$id/items/$productId';
  static String wishlistShare(String id) => '/wishlists/$id/share';
  static String wishlistShared(String token) => '/wishlists/shared/$token';

  // Section 13: Customer Wallet, Ledger & IBAN Withdrawals (M92-M94)
  static const String wallet = '/wallet';
  static const String walletTransactions = '/wallet/transactions';
  static const String walletWithdraw = '/wallet/withdraw';

  // Section 14: AI Stylist Fashion Advisor (M95)
  static const String aiChat = '/ai/chat';

  // Section 15: Push Notifications & Device Token Registration (M96-M99)
  static const String notificationDeviceToken = '/notifications/device-token';
  static const String notifications = '/notifications';
  static const String notificationsRead = '/notifications/read';
  static String notificationRead(String id) => '/notifications/$id/read';
  static const String notificationOffers = '/notifications/offers';

  // Section 16: On-Demand Door-to-Door Courier Delivery Module
  static const String deliveries = '/deliveries';
  static String deliveryCheckout(String id) => '/deliveries/$id/checkout';
  static const String deliveryCompareCompanies = '/deliveries/compare-companies';

  /// Routes that must NOT carry an Authorization header, matching the
  /// guide's "Auth Required: No" column. Optional-auth routes (e.g. home
  /// feed) are intentionally left out: the token is attached when present
  /// but the call still succeeds without one.
  static const Set<String> publicPaths = {
    otpSend,
    otpVerify,
    otpResend,
    register,
    login,
    refreshToken,
    forgotPasswordRequest,
    forgotPasswordReset,
    googleSignIn,
    appleSignIn,
    categories,
    categoryBanners,
    search,
    products,
    productSearch,
    productFilters,
    brands,
    brandCategories,
    regions,
    addressGeocode,
    refundReasons,
  };
}
