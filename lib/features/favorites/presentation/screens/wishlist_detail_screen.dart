import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sfa/core/localization/app_localizations.dart';
import 'package:sfa/core/theme/app_palette.dart';
import 'package:sfa/utils/assets_constants.dart';
import 'package:sfa/features/favorites/data/wishlist_models.dart';
import 'package:sfa/features/favorites/providers/wishlists_providers.dart';

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
            child: Text(error.toString(), style: TextStyle(color: context.palette.textMuted)),
          ),
          data: (wishlist) => SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Title + product count row
                Container(
                  padding: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: context.palette.textPrimary.withValues(alpha: 0.1), width: 1),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${wishlist.items.length} ${loc.translate('productsCount')}',
                        style: GoogleFonts.cairo(fontSize: 15, fontWeight: FontWeight.w300, color: context.palette.textPrimary),
                      ),
                      Text(
                        wishlist.title,
                        style: GoogleFonts.cairo(fontSize: 21, fontWeight: FontWeight.bold, color: context.palette.textPrimary),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                if (wishlist.ownerName.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: context.palette.surfaceMuted,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              loc.translate('wishlistAddedBy'),
                              style: GoogleFonts.cairo(fontSize: 15, fontWeight: FontWeight.w300, color: context.palette.textPrimary),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              wishlist.ownerName,
                              style: GoogleFonts.cairo(fontSize: 18, color: context.palette.textPrimary),
                            ),
                          ],
                        ),
                        if (wishlist.ownerAvatar.isNotEmpty)
                          Container(
                            width: 86,
                            height: 86,
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: context.palette.primary, width: 2),
                            ),
                            child: ClipOval(
                              child: Image.network(
                                wishlist.ownerAvatar,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => Container(color: context.palette.surfaceAlt),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                const SizedBox(height: 10),

                for (int i = 0; i < wishlist.items.length; i++) ...[
                  _buildProductRow(context, ref, wishlist.items[i], isAr, loc),
                  if (i != wishlist.items.length - 1) Container(height: 0.2, color: context.palette.divider),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProductRow(
    BuildContext context,
    WidgetRef ref,
    WishlistItemEntry item,
    bool isAr,
    AppLocalizations loc,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Image.network(
                      item.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(color: context.palette.surfaceMuted),
                    ),
                  ),
                  Positioned(
                    top: 12,
                    right: 10,
                    child: GestureDetector(
                      onTap: () async {
                        final result = await ref
                            .read(wishlistsRepositoryProvider)
                            .removeItem(wishlistId, item.productId);
                        if (result.isSuccess) {
                          ref.invalidate(wishlistDetailProvider(wishlistId));
                        }
                      },
                      child: Container(
                        width: 32,
                        height: 32,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.67), borderRadius: BorderRadius.circular(16)),
                        child: SvgPicture.asset(
                          AssetsConstants.trash,
                          width: 18,
                          height: 18,
                          colorFilter: ColorFilter.mode(AppPalette.lightTextPrimary.withValues(alpha: 0.5), BlendMode.srcIn),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    item.brandName,
                    style: GoogleFonts.cairo(fontSize: 15, fontWeight: FontWeight.w600, color: context.palette.textPrimary),
                    textAlign: TextAlign.end,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.name,
                    style: GoogleFonts.cairo(fontSize: 15, fontWeight: FontWeight.w600, color: context.palette.textPrimary),
                    textAlign: TextAlign.end,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    item.price,
                    style: GoogleFonts.cairo(fontSize: 15, fontWeight: FontWeight.w600, color: context.palette.primary),
                  ),
                  if (item.colorValue != null) ...[
                    const SizedBox(height: 10),
                    Container(height: 0.2, color: context.palette.divider),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(shape: BoxShape.circle, color: item.colorValue),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          loc.translate('colorLabel'),
                          style: GoogleFonts.cairo(fontSize: 15, fontWeight: FontWeight.w300, color: context.palette.textPrimary),
                        ),
                      ],
                    ),
                  ],
                  if (item.selectedSize != null) ...[
                    const SizedBox(height: 10),
                    Container(height: 0.2, color: context.palette.divider),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(color: context.palette.surfaceMuted, borderRadius: BorderRadius.circular(4)),
                          child: Text(
                            item.selectedSize!,
                            style: GoogleFonts.cairo(fontSize: 15, fontWeight: FontWeight.w500, color: context.palette.textPrimary),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          loc.translate('sizeLabel'),
                          style: GoogleFonts.cairo(fontSize: 15, fontWeight: FontWeight.w300, color: context.palette.textPrimary),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
