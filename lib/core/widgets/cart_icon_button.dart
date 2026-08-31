import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:sfa/features/cart/providers/cart_provider.dart';
import 'package:sfa/utils/assets_constants.dart';
import 'package:sfa/utils/color_constants.dart';

/// Cart shortcut used in every app bar: the bag icon plus a live badge of
/// [cartItemCountProvider], so adding/removing items anywhere in the app is
/// reflected everywhere without each screen wiring the count itself.
class CartIconButton extends ConsumerWidget {
  final String icon;
  final double size;
  final Color color;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;

  const CartIconButton({
    super.key,
    required this.color,
    this.icon = AssetsConstants.shoppingBag2,
    this.size = 22,
    this.onTap,
    this.padding = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(cartItemCountProvider);

    return GestureDetector(
      onTap: onTap ?? () => context.push('/cart'),
      child: Padding(
        padding: padding,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            SvgPicture.asset(
              icon,
              width: size,
              colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
            ),
            if (count > 0)
              Positioned(
                right: -6,
                top: -6,
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 15,
                    minHeight: 15,
                  ),
                  child: Center(
                    child: Text(
                      '$count',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        height: 1.0,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
