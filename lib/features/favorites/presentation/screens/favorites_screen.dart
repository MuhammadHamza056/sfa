import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sfa/core/localization/app_localizations.dart';
import 'package:sfa/utils/assets_constants.dart';
import 'package:sfa/utils/color_constants.dart';
import 'package:sfa/features/favorites/models/favorite_product.dart';
import 'package:sfa/features/favorites/bloc/favorites_bloc.dart';
import 'package:sfa/features/favorites/bloc/favorites_event.dart';
import 'package:sfa/features/favorites/bloc/favorites_state.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final isAr = loc.isArabic;

    // Mock Wishlist Data
    final List<Map<String, dynamic>> wishlists = [
      {
        'title': loc.translate('eidGifts'),
        'count': 8,
        'images': [
          'https://images.unsplash.com/photo-1609357518652-6cf0416f0cbe?w=300',
          'https://images.unsplash.com/photo-1595777457583-95e059d581b8?w=300',
          'https://images.unsplash.com/photo-1605763240000-7e93b172d754?w=300',
        ],
      },
      {
        'title': loc.translate('summerOutfits'),
        'count': 4,
        'images': [
          'https://images.unsplash.com/photo-1572804013309-59a88b7e92f1?w=300',
          'https://images.unsplash.com/photo-1605763240000-7e93b172d754?w=300',
          'https://images.unsplash.com/photo-1509631179647-0177331693ae?w=300',
        ],
      },
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocBuilder<FavoritesBloc, FavoritesState>(
        builder: (context, state) {
          final selectedTab = state.selectedTab;
          return Directionality(
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
                          onTap: () {
                            context.read<FavoritesBloc>().add(const ChangeFavoritesTabEvent(0));
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: selectedTab == 0
                                  ? AppColors.primary
                                  : const Color(0xFFF6F6F6),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              loc.translate('wishlists'),
                              style: GoogleFonts.cairo(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: selectedTab == 0
                                    ? Colors.white
                                    : AppColors.textcolor_50,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Favorites Tab
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            context.read<FavoritesBloc>().add(const ChangeFavoritesTabEvent(1));
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: selectedTab == 1
                                  ? AppColors.primary
                                  : const Color(0xFFF6F6F6),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              loc.translate('favorites'),
                              style: GoogleFonts.cairo(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: selectedTab == 1
                                    ? Colors.white
                                    : AppColors.textcolor_50,
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
                        color: AppColors.textcolor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // Main Content Area
                Expanded(
                  child: (() {
                    if (selectedTab == 0) {
                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: wishlists.length,
                        itemBuilder: (context, index) {
                          final list = wishlists[index];
                          return _buildWishlistCard(context, list, isAr);
                        },
                      );
                    }

                    final favoriteProducts = state.favorites;
                    if (favoriteProducts.isEmpty) {
                      return Center(
                        child: Text(
                          isAr ? 'لا توجد منتجات مفضلة بعد' : 'No favorite products yet',
                          style: GoogleFonts.cairo(
                            fontSize: 16,
                            color: AppColors.textcolor_50,
                          ),
                        ),
                      );
                    }

                    return GridView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.7,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                      itemCount: favoriteProducts.length,
                      itemBuilder: (context, index) {
                        final product = favoriteProducts[index];
                        return _buildFavoriteProductCard(context, product);
                      },
                    );
                  })(),
                ),

                // Add Wishlist button at bottom (only visible for Wishlists tab)
                if (selectedTab == 0)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: AppColors.textcolor.withValues(alpha: 0.3),
                          width: 1,
                        ),
                        shape: const StadiumBorder(),
                        padding: const EdgeInsets.symmetric(
                          vertical: 14,
                          horizontal: 24,
                        ),
                        minimumSize: const Size(double.infinity, 50),
                        backgroundColor: Colors.white,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            loc.translate('addWishlist'),
                            style: GoogleFonts.cairo(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textcolor,
                            ),
                          ),
                          Icon(Icons.add, color: AppColors.textcolor, size: 20),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildWishlistCard(
    BuildContext context,
    Map<String, dynamic> wishlist,
    bool isAr,
  ) {
    final List<String> images = wishlist['images'];
    final loc = AppLocalizations.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFDFDFD),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF3EFE9), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Three images row
          Row(
            children: List.generate(3, (imgIndex) {
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    left: imgIndex == 2 ? 0 : 8.0,
                    right: imgIndex == 0 ? 0 : 8.0,
                  ),
                  child: Stack(
                    children: [
                      AspectRatio(
                        aspectRatio: 0.9,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            images[imgIndex],
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(color: Colors.grey.shade200),
                          ),
                        ),
                      ),
                      // Heart button badge
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: SvgPicture.asset(
                            AssetsConstants.heart,
                            width: 14,
                            height: 14,
                            colorFilter: ColorFilter.mode(
                              AppColors.primary,
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                      ),
                    ],
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
              // Title and Product Count
              Column(
                crossAxisAlignment: isAr ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  Text(
                    wishlist['title'],
                    style: GoogleFonts.cairo(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textcolor,
                    ),
                  ),
                  Text(
                    '${wishlist['count']} ${loc.translate('productsCount')}',
                    style: GoogleFonts.cairo(
                      fontSize: 12,
                      color: AppColors.textcolor_50,
                    ),
                  ),
                ],
              ),

              // Share Button
              Theme(
                data: Theme.of(context).copyWith(
                  cardColor: const Color(0xFFF5EFEB), // beige background matching screenshot
                ),
                child: PopupMenuButton<int>(
                  offset: const Offset(0, 40),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  icon: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.textcolor.withValues(alpha: 0.1),
                        width: 1,
                      ),
                    ),
                    padding: const EdgeInsets.all(8),
                    child: SvgPicture.asset(
                      AssetsConstants.iconShare2,
                      width: 18,
                      height: 18,
                      colorFilter: ColorFilter.mode(
                        AppColors.textcolor,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onSelected: (val) {
                    if (val == 1) {
                      final link = 'https://sfa.sa/wishlist/${wishlist['title'].hashCode}';
                      Clipboard.setData(ClipboardData(text: link));
                      Share.share(
                        isAr
                            ? 'ألقِ نظرة على قائمة أمنياتي: $link'
                            : 'Check out my wishlist: $link',
                      );
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 1,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.copy_rounded,
                            color: AppColors.textcolor,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            loc.translate('copyShareLink'),
                            style: GoogleFonts.cairo(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textcolor,
                            ),
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
    );
  }

  Widget _buildFavoriteProductCard(
    BuildContext context,
    FavoriteProduct product,
  ) {
    final loc = AppLocalizations.of(context);
    final isAr = loc.isArabic;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF3EFE9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                    child: Image.network(
                      product.imageUrl,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                // Heart Button Badge
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: () {
                      context.read<FavoritesBloc>().add(ToggleFavoriteEvent(product));
                    },
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: SvgPicture.asset(
                        AssetsConstants.heartFilled,
                        colorFilter: ColorFilter.mode(
                          AppColors.primary,
                          BlendMode.srcIn,
                        ),
                        width: 16,
                        height: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: isAr
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: isAr ? Alignment.centerRight : Alignment.centerLeft,
                  child: Text(
                    product.title,
                    style: GoogleFonts.cairo(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textcolor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: isAr ? TextAlign.right : TextAlign.left,
                  ),
                ),
                const SizedBox(height: 2),
                Align(
                  alignment: isAr ? Alignment.centerRight : Alignment.centerLeft,
                  child: Text(
                    product.price,
                    style: GoogleFonts.cairo(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                    textAlign: isAr ? TextAlign.right : TextAlign.left,
                  ),
                ),
                const SizedBox(height: 2),
                // Rating row
                Align(
                  alignment: isAr ? Alignment.centerRight : Alignment.centerLeft,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: isAr
                        ? MainAxisAlignment.end
                        : MainAxisAlignment.start,
                    children: [
                      if (isAr) ...[
                        Text(
                          '85 ${loc.translate('reviewsCount').replaceAll('{count}', '').trim()}  •  4.9',
                          style: GoogleFonts.cairo(
                            fontSize: 11,
                            color: AppColors.textcolor_50,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.star_rounded,
                           color: Color(0xFFFBC02D),
                          size: 15,
                        ),
                      ] else ...[
                        const Icon(
                          Icons.star_rounded,
                          color: Color(0xFFFBC02D),
                          size: 15,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '4.9  •  85 ${loc.translate('reviewsCount').replaceAll('{count}', '').trim()}',
                          style: GoogleFonts.cairo(
                            fontSize: 11,
                            color: AppColors.textcolor_50,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
