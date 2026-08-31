import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:sfa/core/localization/app_localizations.dart';
import 'package:sfa/core/providers/nav_providers.dart';
import 'package:sfa/core/theme/app_palette.dart';
import 'package:sfa/utils/app_style.dart';
import 'package:sfa/utils/assets_constants.dart';

const List<String> _shellBranchPaths = [
  '/home',
  '/brands',
  '/reels',
  '/profile',
  '/notifications',
];

/// The bottom navigation bar shared by the tab shell and by every screen
/// pushed on top of it (cart, brand/product detail, wallet, addresses, ...),
/// so the nav bar stays visible and correctly highlighted everywhere.
///
/// - [overrideIndex]: force a specific tab to read as active (mirrors the
///   old `customIndex`), used by fixed-tab sub-pages like Wallet or Addresses.
///   When null, the currently highlighted shell tab is read from
///   [highlightedTabIndexProvider] (mirrors the old dynamic `previousIndex`).
/// - [onTap]: how tapping an item is handled. Defaults to navigating back to
///   that shell branch via [GoRouter.go], which also clears any pushed routes.
/// - [isReelStyle]: the transparent/white-on-black treatment used only while
///   the Reels tab is actually visible behind the bar.
class AppBottomNavBar extends ConsumerWidget {
  final int? overrideIndex;
  final ValueChanged<int>? onTap;
  final bool isReelStyle;

  const AppBottomNavBar({
    super.key,
    this.overrideIndex,
    this.onTap,
    this.isReelStyle = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context);
    final int activeIndex =
        overrideIndex ?? ref.watch(highlightedTabIndexProvider);

    Color getTabIconColor(int index) {
      final isSelected = activeIndex == index;
      if (isReelStyle) {
        return isSelected ? Colors.white : Colors.white.withValues(alpha: 0.5);
      }
      return isSelected ? context.palette.textPrimary : context.palette.textMuted;
    }

    return BottomNavigationBar(
      currentIndex: activeIndex,
      onTap: onTap ?? (index) => context.go(_shellBranchPaths[index]),
      type: BottomNavigationBarType.fixed,
      backgroundColor: isReelStyle
          ? Colors.white.withValues(alpha: 0.05)
          : context.palette.surface,
      elevation: isReelStyle ? 0 : 8,
      selectedItemColor: isReelStyle ? Colors.white : context.palette.textPrimary,
      unselectedItemColor: isReelStyle
          ? Colors.white.withValues(alpha: 0.5)
          : context.palette.textMuted,
      selectedLabelStyle: AppStyle.navLabel.copyWith(
        color: isReelStyle ? Colors.white : context.palette.textPrimary,
      ),
      unselectedLabelStyle: AppStyle.navLabel.copyWith(
        fontWeight: FontWeight.normal,
        color: isReelStyle ? Colors.white.withValues(alpha: 0.5) : context.palette.textMuted,
      ),
      items: [
        BottomNavigationBarItem(
          icon: SvgPicture.asset(
            AssetsConstants.house3,
            width: 22,
            colorFilter: ColorFilter.mode(getTabIconColor(0), BlendMode.srcIn),
          ),
          label: loc.translate('home'),
        ),
        BottomNavigationBarItem(
          icon: SvgPicture.asset(
            AssetsConstants.store2,
            width: 22,
            colorFilter: ColorFilter.mode(getTabIconColor(1), BlendMode.srcIn),
          ),
          label: loc.translate('brands'),
        ),
        BottomNavigationBarItem(
          icon: SvgPicture.asset(
            AssetsConstants.tvMinimalPlay,
            width: 22,
            colorFilter: ColorFilter.mode(getTabIconColor(2), BlendMode.srcIn),
          ),
          label: loc.translate('reels'),
        ),
        BottomNavigationBarItem(
          icon: SvgPicture.asset(
            AssetsConstants.circleUser3,
            width: 22,
            colorFilter: ColorFilter.mode(getTabIconColor(3), BlendMode.srcIn),
          ),
          label: loc.translate('myAccount'),
        ),
        BottomNavigationBarItem(
          icon: SvgPicture.asset(
            AssetsConstants.bell,
            width: 22,
            colorFilter: ColorFilter.mode(getTabIconColor(4), BlendMode.srcIn),
          ),
          label: loc.translate('notifications'),
        ),
      ],
    );
  }
}
