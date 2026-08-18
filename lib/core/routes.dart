import 'package:go_router/go_router.dart';
import '../features/splash/presentation/screens/splash_screen.dart';
import '../features/onboarding/presentation/screens/language_selection_screen.dart';
import '../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/signup_screen.dart';
import '../features/auth/presentation/screens/otp_screen.dart';
import '../features/auth/presentation/screens/success_screen.dart';
import '../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../features/cart/presentation/screens/cart_screen.dart';
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
import 'package:flutter_bloc/flutter_bloc.dart';
import '../features/orders/bloc/orders_bloc.dart';
import '../features/address/presentation/screens/address_screen.dart';
import '../features/address/presentation/screens/add_edit_address_screen.dart';
import '../features/brands/presentation/screens/product_reviews_screen.dart';
import '../features/brands/presentation/screens/write_review_screen.dart';
import '../features/favorites/presentation/screens/wishlist_detail_screen.dart';
import '../features/favorites/models/wishlist_product.dart';


final router = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(
      path: '/splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/language',
      builder: (context, state) => const LanguageSelectionScreen(),
    ),
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/signup',
      builder: (context, state) => const SignUpScreen(),
    ),
    GoRoute(
      path: '/otp',
      builder: (context, state) => const OtpScreen(),
    ),
    GoRoute(
      path: '/success',
      builder: (context, state) => const SuccessScreen(),
    ),
    GoRoute(
      path: '/dashboard',
      builder: (context, state) {
        final tabParam = state.uri.queryParameters['tab'];
        final initialTab = tabParam != null ? int.tryParse(tabParam) : null;
        final openDrawer = state.uri.queryParameters['drawer'] == 'true';
        return DashboardScreen(
          initialTab: initialTab,
          openDrawerOnStart: openDrawer,
        );
      },
    ),
    GoRoute(
      path: '/cart',
      builder: (context, state) => const CartScreen(),
    ),
    GoRoute(
      path: '/checkout',
      builder: (context, state) => const DashboardScreen(
        body: CheckoutScreen(),
        customIndex: 3,
      ),
    ),
    GoRoute(
      path: '/payment-success',
      builder: (context, state) => const PaymentSuccessScreen(),
    ),
    GoRoute(
      path: '/order-tracking',
      builder: (context, state) => const DashboardScreen(
        body: OrderTrackingScreen(),
        customIndex: 3,
      ),
    ),
    GoRoute(
      path: '/previous-orders',
      builder: (context, state) => DashboardScreen(
        body: BlocProvider(
          create: (context) => OrdersBloc(),
          child: const PreviousOrdersScreen(),
        ),
        customIndex: 3,
      ),
    ),
    GoRoute(
      path: '/addresses',
      builder: (context, state) => const DashboardScreen(
        body: AddressScreen(),
        customIndex: 3,
      ),
    ),
    GoRoute(
      path: '/addresses/add',
      builder: (context, state) => const DashboardScreen(
        body: AddEditAddressScreen(),
        customIndex: 3,
      ),
    ),
    GoRoute(
      path: '/addresses/edit',
      builder: (context, state) {
        final address = state.extra as Map<String, String>?;
        return DashboardScreen(
          body: AddEditAddressScreen(address: address),
          customIndex: 3,
        );
      },
    ),
    GoRoute(
      path: '/wishlist-detail',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>;
        return DashboardScreen(
          body: WishlistDetailScreen(
            title: extra['title'] as String,
            addedByName: extra['addedByName'] as String,
            avatarUrl: extra['avatarUrl'] as String,
            products: extra['products'] as List<WishlistProduct>,
          ),
        );
      },
    ),
    GoRoute(
      path: '/refund-request/:id',
      builder: (context, state) {
        final orderId = state.pathParameters['id'] ?? '84739201';
        return DashboardScreen(
          body: BlocProvider(
            create: (context) => OrdersBloc(),
            child: RefundRequestScreen(orderId: orderId),
          ),
          customIndex: 3,
        );
      },
    ),
    GoRoute(
      path: '/refund-status/:id',
      builder: (context, state) {
        final orderId = state.pathParameters['id'] ?? '84739201';
        return DashboardScreen(
          body: BlocProvider(
            create: (context) => OrdersBloc(),
            child: RefundStatusScreen(orderId: orderId),
          ),
          customIndex: 3,
        );
      },
    ),
    GoRoute(
      path: '/ai-chat',
      builder: (context, state) => const AIChatScreen(),
    ),
    GoRoute(
      path: '/featured-products',
      builder: (context, state) => const FeaturedProductsScreen(),
    ),
    GoRoute(
      path: '/wallet',
      builder: (context, state) => const DashboardScreen(
        body: WalletScreen(),
        initialTab: 3,
        customIndex: 3, // Shows bottom nav bar highlights "My Account" (index 3)
      ),
    ),
    GoRoute(
      path: '/all-transactions',
      builder: (context, state) => const DashboardScreen(
        body: AllTransactionsScreen(),
        initialTab: 3,
        customIndex: 3,
      ),
    ),
    GoRoute(
      path: '/product-reviews',
      builder: (context, state) => const DashboardScreen(
        body: ProductReviewsScreen(),
        customIndex: 1,
      ),
    ),
    GoRoute(
      path: '/write-review',
      builder: (context, state) => const DashboardScreen(
        body: WriteReviewScreen(),
        customIndex: 1,
      ),
    ),
  ],
);
