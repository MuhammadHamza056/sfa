import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sfa/core/localization/app_localizations.dart';
import 'package:sfa/features/brands/presentation/widgets/brands_grid.dart';
import 'package:sfa/features/brands/presentation/widgets/brands_header.dart';
import 'package:sfa/features/brands/presentation/widgets/brands_promo_banner.dart';
import 'package:sfa/features/catalog/providers/catalog_providers.dart';
import 'package:sfa/core/theme/app_palette.dart';
import 'package:sfa/utils/app_style.dart';

const _kPromoBannerUrl =
    'https://images.unsplash.com/photo-1490481651871-ab68de25d43d?w=800&q=80';

class BrandsScreen extends ConsumerWidget {
  const BrandsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context);
    final isAr = loc.isArabic;
    final brandsAsync = ref.watch(brandsListProvider);

    return Directionality(
      textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
      child: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        behavior: HitTestBehavior.opaque,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Stack(
            children: [
              // Scaffold background image from assets
              SizedBox(
                height: 600,
                width: double.infinity,
                child: Image.asset(
                  'assets/images/brandbackground.png',
                  fit: BoxFit.fill,
                ),
              ),
              // Content overlay
              Column(
                children: [
                  // ── Header: heading + tabs + categories + search ──
                  const BrandsHeader(),

                  // ── Scrollable Content ──
                  Expanded(
                    child: brandsAsync.when(
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (error, _) => Center(
                        child: Text(
                          error.toString(),
                          style: AppStyle.bodyText.copyWith(color: context.palette.textMuted),
                        ),
                      ),
                      data: (brands) {
                        if (brands.isEmpty) {
                          return Center(
                            child: Text(
                              isAr ? 'لا توجد علامات تجارية' : 'No brands yet',
                              style: AppStyle.bodyText.copyWith(color: context.palette.textMuted),
                            ),
                          );
                        }
                        final mid = (brands.length / 2).ceil();
                        final row1 = brands
                            .take(mid)
                            .map(
                              (b) => BrandItem(
                                id: b.id,
                                imageUrl: b.logo ?? '',
                                name: b.name.resolve(isAr),
                              ),
                            )
                            .toList();
                        final row2 = brands
                            .skip(mid)
                            .map(
                              (b) => BrandItem(
                                id: b.id,
                                imageUrl: b.logo ?? '',
                                name: b.name.resolve(isAr),
                              ),
                            )
                            .toList();

                        return SingleChildScrollView(
                          child: Column(
                            children: [
                              const SizedBox(height: 15),
                              BrandsGrid(brands: row1),
                              BrandsPromoBanner(
                                imageUrl: _kPromoBannerUrl,
                                title: loc.translate('summerSale'),
                                subtitle: loc.translate('upTo80'),
                                brandName: loc.translate('saudiBrands'),
                              ),
                              if (row2.isNotEmpty) BrandsGrid(brands: row2),
                              const SizedBox(height: 24),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
