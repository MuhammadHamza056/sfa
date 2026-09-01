import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sfa/core/localization/app_localizations.dart';
import 'package:sfa/core/widgets/primary_app_bar.dart';
import 'package:sfa/core/widgets/product_card.dart';
import 'package:sfa/features/catalog/providers/catalog_providers.dart';
import 'package:sfa/utils/app_style.dart';
import 'package:sfa/utils/assets_constants.dart';
import 'package:sfa/core/theme/app_palette.dart';

class BrandDetailScreen extends ConsumerWidget {
  final String brandId;
  final String? initialName;

  const BrandDetailScreen({super.key, required this.brandId, this.initialName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context);
    final isAr = loc.isArabic;

    final sortLabel = loc.translate('brandSortLabel');
    final filterLabel = loc.translate('brandFilterLabel');

    if (brandId.isEmpty) {
      return Scaffold(
        backgroundColor: context.palette.background,
        appBar: PrimaryAppBar(title: initialName ?? '', showBackButton: true),
        body: Center(
          child: Text(
            isAr ? 'العلامة التجارية غير متاحة' : 'Brand not found',
            style: AppStyle.bodyText.copyWith(color: context.palette.textMuted),
          ),
        ),
      );
    }

    final brandAsync = ref.watch(brandDetailProvider(brandId));
    final productsAsync = ref.watch(brandProductsProvider(brandId));

    return Scaffold(
      backgroundColor: context.palette.background,
      appBar: PrimaryAppBar(
        title: brandAsync.valueOrNull?.name ?? initialName ?? '',
        fontSize: 19,
        letterSpacing: 0,
        showBackButton: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Brand Image Banner
            CachedNetworkImage(
              imageUrl: brandAsync.valueOrNull?.logo ?? '',
              height: 320,
              fit: BoxFit.cover,
              placeholder: (_, __) => Container(color: context.palette.surfaceMuted),
              errorWidget: (_, __, ___) => Container(color: context.palette.surfaceMuted),
            ),

            // 2. Brand Description
            if (brandAsync.valueOrNull?.story != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Text(
                  brandAsync.value!.story!.resolve(isAr),
                  textAlign: TextAlign.start,
                  style: AppStyle.bodyText.copyWith(
                    fontSize: 13.5,
                    color: context.palette.textPrimary.withValues(alpha: 0.80),
                    height: 1.6,
                  ),
                ),
              ),

            // 3. Info Row & Filters
            productsAsync.maybeWhen(
              data: (products) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Text(
                      isAr ? '${products.length} منتج' : '${products.length} products',
                      style: AppStyle.bodyText.copyWith(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: context.palette.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    _buildFilterBtn(context, label: sortLabel, icon: AssetsConstants.arrowDownUp),
                    const SizedBox(width: 8),
                    _buildFilterBtn(context, label: filterLabel, icon: AssetsConstants.settings2),
                  ],
                ),
              ),
              orElse: () => const SizedBox.shrink(),
            ),

            const SizedBox(height: 12),

            // 4. Products Grid (2 columns)
            productsAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: 48),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (error, _) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 48),
                child: Center(
                  child: Text(
                    error.toString(),
                    style: AppStyle.bodyText.copyWith(color: context.palette.textMuted),
                  ),
                ),
              ),
              data: (products) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: products.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.65,
                  ),
                  itemBuilder: (context, index) {
                    return ProductCard(product: products[index].toProduct(isAr), isAr: isAr);
                  },
                ),
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
