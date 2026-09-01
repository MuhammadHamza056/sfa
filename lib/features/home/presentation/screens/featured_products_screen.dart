import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sfa/core/widgets/primary_app_bar.dart';
import 'package:sfa/utils/app_style.dart';
import 'package:sfa/core/localization/app_localizations.dart';
import 'package:sfa/core/providers/home_providers.dart';
import 'package:sfa/core/widgets/product_card.dart';
import 'package:sfa/core/theme/app_palette.dart';
import 'package:sfa/features/catalog/providers/catalog_providers.dart';

class FeaturedProductsScreen extends ConsumerWidget {
  const FeaturedProductsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context);
    final isAr = loc.isArabic;
    final selectedTab = ref.watch(homeSelectedFeaturedTabProvider);
    final categoriesAsync = ref.watch(categoriesProvider);

    return Directionality(
      textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: context.palette.background,
        appBar: PrimaryAppBar(
          title: loc.translate('featuredProducts'),
          showBackButton: true,
        ),
        body: SafeArea(
          child: categoriesAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Center(
              child: Text(
                error.toString(),
                style: AppStyle.bodyText.copyWith(color: context.palette.textMuted),
              ),
            ),
            data: (categories) {
              if (categories.isEmpty) {
                return Center(
                  child: Text(
                    isAr ? 'لا توجد منتجات' : 'No products yet',
                    style: AppStyle.bodyText.copyWith(color: context.palette.textMuted),
                  ),
                );
              }
              final clampedTab = selectedTab.clamp(0, categories.length - 1);
              final selectedCategory = categories[clampedTab];

              return Column(
                children: [
                  const SizedBox(height: 16),
                  // Tab Selector
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Directionality(
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
                  ),
                  const SizedBox(height: 16),
                  // Product Grid
                  Expanded(
                    child: Consumer(
                      builder: (context, ref, _) {
                        final productsAsync =
                            ref.watch(featuredProductsProvider(selectedCategory.id));
                        return productsAsync.when(
                          loading: () => const Center(child: CircularProgressIndicator()),
                          error: (error, _) => Center(
                            child: Text(
                              error.toString(),
                              style: AppStyle.bodyText.copyWith(color: context.palette.textMuted),
                            ),
                          ),
                          data: (products) {
                            final currentProducts =
                                products.map((p) => p.toProduct(isAr)).toList();
                            return Directionality(
                              textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
                              child: GridView.builder(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                  ),
                ],
              );
            },
          ),
        ),
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
