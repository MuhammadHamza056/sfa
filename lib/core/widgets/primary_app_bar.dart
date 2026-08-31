import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:sfa/core/localization/app_localizations.dart';
import 'package:sfa/core/theme/app_palette.dart';
import 'package:sfa/core/widgets/cart_icon_button.dart';
import 'package:sfa/features/dashboard/presentation/screens/app_shell.dart';
import 'package:sfa/utils/app_style.dart';
import 'package:sfa/utils/assets_constants.dart';

/// Shared top app bar used across order/checkout-style screens: cart +
/// favorites on the leading side, a centered title, and search + a trailing
/// icon on the actions side.
///
/// The trailing icon is either the drawer [AssetsConstants.menu] (default,
/// opening the same [AppDrawer] used elsewhere as a slide-in overlay) or a
/// [AssetsConstants.back] button that pops the route — set [showBackButton]
/// to true for screens that are pushed on top of another screen and must
/// navigate back instead of opening the drawer.
class PrimaryAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final double fontSize;
  final double letterSpacing;
  final bool showBackButton;
  final String cartIcon;
  final String heartIcon;
  final VoidCallback? onCartTap;
  final VoidCallback? onHeartTap;
  final VoidCallback? onSearchTap;
  final VoidCallback? onBackTap;
  final VoidCallback? onMenuTap;

  const PrimaryAppBar({
    super.key,
    required this.title,
    this.fontSize = 24,
    this.letterSpacing = 2,
    this.showBackButton = false,
    this.cartIcon = AssetsConstants.shoppingBag2,
    this.heartIcon = AssetsConstants.heart,
    this.onCartTap,
    this.onHeartTap,
    this.onSearchTap,
    this.onBackTap,
    this.onMenuTap,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  void _openDrawer(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final isAr = loc.isArabic;
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.black.withOpacity(0.45),
      transitionDuration: const Duration(milliseconds: 280),
      pageBuilder: (context, anim1, anim2) {
        return AppDrawer(
          isAr: isAr,
          loc: loc,
          onClose: () => Navigator.of(context).pop(),
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        final beginOffset = isAr
            ? const Offset(1.0, 0.0)
            : const Offset(-1.0, 0.0);
        return SlideTransition(
          position: anim1.drive(
            Tween<Offset>(
              begin: beginOffset,
              end: Offset.zero,
            ).chain(CurveTween(curve: Curves.easeOutCubic)),
          ),
          child: child,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final iconColor = ColorFilter.mode(
      context.palette.textPrimary,
      BlendMode.srcIn,
    );

    return AppBar(
      backgroundColor: context.palette.background,
      elevation: 0,
      scrolledUnderElevation: 0,
      automaticallyImplyLeading: false,
      leadingWidth: 108,
      leading: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CartIconButton(
              icon: cartIcon,
              color: context.palette.textPrimary,
              onTap: onCartTap,
            ),
            const SizedBox(width: 16),
            GestureDetector(
              onTap: onHeartTap ?? () => context.push('/favorites'),
              child: SvgPicture.asset(
                heartIcon,
                width: 22,
                colorFilter: iconColor,
              ),
            ),
          ],
        ),
      ),
      title: Text(
        title,
        style: AppStyle.welcomeTitle.copyWith(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: context.palette.textPrimary,
          letterSpacing: letterSpacing,
        ),
      ),
      centerTitle: true,
      actions: [
        // GestureDetector(
        //   onTap: onSearchTap ?? () {},
        //   child: SvgPicture.asset(
        //     AssetsConstants.search,
        //     width: 22,
        //     colorFilter: iconColor,
        //   ),
        // ),
        // const SizedBox(width: 16),
        GestureDetector(
          onTap: showBackButton
              ? (onBackTap ?? () => context.pop())
              : (onMenuTap ?? () => _openDrawer(context)),
          child: SvgPicture.asset(
            showBackButton ? AssetsConstants.back : AssetsConstants.menu,
            width: 22,
            matchTextDirection: true,
            colorFilter: iconColor,
          ),
        ),
        const SizedBox(width: 16),
      ],
    );
  }
}
