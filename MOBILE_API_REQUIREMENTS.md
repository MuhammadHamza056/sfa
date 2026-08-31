# Mobile API Requirements — SFA Flutter App

**Audit date:** 2026-08-20
**Scope:** Backend API requirements derived from the existing Flutter application only.
**Method:** Static audit of all 97 project Dart files under `lib/` (routes, screens, widgets, providers, models, core networking).

---

## Headline finding

**The application has no live backend integration whatsoever.**

- A Dio-based HTTP wrapper exists at [lib/core/base_client.dart](lib/core/base_client.dart) (`BaseClients.get/post/login/put/delete`) — it has **zero call sites** anywhere in `lib/`.
- Two base URLs are declared in [lib/core/base_urls.dart](lib/core/base_urls.dart) — `http://58.27.160.180:5000/yumas/` and `http://58.27.160.180:5000/admin/` — and are **never referenced**.
- **No endpoint path is defined anywhere in the codebase.** Every `Endpoint` cell below is therefore blank.
- Every screen renders hardcoded/mock data (Arabic + English literals, Unsplash image URLs, static lists).
- Token storage exists (`SecureStorage.putTokken` / `getTokken` in [lib/core/hive_services.dart](lib/core/hive_services.dart)) but `putTokken` is **never called**, so no token is ever persisted.

Consequently **every one of the 99 required APIs is `MISSING`**, except three marked `UNKNOWN` where the requirement itself cannot be established from the code.

### How to read the table

| Column | Meaning |
|---|---|
| **Method** | **Inferred** from the operation's semantics (read vs. create vs. update vs. delete). No HTTP method is declared anywhere in the code. |
| **Endpoint** | Left blank (`—`) throughout: no endpoint path exists in the codebase. Nothing has been invented. |
| **Request** | Fields the current UI actually collects. Where the UI collects nothing, this is stated. |
| **Response** | The data the screen renders today (currently sourced from mock literals). Field *names* are not invented — these are descriptions of the data the UI consumes. |
| **Auth** | Whether the operation is user-scoped. Note: the app currently has **no auth mechanism at all**, so this column expresses the requirement, not current behaviour. |

### Status legend

| Status | Meaning | Count |
|---|---|---|
| `EXISTING` | Implemented and appears complete | 0 |
| `PARTIAL` | API exists but incomplete | 0 |
| `MISSING` | UI/flow exists, no backend implementation | 96 |
| `UNKNOWN` | Backend requirement not determinable from the code | 3 |

---

## Master table

| # | Feature | Screen | API Purpose | Method | Endpoint | Request | Response | Auth | Status | Notes |
|---|---|---|---|---|---|---|---|---|---|---|
| **1. AUTHENTICATION** |||||||||||
| 1 | Auth | Login ([login_screen.dart](lib/features/auth/presentation/screens/login_screen.dart)) | Authenticate user by phone number | POST | — | Dial code + phone number (default `+965` / `KW`, per-country max length validated by `PhoneInputValidator`) | Session token + user identity | No | MISSING | `submitLogin()` ([auth_provider.dart:107](lib/features/auth/providers/auth_provider.dart)) only does `await Future.delayed(2s)` then sets success. The Login button ([login_screen.dart:38](lib/features/auth/presentation/screens/login_screen.dart)) bypasses even that and calls `context.go('/dashboard')` directly. |
| 2 | Auth | Login (email mode) | Authenticate user by email | POST | — | Email address (`_emailController`) | Session token + user identity | No | MISSING | `toggleAuthMode(isEmailMode)` switches the input to email. **No password field exists on the login screen in either mode** — the flow that follows email entry is not implemented, so the credential model cannot be determined from the code. |
| 3 | Auth | Signup ([signup_screen.dart](lib/features/auth/presentation/screens/signup_screen.dart)) | Register a new account | POST | — | Full name, dial code + phone, email, password, password confirmation, `registerAsMerchant` flag, `agreeTerms` flag | Created user + OTP challenge reference | No | MISSING | Signup button ([signup_screen.dart:46](lib/features/auth/presentation/screens/signup_screen.dart)) shows a success toast and navigates to `/otp` with no validation and no call. `registerAsMerchant` / `agreeTerms` live in `AuthState` but are never transmitted. |
| 4 | Auth | Signup → OTP | Request/send an OTP challenge | POST | — | Phone or email identifier | Challenge reference + cooldown | No | MISSING | No explicit "send OTP" step exists; `/otp` is reached by plain navigation. |
| 5 | Auth | OTP ([otp_screen.dart](lib/features/auth/presentation/screens/otp_screen.dart)) | Verify the OTP code | POST | — | **4-digit** code (`Pinput(length: 4)`, [otp_screen.dart:213](lib/features/auth/presentation/screens/otp_screen.dart)) + challenge reference | Session token + user identity | No | MISSING | Verify button ([otp_screen.dart:75](lib/features/auth/presentation/screens/otp_screen.dart)) calls `context.go('/success')` unconditionally — the entered code is never read. |
| 6 | Auth | OTP | Resend the OTP code | POST | — | Challenge reference | New challenge + cooldown | No | MISSING | `_onResendOtp()` ([otp_screen.dart:46](lib/features/auth/presentation/screens/otp_screen.dart)) contains the comment `// Trigger OTP resend` and only restarts the local 60-second timer. |
| 7 | Auth | App-wide | Refresh an expired session token | POST | — | Refresh token | New access token | Yes | UNKNOWN | No refresh logic, interceptor, or token-expiry handling exists anywhere. Whether refresh tokens are part of the auth model cannot be determined from the app. |
| 8 | Auth | Profile ([profile_screen.dart:359](lib/features/profile/presentation/screens/profile_screen.dart)) | Invalidate the session server-side | POST | — | Session token | Confirmation | Yes | MISSING | Logout only calls `context.go('/login')`. It does **not** clear local credentials — `SecureStorage.deleteHiveData()` / `deleteHive()` exist but are never called. |
| 9 | Auth | Login | Sign in with Apple | POST | — | Apple identity token | Session token + user identity | No | MISSING | Button is `onPressed: () {}` ([login_screen.dart:188](lib/features/auth/presentation/screens/login_screen.dart)). No `sign_in_with_apple` dependency in `pubspec.yaml`. |
| 10 | Auth | Login | Sign in with Google | POST | — | Google ID token | Session token + user identity | No | MISSING | Button is `onPressed: () {}` ([login_screen.dart:220](lib/features/auth/presentation/screens/login_screen.dart)). No `google_sign_in` dependency in `pubspec.yaml`. |
| 11 | Auth | — | Password / account recovery | POST | — | — | — | No | MISSING | The l10n key `forgotPassword` exists in `app_ar.arb` / `app_en.arb` (line 24) but is **referenced by no Dart file** — there is no recovery UI or entry point in the current build. |
| **2. HOME / DISCOVERY** |||||||||||
| 12 | Home | Home ([home_screen.dart](lib/features/home/presentation/screens/home_screen.dart)) | Fetch home hero/banner content | GET | — | Locale | Hero image, headline, CTA | No | MISSING | Hero image is a hardcoded Unsplash URL; copy comes from l10n. CTA at [home_screen.dart:287](lib/features/home/presentation/screens/home_screen.dart) is `onTap: () {}`. |
| 13 | Home | Home | Fetch gender/category tabs (Women/Men/Kids) | GET | — | Locale | Tab list | No | MISSING | `homeSelectedCategoryIndexProvider` stores an index only; changing it filters nothing on screen. |
| 14 | Home | Home | Fetch category banner tiles | GET | — | Locale | Banner image + label + target per tile | No | MISSING | 3 hardcoded Unsplash tiles in [category_banners_section.dart:19-39](lib/features/home/presentation/widgets/category_banners_section.dart); all navigate to the same `/featured-products`. |
| 15 | Home | Home + Featured Products | Fetch featured products | GET | — | Gender/tab selection, pagination | Product list: image, title, price, rating, brand name, reviews label | No | MISSING | 12 hardcoded products duplicated across [featured_products_section.dart](lib/features/home/presentation/widgets/featured_products_section.dart) and [featured_products_screen.dart](lib/features/home/presentation/screens/featured_products_screen.dart). `homeSelectedFeaturedTabProvider` does not filter them. |
| 16 | Home | Home | Fetch home reels strip | GET | — | — | Reel thumbnails + brand avatars | No | MISSING | 4 hardcoded entries in [reels_section.dart:86-118](lib/features/home/presentation/widgets/reels_section.dart). |
| 17 | Brands | Brands ([brands_screen.dart](lib/features/brands/presentation/screens/brands_screen.dart)) | Fetch the brand list | GET | — | Gender + category filters, pagination | Brand list: image, name | No | MISSING | Two static rows `_kBrandsRow1` / `_kBrandsRow2` (6 brands each, [brands_screen.dart:9-72](lib/features/brands/presentation/screens/brands_screen.dart)). Names are l10n keys, not data. |
| 18 | Brands | Brands | Fetch brands promo banner | GET | — | — | Banner image + copy | No | MISSING | `_kPromoBannerUrl` hardcoded at [brands_screen.dart:74](lib/features/brands/presentation/screens/brands_screen.dart). |
| 19 | Brands | Brand Detail ([brand_detail_screen.dart](lib/features/brands/presentation/screens/brand_detail_screen.dart)) | Fetch brand profile + its products | GET | — | Brand identifier | Brand cover image, name, product list | No | MISSING | The route passes only a **brand name string** (`state.extra as String?`, defaulting to `'brandJuba'`) — there is no brand id in the app. 6 products hardcoded at [brand_detail_screen.dart:31-66](lib/features/brands/presentation/screens/brand_detail_screen.dart). |
| 20 | Products | Product Detail ([product_detail_screen.dart](lib/features/brands/presentation/screens/product_detail_screen.dart)) | Fetch full product detail | GET | — | Product identifier | Images, title, price, rating, description, brand, care/shipping info | No | MISSING | The screen receives `ProductDetailArgs` (name, imageUrl, price, rating, brandNameKey) via `state.extra` — **no product id exists in the app**. `productDetailKey()` composes a key from `name::imageUrl` precisely because of this ([product_detail_provider.dart](lib/features/brands/providers/product_detail_provider.dart)). |
| 21 | Products | Product Detail | Fetch product variants (colors / sizes) | GET | — | Product identifier | Available colors + sizes, per-variant availability | No | MISSING | `_colors` (5 `Color` literals) and `_sizes` (`['S','M','L','XL','XXL']`) are `static const` at [product_detail_screen.dart:50,56](lib/features/brands/presentation/screens/product_detail_screen.dart) — identical for every product. |
| 22 | Products | Product Detail | Fetch stock / urgency indicator | GET | — | Product identifier + variant | Stock level or urgency message | No | MISSING | The red "hurry" pill ([product_detail_screen.dart:248](lib/features/brands/presentation/screens/product_detail_screen.dart)) renders static l10n text. |
| 23 | Products | Product Detail | Fetch related products | GET | — | Product identifier | Product list (same shape as #15) | No | MISSING | `relatedProducts` list built inline at [product_detail_screen.dart:80](lib/features/brands/presentation/screens/product_detail_screen.dart). |
| 24 | Products | Product Detail | Fetch delivery terms content | GET | — | Locale | Terms text | No | MISSING | [delivery_terms_bottom_sheet.dart](lib/features/brands/presentation/widgets/delivery_terms_bottom_sheet.dart) renders l10n strings only. |
| 25 | Search | Brands header ([brands_header.dart:275](lib/features/brands/presentation/widgets/brands_header.dart)) | Search brands/products | GET | — | Query text, filters | Result list | No | MISSING | The search `TextField` has **no controller, no `onChanged`, no `onSubmitted`** — typed input is discarded. The search icon buttons in [primary_app_bar.dart:131](lib/core/widgets/primary_app_bar.dart), [floating_top_bar.dart:106](lib/core/widgets/floating_top_bar.dart) and [brands_header.dart:296](lib/features/brands/presentation/widgets/brands_header.dart) are commented out. |
| 26 | Filters | Brands header | Fetch filter facets + apply filters | GET | — | Gender index, category index | Filtered result set | No | MISSING | `BrandsNotifier.changeGender/changeCategory` store indices only ([brands_provider.dart](lib/features/brands/providers/brands_provider.dart)); the grid is not filtered. |
| 27 | Sorting | — | Sort results | GET | — | — | — | No | UNKNOWN | **No sorting UI exists anywhere in the app** — no sort control, dropdown, or state field. The requirement cannot be established from the code. |
| **3. CART / CHECKOUT** |||||||||||
| 28 | Cart | Cart ([cart_screen.dart](lib/features/cart/presentation/screens/cart_screen.dart)) | Fetch the user's cart | GET | — | — | Line items (image, brand, title, price, color, size, quantity), totals | Yes | MISSING | `CartNotifier.build()` returns `[]` ([cart_provider.dart](lib/features/cart/providers/cart_provider.dart)). Cart is in-memory only and **lost on every app restart**. |
| 29 | Cart | Product Detail | Add an item to the cart | POST | — | Product ref, selected color, selected size, quantity | Updated cart + totals | Yes | MISSING | `addItem()` mutates local state ([product_detail_screen.dart:790](lib/features/brands/presentation/screens/product_detail_screen.dart)). Line identity is `'$title\|$color\|$size'` — a string key, not a server id. |
| 30 | Cart | Cart | Remove a cart item | DELETE | — | Cart line identifier | Updated cart + totals | Yes | MISSING | `removeItem()` local only ([cart_screen.dart:83](lib/features/cart/presentation/screens/cart_screen.dart)). |
| 31 | Cart | Cart | Update cart item quantity | PUT | — | Cart line identifier, new quantity | Updated cart + totals | Yes | MISSING | **No quantity editing control exists in the UI** — [cart_item_card.dart:158](lib/features/cart/presentation/widgets/cart_item_card.dart) renders the quantity as read-only text. Quantity can only increment by re-adding the same variant. |
| 32 | Cart | Cart | Move a cart item to favorites | POST | — | Cart line identifier | Updated cart + favorites | Yes | MISSING | `onFavorite: () {}` at [cart_screen.dart:85](lib/features/cart/presentation/screens/cart_screen.dart) — the button is inert. |
| 33 | Cart | Cart | Validate + apply a coupon code | POST | — | Coupon code | Validity, discount amount, updated totals | Yes | MISSING | `CouponCodeField` is instantiated as `const CouponCodeField()` ([cart_screen.dart:215](lib/features/cart/presentation/screens/cart_screen.dart)) with **null controller and null `onApply`** — the Apply button does nothing and the typed code is unreadable. |
| 34 | Cart | Cart | Apply gift wrapping + gift message | POST | — | Gift-wrap flag, gift card message text | Updated order/cart | Yes | MISSING | `_freeGiftWrap` bool and `_giftCardController` are local `setState` only; the message text is never read or transmitted. |
| 35 | Cart | Cart | Fetch + redeem loyalty points | POST | — | Redeem flag, points amount | Points balance, discount, updated totals | Yes | MISSING | `_earnAndRedeem` toggles a **hardcoded `pointsDiscountAmount = 20.0`** ([cart_screen.dart:39](lib/features/cart/presentation/screens/cart_screen.dart)). |
| 36 | Cart | Cart | Server-side cart totals | GET | — | Cart identifier | Subtotal, discounts, shipping, tax, total | Yes | MISSING | Totals are computed client-side by `cartSubtotal()`, which **parses digits out of formatted display strings** (`"1,250 SAR"` → `1250`) via `replaceAll(RegExp(r'[^0-9.]'), '')` ([cart_provider.dart](lib/features/cart/providers/cart_provider.dart)). No shipping, tax, or VAT line exists. |
| 37 | Checkout | Checkout ([checkout_screen.dart](lib/features/checkout/presentation/screens/checkout_screen.dart)) | Fetch selectable regions | GET | — | Locale | Region list | No | MISSING | 5 regions hardcoded as a bilingual literal at [checkout_screen.dart:49](lib/features/checkout/presentation/screens/checkout_screen.dart). |
| 38 | Checkout | Checkout | Fetch checkout order summary | GET | — | Cart identifier | Subtotal + total | Yes | MISSING | Subtotal and total are **hardcoded to `2,500 SAR`** ([checkout_screen.dart:260-270](lib/features/checkout/presentation/screens/checkout_screen.dart)) and are **not connected to the actual cart** — the displayed amount does not change with cart contents. |
| 39 | Checkout | Checkout | Submit the order | POST | — | Full name, phone, region, city, detailed address, `saveAddress` flag, selected payment option, cart ref | Order id + payment handle | Yes | MISSING | `_onConfirmOrder()` ([checkout_screen.dart:632](lib/features/checkout/presentation/screens/checkout_screen.dart)) validates the form then calls `context.push('/payment-success')`. Nothing is submitted. |
| 40 | Checkout | Checkout | Save the entered address for future use | POST | — | Address fields | Saved address | Yes | MISSING | The `_saveAddress` checkbox is local-only and **does not write to `addressProvider`**. |
| 41 | Checkout | Checkout | Select from saved addresses | GET | — | — | Saved address list | Yes | MISSING | Checkout uses a **free-text address form** and does not read the saved-address list from [address_provider.dart](lib/features/address/providers/address_provider.dart) at all — the two features are disconnected. |
| 42 | Checkout | Checkout | Resolve address from map pin (geocoding) | GET | — | Coordinates | Structured address | Yes | MISSING | The `_CheckoutMap` widget is a **static, non-interactive** `flutter_map` view pinned to a fixed `LatLng(29.3375, 48.0750)` (Kuwait City), labelled "Address by map". No pin selection or geocoding is wired. Map tiles come from OpenStreetMap — an external tile service, not this backend. |
| 43 | Delivery | Product Detail | Fetch delivery estimate for a city | GET | — | Product ref + selected city (one of `cityRiyadh`, `cityJeddah`, `cityDammam`, `cityMecca`, `cityMedina`) | Estimated delivery days, shipping origin | No | MISSING | `selectCity()` stores the city key ([product_detail_provider.dart](lib/features/brands/providers/product_detail_provider.dart)); the days figure shown alongside is static l10n text and does not change with the selection. |
| **4. PAYMENTS** |||||||||||
| 44 | Payments | Checkout | Fetch available payment methods | GET | — | — | Method list | Yes | MISSING | Hardcoded as three plain strings: `['PayTaps', 'TapPayments', 'Moyasar']` ([checkout_screen.dart:53](lib/features/checkout/presentation/screens/checkout_screen.dart)). These are **display labels only** — no payment SDK or provider dependency exists in `pubspec.yaml`, and no integration code exists. |
| 45 | Payments | Checkout | Initialize a payment | POST | — | Order ref, amount, selected method | Payment session / redirect handle | Yes | MISSING | No payment initialization exists. Confirm goes straight to the success screen. |
| 46 | Payments | Checkout → Payment Success | Confirm payment / handle callback | POST | — | Payment session ref | Payment result | Yes | MISSING | [payment_success_screen.dart](lib/features/checkout/presentation/screens/payment_success_screen.dart) is entirely static — it renders a fixed success message and a button to `/order-tracking`. It receives **no order id or payment reference**. |
| 47 | Payments | Payment Success | Poll/fetch payment status | GET | — | Payment session ref | Status | Yes | MISSING | No status check exists; success is assumed by navigation. |
| 48 | Payments | Refund flow | Issue a payment refund | POST | — | Order ref, items, amount | Refund record | Yes | MISSING | See #58/#59 — the refund UI exists but performs no backend call. |
| **5. ORDERS** |||||||||||
| 49 | Orders | Checkout | Create an order | POST | — | See #39 | Order id, number, status | Yes | MISSING | Same gap as #39 — no order is ever created. |
| 50 | Orders | Previous Orders ([previous_orders_screen.dart](lib/features/orders/presentation/screens/previous_orders_screen.dart)) | Fetch current orders | GET | — | Pagination | Order number, amount, delivery state, delivered time | Yes | MISSING | `_currentOrders` is a `static const List<_OrderCardData>` ([previous_orders_screen.dart:339](lib/features/orders/presentation/screens/previous_orders_screen.dart)). |
| 51 | Orders | Previous Orders | Fetch past orders | GET | — | Pagination | Same shape as #50 | Yes | MISSING | `_previousOrders` — also `static const`. Both tabs are hardcoded. |
| 52 | Orders | Previous Orders | Fetch order tracking details (expandable card) | GET | — | Order id | Tracking detail rows | Yes | MISSING | `_buildTrackingDetailsSection` renders static content; expansion is pure local UI state (`toggleCardExpanded`). |
| 53 | Orders | Order Tracking ([order_tracking_screen.dart](lib/features/orders/presentation/screens/order_tracking_screen.dart)) | Fetch order info header | GET | — | Order id | Order number, order date, total amount | Yes | MISSING | Hardcoded: order `#84739201`, date from l10n, total `2,500 SAR` ([order_tracking_screen.dart:68-78](lib/features/orders/presentation/screens/order_tracking_screen.dart)). **The screen takes no order id — the route `/order-tracking` has no parameter.** |
| 54 | Orders | Order Tracking | Fetch order status timeline | GET | — | Order id | Ordered list of status steps with timestamps + completion flags | Yes | MISSING | 3 fixed steps (Processing `09:15` ✓, Shipped `12:00` ✓, Delivered `--:--` ✗) built inline at [order_tracking_screen.dart:276](lib/features/orders/presentation/screens/order_tracking_screen.dart). |
| 55 | Orders | Order Tracking | Cancel an order | POST | — | Order id, reason | Updated order status | Yes | MISSING | `_buildCancelButton` ([order_tracking_screen.dart:222](lib/features/orders/presentation/screens/order_tracking_screen.dart)) only pops the route / navigates to `/dashboard`. No reason is collected. |
| 56 | Orders | Order Tracking | Confirm delivery receipt | POST | — | Order id | Updated order status | Yes | MISSING | Confirm-delivery button ([order_tracking_screen.dart:106](lib/features/orders/presentation/screens/order_tracking_screen.dart)) only pops the route. |
| 57 | Orders | Refund Request ([refund_request_screen.dart](lib/features/orders/presentation/screens/refund_request_screen.dart)) | Fetch returnable items for an order | GET | — | Order id (route param `:id`, default `'84739201'`) | Item list: brand, title, price, size, color, image | Yes | MISSING | `_products` is a hardcoded 2-item `List<Map<String, dynamic>>` with local ids `'1'` / `'2'` ([refund_request_screen.dart:23](lib/features/orders/presentation/screens/refund_request_screen.dart)). |
| 58 | Orders | Refund Request | Fetch return reasons | GET | — | Locale | Reason list | Yes | MISSING | 4 reasons built from l10n keys (`reasonSizeNotFitting`, `reasonDefective`, `reasonNoLongerNeeded`, `reasonWrongProduct`) at [refund_request_screen.dart:81](lib/features/orders/presentation/screens/refund_request_screen.dart). |
| 59 | Orders | Refund Request | Submit a return/refund request | POST | — | Order id, selected item ids, selected reason, free-text notes (`_notesController`) | Refund request id + status | Yes | MISSING | Submit ([refund_request_screen.dart:553](lib/features/orders/presentation/screens/refund_request_screen.dart)) validates only that ≥1 item is selected, then navigates to `/refund-status/:id`. **The selected reason and the notes text are never read on submit.** |
| 60 | Orders | Refund Status ([refund_status_screen.dart](lib/features/orders/presentation/screens/refund_status_screen.dart)) | Fetch refund status timeline | GET | — | Order/refund id | Status steps with timestamps | Yes | MISSING | 3 fixed steps (`statusRefundProcessing` 09:15, `statusProductsReceived` 12:00, `statusRefundSuccessful` 12:30) at [refund_status_screen.dart:68](lib/features/orders/presentation/screens/refund_status_screen.dart). |
| 61 | Orders | Refund Status | Fetch returned items | GET | — | Order/refund id | Item list | Yes | MISSING | `_returnedProducts` hardcoded at [refund_status_screen.dart:20](lib/features/orders/presentation/screens/refund_status_screen.dart). |
| 62 | Orders | Notifications | Fetch order statistics counters | GET | — | — | Counts for active / delivered / in-shipping / returned | Yes | MISSING | Hardcoded `'3'`, `'12'`, `'2'`, `'1'` ([notifications_screen.dart:79-100](lib/features/notifications/presentation/screens/notifications_screen.dart)). |
| **6. DELIVERY / TRACKING** |||||||||||
| 63 | Delivery | Order Tracking | Fetch delivery agent / courier info | GET | — | Order id | Agent name, delivery company | Yes | MISSING | Agent name hardcoded as `'أحمد محمد'` (Arabic literal, shown regardless of locale) at [order_tracking_screen.dart:402](lib/features/orders/presentation/screens/order_tracking_screen.dart); company from l10n key `deliveryCompanyValue`. **No courier phone number or contact action exists in the UI.** |
| 64 | Delivery | — | Live driver location | — | — | — | — | — | UNKNOWN | **Not used by the app.** The order tracking screen contains no map (the only `flutter_map` usage is the static checkout map, #42) and no location polling or subscription. No requirement is derivable. |
| 65 | Delivery | — | Delivery ETA | — | — | — | — | — | MISSING | Not consumed dynamically. The tracking timeline shows fixed literal times (`09:15`, `12:00`, `--:--`); the product-detail delivery estimate is static l10n text (#43). |
| **7. REVIEWS / RATINGS** |||||||||||
| 66 | Reviews | Product Reviews ([product_reviews_screen.dart](lib/features/brands/presentation/screens/product_reviews_screen.dart)) | Fetch product reviews | GET | — | Product ref, pagination | Per review: reviewer name, relative date, star rating, review body, helpful count, verified-purchase flag | No | MISSING | `_reviews` is a `const` 2-item list ([product_reviews_screen.dart:49](lib/features/brands/presentation/screens/product_reviews_screen.dart)). The `ReviewItem` model carries **separate `Ar`/`En` fields per review** — a bilingual content model the backend must account for. |
| 67 | Reviews | Product Reviews | Fetch rating summary + distribution | GET | — | Product ref | Average rating, total count, per-star breakdown | No | MISSING | `totalRatingsCount = 85` and `ratingsDistribution` hardcoded at [product_reviews_screen.dart:96](lib/features/brands/presentation/screens/product_reviews_screen.dart). |
| 68 | Reviews | Write Review ([write_review_screen.dart](lib/features/brands/presentation/screens/write_review_screen.dart)) | Submit a product review | POST | — | Product ref, star rating (`_selectedRating`, 1–5, defaults to 2), comment text (`_commentController`) | Created review | Yes | MISSING | Submit ([write_review_screen.dart:272](lib/features/brands/presentation/screens/write_review_screen.dart)) is `// Submit logic and go back` followed by `context.pop()`. Neither the rating nor the comment is read. |
| 69 | Reviews | Product Reviews | Mark a review as helpful | POST | — | Review ref | Updated helpful count | Yes | MISSING | Helpful button is `onTap: () {}` at [product_reviews_screen.dart:492](lib/features/brands/presentation/screens/product_reviews_screen.dart). |
| **8. REELS / SOCIAL** |||||||||||
| 70 | Reels | Reels ([reels_screen.dart](lib/features/reels/presentation/screens/reels_screen.dart)) | Fetch the reels feed | GET | — | Pagination | Per reel: video URL, brand name, brand avatar, description, likes count, linked product (name, price, image) | No | MISSING | 6 reels built in `initState` ([reels_screen.dart:70](lib/features/reels/presentation/screens/reels_screen.dart)); **every one uses the same placeholder video URL `https://lorem.video/720p`**. `likesCount` is a pre-formatted display string (`'2.4K'`), not a number. |
| 71 | Reels | Reels | Like a reel | POST | — | Reel ref | Updated like count + like state | Yes | MISSING | `onTap: () {}` at [reels_screen.dart:542](lib/features/reels/presentation/screens/reels_screen.dart). There is no liked/unliked state in `ReelsState`. |
| 72 | Reels | Reels | Save / bookmark a reel | POST | — | Reel ref | Updated saved state | Yes | MISSING | `onTap: () {}` at [reels_screen.dart:549](lib/features/reels/presentation/screens/reels_screen.dart). |
| 73 | Reels | Reels | Share a reel (shareable link) | GET | — | Reel ref | Share URL | No | MISSING | `onTap: () {}` at [reels_screen.dart:556](lib/features/reels/presentation/screens/reels_screen.dart) — `share_plus` is a dependency but is not wired to this button. |
| 74 | Reels | Reels | Resolve reel → product link | GET | — | Reel ref | Product ref | No | MISSING | The "go to product" control navigates using the reel's local literal product fields; no lookup occurs. |
| **9. USER ACCOUNT** |||||||||||
| 75 | Account | Profile ([profile_screen.dart](lib/features/profile/presentation/screens/profile_screen.dart)) | Fetch user profile | GET | — | — | Display name, email, avatar image | Yes | MISSING | Hardcoded: name `'سارة عبد العزيز'` / `'Sara Abdulaziz'`, email `sara.abdulaziz@example.com`, avatar an Unsplash URL ([profile_screen.dart:43-56](lib/features/profile/presentation/screens/profile_screen.dart)). |
| 76 | Account | Profile | Fetch loyalty membership + points | GET | — | — | Tier label, points balance, progress toward next tier | Yes | MISSING | Hardcoded: "Bronze Membership", `520` points, and a fixed `widthFactor: 0.52` progress bar with the code comment `// Progress Fill (520 / 1000 = 52%)`. |
| 77 | Account | — | Update user profile | PUT | — | — | — | Yes | MISSING | **No UI entry point exists in the current build** — the account-management menu tile is commented out at [profile_screen.dart:502-506](lib/features/profile/presentation/screens/profile_screen.dart). No edit-profile screen or route exists. |
| 78 | Account | Language Selection ([language_selection_screen.dart](lib/features/onboarding/presentation/screens/language_selection_screen.dart)) / Profile | Persist user preferences (language, dark mode) server-side | PUT | — | Locale (`ar`/`en`), dark-mode flag | Confirmation | Yes | MISSING | Both are **device-local only**: locale via `localeNotifier`, dark mode via `SecureStorage.putDarkMode`. Preferences do not follow the account across devices. |
| 79 | Addresses | Addresses ([address_screen.dart](lib/features/address/presentation/screens/address_screen.dart)) | Fetch saved addresses | GET | — | — | Per address: title, line 1, line 2, phone — each in Arabic **and** English | Yes | MISSING | `AddressNotifier.build()` returns **2 hardcoded seed addresses** (`'seed-1'`, `'seed-2'`) ([address_provider.dart](lib/features/address/providers/address_provider.dart)). In-memory only — all edits are lost on restart. |
| 80 | Addresses | Add Address ([add_edit_address_screen.dart](lib/features/address/presentation/screens/add_edit_address_screen.dart)) | Create an address | POST | — | Name, phone, address line 1, city/area | Created address (with server id) | Yes | MISSING | `_onSave()` generates a **client-side id from `DateTime.now().microsecondsSinceEpoch`** ([add_edit_address_screen.dart:70](lib/features/address/presentation/screens/add_edit_address_screen.dart)). Note: the form has 4 fields but the model has 7 — the single entered name/line is written to **both** the `Ar` and `En` variants. |
| 81 | Addresses | Edit Address | Update an address | PUT | — | Address id + the 4 fields above | Updated address | Yes | MISSING | `updateAddress()` local only. |
| 82 | Addresses | Addresses | Delete an address | DELETE | — | Address id | Confirmation | Yes | MISSING | `removeAddress()` at [address_screen.dart:215](lib/features/address/presentation/screens/address_screen.dart) — local, and **without a confirmation dialog**. |
| 83 | Addresses | Addresses | Set a default address | PUT | — | — | — | Yes | MISSING | **No default-address concept exists** in the `Address` model or UI. |
| 84 | Favorites | Favorites ([favorites_screen.dart](lib/features/favorites/presentation/screens/favorites_screen.dart)) | Fetch favorite products | GET | — | — | Product list: title, image, price, rating | Yes | MISSING | Persisted **device-locally** to `FlutterSecureStorage` under key `'favorite_products'` ([favorites_provider.dart](lib/features/favorites/providers/favorites_provider.dart)). Never synced; not shared across devices. Equality is by **title only** (`operator ==` compares `title`), so distinct products sharing a title collide. |
| 85 | Favorites | Product Detail / Favorites | Toggle a product favorite | POST/DELETE | — | Product ref | Updated favorite state | Yes | MISSING | `FavoritesNotifier.toggle()` writes to local secure storage only. |
| 86 | Wishlists | Favorites (Wishlists tab) | Fetch named wishlists | GET | — | — | Per list: title, item count, preview images, "added by" name, "added by" avatar, products | Yes | MISSING | 2 hardcoded lists ("Eid Gifts" count 8, "Summer Outfits" count 4) at [favorites_screen.dart:49](lib/features/favorites/presentation/screens/favorites_screen.dart). The `addedByName`/`avatarUrl` fields imply **shared/collaborative lists**, which requires a sharing model on the backend. |
| 87 | Wishlists | Favorites | Create a wishlist | POST | — | — | Created list | Yes | MISSING | The "Add Wishlist" button is `onPressed: () {}` at [favorites_screen.dart:188](lib/features/favorites/presentation/screens/favorites_screen.dart) — no name-entry dialog exists. |
| 88 | Wishlists | Favorites | Generate a wishlist share link | GET | — | Wishlist ref | Share URL | Yes | MISSING | The link is **fabricated client-side**: `'https://sfa.sa/wishlist/${wishlist['title'].hashCode}'` ([favorites_screen.dart:439](lib/features/favorites/presentation/screens/favorites_screen.dart)), copied to clipboard and passed to `share_plus`. A real, resolvable share URL requires a backend. |
| 89 | Wishlists | Wishlist Detail ([wishlist_detail_screen.dart](lib/features/favorites/presentation/screens/wishlist_detail_screen.dart)) | Fetch / modify wishlist contents | GET / DELETE | — | Wishlist ref, product ref | Product list | Yes | MISSING | Products arrive via `state.extra`; removal is a local `setState(() => _products.remove(product))` at [wishlist_detail_screen.dart:184](lib/features/favorites/presentation/screens/wishlist_detail_screen.dart) and is not persisted even locally. |
| 90 | Wallet | Wallet ([wallet_screen.dart](lib/features/wallet/presentation/screens/wallet_screen.dart)) / Profile | Fetch wallet balance | GET | — | — | Balance amount + currency | Yes | MISSING | Balance appears as a hardcoded literal in two places: `1478.00` on the profile card and a fixed value on the wallet screen. |
| 91 | Wallet | Wallet | Fetch recent transactions | GET | — | — | Per transaction: title (with order id), date, amount, credit/debit flag | Yes | MISSING | 4 mock entries at [wallet_screen.dart:26](lib/features/wallet/presentation/screens/wallet_screen.dart). |
| 92 | Wallet | All Transactions ([all_transactions_screen.dart](lib/features/wallet/presentation/screens/all_transactions_screen.dart)) | Fetch full transaction history | GET | — | Pagination | Same shape as #91 | Yes | MISSING | Separate mock list at [all_transactions_screen.dart:18](lib/features/wallet/presentation/screens/all_transactions_screen.dart). Note one entry hardcodes the date `'12 مايو 2026'`. |
| 93 | Wallet | Wallet / Profile | Withdraw / transfer balance to a bank account | POST | — | — | Payout record | Yes | MISSING | Both entry points are empty handlers with placeholder comments: `// Handle transfer logic` ([wallet_screen.dart:106](lib/features/wallet/presentation/screens/wallet_screen.dart)) and `// Handle withdrawal` ([profile_screen.dart:280](lib/features/profile/presentation/screens/profile_screen.dart)). **No bank-details form or field exists anywhere in the app**, so the request contract is not derivable. |
| 94 | Account | — | Delete account | DELETE | — | — | — | Yes | MISSING | **No account-deletion UI, route, or string exists** anywhere in the app. Flagged because app-store policy generally requires it for accounts created in-app. |
| 95 | AI Chat | AI Chat ([aichat_screen.dart](lib/features/profile/presentation/screens/aichat_screen.dart)) | Send a message / receive an assistant reply | POST | — | Message text (`_messageController`), conversation ref | Assistant reply | Yes | MISSING | The send button **clears the input and does nothing else** ([aichat_screen.dart:282](lib/features/profile/presentation/screens/aichat_screen.dart)). There is **no message list widget** on the screen — only a static intro, 3 canned suggestion chips, and the input bar. The conversation contract is not derivable from the code. |
| **10. NOTIFICATIONS** |||||||||||
| 96 | Notifications | App startup | Register a device push token | POST | — | Device token, platform | Confirmation | Yes | MISSING | **No push infrastructure exists at all** — no `firebase_messaging`, `firebase_core`, or any push dependency in `pubspec.yaml`, and no token retrieval or permission-request code. |
| 97 | Notifications | Notifications ([notifications_screen.dart](lib/features/notifications/presentation/screens/notifications_screen.dart)) | Fetch the notification list | GET | — | Pagination | Per item: icon/type, title, body, relative time | Yes | MISSING | 4 hardcoded `NotificationItemTile`s with inline bilingual literals ([notifications_screen.dart:209-272](lib/features/notifications/presentation/screens/notifications_screen.dart)). |
| 98 | Notifications | Notifications | Mark notifications read / fetch unread count | PUT / GET | — | — | — | Yes | MISSING | **No read/unread state exists** — `NotificationItemTile` has no read flag, there is no unread badge on the bottom-nav notifications tab, and no mark-read action. |
| 99 | Notifications | Notifications | Fetch promotional offers | GET | — | Locale | Per promo: badge text, title, image, target | No | MISSING | 2 hardcoded promo cards; the "view all" control is `onTap: () {}` at [notifications_screen.dart:121](lib/features/notifications/presentation/screens/notifications_screen.dart). |
| **11. FILE UPLOADS** |||||||||||
| 100 | Uploads | — | Any client→server file upload | — | — | — | — | — | — | **No upload is required by the current application.** There is no `image_picker`, `file_picker`, or camera dependency in `pubspec.yaml`, and no upload UI anywhere: the profile avatar is a fixed `NetworkImage` with no change control (#75), the write-review screen has no photo attachment (#68), and there is no reel/video creation flow. All images in the app are **downloaded** (Unsplash URLs via `cached_network_image`). |
| **12. REALTIME** |||||||||||
| 101 | Realtime | — | WebSocket / socket.io / SSE connection | — | — | — | — | — | — | **No realtime transport is used by the application.** No `web_socket_channel`, `socket_io_client`, SSE, or Firebase dependency; no `WebSocket` reference anywhere in `lib/`. No screen subscribes to or consumes push-style events. Every screen that could plausibly want realtime (order tracking, reels, notifications, AI chat) renders static data. **0 realtime APIs required by the current code.** |

---

## Summary

| Metric | Count |
|---|---|
| **Total APIs required** | **99** |
| Existing (`EXISTING`) | **0** |
| Partial (`PARTIAL`) | **0** |
| Missing (`MISSING`) | **96** |
| Unknown (`UNKNOWN`) | **3** (#7 refresh token, #27 sorting, #64 live driver location) |
| WebSocket / realtime APIs | **0** |

Numbered rows #1–#99 are the required APIs (96 `MISSING` + 3 `UNKNOWN` = 99). Rows #100 (file uploads) and #101 (realtime) document the **absence of a requirement** and are excluded from the total. The three `UNKNOWN` rows are #7 (refresh token), #27 (sorting), and #64 (live driver location).

### By area

| Area | APIs required | All missing? |
|---|---|---|
| 1. Authentication | 11 | Yes (10 MISSING, 1 UNKNOWN) |
| 2. Home / Discovery | 16 | Yes (15 MISSING, 1 UNKNOWN) |
| 3. Cart / Checkout | 16 | Yes |
| 4. Payments | 5 | Yes |
| 5. Orders | 14 | Yes |
| 6. Delivery / Tracking | 3 | Yes (2 MISSING, 1 UNKNOWN) |
| 7. Reviews / Ratings | 4 | Yes |
| 8. Reels / Social | 5 | Yes |
| 9. User Account | 21 | Yes |
| 10. Notifications | 4 | Yes |
| 11. File uploads | 0 | n/a — none required |
| 12. Realtime | 0 | n/a — none required |

---

## Cross-cutting observations

These are factual observations about the existing code that affect every endpoint above. No code was modified.

1. **No identifiers exist in the app's data model.** Products, brands, reels, reviews, cart lines, and wishlists are all identified by **display strings**, not ids:
   - `productDetailKey()` composes a key from `'$name::$imageUrl'` because `ProductDetailArgs` carries no id.
   - `CartItem.keyFor()` builds `'$title|$color|$size'`.
   - `FavoriteProduct.operator ==` compares **title only**.
   - `/brand-detail` receives a brand *name string* via `state.extra`.

   Every list and detail endpoint will need to introduce stable ids, and the corresponding Flutter models will need id fields added.

2. **Prices are formatted display strings, not numbers.** `Product.price` and `CartItem.price` are strings like `"1,250 SAR"` / `"1,250 ر.س."`. `cartSubtotal()` recovers a number by stripping non-digits with a regex. API responses should carry numeric amounts plus a currency code.

3. **Content is bilingual at the record level.** `Address` and `ReviewItem` carry parallel `Ar`/`En` fields, and much screen content resolves through l10n keys (brand names are l10n keys such as `brandJuba`, not data). The API contract must settle whether localization is server-side (locale-negotiated responses) or per-record bilingual fields.

4. **The auth header in `BaseClients` is inconsistent and unused.** `get()` and `post()` have their `Authorization` header **commented out**; `put()` sends `'Authorization': 'bearearToken ${SecureStorage.getTokken()}'` — note `bearearToken` rather than the conventional `Bearer` scheme. `login()` sends no auth header. Since `putTokken()` is never called, `getTokken()` always returns `''`.

5. **Base URLs are plain HTTP to a bare IP.** `http://58.27.160.180:5000/yumas/` and `http://58.27.160.180:5000/admin/` — unencrypted, and the `/admin/` path suggests a back-office surface. Both need review before the mobile client points at them. iOS ATS and Android cleartext policy will block plain HTTP by default.

6. **`/order-tracking` takes no order id.** Unlike `/refund-request/:id` and `/refund-status/:id`, the tracking route has no parameter and the screen hardcodes `#84739201`. Routing must change before a real tracking endpoint can be called.

7. **Two screens display the same data from different mock sources**, which will diverge once wired: featured products (home section vs. standalone screen) and wallet transactions (wallet screen vs. all-transactions screen).

8. **External services already in use that are *not* this backend:** Unsplash (all product/brand/avatar imagery), OpenStreetMap tiles (the static checkout map), and `https://lorem.video/720p` (every reel video). All three are placeholders that a real API must replace with owned media URLs.
