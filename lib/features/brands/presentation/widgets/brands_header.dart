import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sfa/core/localization/app_localizations.dart';
import 'package:sfa/utils/app_style.dart';
import 'package:sfa/features/brands/providers/brands_provider.dart';
import 'package:sfa/features/catalog/providers/catalog_providers.dart';

class BrandsHeader extends ConsumerWidget {
  const BrandsHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context);
    final isAr = loc.isArabic;

    final genderTabs = [
      loc.translate('women'),
      loc.translate('men'),
      loc.translate('kids'),
    ];

    final heading = loc.translate('saudiBrands');

    final searchHint = loc.translate('searchHintBrands');

    final state = ref.watch(brandsProvider);
    final categoriesAsync = ref.watch(brandCategoriesProvider);

    return Container(
      color: Colors.transparent,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Divider Line
                Container(
                  height: 1,
                  color: Colors.white.withOpacity(0.18),
                  margin: const EdgeInsets.only(top: 4, bottom: 16),
                ),

                // ── Heading (Right-aligned) ──
                Align(
                  alignment: isAr
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
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
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                //   children: List.generate(genderTabs.length, (i) {
                //     final isSelected = state.selectedGender == i;
                //     return GestureDetector(
                //       onTap: () =>
                //           ref.read(brandsProvider.notifier).changeGender(i),
                //       child: isSelected
                //           ? Column(
                //               mainAxisSize: MainAxisSize.min,
                //               children: [
                //                 ClipRRect(
                //                   borderRadius: BorderRadius.circular(8),
                //                   child: BackdropFilter(
                //                     filter: ImageFilter.blur(
                //                       sigmaX: 10,
                //                       sigmaY: 10,
                //                     ),
                //                     child: Container(
                //                       padding: const EdgeInsets.symmetric(
                //                         horizontal: 32,
                //                         vertical: 10,
                //                       ),
                //                       decoration: BoxDecoration(
                //                         color: Colors.white.withOpacity(0.18),
                //                         borderRadius: BorderRadius.circular(8),
                //                         border: Border.all(
                //                           color: Colors.white.withOpacity(0.35),
                //                           width: 1,
                //                         ),
                //                       ),
                //                       child: Text(
                //                         genderTabs[i],
                //                         style: AppStyle.tabSelected.copyWith(
                //                           fontSize: 16,
                //                           fontWeight: FontWeight.w700,
                //                           color: Colors.white,
                //                         ),
                //                       ),
                //                     ),
                //                   ),
                //                 ),
                //                 CustomPaint(
                //                   size: const Size(12, 6),
                //                   painter: _DownCaretPainter(),
                //                 ),
                //               ],
                //             )
                //           : Padding(
                //               padding: const EdgeInsets.symmetric(
                //                 horizontal: 24,
                //                 vertical: 10,
                //               ),
                //               child: Text(
                //                 genderTabs[i],
                //                 style: AppStyle.tabUnselected.copyWith(
                //                   fontSize: 16,
                //                   fontWeight: FontWeight.w400,
                //                   color: Colors.white.withOpacity(0.70),
                //                 ),
                //               ),
                //             ),
                //     );
                //   }),
                // ),
                const SizedBox(height: 16),

                // ── Category row ──
                categoriesAsync.when(
                  // The Brands grid below already shows the page's one
                  // loading indicator while brands+categories are in
                  // flight, so this row stays blank rather than showing a
                  // second spinner.
                  loading: () => const SizedBox(height: 32),
                  error: (error, _) => const SizedBox(height: 32),
                  data: (categories) {
                    final chips = <_CategoryChip>[
                      _CategoryChip(
                        id: '',
                        label: loc.translate('allCategories'),
                      ),
                      ...categories.map(
                        (c) => _CategoryChip(
                          id: c.id,
                          label: c.name.resolve(isAr),
                        ),
                      ),
                    ];
                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      reverse: isAr,
                      child: Row(
                        children: chips.map((chip) {
                          final sel = state.selectedCategoryId == chip.id;
                          return GestureDetector(
                            onTap: () => ref
                                .read(brandsProvider.notifier)
                                .changeCategory(chip.id),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 4,
                              ),
                              child: Text(
                                chip.label,
                                style: AppStyle.categoryLabel.copyWith(
                                  fontSize: 15,
                                  fontWeight: sel
                                      ? FontWeight.w700
                                      : FontWeight.w400,
                                  color: sel
                                      ? Colors.white
                                      : Colors.white.withOpacity(0.60),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    );
                  },
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
                      // Padding(
                      //   padding: const EdgeInsets.only(right: 14, left: 10),
                      //   child: SvgPicture.asset(
                      //     AssetsConstants.search2,
                      //     colorFilter: const ColorFilter.mode(
                      //       Colors.white,
                      //       BlendMode.srcIn,
                      //     ),
                      //     width: 18,
                      //     height: 18,
                      //   ),
                      // ),
                    ],
                  ),
                ),
                const SizedBox(height: 2),
              ],
            ),
          ),
        ],
      ),
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

class _CategoryChip {
  final String id;
  final String label;

  const _CategoryChip({required this.id, required this.label});
}
