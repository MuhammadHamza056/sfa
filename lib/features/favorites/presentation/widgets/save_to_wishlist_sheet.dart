import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sfa/core/localization/app_localizations.dart';
import 'package:sfa/core/theme/app_palette.dart';
import 'package:sfa/features/favorites/data/wishlist_models.dart';
import 'package:sfa/features/favorites/providers/wishlists_providers.dart';
import 'package:sfa/utils/color_constants.dart';

import 'wishlist_name_dialog.dart';

/// What the sheet popped with, so the caller owns the confirmation snackbar
/// (the same split [_AddToCartButton] uses — a snackbar raised from inside a
/// modal sheet is torn down with the sheet).
class SaveToWishlistResult {
  final bool added;
  final String? errorMessage;

  const SaveToWishlistResult.added() : added = true, errorMessage = null;
  const SaveToWishlistResult.failed(this.errorMessage) : added = false;
}

/// M88 — picks a wishlist to drop the current product into, with an inline
/// "create a new one" row so an empty account isn't a dead end.
///
/// Deliberately separate from the heart icon: the heart is M83 `/favorites`,
/// a flat per-user list, while this writes to a specific collaborative
/// wishlist. They are different backend collections, so they get different
/// affordances.
class SaveToWishlistSheet extends ConsumerStatefulWidget {
  final String productId;
  final String? selectedSize;
  final String? selectedColor;

  const SaveToWishlistSheet({
    super.key,
    required this.productId,
    this.selectedSize,
    this.selectedColor,
  });

  static Future<SaveToWishlistResult?> show(
    BuildContext context, {
    required String productId,
    String? selectedSize,
    String? selectedColor,
  }) {
    return showModalBottomSheet<SaveToWishlistResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => SaveToWishlistSheet(
        productId: productId,
        selectedSize: selectedSize,
        selectedColor: selectedColor,
      ),
    );
  }

  @override
  ConsumerState<SaveToWishlistSheet> createState() =>
      _SaveToWishlistSheetState();
}

class _SaveToWishlistSheetState extends ConsumerState<SaveToWishlistSheet> {
  /// Marks the "create new wishlist" row as busy. Real rows key off the
  /// wishlist id, so this is spelled to be unusable as one.
  static const String _createRowKey = '\u0000create';

  /// Id of the row with a write in flight, or null when idle. Only one write
  /// can run at a time, so every other row disables while it does.
  String? _pendingId;

  bool get _isBusy => _pendingId != null;

  Future<void> _addTo(WishlistSummary wishlist) async {
    final loc = AppLocalizations.of(context);

    // A summary that parsed without an id would POST to `/wishlists//items`.
    // Fail loudly instead of writing to a URL that cannot be right.
    if (wishlist.id.isEmpty) {
      Navigator.of(
        context,
      ).pop(SaveToWishlistResult.failed(loc.translate('addToWishlistFailed')));
      return;
    }

    setState(() => _pendingId = wishlist.id);
    final result = await ref
        .read(wishlistsRepositoryProvider)
        .addItem(
          wishlist.id,
          productId: widget.productId,
          selectedSize: widget.selectedSize,
          selectedColor: widget.selectedColor,
        );
    if (!mounted) return;

    if (result.isSuccess) {
      // The summary's itemCount and covers, and the detail page if it is
      // already built, are both stale now.
      ref.invalidate(wishlistsListProvider);
      ref.invalidate(wishlistDetailProvider(wishlist.id));
      Navigator.of(context).pop(const SaveToWishlistResult.added());
    } else {
      setState(() => _pendingId = null);
      Navigator.of(
        context,
      ).pop(SaveToWishlistResult.failed(result.errorOrNull?.toString()));
    }
  }

  Future<void> _onCreateAndAdd() async {
    final name = await promptWishlistName(context);
    if (name == null || !mounted) return;

    setState(() => _pendingId = _createRowKey);
    final created = await ref
        .read(wishlistsRepositoryProvider)
        .createWishlist(name);
    if (!mounted) return;

    final wishlist = created.dataOrNull;
    if (wishlist == null) {
      setState(() => _pendingId = null);
      Navigator.of(context).pop(
        SaveToWishlistResult.failed(created.errorOrNull?.toString()),
      );
      return;
    }

    // The list gained a row whether or not the item write below lands.
    ref.invalidate(wishlistsListProvider);
    await _addTo(wishlist);
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final isAr = loc.isArabic;
    final wishlistsAsync = ref.watch(wishlistsListProvider);

    return Directionality(
      textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
      child: SafeArea(
        top: false,
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.85,
          ),
          decoration: BoxDecoration(
            color: context.palette.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _Header(title: loc.translate('selectWishlist')),
              Flexible(
                child: wishlistsAsync.when(
                  loading: () => const Padding(
                    padding: EdgeInsets.symmetric(vertical: 48),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (error, _) => Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 48,
                    ),
                    child: Center(
                      child: Text(
                        error.toString(),
                        textAlign: TextAlign.center,
                        style: GoogleFonts.cairo(
                          fontSize: 14,
                          color: context.palette.textMuted,
                        ),
                      ),
                    ),
                  ),
                  data: (wishlists) => ListView(
                    shrinkWrap: true,
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                    children: [
                      if (wishlists.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 24),
                          child: Center(
                            child: Text(
                              loc.translate('noWishlistsYet'),
                              style: GoogleFonts.cairo(
                                fontSize: 15,
                                color: context.palette.textMuted,
                              ),
                            ),
                          ),
                        ),
                      for (final wishlist in wishlists)
                        _WishlistRow(
                          wishlist: wishlist,
                          isPending: _pendingId == wishlist.id,
                          enabled: !_isBusy,
                          onTap: () => _addTo(wishlist),
                        ),
                      const SizedBox(height: 4),
                      _CreateRow(
                        label: loc.translate('createNewWishlist'),
                        isPending: _pendingId == _createRowKey,
                        enabled: !_isBusy,
                        onTap: _onCreateAndAdd,
                      ),
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

class _Header extends StatelessWidget {
  final String title;

  const _Header({required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: context.palette.divider, width: 1),
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 56, vertical: 20),
            child: Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.cairo(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: context.palette.textPrimary,
              ),
            ),
          ),
          PositionedDirectional(
            end: 4,
            child: IconButton(
              icon: Icon(
                Icons.close,
                color: context.palette.textPrimary,
                size: 22,
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ],
      ),
    );
  }
}

class _WishlistRow extends StatelessWidget {
  final WishlistSummary wishlist;
  final bool isPending;
  final bool enabled;
  final VoidCallback onTap;

  const _WishlistRow({
    required this.wishlist,
    required this.isPending,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final cover = wishlist.coverImages.isNotEmpty
        ? wishlist.coverImages.first
        : null;

    return Opacity(
      opacity: enabled || isPending ? 1 : 0.4,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: SizedBox(
                  width: 48,
                  height: 48,
                  child: cover == null
                      ? Container(color: context.palette.surfaceMuted)
                      : Image.network(
                          cover,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              Container(color: context.palette.surfaceMuted),
                        ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      wishlist.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.cairo(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: context.palette.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${wishlist.itemCount} ${loc.translate('productsCount')}',
                      style: GoogleFonts.cairo(
                        fontSize: 12,
                        color: context.palette.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 24,
                height: 24,
                child: isPending
                    ? const CircularProgressIndicator(strokeWidth: 2.5)
                    : Icon(
                        Icons.add,
                        size: 22,
                        color: context.palette.textPrimary,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CreateRow extends StatelessWidget {
  final String label;
  final bool isPending;
  final bool enabled;
  final VoidCallback onTap;

  const _CreateRow({
    required this.label,
    required this.isPending,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: enabled ? onTap : null,
      style: OutlinedButton.styleFrom(
        side: BorderSide(
          color: context.palette.textPrimary.withValues(alpha: 0.3),
          width: 1,
        ),
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
        minimumSize: const Size(double.infinity, 50),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.cairo(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: context.palette.textPrimary,
            ),
          ),
          SizedBox(
            width: 20,
            height: 20,
            child: isPending
                ? const CircularProgressIndicator(strokeWidth: 2.5)
                : Icon(Icons.add, color: AppColors.primary, size: 20),
          ),
        ],
      ),
    );
  }
}
