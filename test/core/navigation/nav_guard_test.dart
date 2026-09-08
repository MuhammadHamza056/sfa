import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:sfa/core/navigation/nav_guard.dart';

/// Mirrors the real app: `/cart` and `/favorites` are pushed on the root
/// navigator on top of the bottom-nav [StatefulShellRoute].
GoRouter _buildRouter(GlobalKey<NavigatorState> rootKey) {
  Widget page(String label) => Scaffold(
    appBar: AppBar(
      leading: Builder(
        builder: (context) => IconButton(
          key: const Key('cartIcon'),
          icon: const Icon(Icons.shopping_bag),
          onPressed: () => handleAppBarNavTap(context, '/cart', null),
        ),
      ),
    ),
    body: Text(label),
  );

  return GoRouter(
    navigatorKey: rootKey,
    initialLocation: '/home',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => shell,
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(path: '/home', builder: (_, _) => page('home')),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/cart',
        parentNavigatorKey: rootKey,
        builder: (_, _) => page('cart'),
      ),
    ],
  );
}

void main() {
  testWidgets('cart icon pushes /cart from the shell, but not from /cart', (
    tester,
  ) async {
    final rootKey = GlobalKey<NavigatorState>();
    final router = _buildRouter(rootKey);
    addTearDown(router.dispose);

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    expect(find.text('home'), findsOneWidget);

    final depthOnHome =
        router.routerDelegate.currentConfiguration.matches.length;

    // From /home the icon navigates.
    await tester.tap(find.byKey(const Key('cartIcon')));
    await tester.pumpAndSettle();
    expect(find.text('cart'), findsOneWidget);

    final depthOnCart =
        router.routerDelegate.currentConfiguration.matches.length;
    expect(depthOnCart, greaterThan(depthOnHome));

    // The imperative push leaves the base location behind — this is exactly
    // why `currentConfiguration.uri` cannot be used for the guard.
    expect(router.routerDelegate.currentConfiguration.uri.path, '/home');

    // On /cart the same icon is inert: no extra page is stacked.
    await tester.tap(find.byKey(const Key('cartIcon')));
    await tester.pumpAndSettle();
    expect(
      router.routerDelegate.currentConfiguration.matches.length,
      depthOnCart,
    );
  });
}
