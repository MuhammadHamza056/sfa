import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sfa/utils/app_style.dart';
import 'package:go_router/go_router.dart';
import 'package:sfa/core/localization/app_localizations.dart';
import 'package:sfa/features/home/bloc/home_bloc.dart';
import 'package:sfa/features/home/bloc/home_event.dart';
import 'package:sfa/features/home/bloc/home_state.dart';
import 'package:sfa/core/theme/app_palette.dart';

class FeaturedProductsScreen extends StatefulWidget {
  const FeaturedProductsScreen({super.key});

  @override
  State<FeaturedProductsScreen> createState() => _FeaturedProductsScreenState();
}

class _FeaturedProductsScreenState extends State<FeaturedProductsScreen> {

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final isAr = loc.isArabic;

    // Localized Products data
    final Map<int, List<Map<String, String>>> productsData = {
      0: [
        {
          'image':
              'https://images.unsplash.com/photo-1529139574466-a303027c1d8b?w=400&q=80',
          'brand': loc.translate('brandJuba'),
          'title': loc.translate('brandProductDesertRose'),
          'price': loc.translate('brandProductPrice1250'),
          'rating': '4.9',
          'reviews': isAr ? '85 تقييمًا' : '85 reviews',
        },
        {
          'image':
              'https://images.unsplash.com/photo-1607990283143-e81e7a2c93ab?w=400&q=80',
          'brand': loc.translate('brandAnbar'),
          'title': loc.translate('brandProductBlackSilk'),
          'price': loc.translate('brandProductPrice1250'),
          'rating': '4.9',
          'reviews': isAr ? '85 تقييمًا' : '85 reviews',
        },
        {
          'image':
              'https://images.unsplash.com/photo-1529139574466-a303027c1d8b?w=400&q=80',
          'brand': loc.translate('brandAnbar'),
          'title': loc.translate('brandProductLinenSet'),
          'price': loc.translate('brandProductPrice450'),
          'rating': '4.9',
          'reviews': isAr ? '85 تقييمًا' : '85 reviews',
        },
        {
          'image':
              'https://images.unsplash.com/photo-1607990283143-e81e7a2c93ab?w=400&q=80',
          'brand': loc.translate('brandJuba'),
          'title': loc.translate('brandProductCrepeAbaya'),
          'price': loc.translate('brandProductPrice780'),
          'rating': '4.9',
          'reviews': isAr ? '85 تقييمًا' : '85 reviews',
        },
      ],
      1: [
        {
          'image':
              'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=400&q=80',
          'brand': loc.translate('brandNaseej'),
          'title': isAr ? 'ثوب سعودي كلاسيك' : 'Classic Saudi Thobe',
          'price': isAr ? '350 ر.س.' : '350 SAR',
          'rating': '4.8',
          'reviews': isAr ? '42 تقييمًا' : '42 reviews',
        },
        {
          'image':
              'https://images.unsplash.com/photo-1607990283143-e81e7a2c93ab?w=400&q=80',
          'brand': isAr ? 'الفارس' : 'Al Faris',
          'title': isAr ? 'شماغ أحمر ملكي' : 'Royal Red Shemagh',
          'price': isAr ? '220 ر.س.' : '220 SAR',
          'rating': '4.9',
          'reviews': isAr ? '98 تقييمًا' : '98 reviews',
        },
        {
          'image':
              'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=400&q=80',
          'brand': loc.translate('brandNaseej'),
          'title': isAr ? 'بشت رسمي فاخر' : 'Luxury Official Bisht',
          'price': isAr ? '1,800 ر.س.' : '1,800 SAR',
          'rating': '5.0',
          'reviews': isAr ? '15 تقييمًا' : '15 reviews',
        },
        {
          'image':
              'https://images.unsplash.com/photo-1607990283143-e81e7a2c93ab?w=400&q=80',
          'brand': loc.translate('brandAnbar'),
          'title': isAr ? 'عطر رسمي رجالي' : 'Men\'s Signature Perfume',
          'price': isAr ? '490 ر.س.' : '490 SAR',
          'rating': '4.7',
          'reviews': isAr ? '31 تقييمًا' : '31 reviews',
        },
      ],
      2: [
        {
          'image':
              'https://images.unsplash.com/photo-1502086223501-7ea6ecd79368?w=400&q=80',
          'brand': isAr ? 'صغارنا' : 'Sigharuna',
          'title': isAr ? 'طقم ولادي قطني' : 'Boy\'s Cotton Set',
          'price': isAr ? '180 ر.س.' : '180 SAR',
          'rating': '4.6',
          'reviews': isAr ? '18 تقييمًا' : '18 reviews',
        },
        {
          'image':
              'https://images.unsplash.com/photo-1502086223501-7ea6ecd79368?w=400&q=80',
          'brand': isAr ? 'جوبا جونيور' : 'Juba Junior',
          'title': isAr ? 'فستان بناتي ربيعي' : 'Girl\'s Spring Dress',
          'price': isAr ? '240 ر.س.' : '240 SAR',
          'rating': '4.8',
          'reviews': isAr ? '27 تقييمًا' : '27 reviews',
        },
        {
          'image':
              'https://images.unsplash.com/photo-1502086223501-7ea6ecd79368?w=400&q=80',
          'brand': isAr ? 'صغارنا' : 'Sigharuna',
          'title': isAr ? 'ثوب أطفال مطرز' : 'Kid\'s Embroidered Thobe',
          'price': isAr ? '150 ر.س.' : '150 SAR',
          'rating': '4.9',
          'reviews': isAr ? '12 تقييمًا' : '12 reviews',
        },
        {
          'image':
              'https://images.unsplash.com/photo-1502086223501-7ea6ecd79368?w=400&q=80',
          'brand': isAr ? 'جوبا جونيور' : 'Juba Junior',
          'title': isAr ? 'طقم بناتي كاجوال' : 'Girl\'s Casual Set',
          'price': isAr ? '195 ر.س.' : '195 SAR',
          'rating': '4.7',
          'reviews': isAr ? '20 تقييمًا' : '20 reviews',
        },
      ],
    };

    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        final selectedTab = state.selectedFeaturedTab;
        final currentProducts = productsData[selectedTab] ?? [];

        return Directionality(
          textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
          child: Scaffold(
            backgroundColor: context.palette.background,
            appBar: AppBar(
              backgroundColor: context.palette.background,
              elevation: 0.5,
              centerTitle: true,
              leading: IconButton(
                icon: Icon(
                  isAr ? Icons.arrow_back_ios_new : Icons.arrow_back_ios_new,
                  color: context.palette.icon,
                  size: 20,
                ),
                onPressed: () => context.pop(),
              ),
              title: Text(
                loc.translate('featuredProducts'),
                style: AppStyle.sectionHeader.copyWith(
                  color: context.palette.textPrimary,
                  fontSize: 18,
                ),
              ),
            ),
            body: SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  // Tab Selector
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Directionality(
                      textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
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
                  ),
                  const SizedBox(height: 16),
                  // Product Grid
                  Expanded(
                    child: Directionality(
                      textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
                      child: GridView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        itemCount: currentProducts.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.65,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 16,
                            ),
                        itemBuilder: (context, index) {
                          final product = currentProducts[index];
                          return _buildProductCard(product, isAr);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
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
          color: isSelected
              ? (context.isDarkMode
                    ? context.palette.surfaceAlt
                    : const Color(0xFF2B2B2B))
              : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isSelected ? Colors.transparent : context.palette.divider,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: AppStyle.chipLabel.copyWith(
            color: isSelected ? Colors.white : context.palette.textMuted,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildProductCard(Map<String, String> product, bool isAr) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Image Stack
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
              Positioned(
                top: 8,
                right: isAr ? null : 8,
                left: isAr ? 8 : null,
                child: Container(
                  height: 32,
                  width: 32,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.8),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.favorite_border,
                    size: 18,
                    color: Colors.grey[600],
                  ),
                ),
              ),
            ],
          ),
        ),
        // Info strip — the design keeps this white in both themes.
        Container(
          color: Colors.white,
          width: double.infinity,
          padding: const EdgeInsets.only(top: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            // Brand
            Text(
              product['brand']!,
              style: AppStyle.productTitle.copyWith(
                color: const Color(0xFF3A1E1A),
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            // Title
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
          ),
        ),
      ],
    );
  }
}
