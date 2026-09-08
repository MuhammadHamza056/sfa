import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

/// Helpers that stop the shared app bars from pushing a route the user is
/// already looking at — tapping the cart icon while on `/cart` (or the heart
/// while on `/favorites`) would otherwise stack a second identical page.
extension NavGuard on BuildContext {
  /// Location of the go_router page this widget is built inside, e.g. `/cart`.
  ///
  /// Deliberately *not* `GoRouter.of(context).routerDelegate
  /// .currentConfiguration.uri`: `/cart` and `/favorites` are pushed on the
  /// root navigator on top of the bottom-nav [StatefulShellRoute], and an
  /// imperative push only appends an `ImperativeRouteMatch` to the match list
  /// while `RouteMatchList.copyWith` keeps the *base* uri — so that getter
  /// still reports `/home` while the cart page is on screen.
  /// [GoRouterState.of] instead resolves the page enclosing this widget
  /// (`ImperativeRouteMatch.buildState` uses the pushed match list).
  ///
  /// Null when the widget isn't under a route at all — defensive only; the
  /// shared app bars always are.
  String? get currentPageLocation {
    try {
      return GoRouterState.of(this).uri.path;
    } catch (_) {
      return null;
    }
  }

  bool isCurrentPage(String path) => currentPageLocation == path;
}

/// Runs an app bar icon's navigation, unless [path] is the page the icon is
/// already sitting on. [onTap] is the caller-supplied override (it is assumed
/// to lead to [path]); when null the icon falls back to pushing [path].
void handleAppBarNavTap(
  BuildContext context,
  String path,
  VoidCallback? onTap,
) {
  if (context.isCurrentPage(path)) return;
  if (onTap != null) {
    onTap();
    return;
  }
  context.push(path);
}
