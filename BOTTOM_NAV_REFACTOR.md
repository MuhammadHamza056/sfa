# Bottom-Nav Shell Refactor

This document explains the refactor that replaced the old `DashboardScreen`
mega-widget with a proper go_router `StatefulShellRoute` shell plus Riverpod
for tab-highlight state, and moved every non-tab screen onto the Navigator.

## Motivation

Before this change, almost every screen in the app — Cart, Brand Detail,
Product Detail, Wallet, Addresses, Checkout, Orders, Refunds, Reviews,
Wishlist Detail — was rendered *inside* `DashboardScreen`, either as a fake
"tab" in an `IndexedStack` (`_pages[5..8]`) or via a `body:`/`customIndex:`
override. Tab switching, drawer state, and even per-screen data (selected
brand/product) all lived in one `DashboardBloc`. This made the widget tree
one giant shared Scaffold, and meant unrelated screens had to read/write a
single global bloc just to know which product they were showing.

The goal: a real go_router shell for the 5 bottom-nav tabs (Home, Brands,
Reels, Profile, Notifications), with everything else handled by normal
Navigator pushes — while keeping the existing visual behavior (bottom nav
bar staying visible and correctly highlighted on secondary screens).

## New architecture

### 1. The tab shell (`StatefulShellRoute.indexedStack`)

`lib/core/routes.dart` now declares a `StatefulShellRoute.indexedStack` with
5 branches, each a real go_router `Navigator` with its own path:

| Branch | Path            | Screen               |
|--------|-----------------|-----------------------|
| 0      | `/home`         | `HomeScreen`          |
| 1      | `/brands`       | `BrandsScreen`        |
| 2      | `/reels`        | `ReelsScreen`         |
| 3      | `/profile`      | `ProfileScreen`       |
| 4      | `/notifications`| `NotificationsScreen` |

The shell chrome (drawer, scrim, bottom nav bar) lives in
`lib/features/dashboard/presentation/screens/app_shell.dart` — `AppShell`,
a `ConsumerStatefulWidget` that wraps `StatefulNavigationShell`. This
replaces `DashboardScreen` and `AppDrawer` now lives in this same file
(previously in `dashboard_screen.dart`).

`/dashboard` (the old entry path) is kept as a redirect to `/home`, so
existing `context.go('/dashboard')` call sites (login, signup success,
onboarding, order tracking) didn't need to change.

### 2. Riverpod for tab-highlight state

`lib/core/providers/nav_providers.dart`:

- `highlightedTabIndexProvider` (`StateProvider<int>`) — which of the 5 tabs
  should read as "active" in the bottom nav bar. The shell keeps this in
  sync with `navigationShell.currentIndex` on every rebuild. Screens pushed
  *on top* of the shell (cart, brand detail, wallet, …) never touch it, so
  it keeps showing whichever tab the user came from — this is a direct
  replacement for the old `DashboardState.previousIndex`.
- `drawerOpenProvider` (`StateProvider<bool>`) — replaces
  `DashboardState.drawerOpen`. Any widget can open/close the drawer from
  anywhere (Riverpod providers aren't scoped to a subtree like the old
  `BlocProvider` was), the shell just listens and drives the slide/scrim
  animation.

This is intentionally minimal — `StateProvider` for two flags, no custom
`Notifier` classes, since that's all the state actually is.

### 3. Shared widgets for the "bottom nav stays visible" behavior

Per your call to keep the bottom nav bar visible (with the right tab lit)
on secondary screens like Wallet/Addresses/Checkout, two shared widgets
reproduce what `DashboardScreen` used to draw around `body:`:

- **`lib/core/widgets/app_bottom_nav_bar.dart`** — `AppBottomNavBar`. Used
  both by the shell itself and by every pushed route's own `Scaffold`.
  - `overrideIndex` — forces a specific tab lit, replacing the old
    `customIndex` (e.g. Wallet always passes `overrideIndex: 3`).
  - No `overrideIndex` — reads `highlightedTabIndexProvider`, replacing the
    old dynamic `previousIndex` fallback (Cart/Favorites/Brand
    Detail/Product Detail/Wishlist Detail all use this).
  - `isReelStyle` — the transparent/white-on-black treatment, now only set
    `true` by the shell itself while the Reels branch is actually visible.
  - Tapping an item defaults to `context.go('/home' | '/brands' | ...)`,
    which also clears whatever was pushed on top — same effect as the old
    `context.go('/dashboard?tab=$index')`.
- **`lib/core/widgets/sub_page_app_bar.dart`** — `SubPageAppBar`. The
  minimal title + bag/heart/search/back bar `DashboardScreen` used to draw
  for screens that don't own a full `Scaffold`/`AppBar` themselves (Wallet,
  Addresses, Add/Edit Address, Product Reviews, Write Review, Wishlist
  Detail). Bag → `/cart`, heart → `/favorites`, back → `context.pop()`.

Screens that already had their own internal `Scaffold`/`AppBar` (Checkout,
Order Tracking, Previous Orders, Refund Request/Status) keep that as-is;
`routes.dart` just wraps them in an outer `Scaffold(bottomNavigationBar:
AppBottomNavBar(overrideIndex: ...))`, same nesting pattern the old
`DashboardScreen` used.

### 4. Passing data without a global bloc

`lib/core/models/product_detail_args.dart` — `ProductDetailArgs` (name,
imageUrl, price, rating, brandNameKey). Replaces the
`selectedProductName`/`selectedProductImage`/… fields that used to live on
`DashboardState`. Passed via `extra:` on `context.push`:

```
Brands grid → context.push('/brand-detail', extra: brand.name)
Brand detail product tap → context.push('/product-detail', extra: ProductDetailArgs(...))
Product detail → "reviews" tap → context.push('/product-reviews', extra: args)
Product reviews → "write review" tap → context.push('/write-review', extra: widget.args)
```

`BrandDetailScreen` now takes `brandName` as a required constructor param
instead of reading `DashboardState.selectedBrandName`. `ProductDetailScreen`,
`ProductReviewsScreen`, `WriteReviewScreen` take an optional
`ProductDetailArgs? args` (falls back to the same mock defaults the old
code used when `null`).

### 5. `FavoritesBloc` hoisted to the app root

Since `BrandDetailScreen`/`ProductDetailScreen` are no longer inside
`DashboardScreen`'s `MultiBlocProvider`, but still need to read
`FavoritesBloc` (for the heart-fill icon state), `FavoritesBloc` moved up
to `lib/main.dart`, wrapping the whole `MaterialApp.router` — available to
every route, shell branch or pushed, instead of being scoped under the old
dashboard tree.

`main.dart` also now wraps everything in `ProviderScope` for Riverpod.

## Files added

- `lib/core/providers/nav_providers.dart`
- `lib/core/widgets/app_bottom_nav_bar.dart`
- `lib/core/widgets/sub_page_app_bar.dart`
- `lib/core/models/product_detail_args.dart`
- `lib/features/dashboard/presentation/screens/app_shell.dart`

## Files deleted

- `lib/features/dashboard/presentation/screens/dashboard_screen.dart`
- `lib/features/dashboard/bloc/dashboard_bloc.dart`
- `lib/features/dashboard/bloc/dashboard_event.dart`
- `lib/features/dashboard/bloc/dashboard_state.dart`

## Files modified

- **`pubspec.yaml`** — added `flutter_riverpod: ^2.6.1`.
- **`lib/main.dart`** — wraps app in `ProviderScope`; hoists `FavoritesBloc`
  to the root.
- **`lib/core/routes.dart`** — full rewrite: `StatefulShellRoute.indexedStack`
  for the 5 tabs, `/dashboard` → `/home` redirect, every other screen as a
  plain `GoRoute` (root navigator) wrapped with `AppBottomNavBar` /
  `SubPageAppBar` as described above.
- **`lib/features/brands/presentation/screens/brand_detail_screen.dart`** —
  takes `brandName` param; bag/heart icons push `/cart`/`/favorites`; back
  icon calls `context.pop()`; product tap pushes `/product-detail` with
  `ProductDetailArgs`.
- **`lib/features/brands/presentation/screens/product_detail_screen.dart`** —
  takes `ProductDetailArgs? args`; same icon/back changes; related-product
  tap now *pushes* a new `/product-detail` instance instead of mutating
  shared bloc state in place; "reviews" tap forwards `args`.
- **`lib/features/brands/presentation/screens/product_reviews_screen.dart`**
  / **`write_review_screen.dart`** — take `ProductDetailArgs? args` instead
  of reading `DashboardBloc`; `product_reviews_screen.dart` forwards `args`
  when pushing `/write-review`.
- **`lib/features/brands/presentation/widgets/brands_grid.dart`** — brand
  tap pushes `/brand-detail` with the brand name instead of dispatching
  `SelectBrandEvent`.
- **`lib/features/brands/presentation/widgets/brands_header.dart`** —
  converted to `ConsumerWidget`; bag/heart push `/cart`/`/favorites`; menu
  sets `drawerOpenProvider`.
- **`lib/features/home/presentation/screens/home_screen.dart`** — converted
  to `ConsumerStatefulWidget`; same bag/heart/menu changes.
- **`lib/features/reels/presentation/screens/reels_screen.dart`** —
  converted to `ConsumerStatefulWidget`; the "is Reels tab active & drawer
  closed" check (used to decide whether to autoplay/pause video) now reads
  `highlightedTabIndexProvider`/`drawerOpenProvider` via `ref.listen`
  instead of a `BlocListener<DashboardBloc>`; bag icon pushes `/cart`; menu
  sets `drawerOpenProvider`; the 3 "go to product" taps push
  `/product-detail` with `ProductDetailArgs` instead of dispatching
  `SelectProductEvent`.
- **`lib/features/profile/presentation/screens/profile_screen.dart`** —
  "Favorites" menu tile pushes `/favorites` instead of dispatching
  `ChangeTabEvent(8)`.
- **`lib/features/orders/presentation/screens/previous_orders_screen.dart`**,
  **`refund_request_screen.dart`**, **`refund_status_screen.dart`** — the
  bag/heart "go to cart/favorites" links now go to `/cart`/`/favorites`
  directly instead of `/dashboard?tab=5` / `/dashboard?tab=8` (those fake
  tab indices no longer exist); `previous_orders_screen.dart`'s own
  drawer-preview dialog now imports `AppDrawer` from `app_shell.dart`
  instead of the deleted `dashboard_screen.dart`.

## Behavioral notes / things worth knowing

- **Cart, Favorites, Brand Detail, Product Detail, Wishlist Detail** show
  the bottom nav highlighting whichever real tab (Home/Brands/Reels/
  Profile/Notifications) the user was last on — exactly like the old
  `previousIndex` fallback, just via `highlightedTabIndexProvider` instead
  of bloc state.
- **Wallet, All Transactions, Addresses, Add/Edit Address, Checkout, Order
  Tracking, Previous Orders, Refund Request/Status, Product Reviews, Write
  Review** always force a fixed tab lit (`overrideIndex: 3` for
  account-related screens, `overrideIndex: 1` for review screens) — same
  as the old `customIndex`.
- Tapping a bottom-nav item while on any pushed screen calls
  `context.go('/home' | ...)`, which discards the pushed stack and lands
  back in the shell on that branch — matching the old behavior of
  `context.go('/dashboard?tab=$index')`.
- `ProductDetailScreen`'s related-products grid now genuinely **pushes** a
  new product detail screen (adds to the back stack) instead of mutating
  shared state on the same screen instance. This is arguably more correct
  (each product gets its own route/back entry) but is a small behavior
  change worth knowing about.

## Verification

- `flutter analyze` — clean (no errors; only pre-existing style-level
  info/warnings unrelated to this refactor).
- Launched on the iOS Simulator (iPhone 16 Plus) — app boots through
  splash/language selection with no runtime crash.
- **Not automated**: tapping through all 5 tabs and the cart/detail push
  flows live in the simulator — no `idb`/`cliclick` and no Accessibility
  permission for AppleScript-driven taps were available in this
  environment. This was instead verified by careful code review against
  the original `DashboardScreen` logic (see the routing table and
  `overrideIndex`/`highlightedTabIndexProvider` mapping above).
