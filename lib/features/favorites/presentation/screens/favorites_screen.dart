import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sfa/core/localization/app_localizations.dart';
import 'package:sfa/core/models/product.dart';
import 'package:sfa/core/widgets/product_card.dart';
import 'package:sfa/utils/assets_constants.dart';
import 'package:sfa/utils/color_constants.dart';
import 'package:sfa/features/favorites/data/wishlist_models.dart';
import 'package:sfa/features/favorites/providers/favorites_provider.dart';
import 'package:sfa/features/favorites/providers/wishlists_providers.dart';
import 'package:sfa/core/theme/app_palette.dart';
import 'package:sfa/core/theme/always_light.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  Future<void> _onAddWishlist(BuildContext context, WidgetRef ref, AppLocalizations loc) async {
    final controller = TextEditingController();
    final title = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(loc.translate('addWishlist')),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(hintText: loc.isArabic ? 'اسم القائمة' : 'Wishlist name'),
        ),
        actions: [
          TextButton(onPressed: () => context.pop(), child: Text(loc.translate('cancel'))),
          TextButton(
            onPressed: () => context.pop(controller.text.trim()),
            child: Text(loc.translate('addWishlist')),
          ),
        ],
      ),
    );
    if (title == null || title.isEmpty) return;
    final result = await ref.read(wishlistsRepositoryProvider).createWishlist(title);
    if (result.isSuccess) {
      ref.invalidate(wishlistsListProvider);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context);
    final isAr = loc.isArabic;

    final favoritesState = ref.watch(favoritesProvider);
    final selectedTab = favoritesState.selectedTab;

    return Scaffold(
      backgroundColor: context.palette.background,
      body: Directionality(
        textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
        child: Column(
          children: [
            // Tabs Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                children: [
                  // Wishlists Tab
                  Expanded(
                    child: GestureDetector(
                      onTap: () => ref.read(favoritesProvider.notifier).changeTab(0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: selectedTab == 0 ? AppColors.primary : context.palette.surfaceMuted,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          loc.translate('wishlists'),
                          style: GoogleFonts.cairo(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: selectedTab == 0 ? Colors.white : context.palette.textMuted,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Favorites Tab
                  Expanded(
                    child: GestureDetector(
                      onTap: () => ref.read(favoritesProvider.notifier).changeTab(1),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: selectedTab == 1 ? AppColors.primary : context.palette.surfaceMuted,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          loc.translate('favorites'),
                          style: GoogleFonts.cairo(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: selectedTab == 1 ? Colors.white : context.palette.textMuted,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Content Title
            Align(
              alignment: isAr ? Alignment.centerRight : Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  selectedTab == 0
                      ? loc.translate('collaborativeWishlists')
                      : loc.translate('favoriteProductsTitle'),
                  style: GoogleFonts.cairo(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: context.palette.textPrimary,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Main Content Area
            Expanded(
              child: selectedTab == 0
                  ? _WishlistsTab(isAr: isAr)
                  : _FavoritesTab(favoritesState: favoritesState, isAr: isAr),
            ),

            // Add Wishlist button at bottom (only visible for Wishlists tab)
            if (selectedTab == 0)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: OutlinedButton(
                  onPressed: () => _onAddWishlist(context, ref, loc),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: context.palette.textPrimary.withValues(alpha: 0.3), width: 1),
                    shape: const StadiumBorder(),
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                    minimumSize: const Size(double.infinity, 50),
                    backgroundColor: context.palette.background,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        loc.translate('addWishlist'),
                        style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.bold, color: context.palette.textPrimary),
                      ),
                      Icon(Icons.add, color: context.palette.textPrimary, size: 20),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _FavoritesTab extends StatelessWidget {
  final FavoritesState favoritesState;
  final bool isAr;

  const _FavoritesTab({required this.favoritesState, required this.isAr});

  @override
  Widget build(BuildContext context) {
    if (favoritesState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (favoritesState.favorites.isEmpty) {
      return Center(
        child: Text(
          isAr ? 'لا توجد منتجات مفضلة بعد' : 'No favorite products yet',
          style: GoogleFonts.cairo(fontSize: 16, color: context.palette.textMuted),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.7,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: favoritesState.favorites.length,
      itemBuilder: (context, index) {
        final product = favoritesState.favorites[index];
        return ProductCard(
          isAr: isAr,
          product: Product(
            id: product.productId,
            imageUrl: product.imageUrl,
            title: product.title,
            price: product.price,
            rating: product.rating,
            brandName: product.brandName,
          ),
        );
      },
    );
  }
}

class _WishlistsTab extends ConsumerWidget {
  final bool isAr;

  const _WishlistsTab({required this.isAr});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wishlistsAsync = ref.watch(wishlistsListProvider);

    return wishlistsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(
        child: Text(error.toString(), style: TextStyle(color: context.palette.textMuted)),
      ),
      data: (wishlists) {
        if (wishlists.isEmpty) {
          return Center(
            child: Text(
              isAr ? 'لا توجد قوائم أمنيات بعد' : 'No wishlists yet',
              style: GoogleFonts.cairo(fontSize: 16, color: context.palette.textMuted),
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: wishlists.length,
          itemBuilder: (context, index) => _buildWishlistCard(context, wishlists[index], isAr),
        );
      },
    );
  }

  Widget _buildWishlistCard(BuildContext context, WishlistSummary wishlist, bool isAr) {
    final loc = AppLocalizations.of(context);

    return AlwaysLight(
      child: GestureDetector(
        onTap: () => context.push('/wishlist-detail/${wishlist.id}'),
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFFDFDFD),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFF3EFE9), width: 1),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4)),
            ],
          ),
          child: Column(
            children: [
              // Cover images row
              Row(
                children: List.generate(3, (imgIndex) {
                  final url = imgIndex < wishlist.coverImages.length ? wishlist.coverImages[imgIndex] : null;
                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(left: imgIndex == 2 ? 0 : 8.0, right: imgIndex == 0 ? 0 : 8.0),
                      child: AspectRatio(
                        aspectRatio: 0.9,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: url == null
                              ? Container(color: Colors.grey.shade200)
                              : Image.network(
                                  url,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey.shade200),
                                ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 14),

              // Title + Count & Share Button Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: isAr ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                    children: [
                      Text(
                        wishlist.title,
                        style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.bold, color: context.palette.textPrimary),
                      ),
                      Text(
                        '${wishlist.itemCount} ${loc.translate('productsCount')}',
                        style: GoogleFonts.cairo(fontSize: 12, color: context.palette.textMuted),
                      ),
                    ],
                  ),
                  Theme(
                    data: Theme.of(context).copyWith(cardColor: const Color(0xFFF5EFEB)),
                    child: PopupMenuButton<int>(
                      offset: const Offset(0, 40),
                      elevation: 4,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      icon: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: context.palette.textPrimary.withValues(alpha: 0.1), width: 1),
                        ),
                        padding: const EdgeInsets.all(8),
                        child: SvgPicture.asset(
                          AssetsConstants.iconShare2,
                          width: 18,
                          height: 18,
                          colorFilter: ColorFilter.mode(context.palette.textPrimary, BlendMode.srcIn),
                        ),
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onSelected: (val) async {
                        if (val != 1) return;
                        final result = await ProviderScope.containerOf(context)
                            .read(wishlistsRepositoryProvider)
                            .getShareLink(wishlist.id);
                        final link = result.dataOrNull?.shareUrl;
                        if (link == null) return;
                        Clipboard.setData(ClipboardData(text: link));
                        Share.share(
                          isAr ? 'ألقِ نظرة على قائمة أمنياتي: $link' : 'Check out my wishlist: $link',
                        );
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 1,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.copy_rounded, color: context.palette.textPrimary, size: 18),
                              const SizedBox(width: 8),
                              Text(
                                loc.translate('copyShareLink'),
                                style: GoogleFonts.cairo(fontSize: 13, fontWeight: FontWeight.bold, color: context.palette.textPrimary),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
