import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sfa/core/providers/nav_providers.dart';
import 'package:sfa/core/widgets/cart_icon_button.dart';
import 'package:sfa/utils/assets_constants.dart';

/// Shared floating "SFA" bar used on root tab screens that scroll behind
/// it: cart + favorites on the left, the centered "SFA" logo, and search +
/// a trailing icon on the right, all white so they read over hero imagery.
///
/// Meant to sit inside a [Stack] as a [Positioned] overlay (not a
/// Scaffold.appBar — it has no fixed opaque background of its own).
/// Pass [scrollOffset] to fade in a solid backdrop once the content behind
/// it has scrolled past [fadeDistance] logical pixels; leave it at 0 (the
/// default) for screens that don't animate the backdrop.
///
/// The trailing icon is the drawer [AssetsConstants.menu] by default; set
/// [showBackButton] to true to pop the route instead, for screens pushed
/// on top of another screen.
class FloatingTopBar extends ConsumerWidget {
  final double scrollOffset;
  final double fadeDistance;
  final bool showBackButton;
  final String cartIcon;
  final String heartIcon;
  final VoidCallback? onCartTap;
  final VoidCallback? onHeartTap;
  final VoidCallback? onSearchTap;
  final VoidCallback? onBackTap;
  final VoidCallback? onMenuTap;

  const FloatingTopBar({
    super.key,
    this.scrollOffset = 0,
    this.fadeDistance = 180,
    this.showBackButton = false,
    this.cartIcon = AssetsConstants.shoppingBag,
    this.heartIcon = AssetsConstants.heart,
    this.onCartTap,
    this.onHeartTap,
    this.onSearchTap,
    this.onBackTap,
    this.onMenuTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fadeT = (scrollOffset / fadeDistance).clamp(0.0, 1.0);
    final background = Color.lerp(
      Colors.transparent,
      Colors.black.withValues(alpha: 0.92),
      fadeT,
    )!;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      color: background,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 10),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // SFA Title (Centered)
                SvgPicture.asset(AssetsConstants.sfaWhite),
                // Text(
                //   'SFA',
                //   style: GoogleFonts.cairo(
                //     fontSize: 26,
                //     fontWeight: FontWeight.bold,
                //     letterSpacing: 2.0,
                //     color: Colors.white,
                //   ),
                // ),
                // Navigation Icons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Left Side: Shopping Bag & Heart
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CartIconButton(
                          icon: cartIcon,
                          color: Colors.white,
                          onTap: onCartTap,
                          padding: const EdgeInsets.all(8.0),
                        ),
                        _IconBtn(
                          icon: heartIcon,
                          onTap: onHeartTap ?? () => context.push('/favorites'),
                        ),
                      ],
                    ),
                    // Right Side: Search & Menu/Back
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // _IconBtn(
                        //   icon: AssetsConstants.search,
                        //   onTap: onSearchTap ?? () {},
                        // ),
                        _IconBtn(
                          icon: showBackButton
                              ? AssetsConstants.back
                              : AssetsConstants.menu,
                          onTap: showBackButton
                              ? (onBackTap ?? () => context.pop())
                              : (onMenuTap ??
                                    () =>
                                        ref
                                                .read(
                                                  drawerOpenProvider.notifier,
                                                )
                                                .state =
                                            true),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _IconBtn extends StatelessWidget {
  final String icon;
  final VoidCallback onTap;

  const _IconBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SvgPicture.asset(
          icon,
          width: 22,
          colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
        ),
      ),
    );
  }
}
