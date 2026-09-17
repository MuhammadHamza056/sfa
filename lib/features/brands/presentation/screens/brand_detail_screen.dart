import 'package:cached_network_image/cached_network_image.dart';
import 'package:sfa/core/network/api_exception.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sfa/core/localization/app_localizations.dart';
import 'package:sfa/core/widgets/primary_app_bar.dart';
import 'package:sfa/core/widgets/product_card.dart';
import 'package:sfa/features/catalog/data/catalog_models.dart';
import 'package:sfa/features/catalog/providers/catalog_providers.dart';
import 'package:sfa/utils/app_style.dart';
import 'package:sfa/utils/assets_constants.dart';
import 'package:sfa/core/theme/app_palette.dart';

enum _ProductSortOption { none, nameAToZ, nameZToA, priceLowToHigh, priceHighToLow }

class _ProductFilters {
  final bool inStockOnly;
  final bool onSaleOnly;
  final double minRating;

  const _ProductFilters({
    this.inStockOnly = false,
    this.onSaleOnly = false,
    this.minRating = 0,
  });

  bool get isActive => inStockOnly || onSaleOnly || minRating > 0;

  _ProductFilters copyWith({bool? inStockOnly, bool? onSaleOnly, double? minRating}) {
    return _ProductFilters(
      inStockOnly: inStockOnly ?? this.inStockOnly,
      onSaleOnly: onSaleOnly ?? this.onSaleOnly,
      minRating: minRating ?? this.minRating,
    );
  }
}

class BrandDetailScreen extends ConsumerStatefulWidget {
  final String brandId;
  final String? initialName;

  const BrandDetailScreen({super.key, required this.brandId, this.initialName});

  @override
  ConsumerState<BrandDetailScreen> createState() => _BrandDetailScreenState();
}

class _BrandDetailScreenState extends ConsumerState<BrandDetailScreen> {
  _ProductSortOption _sortOption = _ProductSortOption.none;
  _ProductFilters _filters = const _ProductFilters();

  List<CatalogProduct> _applySortAndFilter(List<CatalogProduct> products, bool isAr) {
    var result = products.where((p) {
      if (_filters.inStockOnly && !p.isAvailable) return false;
      if (_filters.onSaleOnly && !(p.oldPriceFils != null && p.oldPriceFils! > p.priceFils)) {
        return false;
      }
      if (p.avgRating < _filters.minRating) return false;
      return true;
    }).toList();

    switch (_sortOption) {
      case _ProductSortOption.nameAToZ:
        result.sort((a, b) => a.name.resolve(isAr).compareTo(b.name.resolve(isAr)));
        break;
      case _ProductSortOption.nameZToA:
        result.sort((a, b) => b.name.resolve(isAr).compareTo(a.name.resolve(isAr)));
        break;
      case _ProductSortOption.priceLowToHigh:
        result.sort((a, b) => a.priceFils.compareTo(b.priceFils));
        break;
      case _ProductSortOption.priceHighToLow:
        result.sort((a, b) => b.priceFils.compareTo(a.priceFils));
        break;
      case _ProductSortOption.none:
        break;
    }
    return result;
  }

  Future<void> _showSortDialog(bool isAr) async {
    final loc = AppLocalizations.of(context);
    final selected = await showDialog<_ProductSortOption>(
      context: context,
      builder: (_) {
        var current = _sortOption;
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            Widget option(_ProductSortOption value, String label) {
              return RadioListTile<_ProductSortOption>(
                value: value,
                groupValue: current,
                title: Text(
                  label,
                  style: AppStyle.bodyText.copyWith(color: dialogContext.palette.textPrimary),
                ),
                activeColor: dialogContext.palette.primary,
                onChanged: (value) => setDialogState(() => current = value!),
              );
            }

            return AlertDialog(
              backgroundColor: dialogContext.palette.surface,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Text(
                loc.translate('brandSortDialogTitle'),
                style: AppStyle.bodyText.copyWith(
                  fontWeight: FontWeight.bold,
                  color: dialogContext.palette.textPrimary,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 8),
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    option(_ProductSortOption.nameAToZ, loc.translate('sortNameAToZ')),
                    option(_ProductSortOption.nameZToA, loc.translate('sortNameZToA')),
                    option(_ProductSortOption.priceLowToHigh, loc.translate('sortPriceLowToHigh')),
                    option(_ProductSortOption.priceHighToLow, loc.translate('sortPriceHighToLow')),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: Text(loc.translate('cancel')),
                ),
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(current),
                  child: Text(loc.translate('apply')),
                ),
              ],
            );
          },
        );
      },
    );

    if (selected != null && mounted) {
      setState(() => _sortOption = selected);
    }
  }

  Future<void> _showFilterDialog(bool isAr) async {
    final loc = AppLocalizations.of(context);
    final selected = await showDialog<_ProductFilters>(
      context: context,
      builder: (_) {
        var current = _filters;
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            Widget ratingOption(double value, String label) {
              return RadioListTile<double>(
                value: value,
                groupValue: current.minRating,
                title: Text(
                  label,
                  style: AppStyle.bodyText.copyWith(color: dialogContext.palette.textPrimary),
                ),
                activeColor: dialogContext.palette.primary,
                onChanged: (value) {
                  setDialogState(() => current = current.copyWith(minRating: value));
                },
              );
            }

            return AlertDialog(
              backgroundColor: dialogContext.palette.surface,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Text(
                loc.translate('brandFilterDialogTitle'),
                style: AppStyle.bodyText.copyWith(
                  fontWeight: FontWeight.bold,
                  color: dialogContext.palette.textPrimary,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 8),
              content: SizedBox(
                width: double.maxFinite,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CheckboxListTile(
                        value: current.inStockOnly,
                        title: Text(
                          loc.translate('filterInStockOnly'),
                          style: AppStyle.bodyText.copyWith(color: dialogContext.palette.textPrimary),
                        ),
                        activeColor: dialogContext.palette.primary,
                        controlAffinity: ListTileControlAffinity.leading,
                        onChanged: (value) {
                          setDialogState(() => current = current.copyWith(inStockOnly: value));
                        },
                      ),
                      CheckboxListTile(
                        value: current.onSaleOnly,
                        title: Text(
                          loc.translate('filterOnSaleOnly'),
                          style: AppStyle.bodyText.copyWith(color: dialogContext.palette.textPrimary),
                        ),
                        activeColor: dialogContext.palette.primary,
                        controlAffinity: ListTileControlAffinity.leading,
                        onChanged: (value) {
                          setDialogState(() => current = current.copyWith(onSaleOnly: value));
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                        child: Text(
                          loc.translate('filterMinRatingLabel'),
                          style: AppStyle.bodyText.copyWith(
                            fontWeight: FontWeight.w600,
                            color: dialogContext.palette.textPrimary,
                          ),
                        ),
                      ),
                      ratingOption(0, loc.translate('filterRatingAny')),
                      ratingOption(3, loc.translate('filterRating3Plus')),
                      ratingOption(4, loc.translate('filterRating4Plus')),
                      ratingOption(4.5, loc.translate('filterRating45Plus')),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    setDialogState(() => current = const _ProductFilters());
                  },
                  child: Text(loc.translate('resetFilters')),
                ),
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: Text(loc.translate('cancel')),
                ),
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(current),
                  child: Text(loc.translate('apply')),
                ),
              ],
            );
          },
        );
      },
    );

    if (selected != null && mounted) {
      setState(() => _filters = selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final isAr = loc.isArabic;

    final sortLabel = loc.translate('brandSortLabel');
    final filterLabel = loc.translate('brandFilterLabel');

    if (widget.brandId.isEmpty) {
      return Scaffold(
        backgroundColor: context.palette.background,
        appBar: PrimaryAppBar(title: widget.initialName ?? '', showBackButton: true),
        body: Center(
          child: Text(
            isAr ? 'العلامة التجارية غير متاحة' : 'Brand not found',
            style: AppStyle.bodyText.copyWith(color: context.palette.textMuted),
          ),
        ),
      );
    }

    final brandAsync = ref.watch(brandDetailProvider(widget.brandId));
    final productsAsync = ref.watch(brandProductsProvider(widget.brandId));

    return Scaffold(
      backgroundColor: context.palette.background,
      appBar: PrimaryAppBar(
        title: brandAsync.valueOrNull?.name.resolve(isAr) ?? widget.initialName ?? '',
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

            // 1.5. Rating / Review Count / Open-Closed Status
            if (brandAsync.valueOrNull != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                child: Row(
                  children: [
                    const Icon(Icons.star, size: 15, color: Colors.amber),
                    const SizedBox(width: 4),
                    Text(
                      '${brandAsync.value!.rating} (${brandAsync.value!.reviewCount})',
                      style: AppStyle.bodyText.copyWith(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: context.palette.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    if (brandAsync.value!.businessStatus.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color:
                              (brandAsync.value!.isOpen
                                      ? context.palette.success
                                      : context.palette.danger)
                                  .withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          brandAsync.value!.isOpen
                              ? (isAr ? 'مفتوح' : 'Open')
                              : (isAr ? 'مغلق' : 'Closed'),
                          style: AppStyle.bodyText.copyWith(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: brandAsync.value!.isOpen
                                ? context.palette.success
                                : context.palette.danger,
                          ),
                        ),
                      ),
                  ],
                ),
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
              data: (products) {
                final visibleCount = _applySortAndFilter(products, isAr).length;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      Text(
                        isAr ? '$visibleCount منتج' : '$visibleCount products',
                        style: AppStyle.bodyText.copyWith(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: context.palette.textPrimary,
                        ),
                      ),
                      const Spacer(),
                      _buildFilterBtn(
                        context,
                        label: sortLabel,
                        icon: AssetsConstants.arrowDownUp,
                        active: _sortOption != _ProductSortOption.none,
                        onTap: () => _showSortDialog(isAr),
                      ),
                      const SizedBox(width: 8),
                      _buildFilterBtn(
                        context,
                        label: filterLabel,
                        icon: AssetsConstants.settings2,
                        active: _filters.isActive,
                        onTap: () => _showFilterDialog(isAr),
                      ),
                    ],
                  ),
                );
              },
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
                    error.errorMessage,
                    style: AppStyle.bodyText.copyWith(color: context.palette.textMuted),
                  ),
                ),
              ),
              data: (products) {
                final visibleProducts = _applySortAndFilter(products, isAr);
                if (visibleProducts.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 48),
                    child: Center(
                      child: Text(
                        isAr ? 'لا توجد منتجات مطابقة' : 'No matching products',
                        style: AppStyle.bodyText.copyWith(color: context.palette.textMuted),
                      ),
                    ),
                  );
                }
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: visibleProducts.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.65,
                    ),
                    itemBuilder: (context, index) {
                      return ProductCard(product: visibleProducts[index].toProduct(isAr), isAr: isAr);
                    },
                  ),
                );
              },
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
    required bool active,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Container(
        decoration: BoxDecoration(
          color: active
              ? context.palette.primary.withValues(alpha: 0.08)
              : context.palette.background,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: active ? context.palette.primary : context.palette.divider,
            width: 0.8,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: AppStyle.bodyText.copyWith(
                fontSize: 13,
                color: active ? context.palette.primary : context.palette.textPrimary,
              ),
            ),
            const SizedBox(width: 6),
            SvgPicture.asset(
              icon,
              width: 14,
              height: 14,
              colorFilter: ColorFilter.mode(
                active ? context.palette.primary : context.palette.textPrimary,
                BlendMode.srcIn,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
