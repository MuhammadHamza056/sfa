import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sfa/core/localization/app_localizations.dart';
import 'package:sfa/utils/app_style.dart';
import 'package:sfa/utils/assets_constants.dart';
import 'package:sfa/utils/color_constants.dart';
import 'package:sfa/features/dashboard/bloc/dashboard_bloc.dart';
import 'package:sfa/features/dashboard/bloc/dashboard_event.dart';
import 'package:sfa/features/dashboard/bloc/dashboard_state.dart';
import 'package:sfa/features/favorites/models/favorite_product.dart';
import 'package:sfa/features/favorites/bloc/favorites_bloc.dart';
import 'package:sfa/features/favorites/bloc/favorites_event.dart';
import 'package:sfa/features/favorites/bloc/favorites_state.dart';

class ProductItem {
  final String imageUrl;
  final String title;
  final String price;
  final String rating;

  const ProductItem({
    required this.imageUrl,
    required this.title,
    required this.price,
    required this.rating,
  });
}

class BrandDetailScreen extends StatelessWidget {
  const BrandDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final isAr = loc.isArabic;

    // Localized labels
    final productsLabel = loc.translate('brandProductsCount');
    final sortLabel = loc.translate('brandSortLabel');
    final filterLabel = loc.translate('brandFilterLabel');

    // 6 Dummy localized products
    final dummyProducts = [
      ProductItem(
        imageUrl: 'https://images.unsplash.com/photo-1509631179647-0177331693ae?w=500&q=80',
        title: loc.translate('brandProductDesertRose'),
        price: loc.translate('brandProductPrice1250'),
        rating: loc.translate('brandProductRatingText'),
      ),
      ProductItem(
        imageUrl: 'https://images.unsplash.com/photo-1529139574466-a303027c1d8b?w=500&q=80',
        title: loc.translate('brandProductBlackSilk'),
        price: loc.translate('brandProductPrice1250'),
        rating: loc.translate('brandProductRatingText'),
      ),
      ProductItem(
        imageUrl: 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=500&q=80',
        title: loc.translate('brandProductLinenSet'),
        price: loc.translate('brandProductPrice450'),
        rating: loc.translate('brandProductRatingText'),
      ),
      ProductItem(
        imageUrl: 'https://images.unsplash.com/photo-1515886657613-9f3515b0c78f?w=500&q=80',
        title: loc.translate('brandProductCrepeAbaya'),
        price: loc.translate('brandProductPrice780'),
        rating: loc.translate('brandProductRatingText'),
      ),
      ProductItem(
        imageUrl: 'https://images.unsplash.com/photo-1539109136881-3be0616acf4b?w=500&q=80',
        title: loc.translate('brandProductDesertRose'),
        price: loc.translate('brandProductPrice1250'),
        rating: loc.translate('brandProductRatingText'),
      ),
      ProductItem(
        imageUrl: 'https://images.unsplash.com/photo-1529139574466-a303027c1d8b?w=500&q=80',
        title: loc.translate('brandProductBlackSilk'),
        price: loc.translate('brandProductPrice1250'),
        rating: loc.translate('brandProductRatingText'),
      ),
    ];

    return BlocBuilder<DashboardBloc, DashboardState>(
      builder: (context, state) {
        final brandNameKey = state.selectedBrandName ?? 'brandJuba';
        final resolvedBrandName = loc.translate(brandNameKey);

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0.5,
            scrolledUnderElevation: 0.5,
            automaticallyImplyLeading: false,
            centerTitle: true,
            leadingWidth: 110,
            leading: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(width: 8),
                IconButton(
                  icon: SvgPicture.asset(
                    AssetsConstants.shoppingBag2,
                    colorFilter: ColorFilter.mode(
                      AppColors.textcolor,
                      BlendMode.srcIn,
                    ),
                    width: 22,
                    height: 22,
                  ),
                  onPressed: () {
                    context.read<DashboardBloc>().add(const CacheCurrentTabEvent());
                    context.read<DashboardBloc>().add(const ChangeTabEvent(5));
                  },
                ),
                IconButton(
                  icon: SvgPicture.asset(
                    AssetsConstants.heart,
                    colorFilter: ColorFilter.mode(
                      AppColors.textcolor,
                      BlendMode.srcIn,
                    ),
                    width: 22,
                    height: 22,
                  ),
                  onPressed: () {
                    context.read<DashboardBloc>().add(const CacheCurrentTabEvent());
                    context.read<DashboardBloc>().add(const ChangeTabEvent(8));
                  },
                ),
              ],
            ),
            title: Text(
              resolvedBrandName,
              style: AppStyle.headerHeading.copyWith(
                fontSize: 19,
                fontWeight: FontWeight.bold,
                color: AppColors.textcolor,
              ),
            ),
            actions: [
              IconButton(
                icon: SvgPicture.asset(
                  AssetsConstants.search3,
                  colorFilter: ColorFilter.mode(
                    AppColors.textcolor,
                    BlendMode.srcIn,
                  ),
                  width: 22,
                  height: 22,
                ),
                onPressed: () {},
              ),
              IconButton(
                icon: SvgPicture.asset(
                  AssetsConstants.back2,
                  colorFilter: ColorFilter.mode(
                    AppColors.textcolor,
                    BlendMode.srcIn,
                  ),
                  width: 20,
                  height: 20,
                ),
                onPressed: () {
                  context.read<DashboardBloc>().add(const RestorePreviousTabEvent());
                },
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Huge Brand Image Banner
                CachedNetworkImage(
                  imageUrl: 'https://images.unsplash.com/photo-1490481651871-ab68de25d43d?w=1000&q=80',
                  height: 520,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(color: Colors.grey[200]),
                  errorWidget: (_, __, ___) => Container(color: Colors.grey[200]),
                ),

                // 2. Brand Description
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  child: Text(
                    loc.translate('brandDescription'),
                    textAlign: TextAlign.start,
                    style: AppStyle.bodyText.copyWith(
                      fontSize: 13.5,
                      color: AppColors.textcolor.withOpacity(0.80),
                      height: 1.6,
                    ),
                  ),
                ),

                // 3. Info Row & Filters
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      // Product count (e.g. 273 products)
                      Text(
                        productsLabel,
                        style: AppStyle.bodyText.copyWith(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textcolor,
                        ),
                      ),
                      const Spacer(),

                      // Sort options button
                      _buildFilterBtn(
                        label: sortLabel,
                        icon: AssetsConstants.arrowDownUp,
                      ),
                      const SizedBox(width: 8),

                      // Filter button
                      _buildFilterBtn(
                        label: filterLabel,
                        icon: AssetsConstants.settings2,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // 4. Products Grid (2 columns)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: dummyProducts.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.65,
                    ),
                    itemBuilder: (context, index) {
                      final product = dummyProducts[index];
                      return GestureDetector(
                        onTap: () {
                          context.read<DashboardBloc>().add(
                            SelectProductEvent(
                              name: product.title,
                              imageUrl: product.imageUrl,
                              price: product.price,
                              rating: product.rating,
                            ),
                          );
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              child: Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: CachedNetworkImage(
                                      imageUrl: product.imageUrl,
                                      width: double.infinity,
                                      height: double.infinity,
                                      fit: BoxFit.cover,
                                      placeholder: (_, __) => Container(color: Colors.grey[100]),
                                      errorWidget: (_, __, ___) => Container(color: Colors.grey[100]),
                                    ),
                                  ),
                                  Positioned(
                                    top: 8,
                                    right: isAr ? null : 8,
                                    left: isAr ? 8 : null,
                                    child: BlocBuilder<FavoritesBloc, FavoritesState>(
                                      builder: (context, favState) {
                                        final favProduct = FavoriteProduct(
                                          title: product.title,
                                          imageUrl: product.imageUrl,
                                          price: product.price,
                                          rating: product.rating,
                                        );
                                        final isFav = favState.favorites.contains(favProduct);
                                        return Container(
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(0.85),
                                            shape: BoxShape.circle,
                                          ),
                                          child: IconButton(
                                            constraints: const BoxConstraints(),
                                            padding: const EdgeInsets.all(6),
                                            icon: SvgPicture.asset(
                                              isFav ? AssetsConstants.heartFilled : AssetsConstants.heart2,
                                              width: 16,
                                              height: 16,
                                              colorFilter: ColorFilter.mode(
                                                isFav ? AppColors.primary : AppColors.textcolor,
                                                BlendMode.srcIn,
                                              ),
                                            ),
                                            onPressed: () {
                                              context.read<FavoritesBloc>().add(ToggleFavoriteEvent(favProduct));
                                            },
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              product.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppStyle.bodyText.copyWith(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textcolor,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              product.price,
                              style: AppStyle.bodyText.copyWith(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textcolor.withOpacity(0.80),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                const Icon(
                                  Icons.star,
                                  size: 13,
                                  color: Colors.amber,
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  product.rating,
                                  style: AppStyle.bodyText.copyWith(
                                    fontSize: 11,
                                    color: AppColors.textcolor_50,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFilterBtn({required String label, required String icon}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: Colors.grey[300]!,
          width: 0.8,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: AppStyle.bodyText.copyWith(
              fontSize: 13,
              color: AppColors.textcolor,
            ),
          ),
          const SizedBox(width: 6),
          SvgPicture.asset(
            icon,
            width: 14,
            height: 14,
            colorFilter: ColorFilter.mode(
              AppColors.textcolor,
              BlendMode.srcIn,
            ),
          ),
        ],
      ),
    );
  }
}
