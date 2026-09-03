import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sfa/core/localization/app_localizations.dart';
import 'package:sfa/core/providers/nav_providers.dart';
import 'package:sfa/core/widgets/cart_icon_button.dart';
import 'package:sfa/features/brands/presentation/widgets/brands_grid.dart';
import 'package:sfa/features/brands/presentation/widgets/brands_header.dart';
// import 'package:sfa/features/brands/presentation/widgets/brands_promo_banner.dart';
import 'package:sfa/features/catalog/providers/catalog_providers.dart';
import 'package:sfa/core/theme/app_palette.dart';
import 'package:sfa/utils/app_style.dart';
import 'package:sfa/utils/assets_constants.dart';

// const _kPromoBannerUrl =
//     'https://images.unsplash.com/photo-1490481651871-ab68de25d43d?w=800&q=80';

const _kBrandsAppBarHeight = 64.0;

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
          extendBodyBehindAppBar: true,
          appBar: const _BrandsAppBar(),
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
              // ── Scrollable content: header + grid ──
              SafeArea(
                bottom: false,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: _kBrandsAppBarHeight),
                      // ── Header: heading + tabs + categories + search ──
                      const BrandsHeader(),
                      const SizedBox(height: 15),
                      brandsAsync.when(
                        loading: () => const SizedBox(
                          height: 300,
                          child: Center(child: CircularProgressIndicator()),
                        ),
                        error: (error, _) => SizedBox(
                          height: 300,
                          child: Center(
                            child: Text(
                              error.toString(),
                              style: AppStyle.bodyText.copyWith(
                                color: context.palette.textMuted,
                              ),
                            ),
                          ),
                        ),
                        data: (brands) {
                          if (brands.isEmpty) {
                            return SizedBox(
                              height: 300,
                              child: Center(
                                child: Text(
                                  isAr
                                      ? 'لا توجد علامات تجارية'
                                      : 'No brands yet',
                                  style: AppStyle.bodyText.copyWith(
                                    color: context.palette.textMuted,
                                  ),
                                ),
                              ),
                            );
                          }
                          final brandItems = brands
                              .map(
                                (b) => BrandItem(
                                  id: b.id,
                                  imageUrl: b.logo ?? '',
                                  name: b.name.resolve(isAr),
                                ),
                              )
                              .toList();

                          return BrandsGrid(brands: brandItems);
                          // BrandsPromoBanner(
                          //   imageUrl: _kPromoBannerUrl,
                          //   title: loc.translate('summerSale'),
                          //   subtitle: loc.translate('upTo80'),
                          //   brandName: loc.translate('saudiBrands'),
                          // ),
                        },
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BrandsAppBar extends ConsumerWidget implements PreferredSizeWidget {
  const _BrandsAppBar();

  @override
  Size get preferredSize => const Size.fromHeight(_kBrandsAppBarHeight);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      toolbarHeight: _kBrandsAppBarHeight,
      automaticallyImplyLeading: false,
      leadingWidth: 96,
      leading: Padding(
        padding: const EdgeInsets.only(left: 16),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CartIconButton(
              icon: AssetsConstants.shoppingBag,
              color: Colors.white,
              size: 24,
            ),
            const SizedBox(width: 4),
            IconButton(
              icon: SvgPicture.asset(
                AssetsConstants.heart2,
                colorFilter: const ColorFilter.mode(
                  Colors.white,
                  BlendMode.srcIn,
                ),
                width: 24,
                height: 24,
              ),
              onPressed: () => context.push('/favorites'),
            ),
          ],
        ),
      ),
      title: Text(
        'SFA',
        style: GoogleFonts.playfairDisplay(
          color: Colors.white,
          fontSize: 38,
          fontWeight: FontWeight.w500,
          letterSpacing: 1.5,
        ),
      ),
      centerTitle: true,
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: IconButton(
            icon: SvgPicture.asset(
              AssetsConstants.menu,
              colorFilter: const ColorFilter.mode(
                Colors.white,
                BlendMode.srcIn,
              ),
              width: 24,
              height: 24,
            ),
            onPressed: () =>
                ref.read(drawerOpenProvider.notifier).state = true,
          ),
        ),
      ],
    );
  }
}
