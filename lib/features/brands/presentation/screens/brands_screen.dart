import 'package:flutter/material.dart';
import 'package:sfa/core/localization/app_localizations.dart';
import 'package:sfa/features/brands/presentation/widgets/brands_grid.dart';
import 'package:sfa/features/brands/presentation/widgets/brands_header.dart';
import 'package:sfa/features/brands/presentation/widgets/brands_promo_banner.dart';

// ── Dummy data ────────────────────────────────────────────────────────────────

const _kBrandsRow1 = [
  BrandItem(
    imageUrl:
        'https://images.unsplash.com/photo-1529139574466-a303027c1d8b?w=400&q=80',
    name: 'brandAnbar',
  ),
  BrandItem(
    imageUrl:
        'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400&q=80',
    name: 'brandJuba',
  ),
  BrandItem(
    imageUrl:
        'https://images.unsplash.com/photo-1490481651871-ab68de25d43d?w=400&q=80',
    name: 'brandSummerShop',
  ),
  BrandItem(
    imageUrl:
        'https://images.unsplash.com/photo-1539109136881-3be0616acf4b?w=400&q=80',
    name: 'brandNaseej',
  ),
  BrandItem(
    imageUrl:
        'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=400&q=80',
    name: 'brandLamsatStyle',
  ),
  BrandItem(
    imageUrl:
        'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=400&q=80',
    name: 'brandThawbi',
  ),
];

const _kBrandsRow2 = [
  BrandItem(
    imageUrl:
        'https://images.unsplash.com/photo-1515886657613-9f3515b0c78f?w=400&q=80',
    name: 'brandSummerShop',
  ),
  BrandItem(
    imageUrl:
        'https://images.unsplash.com/photo-1529139574466-a303027c1d8b?w=400&q=80',
    name: 'brandAnbar',
  ),
  BrandItem(
    imageUrl:
        'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=400&q=80',
    name: 'brandLamsatStyle',
  ),
  BrandItem(
    imageUrl:
        'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=400&q=80',
    name: 'brandThawbi',
  ),
  BrandItem(
    imageUrl:
        'https://images.unsplash.com/photo-1539109136881-3be0616acf4b?w=400&q=80',
    name: 'brandNaseej',
  ),
  BrandItem(
    imageUrl:
        'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400&q=80',
    name: 'brandJuba',
  ),
];

const _kPromoBannerUrl =
    'https://images.unsplash.com/photo-1490481651871-ab68de25d43d?w=800&q=80';

// ── Screen ────────────────────────────────────────────────────────────────────

class BrandsScreen extends StatelessWidget {
  const BrandsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final isAr = loc.isArabic;

    final row1 = _kBrandsRow1
        .map(
          (brand) => BrandItem(
            imageUrl: brand.imageUrl,
            name: loc.translate(brand.name),
          ),
        )
        .toList();

    final row2 = _kBrandsRow2
        .map(
          (brand) => BrandItem(
            imageUrl: brand.imageUrl,
            name: loc.translate(brand.name),
          ),
        )
        .toList();

    return Directionality(
      textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
      child: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        behavior: HitTestBehavior.opaque,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Stack(
            // fit: StackFit.expand,
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
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          const SizedBox(height: 15),

                          // ── First grid ──
                          BrandsGrid(brands: row1),

                          // ── Promo banner ──
                          BrandsPromoBanner(
                            imageUrl: _kPromoBannerUrl,
                            title: loc.translate('summerSale'),
                            subtitle: loc.translate('upTo80'),
                            brandName: loc.translate('saudiBrands'),
                          ),

                          // ── Second grid ──
                          BrandsGrid(brands: row2),

                          const SizedBox(height: 24),
                        ],
                      ),
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
