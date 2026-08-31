import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sfa/core/localization/app_localizations.dart';
import 'package:sfa/core/models/product.dart';
import 'package:sfa/core/widgets/primary_app_bar.dart';
import 'package:sfa/core/widgets/product_card.dart';
import 'package:sfa/utils/app_style.dart';
import 'package:sfa/utils/assets_constants.dart';
import 'package:sfa/core/theme/app_palette.dart';

class BrandDetailScreen extends StatelessWidget {
  final String brandName;

  const BrandDetailScreen({super.key, required this.brandName});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final isAr = loc.isArabic;

    // Localized labels
    final productsLabel = loc.translate('brandProductsCount');
    final sortLabel = loc.translate('brandSortLabel');
    final filterLabel = loc.translate('brandFilterLabel');

    // 6 Dummy localized products
    final dummyProducts = [
      Product(
        imageUrl:
            'https://images.unsplash.com/photo-1509631179647-0177331693ae?w=500&q=80',
        title: loc.translate('brandProductDesertRose'),
        price: loc.translate('brandProductPrice1250'),
        rating: loc.translate('brandProductRatingText'),
      ),
      Product(
        imageUrl:
            'https://images.unsplash.com/photo-1529139574466-a303027c1d8b?w=500&q=80',
        title: loc.translate('brandProductBlackSilk'),
        price: loc.translate('brandProductPrice1250'),
        rating: loc.translate('brandProductRatingText'),
      ),
      Product(
        imageUrl:
            'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=500&q=80',
        title: loc.translate('brandProductLinenSet'),
        price: loc.translate('brandProductPrice450'),
        rating: loc.translate('brandProductRatingText'),
      ),
      Product(
        imageUrl:
            'https://images.unsplash.com/photo-1515886657613-9f3515b0c78f?w=500&q=80',
        title: loc.translate('brandProductCrepeAbaya'),
        price: loc.translate('brandProductPrice780'),
        rating: loc.translate('brandProductRatingText'),
      ),
      Product(
        imageUrl:
            'https://images.unsplash.com/photo-1539109136881-3be0616acf4b?w=500&q=80',
        title: loc.translate('brandProductDesertRose'),
        price: loc.translate('brandProductPrice1250'),
        rating: loc.translate('brandProductRatingText'),
      ),
      Product(
        imageUrl:
            'https://images.unsplash.com/photo-1529139574466-a303027c1d8b?w=500&q=80',
        title: loc.translate('brandProductBlackSilk'),
        price: loc.translate('brandProductPrice1250'),
        rating: loc.translate('brandProductRatingText'),
      ),
    ];

    final resolvedBrandName = loc.translate(brandName);

    return Scaffold(
      backgroundColor: context.palette.background,
      appBar: PrimaryAppBar(
        title: resolvedBrandName,
        fontSize: 19,
        letterSpacing: 0,
        showBackButton: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Huge Brand Image Banner
            CachedNetworkImage(
              imageUrl:
                  'https://images.unsplash.com/photo-1490481651871-ab68de25d43d?w=1000&q=80',
              height: 520,
              fit: BoxFit.cover,
              placeholder: (_, __) =>
                  Container(color: context.palette.surfaceMuted),
              errorWidget: (_, __, ___) =>
                  Container(color: context.palette.surfaceMuted),
            ),

            // 2. Brand Description
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Text(
                loc.translate('brandDescription'),
                textAlign: TextAlign.start,
                style: AppStyle.bodyText.copyWith(
                  fontSize: 13.5,
                  color: context.palette.textPrimary.withOpacity(0.80),
                  height: 1.6,
                ),
              ),
            ),

            // 3. Info Row & Filters
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  // Product count (e.g. 273 products)
                  Text(
                    productsLabel,
                    style: AppStyle.bodyText.copyWith(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: context.palette.textPrimary,
                    ),
                  ),
                  const Spacer(),

                  // Sort options button
                  _buildFilterBtn(
                    context,
                    label: sortLabel,
                    icon: AssetsConstants.arrowDownUp,
                  ),
                  const SizedBox(width: 8),

                  // Filter button
                  _buildFilterBtn(
                    context,
                    label: filterLabel,
                    icon: AssetsConstants.settings2,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // 4. Products Grid (2 columns)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: dummyProducts.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.65,
                ),
                itemBuilder: (context, index) {
                  return ProductCard(
                    product: dummyProducts[index],
                    isAr: isAr,
                    brandNameKey: brandName,
                  );
                },
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterBtn(
    BuildContext context, {
    required String label,
    required String icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: context.palette.background,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: context.palette.divider, width: 0.8),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: AppStyle.bodyText.copyWith(
              fontSize: 13,
              color: context.palette.textPrimary,
            ),
          ),
          const SizedBox(width: 6),
          SvgPicture.asset(
            icon,
            width: 14,
            height: 14,
            colorFilter: ColorFilter.mode(
              context.palette.textPrimary,
              BlendMode.srcIn,
            ),
          ),
        ],
      ),
    );
  }
}
