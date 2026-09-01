import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sfa/utils/Values.dart';
import 'package:sfa/utils/app_style.dart';
import 'package:sfa/core/localization/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:sfa/core/providers/home_providers.dart';
import 'package:sfa/core/widgets/product_card.dart';
import 'package:sfa/core/theme/app_palette.dart';
import 'package:sfa/features/catalog/providers/catalog_providers.dart';

class FeaturedProductsSection extends ConsumerWidget {
  final bool isAr;

  const FeaturedProductsSection({super.key, required this.isAr});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context);
    final selectedTab = ref.watch(homeSelectedFeaturedTabProvider);
    final categoriesAsync = ref.watch(categoriesProvider);

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
                    Text(
                      loc.translate('viewAll'),
                      style: AppStyle.labelTextMuted.copyWith(
                        color: Colors.grey[400],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(Icons.arrow_forward_ios, size: 12, color: Colors.grey[400]),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          categoriesAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (error, _) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Text(
                error.toString(),
                style: AppStyle.bodyText.copyWith(color: context.palette.textMuted),
              ),
            ),
            data: (categories) {
              if (categories.isEmpty) return const SizedBox.shrink();
              final clampedTab = selectedTab.clamp(0, categories.length - 1);
              final selectedCategory = categories[clampedTab];

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Categories Selector Tabs (RTL aligned if Arabic)
                  Directionality(
                    textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          for (var i = 0; i < categories.length; i++) ...[
                            if (i > 0) const SizedBox(width: 12),
                            _buildTabButton(
                              context,
                              ref,
                              i,
                              categories[i].name.resolve(isAr),
                              clampedTab,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  Consumer(
                    builder: (context, ref, _) {
                      final productsAsync =
                          ref.watch(featuredProductsProvider(selectedCategory.id));
                      return productsAsync.when(
                        loading: () => const Padding(
                          padding: EdgeInsets.symmetric(vertical: 24),
                          child: Center(child: CircularProgressIndicator()),
                        ),
                        error: (error, _) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 24),
                          child: Text(
                            error.toString(),
                            style: AppStyle.bodyText.copyWith(color: context.palette.textMuted),
                          ),
                        ),
                        data: (products) {
                          final currentProducts = products
                              .map((p) => p.toProduct(isAr))
                              .toList();
                          return Directionality(
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
                          );
                        },
                      );
                    },
                  ),
                ],
              );
            },
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
