import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sfa/utils/Values.dart';
import 'package:sfa/utils/app_style.dart';
import 'package:sfa/core/localization/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:sfa/core/models/product.dart';
import 'package:sfa/core/providers/home_providers.dart';
import 'package:sfa/core/widgets/product_card.dart';
import 'package:sfa/core/theme/app_palette.dart';

class FeaturedProductsSection extends ConsumerWidget {
  final bool isAr;

  const FeaturedProductsSection({super.key, required this.isAr});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context);
    final selectedTab = ref.watch(homeSelectedFeaturedTabProvider);

    // Localized Products data constructed dynamically in build method
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

    final currentProducts = (productsData[selectedTab] ?? [])
        .map(
          (m) => Product(
            imageUrl: m['image']!,
            brandName: m['brand'],
            title: m['title']!,
            price: m['price']!,
            rating: m['rating']!,
            reviewsLabel: m['reviews'],
          ),
        )
        .toList();

    return Container(
      color: context.palette.background,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        vertical: 24,
        horizontal: Values.horizontalPadding,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title Row (Featured Products / منتجات مميزة)
          Row(
            textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                loc.translate('featuredProducts'),
                style: AppStyle.sectionHeader.copyWith(
                  color: context.palette.textPrimary,
                  fontSize: 20,
                ),
              ),
              GestureDetector(
                onTap: () => context.push('/featured-products'),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
                  children: [
                    if (isAr) ...[
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
            textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
            child: Row(
              children: [
                _buildTabButton(
                  context,
                  ref,
                  0,
                  loc.translate('women'),
                  selectedTab,
                ),
                const SizedBox(width: 12),
                _buildTabButton(
                  context,
                  ref,
                  1,
                  loc.translate('men'),
                  selectedTab,
                ),
                const SizedBox(width: 12),
                _buildTabButton(
                  context,
                  ref,
                  2,
                  loc.translate('kids'),
                  selectedTab,
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Products Grid (2 columns)
          Directionality(
            textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
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
                return ProductCard(product: currentProducts[index], isAr: isAr);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(
    BuildContext context,
    WidgetRef ref,
    int index,
    String label,
    int selectedTab,
  ) {
    final isSelected = selectedTab == index;
    return GestureDetector(
      onTap: () =>
          ref.read(homeSelectedFeaturedTabProvider.notifier).state = index,
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
}
