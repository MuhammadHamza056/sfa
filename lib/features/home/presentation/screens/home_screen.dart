import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sfa/core/localization/app_localizations.dart';
import 'package:sfa/core/providers/home_providers.dart';
import 'package:sfa/utils/Values.dart';
import 'package:sfa/utils/assets_constants.dart';
import 'package:sfa/features/home/presentation/widgets/reels_section.dart';
import 'package:sfa/features/home/presentation/widgets/category_banners_section.dart';
import 'package:sfa/features/home/presentation/widgets/featured_products_section.dart';
import 'package:sfa/utils/app_style.dart';
import 'package:sfa/core/theme/app_palette.dart';
import 'package:sfa/core/widgets/floating_top_bar.dart';

/// Height of the fixed top bar's own content (SFA title + icon row),
/// excluding the device's top safe-area inset. Used to reserve matching
/// empty space at the top of the scrollable hero section so the
/// announcements bar/tabs (which now scroll away with the rest of the
/// page) don't render underneath the pinned bar.
const double _kTopBarContentHeight = 46;

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context);
    final isAr = loc.isArabic;
    final topBarReservedHeight =
        MediaQuery.paddingOf(context).top + _kTopBarContentHeight;

    return Scaffold(
      body: Stack(
        children: [
          // 1. Scrollable content: hero image, announcements bar, tabs and
          // every section below all scroll together. Only the bar above
          // (SFA logo + icons) stays fixed on screen.
          Positioned.fill(
            child: NotificationListener<ScrollNotification>(
              onNotification: (notification) {
                final metrics = notification.metrics;
                ref.read(homeScrollOffsetProvider.notifier).state = metrics
                    .pixels
                    .clamp(0.0, metrics.maxScrollExtent);
                return false;
              },
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    // Main Cover Page
                    SizedBox(
                      height: MediaQuery.of(context).size.height,
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: Image.asset(
                              AssetsConstants.homeBackground,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.black.withValues(alpha: 0.3),
                                    Colors.transparent,
                                    Colors.black.withValues(alpha: 0.85),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          // Announcements Bar + Tabs — scroll away with the
                          // hero image now, instead of staying pinned.
                          Positioned(
                            top: 0,
                            left: 0,
                            right: 0,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(height: topBarReservedHeight),
                                const SizedBox(height: 12),
                                Divider(
                                  color: Colors.white.withValues(alpha: 0.12),
                                  height: 1,
                                  thickness: 1,
                                ),
                                const SizedBox(height: 12),

                                // Announcements Bar
                                SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  physics: const BouncingScrollPhysics(),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  child: Row(
                                    children: [
                                      // Free Gift Wrapping Card
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 10,
                                          horizontal: 16,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withValues(
                                            alpha: 0.08,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          border: Border.all(
                                            color: Colors.white.withValues(
                                              alpha: 0.12,
                                            ),
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              loc.translate('freeGiftWrap'),
                                              style: GoogleFonts.cairo(
                                                color: Colors.white.withValues(
                                                  alpha: 0.9,
                                                ),
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            SvgPicture.asset(
                                              AssetsConstants.gift,
                                              width: 16,
                                              height: 16,
                                              colorFilter:
                                                  const ColorFilter.mode(
                                                    Colors.white,
                                                    BlendMode.srcIn,
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      // Fast Delivery Card
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 10,
                                          horizontal: 16,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withValues(
                                            alpha: 0.08,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          border: Border.all(
                                            color: Colors.white.withValues(
                                              alpha: 0.12,
                                            ),
                                          ),
                                        ),
                                        child: Center(
                                          child: Text(
                                            loc.translate('fastDelivery'),
                                            style: GoogleFonts.cairo(
                                              color: Colors.white.withValues(
                                                alpha: 0.9,
                                              ),
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 12),
                                Divider(
                                  color: Colors.white.withValues(alpha: 0.12),
                                  height: 1,
                                  thickness: 1,
                                ),
                                const SizedBox(height: 16),

                                // Tabs / Category Selectors
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  child: Directionality(
                                    textDirection: isAr
                                        ? TextDirection.rtl
                                        : TextDirection.ltr,
                                    child: Consumer(
                                      builder: (context, ref, _) {
                                        final selectedCategoryIndex = ref.watch(
                                          homeSelectedCategoryIndexProvider,
                                        );
                                        return Row(
                                          children: [
                                            _buildTab(
                                              ref,
                                              0,
                                              loc.translate('women'),
                                              selectedCategoryIndex,
                                            ),
                                            const SizedBox(width: 12),
                                            _buildTab(
                                              ref,
                                              1,
                                              loc.translate('men'),
                                              selectedCategoryIndex,
                                            ),
                                            const SizedBox(width: 12),
                                            _buildTab(
                                              ref,
                                              2,
                                              loc.translate('kids'),
                                              selectedCategoryIndex,
                                            ),
                                          ],
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          Positioned(
                            bottom:
                                100, // push up slightly so it doesn't get cut off by bottom nav
                            left: 24,
                            right: 24,
                            child: Column(
                              crossAxisAlignment: isAr
                                  ? CrossAxisAlignment.end
                                  : CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isAr
                                      ? 'مجموعة\nاليوم الوطني'
                                      : 'National Day\nCollection',
                                  textAlign: isAr
                                      ? TextAlign.right
                                      : TextAlign.left,
                                  style: GoogleFonts.cairo(
                                    color: Colors.white,
                                    fontSize: 34,
                                    fontWeight: FontWeight.w800,
                                    height: 1.2,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  isAr
                                      ? 'أكثر من 100 علامة تجارية سعودية أصلية\nعلامات تجارية سعودية نفخر بها'
                                      : 'More than 100 authentic Saudi brands\nSaudi brands we are proud of',
                                  textAlign: isAr
                                      ? TextAlign.right
                                      : TextAlign.left,
                                  style: GoogleFonts.cairo(
                                    color: Colors.white.withValues(alpha: 0.9),
                                    fontSize: 14,
                                    height: 1.4,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                InkWell(
                                  onTap: () {},
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 4,
                                    ),
                                    decoration: const BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(
                                          color: Colors.white,
                                          width: 1.5,
                                        ),
                                      ),
                                    ),
                                    child: Text(
                                      loc.translate('shopNow'),
                                      style: GoogleFonts.cairo(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Saudi Brands Section
                    Container(
                      color: context.palette.background,
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                        vertical: 24,
                        horizontal: Values.horizontalPadding,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title Row
                          Row(
                            textDirection: isAr
                                ? TextDirection.rtl
                                : TextDirection.ltr,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                isAr ? 'البراندات السعودية' : 'Saudi Brands',
                                style: GoogleFonts.cairo(
                                  color: context.palette.textPrimary,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              GestureDetector(
                                onTap: () => context.go('/brands'),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  textDirection: isAr
                                      ? TextDirection.rtl
                                      : TextDirection.ltr,
                                  children: [
                                    if (isAr) ...[
                                      Text(
                                        'عرض الكل',
                                        style: GoogleFonts.cairo(
                                          color: context.palette.textMuted,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Icon(
                                        Icons.arrow_forward_ios,
                                        size: 12,
                                        color: context.palette.textMuted,
                                      ),
                                    ] else ...[
                                      Text(
                                        'View All',
                                        style: GoogleFonts.cairo(
                                          color: context.palette.textMuted,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Icon(
                                        Icons.arrow_forward_ios,
                                        size: 12,
                                        color: context.palette.textMuted,
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Divider(color: context.palette.divider, thickness: 1),
                          const SizedBox(height: 12),
                          Align(
                            alignment: isAr
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: Text(
                              isAr
                                  ? 'علامات تجارية سعودية نفخر بها'
                                  : 'Saudi brands we are proud of',
                              style: AppStyle.labelText.copyWith(
                                color: context.palette.textPrimary.withValues(
                                  alpha: 0.8,
                                ),
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Directionality(
                            textDirection: isAr
                                ? TextDirection.rtl
                                : TextDirection.ltr,
                            child: Row(
                              children: [
                                Expanded(
                                  child: _buildBrandCard(
                                    context,
                                    imageUrl:
                                        'https://images.unsplash.com/photo-1607990283143-e81e7a2c93ab?w=400&q=80',
                                    name: isAr ? 'عنبر' : 'Amber',
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: _buildBrandCard(
                                    context,
                                    imageUrl:
                                        'https://images.unsplash.com/photo-1609357605129-26f69add5d6e?w=400&q=80',
                                    name: isAr ? 'جوبا' : 'Juba',
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: _buildBrandCard(
                                    context,
                                    imageUrl:
                                        'https://images.unsplash.com/photo-1529139574466-a303027c1d8b?w=400&q=80',
                                    name: isAr ? 'سمر_شوب' : 'Summer Shop',
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 4),
                          GestureDetector(
                            onTap: () => context.push('/brand-detail'),
                            child: Image.asset(
                              AssetsConstants.containerPng,
                              height: 500,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Reels Section
                    ReelsSection(isAr: isAr),
                    SizedBox(height: 10),
                    Image.asset(
                      AssetsConstants.container2Png,
                      height: 500,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                    CategoryBannersSection(isAr: isAr),
                    FeaturedProductsSection(isAr: isAr),
                  ],
                ),
              ),
            ),
          ),

          // 2. Fixed Top Bar — always pinned; fades in a solid backdrop as
          // the hero image scrolls away underneath it so the white icons
          // stay legible over whatever content is now behind the bar.
          // Wrapped in its own [Consumer] so that watching
          // [homeScrollOffsetProvider] — which changes on every scroll
          // frame — only rebuilds this small bar instead of the whole
          // home screen.
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Consumer(
              builder: (context, ref, _) => FloatingTopBar(
                scrollOffset: ref.watch(homeScrollOffsetProvider),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(
    WidgetRef ref,
    int index,
    String label,
    int selectedCategoryIndex,
  ) {
    final isSelected = selectedCategoryIndex == index;
    return GestureDetector(
      onTap: () {
        ref.read(homeSelectedCategoryIndexProvider.notifier).state = index;
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.grey.withValues(alpha: 0.3)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? Colors.grey.withValues(alpha: 0.4)
                : Colors.transparent,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.cairo(
            color: isSelected
                ? Colors.white
                : Colors.white.withValues(alpha: 0.6),
            fontSize: 15,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildBrandCard(
    BuildContext context, {
    required String imageUrl,
    required String name,
  }) {
    return GestureDetector(
      onTap: () => context.push('/brand-detail'),
      child: AspectRatio(
        aspectRatio: 0.72,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background Image
            Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: const Color(0xFF1E1B18),
                  child: const Icon(Icons.image, color: Colors.white24),
                );
              },
            ),
            // Bottom gradient scrim
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                height: 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.85),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            // Brand Label
            Positioned(
              left: 8,
              right: 8,
              bottom: 12,
              child: Text(
                name,
                textAlign: TextAlign.center,
                style: GoogleFonts.cairo(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
