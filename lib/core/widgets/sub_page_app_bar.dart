import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sfa/core/theme/app_palette.dart';
import 'package:sfa/core/widgets/cart_icon_button.dart';
import 'package:sfa/utils/assets_constants.dart';

/// Minimal shared app bar for secondary screens that don't own a full
/// Scaffold/AppBar of their own (Wallet, Addresses, Product Reviews, ...).
/// Mirrors the bar the old `DashboardScreen` rendered around its `body`.
class SubPageAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final double fontSize;
  final double letterSpacing;

  const SubPageAppBar({
    super.key,
    required this.title,
    this.fontSize = 20,
    this.letterSpacing = 0,
  });

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: context.palette.background,
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: 56,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Text(
                  title,
                  style: GoogleFonts.cairo(
                    fontSize: fontSize,
                    fontWeight: FontWeight.bold,
                    letterSpacing: letterSpacing,
                    color: context.palette.textPrimary,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CartIconButton(
                          icon: AssetsConstants.shoppingBag,
                          color: context.palette.icon,
                          padding: const EdgeInsets.all(8.0),
                        ),
                        GestureDetector(
                          onTap: () => context.push('/favorites'),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: SvgPicture.asset(
                              AssetsConstants.heart,
                              width: 22,
                              colorFilter: ColorFilter.mode(
                                context.palette.icon,
                                BlendMode.srcIn,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // GestureDetector(
                        //   onTap: () {},
                        //   child: Padding(
                        //     padding: const EdgeInsets.all(8.0),
                        //     child: SvgPicture.asset(
                        //       AssetsConstants.search,
                        //       width: 22,
                        //       colorFilter: ColorFilter.mode(
                        //         context.palette.icon,
                        //         BlendMode.srcIn,
                        //       ),
                        //     ),
                        //   ),
                        // ),
                        GestureDetector(
                          onTap: () => context.pop(),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: SvgPicture.asset(
                              AssetsConstants.back,
                              width: 22,
                              colorFilter: ColorFilter.mode(
                                context.palette.icon,
                                BlendMode.srcIn,
                              ),
                            ),
                          ),
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
