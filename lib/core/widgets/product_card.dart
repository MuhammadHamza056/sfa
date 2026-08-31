import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:sfa/core/models/product.dart';
import 'package:sfa/core/theme/app_palette.dart';
import 'package:sfa/features/favorites/models/favorite_product.dart';
import 'package:sfa/features/favorites/providers/favorites_provider.dart';
import 'package:sfa/utils/app_style.dart';
import 'package:sfa/utils/assets_constants.dart';
import 'package:sfa/utils/color_constants.dart';

/// Shared product tile used by every product grid in the app: image with a
/// favorite-toggle badge, then brand (optional) / title / price / rating.
///
/// Tapping pushes `/product-detail` by default; pass [onTap] to override
/// (e.g. to also reset a scroll controller). Pass [brandNameKey] on screens
/// where the brand is known from page context rather than [Product.brandName].
class ProductCard extends StatelessWidget {
  final Product product;
  final bool isAr;
  final VoidCallback? onTap;
  final String? brandNameKey;

  const ProductCard({
    super.key,
    required this.product,
    required this.isAr,
    this.onTap,
    this.brandNameKey,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap ??
          () => context.push(
                '/product-detail',
                extra: product.toDetailArgs(brandNameKey: brandNameKey),
              ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: CachedNetworkImage(
                    imageUrl: product.imageUrl,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (_, __) =>
                        Container(color: context.palette.surfaceMuted),
                    errorWidget: (_, __, ___) =>
                        Container(color: context.palette.surfaceMuted),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: isAr ? null : 8,
                  left: isAr ? 8 : null,
                  child: Consumer(
                    builder: (context, ref, _) {
                      final favProduct = FavoriteProduct(
                        title: product.title,
                        imageUrl: product.imageUrl,
                        price: product.price,
                        rating: product.rating,
                      );
                      final isFav = ref
                          .watch(favoritesProvider)
                          .favorites
                          .contains(favProduct);
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.85),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          constraints: const BoxConstraints(),
                          padding: const EdgeInsets.all(6),
                          icon: SvgPicture.asset(
                            isFav
                                ? AssetsConstants.heartFilled
                                : AssetsConstants.heart2,
                            width: 16,
                            height: 16,
                            colorFilter: ColorFilter.mode(
                              isFav ? AppColors.primary : context.palette.textPrimary,
                              BlendMode.srcIn,
                            ),
                          ),
                          onPressed: () => ref
                              .read(favoritesProvider.notifier)
                              .toggle(favProduct),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          if (product.brandName != null) ...[
            Text(
              product.brandName!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppStyle.bodyText.copyWith(
                fontSize: 12,
                color: context.palette.textPrimary.withValues(alpha: 0.60),
              ),
            ),
            const SizedBox(height: 2),
          ],
          Text(
            product.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppStyle.bodyText.copyWith(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: context.palette.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            product.price,
            style: AppStyle.bodyText.copyWith(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: context.palette.textPrimary.withValues(alpha: 0.80),
            ),
          ),
          const SizedBox(height: 2),
          Row(
            children: [
              const Icon(Icons.star, size: 13, color: Colors.amber),
              const SizedBox(width: 3),
              Text(
                product.reviewsLabel != null
                    ? '${product.rating} · ${product.reviewsLabel}'
                    : product.rating,
                style: AppStyle.bodyText.copyWith(
                  fontSize: 11,
                  color: context.palette.textMuted,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
