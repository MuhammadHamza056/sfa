import 'package:flutter/material.dart';
import 'package:sfa/utils/app_style.dart';
import 'package:sfa/core/localization/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sfa/utils/assets_constants.dart';
import 'package:sfa/utils/color_constants.dart';
import 'package:sfa/features/favorites/models/favorite_product.dart';
import 'package:sfa/features/favorites/bloc/favorites_bloc.dart';
import 'package:sfa/features/favorites/bloc/favorites_event.dart';
import 'package:sfa/features/favorites/bloc/favorites_state.dart';
import 'package:sfa/features/home/bloc/home_bloc.dart';
import 'package:sfa/features/home/bloc/home_event.dart';
import 'package:sfa/features/home/bloc/home_state.dart';

class FeaturedProductsSection extends StatefulWidget {
  final bool isAr;

  const FeaturedProductsSection({super.key, required this.isAr});

  @override
  State<FeaturedProductsSection> createState() =>
      _FeaturedProductsSectionState();
}

class _FeaturedProductsSectionState extends State<FeaturedProductsSection> {

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    // Localized Products data constructed dynamically in build method
    final Map<int, List<Map<String, String>>> productsData = {
      0: [
        {
          'image': 'https://images.unsplash.com/photo-1529139574466-a303027c1d8b?w=400&q=80',
          'brand': loc.translate('brandJuba'),
          'title': loc.translate('brandProductDesertRose'),
          'price': loc.translate('brandProductPrice1250'),
          'rating': '4.9',
          'reviews': widget.isAr ? '85 تقييمًا' : '85 reviews',
        },
        {
          'image': 'https://images.unsplash.com/photo-1607990283143-e81e7a2c93ab?w=400&q=80',
          'brand': loc.translate('brandAnbar'),
          'title': loc.translate('brandProductBlackSilk'),
          'price': loc.translate('brandProductPrice1250'),
          'rating': '4.9',
          'reviews': widget.isAr ? '85 تقييمًا' : '85 reviews',
        },
        {
          'image': 'https://images.unsplash.com/photo-1529139574466-a303027c1d8b?w=400&q=80',
          'brand': loc.translate('brandAnbar'),
          'title': loc.translate('brandProductLinenSet'),
          'price': loc.translate('brandProductPrice450'),
          'rating': '4.9',
          'reviews': widget.isAr ? '85 تقييمًا' : '85 reviews',
        },
        {
          'image': 'https://images.unsplash.com/photo-1607990283143-e81e7a2c93ab?w=400&q=80',
          'brand': loc.translate('brandJuba'),
          'title': loc.translate('brandProductCrepeAbaya'),
          'price': loc.translate('brandProductPrice780'),
          'rating': '4.9',
          'reviews': widget.isAr ? '85 تقييمًا' : '85 reviews',
        },
      ],
      1: [
        {
          'image': 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=400&q=80',
          'brand': loc.translate('brandNaseej'),
          'title': widget.isAr ? 'ثوب سعودي كلاسيك' : 'Classic Saudi Thobe',
          'price': widget.isAr ? '350 ر.س.' : '350 SAR',
          'rating': '4.8',
          'reviews': widget.isAr ? '42 تقييمًا' : '42 reviews',
        },
        {
          'image': 'https://images.unsplash.com/photo-1607990283143-e81e7a2c93ab?w=400&q=80',
          'brand': widget.isAr ? 'الفارس' : 'Al Faris',
          'title': widget.isAr ? 'شماغ أحمر ملكي' : 'Royal Red Shemagh',
          'price': widget.isAr ? '220 ر.س.' : '220 SAR',
          'rating': '4.9',
          'reviews': widget.isAr ? '98 تقييمًا' : '98 reviews',
        },
        {
          'image': 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=400&q=80',
          'brand': loc.translate('brandNaseej'),
          'title': widget.isAr ? 'بشت رسمي فاخر' : 'Luxury Official Bisht',
          'price': widget.isAr ? '1,800 ر.س.' : '1,800 SAR',
          'rating': '5.0',
          'reviews': widget.isAr ? '15 تقييمًا' : '15 reviews',
        },
        {
          'image': 'https://images.unsplash.com/photo-1607990283143-e81e7a2c93ab?w=400&q=80',
          'brand': loc.translate('brandAnbar'),
          'title': widget.isAr ? 'عطر رسمي رجالي' : 'Men\'s Signature Perfume',
          'price': widget.isAr ? '490 ر.س.' : '490 SAR',
          'rating': '4.7',
          'reviews': widget.isAr ? '31 تقييمًا' : '31 reviews',
        },
      ],
      2: [
        {
          'image': 'https://images.unsplash.com/photo-1502086223501-7ea6ecd79368?w=400&q=80',
          'brand': widget.isAr ? 'صغارنا' : 'Sigharuna',
          'title': widget.isAr ? 'طقم ولادي قطني' : 'Boy\'s Cotton Set',
          'price': widget.isAr ? '180 ر.س.' : '180 SAR',
          'rating': '4.6',
          'reviews': widget.isAr ? '18 تقييمًا' : '18 reviews',
        },
        {
          'image': 'https://images.unsplash.com/photo-1502086223501-7ea6ecd79368?w=400&q=80',
          'brand': widget.isAr ? 'جوبا جونيور' : 'Juba Junior',
          'title': widget.isAr ? 'فستان بناتي ربيعي' : 'Girl\'s Spring Dress',
          'price': widget.isAr ? '240 ر.س.' : '240 SAR',
          'rating': '4.8',
          'reviews': widget.isAr ? '27 تقييمًا' : '27 reviews',
        },
        {
          'image': 'https://images.unsplash.com/photo-1502086223501-7ea6ecd79368?w=400&q=80',
          'brand': widget.isAr ? 'صغارنا' : 'Sigharuna',
          'title': widget.isAr ? 'ثوب أطفال مطرز' : 'Kid\'s Embroidered Thobe',
          'price': widget.isAr ? '150 ر.س.' : '150 SAR',
          'rating': '4.9',
          'reviews': widget.isAr ? '12 تقييمًا' : '12 reviews',
        },
        {
          'image': 'https://images.unsplash.com/photo-1502086223501-7ea6ecd79368?w=400&q=80',
          'brand': widget.isAr ? 'جوبا جونيور' : 'Juba Junior',
          'title': widget.isAr ? 'طقم بناتي كاجوال' : 'Girl\'s Casual Set',
          'price': widget.isAr ? '195 ر.س.' : '195 SAR',
          'rating': '4.7',
          'reviews': widget.isAr ? '20 تقييمًا' : '20 reviews',
        },
      ],
    };

    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        final selectedTab = state.selectedFeaturedTab;
        final currentProducts = productsData[selectedTab] ?? [];

        return Container(
          color: Colors.white,
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title Row (Featured Products / منتجات مميزة)
              Row(
                textDirection: widget.isAr ? TextDirection.rtl : TextDirection.ltr,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    loc.translate('featuredProducts'),
                    style: AppStyle.sectionHeader.copyWith(
                      color: const Color(0xFF3A1E1A),
                      fontSize: 20,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => context.push('/featured-products'),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      textDirection: widget.isAr ? TextDirection.rtl : TextDirection.ltr,
                      children: [
                        if (widget.isAr) ...[
                          Text(
                            loc.translate('viewAll'),
                            style: AppStyle.labelTextMuted.copyWith(
                              color: Colors.grey[400],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 12,
                            color: Colors.grey[400],
                          ),
                        ] else ...[
                          Text(
                            loc.translate('viewAll'),
                            style: AppStyle.labelTextMuted.copyWith(
                              color: Colors.grey[400],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 12,
                            color: Colors.grey[400],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Categories Selector Tabs (RTL aligned if Arabic)
              Directionality(
                textDirection: widget.isAr ? TextDirection.rtl : TextDirection.ltr,
                child: Row(
                  children: [
                    _buildTabButton(context, 0, loc.translate('women'), selectedTab),
                    const SizedBox(width: 12),
                    _buildTabButton(context, 1, loc.translate('men'), selectedTab),
                    const SizedBox(width: 12),
                    _buildTabButton(context, 2, loc.translate('kids'), selectedTab),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              // Products Grid (2 columns)
              Directionality(
                textDirection: widget.isAr ? TextDirection.rtl : TextDirection.ltr,
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.zero,
                  itemCount: currentProducts.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.65,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 16,
                  ),
                  itemBuilder: (context, index) {
                    final product = currentProducts[index];
                    return _buildProductCard(product);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTabButton(BuildContext context, int index, String label, int selectedTab) {
    final isSelected = selectedTab == index;
    return GestureDetector(
      onTap: () {
        context.read<HomeBloc>().add(ChangeFeaturedTabEvent(index));
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2B2B2B) : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isSelected ? Colors.transparent : Colors.grey[300]!,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: AppStyle.chipLabel.copyWith(
            color: isSelected ? Colors.white : Colors.grey[600],
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildProductCard(Map<String, String> product) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Image + Heart Container
        Expanded(
          child: Stack(
            fit: StackFit.expand,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Image.network(
                  product['image']!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: const Color(0xFF1E1B18),
                      child: const Icon(Icons.image, color: Colors.white24),
                    );
                  },
                ),
              ),
              // Wishlist Heart Icon
              Positioned(
                top: 8,
                right: widget.isAr ? null : 8,
                left: widget.isAr ? 8 : null,
                child: BlocBuilder<FavoritesBloc, FavoritesState>(
                  builder: (context, favState) {
                    final favProduct = FavoriteProduct(
                      title: product['title']!,
                      imageUrl: product['image']!,
                      price: product['price']!,
                      rating: product['rating'] ?? '4.9',
                    );
                    final isFav = favState.favorites.contains(favProduct);
                    return GestureDetector(
                      onTap: () {
                        context.read<FavoritesBloc>().add(ToggleFavoriteEvent(favProduct));
                      },
                      child: Container(
                        height: 32,
                        width: 32,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.8),
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: SvgPicture.asset(
                          isFav ? AssetsConstants.heartFilled : AssetsConstants.heart2,
                          width: 16,
                          height: 16,
                          colorFilter: ColorFilter.mode(
                            isFav ? AppColors.primary : AppColors.textcolor,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),

        // Brand
        Text(
          product['brand']!,
          style: AppStyle.productTitle.copyWith(
            color: const Color(0xFF3A1E1A),
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),

        // Product Title
        Text(
          product['title']!,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppStyle.productTitle.copyWith(
            color: Colors.grey[800],
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),

        // Price
        Text(
          product['price']!,
          style: AppStyle.productPrice.copyWith(
            color: Colors.grey[900],
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 4),

        // Rating
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.star, size: 14, color: Colors.amber),
            const SizedBox(width: 4),
            Text(
              '${product['rating']} · ${product['reviews']}',
              style: AppStyle.infoChipText.copyWith(
                color: Colors.grey[500],
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
