import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sfa/core/localization/app_localizations.dart';
import 'package:sfa/utils/app_style.dart';
import 'package:sfa/utils/assets_constants.dart';
import 'package:sfa/features/brands/bloc/brands_bloc.dart';
import 'package:sfa/features/brands/bloc/brands_event.dart';
import 'package:sfa/features/brands/bloc/brands_state.dart';
import 'package:sfa/features/dashboard/bloc/dashboard_bloc.dart';
import 'package:sfa/features/dashboard/bloc/dashboard_event.dart';

class BrandsHeader extends StatelessWidget {
  const BrandsHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final isAr = loc.isArabic;

    final genderTabs = [
      loc.translate('women'),
      loc.translate('men'),
      loc.translate('kids'),
    ];

    final categories = [
      loc.translate('categoryBags'),
      loc.translate('categoryShoes'),
      loc.translate('categoryDresses'),
      loc.translate('categoryJewelry'),
      loc.translate('categoryAccessories'),
    ];

    final heading = loc.translate('saudiBrands');

    final searchHint = loc.translate('searchHintBrands');

    return BlocBuilder<BrandsBloc, BrandsState>(
      builder: (context, state) {
        return Container(
          color: Colors.transparent,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // ── Custom AppBar ──
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Left side: Shopping Bag & Heart
                          Row(
                            children: [
                              IconButton(
                                icon: SvgPicture.asset(
                                  AssetsConstants.shoppingBag,
                                  colorFilter: const ColorFilter.mode(
                                    Colors.white,
                                    BlendMode.srcIn,
                                  ),
                                  width: 24,
                                  height: 24,
                                ),
                                onPressed: () {
                                  context.read<DashboardBloc>().add(const CacheCurrentTabEvent());
                                  context.read<DashboardBloc>().add(const ChangeTabEvent(5));
                                },
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
                                onPressed: () {
                                  context.read<DashboardBloc>().add(const CacheCurrentTabEvent());
                                  context.read<DashboardBloc>().add(const ChangeTabEvent(8));
                                },
                              ),
                            ],
                          ),
                          // Center: SFA Serif Logo
                          Text(
                            'SFA',
                            style: GoogleFonts.playfairDisplay(
                              color: Colors.white,
                              fontSize: 38,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 1.5,
                            ),
                          ),
                          // Right side: Search & Menu
                          Row(
                            children: [
                              IconButton(
                                icon: SvgPicture.asset(
                                  AssetsConstants.search,
                                  colorFilter: const ColorFilter.mode(
                                    Colors.white,
                                    BlendMode.srcIn,
                                  ),
                                  width: 24,
                                  height: 24,
                                ),
                                onPressed: () {},
                              ),
                              const SizedBox(width: 4),
                              IconButton(
                                icon: SvgPicture.asset(
                                  AssetsConstants.menu,
                                  colorFilter: const ColorFilter.mode(
                                    Colors.white,
                                    BlendMode.srcIn,
                                  ),
                                  width: 24,
                                  height: 24,
                                ),
                                onPressed: () {
                                  context.read<DashboardBloc>().add(const SetDrawerOpenEvent(true));
                                },
                              ),
                            ],
                          ),
                        ],
                      ),

                      // Divider Line
                      Container(
                        height: 1,
                        color: Colors.white.withOpacity(0.18),
                        margin: const EdgeInsets.only(top: 4, bottom: 16),
                      ),

                      // ── Heading (Right-aligned) ──
                      Align(
                        alignment: isAr ? Alignment.centerRight : Alignment.centerLeft,
                        child: Text(
                          heading,
                          style: AppStyle.headerHeading.copyWith(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // ── Gender tabs ──
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: List.generate(genderTabs.length, (i) {
                          final isSelected = state.selectedGender == i;
                          return GestureDetector(
                            onTap: () => context
                                .read<BrandsBloc>()
                                .add(ChangeGenderEvent(i)),
                            child: isSelected
                                ? Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: BackdropFilter(
                                          filter: ImageFilter.blur(
                                            sigmaX: 10,
                                            sigmaY: 10,
                                          ),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 32,
                                              vertical: 10,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.white.withOpacity(0.18),
                                              borderRadius: BorderRadius.circular(8),
                                              border: Border.all(
                                                color: Colors.white.withOpacity(0.35),
                                                width: 1,
                                              ),
                                            ),
                                            child: Text(
                                              genderTabs[i],
                                              style: AppStyle.tabSelected.copyWith(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w700,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      CustomPaint(
                                        size: const Size(12, 6),
                                        painter: _DownCaretPainter(),
                                      ),
                                    ],
                                  )
                                : Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24,
                                      vertical: 10,
                                    ),
                                    child: Text(
                                      genderTabs[i],
                                      style: AppStyle.tabUnselected.copyWith(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w400,
                                        color: Colors.white.withOpacity(0.70),
                                      ),
                                    ),
                                  ),
                          );
                        }),
                      ),

                      const SizedBox(height: 16),

                      // ── Category row ──
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        reverse: isAr,
                        child: Row(
                          children: List.generate(categories.length, (i) {
                            final sel = state.selectedCategory == i;
                            return GestureDetector(
                              onTap: () => context
                                  .read<BrandsBloc>()
                                  .add(ChangeCategoryEvent(i)),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                child: Text(
                                  categories[i],
                                  style: AppStyle.categoryLabel.copyWith(
                                    fontSize: 15,
                                    fontWeight: sel ? FontWeight.w700 : FontWeight.w400,
                                    color: sel
                                        ? Colors.white
                                        : Colors.white.withOpacity(0.60),
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // ── Search bar — transparent with white outline ──
                      Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.75),
                            width: 1.2,
                          ),
                        ),
                        child: Row(
                          children: [
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextField(
                                textAlign: isAr ? TextAlign.end : TextAlign.start,
                                style: AppStyle.searchHint.copyWith(
                                  fontSize: 13,
                                  color: Colors.white,
                                ),
                                decoration: InputDecoration(
                                  hintText: searchHint,
                                  hintStyle: AppStyle.searchHint.copyWith(
                                    fontSize: 13,
                                    color: Colors.white.withOpacity(0.60),
                                  ),
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: EdgeInsets.zero,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(right: 14, left: 10),
                              child: SvgPicture.asset(
                                AssetsConstants.search2,
                                colorFilter: const ColorFilter.mode(
                                  Colors.white,
                                  BlendMode.srcIn,
                                ),
                                width: 18,
                                height: 18,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 2),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ── Down-pointing triangle caret ─────────────────────────────────────────────

class _DownCaretPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.35)
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_DownCaretPainter oldDelegate) => false;
}
