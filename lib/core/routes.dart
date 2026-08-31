import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sfa/core/widgets/primary_app_bar.dart';

import 'localization/app_localizations.dart';
import 'models/product_detail_args.dart';
import 'widgets/app_bottom_nav_bar.dart';
import 'widgets/sub_page_app_bar.dart';

import '../features/splash/presentation/screens/splash_screen.dart';
import '../features/onboarding/presentation/screens/language_selection_screen.dart';
import '../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/signup_screen.dart';
import '../features/auth/presentation/screens/otp_screen.dart';
import '../features/auth/presentation/screens/success_screen.dart';
import '../features/dashboard/presentation/screens/app_shell.dart';
import '../features/home/presentation/screens/home_screen.dart';
import '../features/brands/presentation/screens/brands_screen.dart';
import '../features/reels/presentation/screens/reels_screen.dart';
import '../features/profile/presentation/screens/profile_screen.dart';
import '../features/notifications/presentation/screens/notifications_screen.dart';
import '../features/cart/presentation/screens/cart_screen.dart';
import '../features/brands/presentation/screens/brand_detail_screen.dart';
import '../features/brands/presentation/screens/product_detail_screen.dart';
import '../features/favorites/presentation/screens/favorites_screen.dart';
import '../features/orders/presentation/screens/order_tracking_screen.dart';
import '../features/orders/presentation/screens/previous_orders_screen.dart';
import '../features/checkout/presentation/screens/checkout_screen.dart';
import '../features/checkout/presentation/screens/payment_success_screen.dart';
import '../features/profile/presentation/screens/aichat_screen.dart';
import '../features/home/presentation/screens/featured_products_screen.dart';
import '../features/orders/presentation/screens/refund_request_screen.dart';
import '../features/orders/presentation/screens/refund_status_screen.dart';
import '../features/wallet/presentation/screens/wallet_screen.dart';
import '../features/wallet/presentation/screens/all_transactions_screen.dart';
import '../features/orders/providers/orders_provider.dart';
import '../features/address/models/address.dart';
import '../features/address/presentation/screens/address_screen.dart';
import '../features/address/presentation/screens/add_edit_address_screen.dart';
import '../features/brands/presentation/screens/product_reviews_screen.dart';
import '../features/brands/presentation/screens/write_review_screen.dart';
import '../features/favorites/presentation/screens/wishlist_detail_screen.dart';
import '../features/favorites/models/wishlist_product.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/splash',
  routes: [
    GoRoute(path: '/splash', builder: (context, state) => const SplashScreen()),
    GoRoute(
      path: '/language',
      builder: (context, state) => const LanguageSelectionScreen(),
    ),
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(path: '/signup', builder: (context, state) => const SignUpScreen()),
    GoRoute(path: '/otp', builder: (context, state) => const OtpScreen()),
    GoRoute(
      path: '/success',
      builder: (context, state) => const SuccessScreen(),
    ),

    // Legacy deep link — the 5 tabs now live at their own paths below.
    GoRoute(path: '/dashboard', redirect: (context, state) => '/home'),

    // ── Bottom-nav tab shell ────────────────────────────────────────────
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          AppShell(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/home',
              builder: (context, state) => const HomeScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/brands',
              builder: (context, state) => const BrandsScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/reels',
              builder: (context, state) => const ReelsScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/profile',
              builder: (context, state) => const ProfileScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/notifications',
              builder: (context, state) => const NotificationsScreen(),
            ),
          ],
        ),
      ],
    ),

    // ── Everything else: plain pushed routes on the root navigator, with
    // the bottom nav bar reproduced so it stays visible/highlighted ──────
    GoRoute(
      path: '/cart',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => Scaffold(
        appBar: SubPageAppBar(
          title: AppLocalizations.of(context).translate('cartTitle'),
        ),
        body: const CartScreen(),
        bottomNavigationBar: const AppBottomNavBar(),
      ),
    ),
    GoRoute(
      path: '/favorites',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => Scaffold(
        appBar: PrimaryAppBar(title: 'SFA', showBackButton: true),
        body: const FavoritesScreen(),
        bottomNavigationBar: const AppBottomNavBar(),
      ),
    ),
    GoRoute(
      path: '/brand-detail',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final brandName = state.extra as String? ?? 'brandJuba';
        return Scaffold(
          body: BrandDetailScreen(brandName: brandName),
          bottomNavigationBar: const AppBottomNavBar(),
        );
      },
    ),
    GoRoute(
      path: '/product-detail',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final args = state.extra as ProductDetailArgs?;
        return Scaffold(
          body: ProductDetailScreen(args: args),
          bottomNavigationBar: const AppBottomNavBar(),
        );
      },
    ),
    GoRoute(
      path: '/checkout',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => Scaffold(
        body: const CheckoutScreen(),
        bottomNavigationBar: const AppBottomNavBar(overrideIndex: 3),
      ),
    ),
    GoRoute(
      path: '/payment-success',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const PaymentSuccessScreen(),
    ),
    GoRoute(
      path: '/order-tracking',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => Scaffold(
        body: const OrderTrackingScreen(),
        bottomNavigationBar: const AppBottomNavBar(overrideIndex: 3),
      ),
    ),
    GoRoute(
      path: '/previous-orders',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => Scaffold(
        body: const PreviousOrdersScreen(),
        bottomNavigationBar: const AppBottomNavBar(overrideIndex: 3),
      ),
    ),
    GoRoute(
      path: '/addresses',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => Scaffold(
        appBar: SubPageAppBar(
          title: AppLocalizations.of(context).translate('drawerMyAddresses'),
        ),
        body: const AddressScreen(),
        bottomNavigationBar: const AppBottomNavBar(overrideIndex: 3),
      ),
    ),
    GoRoute(
      path: '/addresses/add',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => Scaffold(
        appBar: SubPageAppBar(
          title: AppLocalizations.of(context).translate('addAddress'),
        ),
        body: const AddEditAddressScreen(),
        bottomNavigationBar: const AppBottomNavBar(overrideIndex: 3),
      ),
    ),
    GoRoute(
      path: '/addresses/edit',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final address = state.extra as Address?;
        return Scaffold(
          appBar: SubPageAppBar(
            title: AppLocalizations.of(context).translate('editAddressTitle'),
          ),
          body: AddEditAddressScreen(address: address),
          bottomNavigationBar: const AppBottomNavBar(overrideIndex: 3),
        );
      },
    ),
    GoRoute(
      path: '/wishlist-detail',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>;
        final title = extra['title'] as String;
        return Scaffold(
          appBar: SubPageAppBar(title: title, fontSize: 19),
          body: WishlistDetailScreen(
            title: title,
            addedByName: extra['addedByName'] as String,
            avatarUrl: extra['avatarUrl'] as String,
            products: extra['products'] as List<WishlistProduct>,
          ),
          bottomNavigationBar: const AppBottomNavBar(),
        );
      },
    ),
    GoRoute(
      path: '/refund-request/:id',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final orderId = state.pathParameters['id'] ?? '84739201';
        return Scaffold(
          // Fresh `ordersProvider` state per visit — mirrors the old
          // `BlocProvider(create: (context) => OrdersBloc())` scoping.
          body: ProviderScope(
            overrides: [ordersProvider],
            child: RefundRequestScreen(orderId: orderId),
          ),
          bottomNavigationBar: const AppBottomNavBar(overrideIndex: 3),
        );
      },
    ),
    GoRoute(
      path: '/refund-status/:id',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final orderId = state.pathParameters['id'] ?? '84739201';
        return Scaffold(
          body: ProviderScope(
            overrides: [ordersProvider],
            child: RefundStatusScreen(orderId: orderId),
          ),
          bottomNavigationBar: const AppBottomNavBar(overrideIndex: 3),
        );
      },
    ),
    GoRoute(
      path: '/ai-chat',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const AIChatScreen(),
    ),
    GoRoute(
      path: '/featured-products',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const FeaturedProductsScreen(),
    ),
    GoRoute(
      path: '/wallet',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => Scaffold(
        appBar: SubPageAppBar(
          title: AppLocalizations.of(context).translate('refundWallet'),
        ),
        body: const WalletScreen(),
        bottomNavigationBar: const AppBottomNavBar(overrideIndex: 3),
      ),
    ),
    GoRoute(
      path: '/all-transactions',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => Scaffold(
        appBar: SubPageAppBar(
          title: AppLocalizations.of(context).translate('allTransactionsTitle'),
        ),
        body: const AllTransactionsScreen(),
        bottomNavigationBar: const AppBottomNavBar(overrideIndex: 3),
      ),
    ),
    GoRoute(
      path: '/product-reviews',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final args = state.extra as ProductDetailArgs?;
        return Scaffold(
          appBar: SubPageAppBar(
            title: AppLocalizations.of(context).translate('ratingsAndReviews'),
          ),
          body: ProductReviewsScreen(args: args),
          bottomNavigationBar: const AppBottomNavBar(overrideIndex: 1),
        );
      },
    ),
    GoRoute(
      path: '/write-review',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final args = state.extra as ProductDetailArgs?;
        return Scaffold(
          appBar: SubPageAppBar(
            title: AppLocalizations.of(context).translate('addReview'),
          ),
          body: WriteReviewScreen(args: args),
          bottomNavigationBar: const AppBottomNavBar(overrideIndex: 1),
        );
      },
    ),
  ],
);
