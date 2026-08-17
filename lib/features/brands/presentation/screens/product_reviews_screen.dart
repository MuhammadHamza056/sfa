import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:sfa/core/localization/app_localizations.dart';
import 'package:sfa/features/dashboard/bloc/dashboard_event.dart';
import 'package:sfa/utils/app_style.dart';
import 'package:sfa/utils/assets_constants.dart';
import 'package:sfa/utils/color_constants.dart';
import 'package:sfa/features/dashboard/bloc/dashboard_bloc.dart';
import 'package:sfa/features/dashboard/bloc/dashboard_state.dart';
import 'package:sfa/features/favorites/models/favorite_product.dart';
import 'package:sfa/features/favorites/bloc/favorites_bloc.dart';
import 'package:sfa/features/favorites/bloc/favorites_event.dart';
import 'package:sfa/features/favorites/bloc/favorites_state.dart';

class ReviewItem {
  final String nameAr;
  final String nameEn;
  final String dateAr;
  final String dateEn;
  final double rating;
  final String reviewAr;
  final String reviewEn;
  final int helpfulCount;
  final bool isVerified;

  const ReviewItem({
    required this.nameAr,
    required this.nameEn,
    required this.dateAr,
    required this.dateEn,
    required this.rating,
    required this.reviewAr,
    required this.reviewEn,
    required this.helpfulCount,
    required this.isVerified,
  });
}

class ProductReviewsScreen extends StatefulWidget {
  const ProductReviewsScreen({super.key});

  @override
  State<ProductReviewsScreen> createState() => _ProductReviewsScreenState();
}

class _ProductReviewsScreenState extends State<ProductReviewsScreen> {
  final List<ReviewItem> _reviews = const [
    ReviewItem(
      nameAr: "سارة المطيري",
      nameEn: "Sara Al-Mutairi",
      dateAr: "منذ يومين",
      dateEn: "2 days ago",
      rating: 5.0,
      reviewAr:
          "الخامة ممتازة جداً وتفاصيل التطريز غاية في الدقة. الفستان فخم جداً في المناسبات وتغليف المنتج كان راقياً جداً كما اعتدت من أناس.",
      reviewEn:
          "The material is excellent and the embroidery details are very precise. The dress is very luxurious for occasions and the product packaging was very elegant, as I am used to from Ounass.",
      helpfulCount: 12,
      isVerified: true,
    ),
    ReviewItem(
      nameAr: "أمل القحطاني",
      nameEn: "Amal Al-Qahtani",
      dateAr: "منذ أسبوع",
      dateEn: "1 week ago",
      rating: 4.0,
      reviewAr:
          "أنيق جداً واللون مطابق تماماً للصور. المقاس كان مناسباً جداً ولكن تمنيت لو كان طول الأكمام أقصر قليلاً. بشكل عام تجربة رائعة.",
      reviewEn:
          "Very elegant and the color matches the pictures exactly. The size was very suitable but I wished the sleeve length was slightly shorter. Overall, a great experience.",
      helpfulCount: 8,
      isVerified: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final isAr = loc.isArabic;

    return BlocBuilder<DashboardBloc, DashboardState>(
      builder: (context, dashboardState) {
        final productName =
            dashboardState.selectedProductName ??
            (isAr ? 'وردة الصحراء المطرزة' : 'Embroidered Desert Rose');
        final productImage =
            dashboardState.selectedProductImage ??
            'https://images.unsplash.com/photo-1509631179647-0177331693ae?w=800&q=80';
        final productPrice =
            dashboardState.selectedProductPrice ??
            (isAr ? '1,250 ر.س.' : '1,250 SAR');
        final productRating =
            dashboardState.selectedProductRating ??
            (isAr ? '4.9 · 85 تقييماً' : '4.9 · 85 reviews');
        final brandNameKey = dashboardState.selectedBrandName ?? 'brandJuba';
        final resolvedBrandName = loc.translate(brandNameKey);

        final totalRatingsCount = 85;
        final ratingsDistribution = [
          {'stars': 5, 'count': 47},
          {'stars': 4, 'count': 18},
          {'stars': 3, 'count': 10},
          {'stars': 2, 'count': 6},
          {'stars': 1, 'count': 4},
        ];

        return Directionality(
          textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
          child: Scaffold(
            backgroundColor: Colors.white,
            appBar: null,
            body: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 16),

                  // Product Summary Card
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    child: Builder(
                      builder: (context) {
                        final textSection = Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              resolvedBrandName,
                              style: AppStyle.bodyText.copyWith(
                                fontSize: 24,
                                color: const Color(0xFF4E1D2D),
                                height: 1.1,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              productName,
                              style: AppStyle.bodyText.copyWith(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textcolor,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              productPrice,
                              style: AppStyle.bodyText.copyWith(
                                fontSize: 18,
                                color: AppColors.textcolor.withValues(
                                  alpha: 0.8,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                const Icon(
                                  Icons.star,
                                  size: 16,
                                  color: Colors.amber,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  isAr ? '4.9 · 85 تقييماً' : '4.9 · 85 reviews',
                                  style: AppStyle.bodyText.copyWith(
                                    fontSize: 13.5,
                                    color: Colors.grey[400],
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
                              child: BlocBuilder<FavoritesBloc, FavoritesState>(
                                builder: (context, favState) {
                                  final favProduct = FavoriteProduct(
                                    title: productName,
                                    imageUrl: productImage,
                                    price: productPrice,
                                    rating: productRating,
                                  );
                                  final isFav = favState.favorites.contains(
                                    favProduct,
                                  );
                                  return Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: const Color(
                                        0xFFF9E8D9,
                                      ).withValues(alpha: 0.85),
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
                                          isFav
                                              ? AppColors.primary
                                              : AppColors.textcolor,
                                          BlendMode.srcIn,
                                        ),
                                      ),
                                      onPressed: () {
                                        context.read<FavoritesBloc>().add(
                                          ToggleFavoriteEvent(favProduct),
                                        );
                                      },
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        );

                        return Row(
                          textDirection: isAr
                              ? TextDirection.rtl
                              : TextDirection.ltr,
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

                  // Progress bars distribution
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: ratingsDistribution.map((dist) {
                        final stars = dist['stars'] as int;
                        final count = dist['count'] as int;
                        final percentage = count / totalRatingsCount;

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
                                    backgroundColor: const Color(0xFFF5F5F5),
                                    valueColor:
                                        const AlwaysStoppedAnimation<Color>(
                                          Color(0xFF4E1D2D),
                                        ),
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
                                        color: Colors.grey[400],
                                      ),
                                    ),
                                    const SizedBox(width: 2),
                                    const Icon(
                                      Icons.star,
                                      size: 12,
                                      color: Colors.amber,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Write Review Button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          context.push('/write-review');
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
                  ),

                  const SizedBox(height: 24),

                  // Reviews Header
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
                            color: const Color(0xFF4E1D2D),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Divider(
                          height: 1,
                          thickness: 1,
                          color: Color(0xFFEEEEEE),
                        ),
                      ],
                    ),
                  ),

                  // Reviews List
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    itemCount: _reviews.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final review = _reviews[index];
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    isAr ? review.nameAr : review.nameEn,
                                    style: AppStyle.bodyText.copyWith(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: const Color(0xFF4E1D2D),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  if (review.isVerified)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFE8F5E9),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        loc.translate('verifiedPurchase'),
                                        style: AppStyle.bodyText.copyWith(
                                          fontSize: 10,
                                          color: Colors.green[700],
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              Text(
                                isAr ? review.dateAr : review.dateEn,
                                style: AppStyle.bodyText.copyWith(
                                  fontSize: 12,
                                  color: Colors.grey[400],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: List.generate(5, (starIdx) {
                              return Icon(
                                Icons.star,
                                size: 14,
                                color: starIdx < review.rating
                                    ? Colors.amber
                                    : Colors.grey[300],
                              );
                            }),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            isAr ? review.reviewAr : review.reviewEn,
                            style: AppStyle.bodyText.copyWith(
                              fontSize: 13,
                              color: Colors.grey[700],
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 12),
                          // Helpful button
                          GestureDetector(
                            onTap: () {},
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: const Color(0xFFF0F0F0),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '${review.helpfulCount} ${loc.translate('helpful')}',
                                    style: AppStyle.bodyText.copyWith(
                                      fontSize: 11,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  SvgPicture.asset(
                                    AssetsConstants.thumbsUp2,
                                    width: 12,
                                    height: 12,
                                    colorFilter: ColorFilter.mode(
                                      Colors.grey[600]!,
                                      BlendMode.srcIn,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
