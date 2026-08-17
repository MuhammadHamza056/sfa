import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sfa/core/localization/app_localizations.dart';
import 'package:sfa/features/dashboard/bloc/dashboard_bloc.dart';
import 'package:sfa/features/dashboard/bloc/dashboard_event.dart';
import 'package:sfa/utils/assets_constants.dart';
import 'package:sfa/features/home/presentation/widgets/reels_section.dart';
import 'package:sfa/features/home/presentation/widgets/category_banners_section.dart';
import 'package:sfa/features/home/presentation/widgets/featured_products_section.dart';
import 'package:go_router/go_router.dart';
import 'package:sfa/utils/app_style.dart';
import 'package:sfa/features/home/bloc/home_bloc.dart';
import 'package:sfa/features/home/bloc/home_event.dart';
import 'package:sfa/features/home/bloc/home_state.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final isAr = loc.isArabic;

    return Scaffold(
      body: Stack(
        children: [
          // 1. Scrollable Background Image + Gradient + Text Overlays
          Positioned.fill(
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
                    color: Colors.white,
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      vertical: 24,
                      horizontal: 16,
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
                                color: const Color(0xFF3A1E1A),
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            GestureDetector(
                              onTap: () => context.push('/featured-products'),
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
                                        color: Colors.grey[400],
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Icon(
                                      Icons.arrow_forward_ios,
                                      size: 12,
                                      color: Colors.grey[400],
                                    ),
                                  ] else ...[
                                    Text(
                                      'View All',
                                      style: GoogleFonts.cairo(
                                        color: Colors.grey[400],
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Icon(
                                      Icons.arrow_forward_ios,
                                      size: 12,
                                      color: Colors.grey[400],
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Divider(color: Colors.grey[200], thickness: 1),
                        const SizedBox(height: 12),
                        Align(
                          alignment: isAr ? Alignment.centerRight : Alignment.centerLeft,
                          child: Text(
                            isAr
                                ? 'علامات تجارية سعودية نفخر بها'
                                : 'Saudi brands we are proud of',
                            style: AppStyle.labelText.copyWith(
                              color: const Color(0xFF3A1E1A).withValues(alpha: 0.8),
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
                                  imageUrl:
                                      'https://images.unsplash.com/photo-1607990283143-e81e7a2c93ab?w=400&q=80',
                                  name: isAr ? 'عنبر' : 'Amber',
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _buildBrandCard(
                                  imageUrl:
                                      'https://images.unsplash.com/photo-1609357605129-26f69add5d6e?w=400&q=80',
                                  name: isAr ? 'جوبا' : 'Juba',
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _buildBrandCard(
                                  imageUrl:
                                      'https://images.unsplash.com/photo-1529139574466-a303027c1d8b?w=400&q=80',
                                  name: isAr ? 'سمر_شوب' : 'Summer Shop',
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 10),
                        Image.asset(
                          AssetsConstants.containerPng,
                          height: 500,
                          width: double.infinity,
                          fit: BoxFit.cover,
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

          // 2. Sticky Top Header (Top Bar, Announcements Bar, Category Selectors)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 8),

                  // Custom Top Bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // SFA Title (Centered)
                        Text(
                          'SFA',
                          style: GoogleFonts.cairo(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2.0,
                            color: Colors.white,
                          ),
                        ),
                        // Navigation Icons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Left Side (relative to screen space): Shopping Bag & Heart
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    context.read<DashboardBloc>().add(
                                      const CacheCurrentTabEvent(),
                                    );
                                    context.read<DashboardBloc>().add(
                                      const ChangeTabEvent(5),
                                    );
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: SvgPicture.asset(
                                      AssetsConstants.shoppingBag,
                                      width: 22,
                                      colorFilter: const ColorFilter.mode(
                                        Colors.white,
                                        BlendMode.srcIn,
                                      ),
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    context.read<DashboardBloc>().add(
                                      const CacheCurrentTabEvent(),
                                    );
                                    context.read<DashboardBloc>().add(
                                      const ChangeTabEvent(8),
                                    );
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: SvgPicture.asset(
                                      AssetsConstants.heart,
                                      width: 22,
                                      colorFilter: const ColorFilter.mode(
                                        Colors.white,
                                        BlendMode.srcIn,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            // Right Side (relative to screen space): Search & Menu
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                GestureDetector(
                                  onTap: () {},
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: SvgPicture.asset(
                                      AssetsConstants.search,
                                      width: 22,
                                      colorFilter: const ColorFilter.mode(
                                        Colors.white,
                                        BlendMode.srcIn,
                                      ),
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    context.read<DashboardBloc>().add(
                                      const SetDrawerOpenEvent(true),
                                    );
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: SvgPicture.asset(
                                      AssetsConstants.menu,
                                      width: 22,
                                      colorFilter: const ColorFilter.mode(
                                        Colors.white,
                                        BlendMode.srcIn,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
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
                  const SizedBox(height: 12),

                  // Announcements Bar
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        // Free Gift Wrapping Card
                        Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 16,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.12),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                loc.translate('freeGiftWrap'),
                                style: GoogleFonts.cairo(
                                  color: Colors.white.withValues(alpha: 0.9),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(width: 8),
                              SvgPicture.asset(
                                AssetsConstants.gift,
                                width: 16,
                                height: 16,
                                colorFilter: const ColorFilter.mode(
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
                            color: Colors.white.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.12),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              loc.translate('fastDelivery'),
                              style: GoogleFonts.cairo(
                                color: Colors.white.withValues(alpha: 0.9),
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
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Directionality(
                      textDirection: isAr
                          ? TextDirection.rtl
                          : TextDirection.ltr,
                      child: BlocBuilder<HomeBloc, HomeState>(
                        builder: (context, state) {
                          final selectedCategoryIndex = state.selectedCategoryIndex;
                          return Row(
                            children: [
                              _buildTab(context, 0, loc.translate('women'), selectedCategoryIndex),
                              const SizedBox(width: 12),
                              _buildTab(context, 1, loc.translate('men'), selectedCategoryIndex),
                              const SizedBox(width: 12),
                              _buildTab(context, 2, loc.translate('kids'), selectedCategoryIndex),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(BuildContext context, int index, String label, int selectedCategoryIndex) {
    final isSelected = selectedCategoryIndex == index;
    return GestureDetector(
      onTap: () {
        context.read<HomeBloc>().add(ChangeCategoryIndexEvent(index));
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

  Widget _buildBrandCard({required String imageUrl, required String name}) {
    return AspectRatio(
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
    );
  }
}
