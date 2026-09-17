import 'package:flutter/material.dart';
import 'package:sfa/core/network/api_exception.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sfa/core/localization/app_localizations.dart';
import 'package:sfa/core/navigation/nav_guard.dart';
import 'package:sfa/core/providers/nav_providers.dart';
import 'package:sfa/core/widgets/cart_icon_button.dart';
import 'package:sfa/features/brands/presentation/widgets/brands_grid.dart';
import 'package:sfa/features/brands/presentation/widgets/brands_header.dart';
// import 'package:sfa/features/brands/presentation/widgets/brands_promo_banner.dart';
import 'package:sfa/features/brands/providers/brands_provider.dart';
import 'package:sfa/features/catalog/providers/catalog_providers.dart';
import 'package:sfa/core/theme/app_palette.dart';
import 'package:sfa/utils/app_style.dart';
import 'package:sfa/utils/assets_constants.dart';

// const _kPromoBannerUrl =
//     'https://images.unsplash.com/photo-1490481651871-ab68de25d43d?w=800&q=80';

const _kBrandsAppBarHeight = 64.0;
const _kHeroImageHeight = 320.0;

/// Scroll offset (in the page's [CustomScrollView]) past which the hero
/// image has fully scrolled behind the app bar — the app bar and the pinned
/// category row switch from transparent to solid black at that point so
/// they stay legible once there's no more image behind them.
const _kHeroScrolledPastThreshold = _kHeroImageHeight - _kBrandsAppBarHeight;

class BrandsScreen extends ConsumerStatefulWidget {
  const BrandsScreen({super.key});

  @override
  ConsumerState<BrandsScreen> createState() => _BrandsScreenState();
}

class _BrandsScreenState extends ConsumerState<BrandsScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _scrolledPastHero = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final scrolledPastHero =
        _scrollController.offset > _kHeroScrolledPastThreshold;
    if (scrolledPastHero != _scrolledPastHero) {
      setState(() => _scrolledPastHero = scrolledPastHero);
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final isAr = loc.isArabic;
    final brandsState = ref.watch(brandsProvider);
    final selectedCategoryId = brandsState.selectedCategoryId;
    final searchQuery = brandsState.searchQuery.trim().toLowerCase();
    final categoriesAsync = ref.watch(brandCategoriesProvider);
    final brandsAsync = selectedCategoryId.isEmpty
        ? ref.watch(brandsListProvider)
        : ref.watch(brandsByCategoryProvider(selectedCategoryId));

    // Categories (used by BrandsHeader's chip row) and brands both fetch on
    // entry; gating the one loader below on both means the header and grid
    // populate together instead of a second spinner flashing separately.
    final isLoading = categoriesAsync.isLoading || brandsAsync.isLoading;

    return Directionality(
      textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
      child: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        behavior: HitTestBehavior.opaque,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          extendBodyBehindAppBar: true,
          appBar: _BrandsAppBar(solidBackground: _scrolledPastHero),
          body: Stack(
            children: [
              // Scaffold background image from assets, with a light
              // blackish filter so the white app bar/header text stays
              // legible over bright photos.
              SizedBox(
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      'assets/images/brandbackground.png',
                      fit: BoxFit.fill,
                    ),
                    Container(color: Colors.black.withOpacity(0.4)),
                  ],
                ),
              ),
              // ── Scrollable content: whole page scrolls as one, with the
              // category row pinned below the app bar once it reaches it ──
              SafeArea(
                bottom: false,
                child: CustomScrollView(
                  controller: _scrollController,
                  slivers: [
                    const SliverToBoxAdapter(
                      child: SizedBox(height: _kBrandsAppBarHeight),
                    ),
                    const SliverToBoxAdapter(child: BrandsHeaderTop()),
                    const SliverToBoxAdapter(child: SizedBox(height: 16)),
                    SliverPersistentHeader(
                      pinned: true,
                      delegate: _CategoryChipsHeaderDelegate(
                        solidBackground: _scrolledPastHero,
                        scrollController: _scrollController,
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 20)),
                    const SliverToBoxAdapter(child: BrandsSearchBar()),
                    const SliverToBoxAdapter(child: SizedBox(height: 17)),
                    SliverToBoxAdapter(
                      child: Builder(
                        builder: (context) {
                          if (isLoading) {
                            return const SizedBox(
                              height: 300,
                              child: Center(child: CircularProgressIndicator()),
                            );
                          }
                          if (brandsAsync.hasError) {
                            return SizedBox(
                              height: 300,
                              child: Center(
                                child: Text(
                                  brandsAsync.error!.errorMessage,
                                  style: AppStyle.bodyText.copyWith(
                                    color: context.palette.textMuted,
                                  ),
                                ),
                              ),
                            );
                          }
                          final allBrands = brandsAsync.value ?? const [];
                          final brands = searchQuery.isEmpty
                              ? allBrands
                              : allBrands
                                    .where(
                                      (b) => b.name
                                          .resolve(isAr)
                                          .toLowerCase()
                                          .contains(searchQuery),
                                    )
                                    .toList();
                          if (brands.isEmpty) {
                            return SizedBox(
                              height: 300,
                              child: Center(
                                child: Text(
                                  searchQuery.isNotEmpty
                                      ? (isAr
                                            ? 'لا توجد نتائج مطابقة'
                                            : 'No matching brands')
                                      : (isAr
                                            ? 'لا توجد علامات تجارية'
                                            : 'No brands yet'),
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
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 24)),
                  ],
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
  final bool solidBackground;

  const _BrandsAppBar({required this.solidBackground});

  @override
  Size get preferredSize => const Size.fromHeight(_kBrandsAppBarHeight);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppBar(
      backgroundColor: solidBackground ? Colors.black : Colors.transparent,
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
              onPressed: () => handleAppBarNavTap(context, '/favorites', null),
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
            onPressed: () => ref.read(drawerOpenProvider.notifier).state = true,
          ),
        ),
      ],
    );
  }
}

const _kCategoryChipsHeight = 32.0;

/// Pins the category chip row directly below the app bar once the page
/// scrolls past it, with a solid backdrop so it stays legible once the hero
/// image has scrolled behind the app bar.
class _CategoryChipsHeaderDelegate extends SliverPersistentHeaderDelegate {
  final bool solidBackground;
  final ScrollController scrollController;

  const _CategoryChipsHeaderDelegate({
    required this.solidBackground,
    required this.scrollController,
  });

  @override
  double get minExtent => _kCategoryChipsHeight;

  @override
  double get maxExtent => _kCategoryChipsHeight;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: solidBackground ? Colors.black : Colors.transparent,
      alignment: Alignment.center,
      child: BrandsCategoryChips(scrollController: scrollController),
    );
  }

  @override
  bool shouldRebuild(covariant _CategoryChipsHeaderDelegate oldDelegate) =>
      solidBackground != oldDelegate.solidBackground ||
      scrollController != oldDelegate.scrollController;
}
