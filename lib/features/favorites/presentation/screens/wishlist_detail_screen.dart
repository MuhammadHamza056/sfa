import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sfa/core/localization/app_localizations.dart';
import 'package:sfa/core/theme/app_palette.dart';
import 'package:sfa/utils/assets_constants.dart';
import 'package:sfa/features/favorites/data/wishlist_models.dart';
import 'package:sfa/features/favorites/providers/wishlists_providers.dart';

/// Figma `434:708` ("shearable list").
///
/// The mock is laid out positionally rather than with RTL flow, so its
/// visual order is the *Arabic* order: wishlist title on the right, product
/// image on the right, each label to the right of the swatch/chip it
/// describes. Everything here is therefore expressed with direction-aware
/// alignment (leading/start), which reproduces the mock under `rtl` and
/// mirrors sensibly under `ltr`.
class WishlistDetailScreen extends ConsumerWidget {
  final String wishlistId;

  const WishlistDetailScreen({super.key, required this.wishlistId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context);
    final isAr = loc.isArabic;
    final detailAsync = ref.watch(wishlistDetailProvider(wishlistId));

    return Directionality(
      textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: context.palette.background,
        body: detailAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(
            child: Text(
              error.toString(),
              style: TextStyle(color: context.palette.textMuted),
            ),
          ),
          data: (wishlist) => ListView(
            padding: EdgeInsets.zero,
            children: [
              // Header block — `px-[10px] py-[20px]`, 20px between its rows.
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _TitleRow(wishlist: wishlist),
                    if (wishlist.ownerName.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      _OwnerCard(wishlist: wishlist),
                    ],
                  ],
                ),
              ),

              // Product list — full-bleed, so the imagery reaches the screen
              // edge as designed. `py-[10px]`, rows separated by 20/1/20.
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Column(
                  children: [
                    for (int i = 0; i < wishlist.items.length; i++) ...[
                      if (i != 0) ...[
                        const SizedBox(height: 20),
                        const _HairLine(),
                        const SizedBox(height: 20),
                      ],
                      _ProductRow(
                        wishlistId: wishlistId,
                        item: wishlist.items[i],
                      ),
                    ],
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

/// The `--grey` 1px rule used both between rows and inside a row's detail
/// stack. Full width, so it needs an explicit infinite width to survive a
/// `CrossAxisAlignment.start` parent.
class _HairLine extends StatelessWidget {
  const _HairLine();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      width: double.infinity,
      color: context.palette.surfaceMuted,
    );
  }
}

class _TitleRow extends StatelessWidget {
  final WishlistDetail wishlist;

  const _TitleRow({required this.wishlist});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: context.palette.textPrimary.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Leading (right, in Arabic) per the mock: the list name, then the
          // count on the far side.
          Flexible(
            child: Text(
              wishlist.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.cairo(
                fontSize: 21,
                height: 28 / 21,
                fontWeight: FontWeight.bold,
                color: context.palette.textPrimary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '${wishlist.items.length} ${loc.translate('productsCount')}',
            style: GoogleFonts.cairo(
              fontSize: 15,
              height: 22 / 15,
              fontWeight: FontWeight.w300,
              color: context.palette.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _OwnerCard extends StatelessWidget {
  final WishlistDetail wishlist;

  const _OwnerCard({required this.wishlist});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.palette.surfaceMuted,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  loc.translate('wishlistAddedBy'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.cairo(
                    fontSize: 15,
                    height: 22 / 15,
                    fontWeight: FontWeight.w300,
                    color: context.palette.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  wishlist.ownerName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.cairo(
                    fontSize: 18,
                    height: 24 / 18,
                    color: context.palette.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          if (wishlist.ownerAvatar.isNotEmpty) ...[
            const SizedBox(width: 12),
            Container(
              width: 86,
              height: 86,
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                // `--gold2` #CA9A4E, which is what `palette.primary` resolves
                // to in both themes.
                border: Border.all(color: context.palette.primary, width: 2),
              ),
              child: ClipOval(
                child: Image.network(
                  wishlist.ownerAvatar,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      Container(color: context.palette.surfaceAlt),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ProductRow extends StatelessWidget {
  final String wishlistId;
  final WishlistItemEntry item;

  const _ProductRow({required this.wishlistId, required this.item});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Leading (right, in Arabic) and full-bleed to the screen edge.
          Expanded(child: _Image(wishlistId: wishlistId, item: item)),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 12, right: 12, bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    item.brandName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.cairo(
                      fontSize: 15,
                      height: 22 / 15,
                      fontWeight: FontWeight.w600,
                      color: context.palette.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.cairo(
                      fontSize: 15,
                      height: 22 / 15,
                      fontWeight: FontWeight.w600,
                      color: context.palette.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    item.price,
                    style: GoogleFonts.cairo(
                      fontSize: 15,
                      height: 22 / 15,
                      fontWeight: FontWeight.w600,
                      color: context.palette.primary,
                    ),
                  ),
                  if (item.colorValue != null) ...[
                    const SizedBox(height: 10),
                    const _HairLine(),
                    const SizedBox(height: 10),
                    _DetailRow(
                      label: loc.translate('colorLabel'),
                      trailing: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: item.colorValue,
                        ),
                      ),
                    ),
                  ],
                  if (item.selectedSize != null) ...[
                    const SizedBox(height: 10),
                    const _HairLine(),
                    const SizedBox(height: 10),
                    _DetailRow(
                      label: loc.translate('sizeLabel'),
                      trailing: Container(
                        width: 32,
                        height: 32,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: context.palette.surfaceMuted,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          item.selectedSize!,
                          style: GoogleFonts.cairo(
                            fontSize: 15,
                            height: 18 / 15,
                            fontWeight: FontWeight.w500,
                            color: context.palette.textPrimary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A label followed by its swatch/chip. The label takes the leading edge —
/// the right, in Arabic — matching the mock's `justify-end` rows.
class _DetailRow extends StatelessWidget {
  final String label;
  final Widget trailing;

  const _DetailRow({required this.label, required this.trailing});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: GoogleFonts.cairo(
            fontSize: 15,
            height: 22 / 15,
            fontWeight: FontWeight.w300,
            color: context.palette.textPrimary,
          ),
        ),
        const SizedBox(width: 10),
        trailing,
      ],
    );
  }
}

class _Image extends ConsumerWidget {
  final String wishlistId;
  final WishlistItemEntry item;

  const _Image({required this.wishlistId, required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.network(
          item.imageUrl,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) =>
              Container(color: context.palette.surfaceMuted),
        ),
        // `start` keeps the control on the image's outer edge in both
        // directions — the screen's right in Arabic, as drawn.
        PositionedDirectional(
          top: 12,
          start: 10,
          child: GestureDetector(
            onTap: () async {
              final result = await ref
                  .read(wishlistsRepositoryProvider)
                  .removeItem(wishlistId, item.productId);
              if (result.isSuccess) {
                ref.invalidate(wishlistDetailProvider(wishlistId));
              }
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: Container(
                  width: 32,
                  height: 32,
                  alignment: Alignment.center,
                  color: Colors.white.withValues(alpha: 0.67),
                  // The asset already carries the designed #220D1D @ 50%
                  // stroke, so it renders untinted.
                  child: SvgPicture.asset(
                    AssetsConstants.trash,
                    width: 18,
                    height: 18,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
