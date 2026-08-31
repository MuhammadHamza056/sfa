import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:sfa/core/localization/app_localizations.dart';
import 'package:sfa/core/providers/nav_providers.dart';
import 'package:sfa/core/theme/app_palette.dart';
import 'package:sfa/core/widgets/app_bottom_nav_bar.dart';
import 'package:sfa/utils/app_style.dart';
import 'package:sfa/utils/assets_constants.dart';
import 'package:sfa/utils/color_constants.dart';

/// Shell for the 5 bottom-nav tabs (Home, Brands, Reels, Profile,
/// Notifications). Everything else is a normal pushed route handled by
/// go_router's Navigator, see [AppBottomNavBar] for how those stay in sync
/// with the last-active tab.
class AppShell extends ConsumerStatefulWidget {
  final StatefulNavigationShell navigationShell;

  const AppShell({super.key, required this.navigationShell});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell>
    with SingleTickerProviderStateMixin {
  late final AnimationController _drawerController;
  late final Animation<double> _drawerSlide;
  late final Animation<double> _scrimOpacity;

  @override
  void initState() {
    super.initState();
    _drawerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    _drawerSlide = CurvedAnimation(
      parent: _drawerController,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
    _scrimOpacity = Tween<double>(begin: 0, end: 0.45).animate(_drawerSlide);
  }

  @override
  void dispose() {
    _drawerController.dispose();
    super.dispose();
  }

  void _closeDrawer() {
    ref.read(drawerOpenProvider.notifier).state = false;
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final isAr = loc.isArabic;

    // Keep the shared "highlighted tab" in sync with the shell's own active
    // branch, so screens pushed on top know which tab to keep lit.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (ref.read(highlightedTabIndexProvider) != widget.navigationShell.currentIndex) {
        ref.read(highlightedTabIndexProvider.notifier).state =
            widget.navigationShell.currentIndex;
      }
    });

    final drawerOpen = ref.watch(drawerOpenProvider);
    ref.listen<bool>(drawerOpenProvider, (previous, isOpen) {
      if (isOpen) {
        _drawerController.forward();
      } else {
        _drawerController.reverse();
      }
    });

    final isReel = widget.navigationShell.currentIndex == 2 && !drawerOpen;

    return Directionality(
      textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: context.palette.background,
        extendBody: isReel,
        body: Stack(
          children: [
            widget.navigationShell,

            if (drawerOpen)
              AnimatedBuilder(
                animation: _scrimOpacity,
                builder: (_, __) => GestureDetector(
                  onTap: _closeDrawer,
                  child: Container(
                    color: Colors.black.withValues(alpha: _scrimOpacity.value),
                  ),
                ),
              ),

            if (drawerOpen)
              AnimatedBuilder(
                animation: _drawerSlide,
                builder: (_, child) {
                  final offset = isAr
                      ? Offset(1.0 - _drawerSlide.value, 0)
                      : Offset(_drawerSlide.value - 1.0, 0);
                  return FractionalTranslation(
                    translation: offset,
                    child: child,
                  );
                },
                child: AppDrawer(isAr: isAr, loc: loc, onClose: _closeDrawer),
              ),
          ],
        ),
        bottomNavigationBar: AppBottomNavBar(
          overrideIndex: widget.navigationShell.currentIndex,
          isReelStyle: isReel,
          onTap: (index) {
            if (drawerOpen) _closeDrawer();
            widget.navigationShell.goBranch(
              index,
              initialLocation: index == widget.navigationShell.currentIndex,
            );
          },
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Drawer Widget
// ─────────────────────────────────────────────────────────────────────────────

class AppDrawer extends StatelessWidget {
  final bool isAr;
  final AppLocalizations loc;
  final VoidCallback onClose;

  const AppDrawer({
    required this.isAr,
    required this.loc,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // warm off-white in light, raised maroon in dark
      backgroundColor: context.palette.surfaceWarm,
      body: SafeArea(
        child: Directionality(
          textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),

              // ── Menu items ──
              _DrawerItem(
                icon: AssetsConstants.globe,
                label: loc.translate('drawerChangeLanguage'),
                isAr: isAr,
                trailing: Text(
                  isAr ? 'English' : 'عربي',
                  style: AppStyle.drawerLanguageTag,
                ),
                onTap: () {
                  onClose();
                  localeNotifier.toggleLanguage();
                },
              ),
              _buildDivider(context),

              _DrawerItem(
                icon: AssetsConstants.shoppingBag2,
                label: loc.translate('drawerBrowseProducts'),
                isAr: isAr,
                onTap: () {
                  onClose();
                  context.push('/featured-products');
                },
              ),
              _buildDivider(context),

              _DrawerItem(
                icon: AssetsConstants.trackOrder,
                label: loc.translate('drawerTrackOrders'),
                isAr: isAr,
                onTap: () {
                  onClose();
                  context.push('/previous-orders');
                },
              ),
              _buildDivider(context),

              _DrawerItem(
                icon: AssetsConstants.mapPin,
                label: loc.translate('drawerMyAddresses'),
                isAr: isAr,
                onTap: () {
                  onClose();
                  context.push('/addresses');
                },
              ),
              _buildDivider(context),

              _DrawerItem(
                icon: AssetsConstants.walletCards,
                label: loc.translate('refundWallet'),
                isAr: isAr,
                onTap: () {
                  onClose();
                  context.push('/wallet');
                },
              ),
              _buildDivider(context),

              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDivider(BuildContext context) =>
      Divider(color: context.palette.divider, thickness: 0.8, height: 0);
}

// ─────────────────────────────────────────────────────────────────────────────
// Single Drawer Row
// ─────────────────────────────────────────────────────────────────────────────

class _DrawerItem extends StatelessWidget {
  final String icon;
  final String label;
  final bool isAr;
  final Widget? trailing;
  final VoidCallback onTap;

  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.isAr,
    required this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    // Arabic:  [icon] [label + trailing]  [←]
    // English: [icon] [label + trailing]  [→]
    final chevron = Directionality(
      textDirection: TextDirection.ltr,
      child: Icon(
        isAr ? Icons.chevron_left_rounded : Icons.chevron_right_rounded,
        color: context.palette.textMuted,
        size: 22,
      ),
    );

    final iconWidget = SvgPicture.asset(
      icon,
      width: 22,
      height: 22,
      colorFilter: ColorFilter.mode(context.palette.icon, BlendMode.srcIn),
    );

    return InkWell(
      onTap: onTap,
      splashColor: AppColors.primary.withValues(alpha: 0.08),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        child: Row(
          children: [
            // Icon always on the left edge
            iconWidget,
            const SizedBox(width: 12),
            // Label + optional trailing fills remaining space
            Expanded(
              child: Row(
                children: [
                  Text(label, style: AppStyle.drawerItemLabel),
                  if (trailing != null) ...[
                    const SizedBox(width: 8),
                    trailing!,
                  ],
                ],
              ),
            ),
            // Arrow on the right edge — direction depends on locale
            chevron,
          ],
        ),
      ),
    );
  }
}
