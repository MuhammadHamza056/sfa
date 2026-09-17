import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sfa/core/localization/app_localizations.dart';
import 'package:sfa/utils/app_style.dart';
import 'package:sfa/features/brands/providers/brands_provider.dart';
import 'package:sfa/features/catalog/providers/catalog_providers.dart';

/// Divider + "Saudi Brands" heading. Scrolls away normally with the rest of
/// the page — only [BrandsCategoryChips] below it pins under the app bar.
class BrandsHeaderTop extends ConsumerWidget {
  const BrandsHeaderTop({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context);
    final isAr = loc.isArabic;
    final heading = loc.translate('saudiBrands');

    return Padding(
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
            alignment: isAr ? Alignment.centerRight : Alignment.centerLeft,
            child: Text(
              heading,
              style: AppStyle.headerHeading.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                // color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Horizontally scrollable category chip row. Pinned below the app bar via a
/// [SliverPersistentHeader] in [BrandsScreen] once the page scrolls past it.
class BrandsCategoryChips extends ConsumerWidget {
  /// Controller for the page's [CustomScrollView] — scrolled to top before
  /// switching category so the brand grid swap isn't hidden below the fold.
  final ScrollController scrollController;

  const BrandsCategoryChips({super.key, required this.scrollController});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context);
    final isAr = loc.isArabic;
    final state = ref.watch(brandsProvider);
    final categoriesAsync = ref.watch(brandCategoriesProvider);

    return categoriesAsync.when(
      // The Brands grid below already shows the page's one loading
      // indicator while brands+categories are in flight, so this row stays
      // blank rather than showing a second spinner.
      loading: () => const SizedBox(height: 32),
      error: (error, _) => const SizedBox(height: 32),
      data: (categories) {
        final chips = <_CategoryChip>[
          _CategoryChip(id: '', label: loc.translate('allCategories')),
          ...categories.map(
            (c) => _CategoryChip(id: c.id, label: c.name.resolve(isAr)),
          ),
        ];
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          reverse: isAr,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: chips.map((chip) {
              final sel = state.selectedCategoryId == chip.id;
              return GestureDetector(
                onTap: () async {
                  if (scrollController.hasClients) {
                    await scrollController.animateTo(
                      0,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                    );
                  }
                  ref.read(brandsProvider.notifier).changeCategory(chip.id);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  child: Text(
                    chip.label,
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
            }).toList(),
          ),
        );
      },
    );
  }
}

/// Transparent, white-outlined search field shown under the category row.
/// Filters the brand grid client-side by name via [brandsProvider].
class BrandsSearchBar extends ConsumerWidget {
  const BrandsSearchBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context);
    final isAr = loc.isArabic;
    final searchHint = loc.translate('searchHintBrands');

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white.withOpacity(0.75), width: 1.2),
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
                onChanged: (value) =>
                    ref.read(brandsProvider.notifier).updateSearchQuery(value),
                decoration: InputDecoration(
                  hintText: searchHint,
                  hintStyle: AppStyle.searchHint.copyWith(
                    fontSize: 13,
                    // color: Colors.white.withOpacity(0.60),
                  ),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryChip {
  final String id;
  final String label;

  const _CategoryChip({required this.id, required this.label});
}
