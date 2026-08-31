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
import 'package:sfa/core/theme/app_palette.dart';

class WriteReviewScreen extends StatefulWidget {
  final ProductDetailArgs? args;

  const WriteReviewScreen({super.key, this.args});

  @override
  State<WriteReviewScreen> createState() => _WriteReviewScreenState();
}

class _WriteReviewScreenState extends State<WriteReviewScreen> {
  int _selectedRating = 2; // Default 2 stars selected as in mock image
  final TextEditingController _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final isAr = loc.isArabic;

    final productName =
        widget.args?.name ??
        (isAr ? 'وردة الصحراء المطرزة' : 'Embroidered Desert Rose');
    final productImage =
        widget.args?.imageUrl ??
        'https://images.unsplash.com/photo-1509631179647-0177331693ae?w=800&q=80';
    final productPrice =
        widget.args?.price ?? (isAr ? '1,250 ر.س.' : '1,250 SAR');
    final productRating =
        widget.args?.rating ?? (isAr ? '4.9 · 85 تقييماً' : '4.9 · 85 reviews');
    final brandNameKey = widget.args?.brandNameKey ?? 'brandJuba';
    final resolvedBrandName = loc.translate(brandNameKey);

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
                color: context.palette.textPrimary.withOpacity(0.8),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.star, size: 16, color: Colors.amber),
                const SizedBox(width: 4),
                Text(
                  isAr ? '4.9 · 85 تقييماً' : '4.9 · 85 reviews',
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
                errorWidget: (context, url, error) => Image.network(
                  productImage,
                  width: 140,
                  height: 140,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: Consumer(
                builder: (context, ref, _) {
                  final favProduct = FavoriteProduct(
                    title: productName,
                    imageUrl: productImage,
                    price: productPrice,
                    rating: productRating,
                  );
                  final isFav = ref
                      .watch(favoritesProvider)
                      .favorites
                      .contains(favProduct);
                  return Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9E8D9).withOpacity(0.85),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      constraints: const BoxConstraints(),
                      padding: EdgeInsets.zero,
                      icon: SvgPicture.asset(
                        isFav
                            ? AssetsConstants.heartFilled
                            : AssetsConstants.heart2,
                        width: 18,
                        height: 18,
                        colorFilter: ColorFilter.mode(
                          isFav ? AppColors.primary : context.palette.textPrimary,
                          BlendMode.srcIn,
                        ),
                      ),
                      onPressed: () {
                        ref
                            .read(favoritesProvider.notifier)
                            .toggle(favProduct);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        );

        return Directionality(
          textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
          child: Scaffold(
            backgroundColor: context.palette.background,
            appBar: null,
            body: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Product Info Row
                  Row(
                    textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      imageSection,
                      const SizedBox(width: 12),
                      Expanded(child: textSection),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Add review message
                  Text(
                    loc.translate('addReviewOnProduct'),
                    textAlign: TextAlign.start,
                    style: AppStyle.bodyText.copyWith(
                      fontSize: 16,
                      color: context.palette.textPrimary.withOpacity(0.7),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Rating star selection
                  Text(
                    loc.translate('ratingLabel'),
                    textAlign: TextAlign.start,
                    style: AppStyle.bodyText.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: context.palette.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      final starNum = index + 1;
                      final isSelected = starNum <= _selectedRating;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedRating = starNum;
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: Icon(
                            isSelected ? Icons.star : Icons.star_border,
                            color: Colors.amber,
                            size: 40,
                          ),
                        ),
                      );
                    }),
                  ),

                  const SizedBox(height: 28),

                  // Note field
                  Text(
                    loc.translate('noteLabel'),
                    textAlign: TextAlign.start,
                    style: AppStyle.bodyText.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: context.palette.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _commentController,
                    maxLines: 4,
                    textAlign: TextAlign.start,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.all(16),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: context.palette.divider),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppColors.primary),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),

                  const SizedBox(height: 36),

                  // Write Review submit Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // Submit logic and go back
                        context.pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFCA9A4E),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.symmetric(
                          vertical: 14,
                          horizontal: 24,
                        ),
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
                              colorFilter: const ColorFilter.mode(
                                Colors.white,
                                BlendMode.srcIn,
                              ),
                              width: 18,
                              height: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
  }
}
