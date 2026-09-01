import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:sfa/core/localization/app_localizations.dart';
import 'package:sfa/core/models/product_detail_args.dart';
import 'package:sfa/utils/app_style.dart';
import 'package:sfa/utils/assets_constants.dart';
import 'package:sfa/utils/color_constants.dart';
import 'package:sfa/features/favorites/models/favorite_product.dart';
import 'package:sfa/features/favorites/providers/favorites_provider.dart';
import 'package:sfa/features/reviews/data/review_models.dart';
import 'package:sfa/features/reviews/providers/reviews_providers.dart';
import 'package:sfa/core/theme/app_palette.dart';

class ProductReviewsScreen extends ConsumerWidget {
  final ProductDetailArgs? args;

  const ProductReviewsScreen({super.key, this.args});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context);
    final isAr = loc.isArabic;

    final productName =
        args?.name ?? (isAr ? 'وردة الصحراء المطرزة' : 'Embroidered Desert Rose');
    final productImage = args?.imageUrl ??
        'https://images.unsplash.com/photo-1509631179647-0177331693ae?w=800&q=80';
    final productPrice = args?.price ?? (isAr ? '1,250 ر.س.' : '1,250 SAR');
    final productRating = args?.rating ?? (isAr ? '4.9 · 85 تقييماً' : '4.9 · 85 reviews');
    final brandNameKey = args?.brandNameKey ?? 'brandJuba';
    final resolvedBrandName = loc.translate(brandNameKey);
    final productId = args?.id;

    return Directionality(
      textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: context.palette.background,
        appBar: null,
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),

              // Product Summary Card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                child: Builder(
                  builder: (context) {
                    final textSection = Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          resolvedBrandName,
                          style: AppStyle.bodyText.copyWith(
                            fontSize: 24,
                            color: context.palette.textPrimary,
                            height: 1.1,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          productName,
                          style: AppStyle.bodyText.copyWith(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: context.palette.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          productPrice,
                          style: AppStyle.bodyText.copyWith(
                            fontSize: 18,
                            color: context.palette.textPrimary.withValues(alpha: 0.8),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            const Icon(Icons.star, size: 16, color: Colors.amber),
                            const SizedBox(width: 4),
                            Text(
                              productRating,
                              style: AppStyle.bodyText.copyWith(
                                fontSize: 13.5,
                                color: context.palette.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ],
                    );

                    final imageSection = Stack(
                      clipBehavior: Clip.none,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: CachedNetworkImage(
                            imageUrl: productImage,
                            width: 140,
                            height: 140,
                            fit: BoxFit.cover,
                            errorWidget: (context, url, error) =>
                                Image.network(productImage, width: 140, height: 140, fit: BoxFit.cover),
                          ),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Consumer(
                            builder: (context, ref, _) {
                              final favProduct = FavoriteProduct(
                                productId: productId ?? '',
                                title: productName,
                                imageUrl: productImage,
                                price: productPrice,
                                rating: productRating,
                              );
                              final isFav =
                                  ref.watch(favoritesProvider).favorites.contains(favProduct);
                              return Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF9E8D9).withValues(alpha: 0.85),
                                  shape: BoxShape.circle,
                                ),
                                child: IconButton(
                                  constraints: const BoxConstraints(),
                                  padding: EdgeInsets.zero,
                                  icon: SvgPicture.asset(
                                    isFav ? AssetsConstants.heartFilled : AssetsConstants.heart2,
                                    width: 18,
                                    height: 18,
                                    colorFilter: ColorFilter.mode(
                                      isFav ? AppColors.primary : context.palette.textPrimary,
                                      BlendMode.srcIn,
                                    ),
                                  ),
                                  onPressed: () => ref.read(favoritesProvider.notifier).toggle(favProduct),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    );

                    return Row(
                      textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        imageSection,
                        const SizedBox(width: 12),
                        Expanded(child: textSection),
                      ],
                    );
                  },
                ),
              ),

              const SizedBox(height: 24),

              if (productId == null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    isAr ? 'المنتج غير متاح' : 'Product not found',
                    style: AppStyle.bodyText.copyWith(color: context.palette.textMuted),
                  ),
                )
              else ...[
                // Progress bars distribution (M65)
                Consumer(
                  builder: (context, ref, _) {
                    final summaryAsync = ref.watch(reviewsSummaryProvider(productId));
                    return summaryAsync.when(
                      loading: () => const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                      error: (error, _) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          error.toString(),
                          style: AppStyle.bodyText.copyWith(color: context.palette.textMuted),
                        ),
                      ),
                      data: (summary) {
                        if (summary.total == 0) return const SizedBox.shrink();
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            children: [5, 4, 3, 2, 1].map((stars) {
                              final count = summary.distribution[stars] ?? 0;
                              final percentage = summary.total > 0 ? count / summary.total : 0.0;
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4),
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: 24,
                                      child: Text(
                                        '$count',
                                        textAlign: TextAlign.start,
                                        style: AppStyle.bodyText.copyWith(
                                          fontSize: 13,
                                          color: const Color(0xFF8B2C47),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(4),
                                        child: LinearProgressIndicator(
                                          value: percentage,
                                          minHeight: 6,
                                          backgroundColor: context.palette.surfaceMuted,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(context.palette.textPrimary),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    SizedBox(
                                      width: 32,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          Text(
                                            '$stars',
                                            style: AppStyle.bodyText.copyWith(
                                              fontSize: 13,
                                              color: context.palette.textMuted,
                                            ),
                                          ),
                                          const SizedBox(width: 2),
                                          const Icon(Icons.star, size: 12, color: Colors.amber),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        );
                      },
                    );
                  },
                ),

                const SizedBox(height: 24),

                // Write Review Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => context.push('/write-review', extra: args),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFCA9A4E),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                        elevation: 0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            loc.translate('writeYourReview'),
                            style: AppStyle.bodyText.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15.5,
                            ),
                          ),
                          RotatedBox(
                            quarterTurns: isAr ? 2 : 0,
                            child: SvgPicture.asset(
                              AssetsConstants.moveLeft,
                              colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                              width: 18,
                              height: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        loc.translate('reviewsTitle'),
                        style: AppStyle.bodyText.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: context.palette.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Divider(height: 1, thickness: 1, color: context.palette.divider),
                    ],
                  ),
                ),

                Consumer(
                  builder: (context, ref, _) {
                    final reviewsAsync = ref.watch(productReviewsProvider(productId));
                    return reviewsAsync.when(
                      loading: () => const Padding(
                        padding: EdgeInsets.symmetric(vertical: 32),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                      error: (error, _) => Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          error.toString(),
                          style: AppStyle.bodyText.copyWith(color: context.palette.textMuted),
                        ),
                      ),
                      data: (page) {
                        if (page.items.isEmpty) {
                          return Padding(
                            padding: const EdgeInsets.all(16),
                            child: Text(
                              isAr ? 'لا توجد تقييمات بعد' : 'No reviews yet',
                              style: AppStyle.bodyText.copyWith(color: context.palette.textMuted),
                            ),
                          );
                        }
                        return ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: const EdgeInsets.all(16),
                          itemCount: page.items.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 16),
                          itemBuilder: (context, index) => _ReviewTile(review: page.items[index]),
                        );
                      },
                    );
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ReviewTile extends ConsumerStatefulWidget {
  final Review review;

  const _ReviewTile({required this.review});

  @override
  ConsumerState<_ReviewTile> createState() => _ReviewTileState();
}

class _ReviewTileState extends ConsumerState<_ReviewTile> {
  int? _helpfulCount;
  bool _marked = false;
  bool _busy = false;

  /// M67 is a toggle (helpful/un-helpful), matching the guide's
  /// `{helpful, helpfulCount}` response.
  Future<void> _markHelpful() async {
    if (_busy) return;
    setState(() => _busy = true);
    final result = await ref.read(reviewsRepositoryProvider).markHelpful(widget.review.id);
    if (!mounted) return;
    setState(() {
      _busy = false;
      result.when(
        success: (data) {
          _marked = data.helpful;
          _helpfulCount = data.helpfulCount;
        },
        failure: (_) {},
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final review = widget.review;
    final displayCount = _helpfulCount ?? review.helpfulCount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              review.userName,
              style: AppStyle.bodyText.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: context.palette.textPrimary,
              ),
            ),
            if (review.createdAt != null)
              Text(
                '${review.createdAt!.year}/${review.createdAt!.month}/${review.createdAt!.day}',
                style: AppStyle.bodyText.copyWith(fontSize: 12, color: context.palette.textMuted),
              ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: List.generate(5, (starIdx) {
            return Icon(
              Icons.star,
              size: 14,
              color: starIdx < review.rating ? Colors.amber : context.palette.divider,
            );
          }),
        ),
        const SizedBox(height: 10),
        Text(
          review.comment,
          style: AppStyle.bodyText.copyWith(fontSize: 13, color: context.palette.textMuted, height: 1.5),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: _markHelpful,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: context.palette.surfaceMuted),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$displayCount ${loc.translate('helpful')}',
                  style: AppStyle.bodyText.copyWith(fontSize: 11, color: context.palette.textMuted),
                ),
                const SizedBox(width: 6),
                SvgPicture.asset(
                  AssetsConstants.thumbsUp2,
                  width: 12,
                  height: 12,
                  colorFilter: ColorFilter.mode(
                    _marked ? AppColors.primary : context.palette.textMuted,
                    BlendMode.srcIn,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
