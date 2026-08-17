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
import 'package:sfa/features/brands/bloc/product_detail_bloc.dart';
import 'package:sfa/features/brands/bloc/product_detail_event.dart';
import 'package:sfa/features/brands/bloc/product_detail_state.dart';
import 'package:sfa/features/favorites/models/favorite_product.dart';
import 'package:sfa/features/favorites/bloc/favorites_bloc.dart';
import 'package:sfa/features/favorites/bloc/favorites_event.dart';
import 'package:sfa/features/favorites/bloc/favorites_state.dart';

class RelatedProductItem {
  final String imageUrl;
  final String brandName;
  final String title;
  final String price;
  final String rating;

  const RelatedProductItem({
    required this.imageUrl,
    required this.brandName,
    required this.title,
    required this.price,
    required this.rating,
  });
}

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({super.key});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final ScrollController _scrollController = ScrollController();
  late final ProductDetailBloc _productDetailBloc;

  @override
  void initState() {
    super.initState();
    _productDetailBloc = ProductDetailBloc();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _productDetailBloc.close();
    super.dispose();
  }

  final List<Color> _colors = [
    const Color(0xFF141D2B), // Dark blue
    const Color(0xFFC9DBCA), // Light green
    const Color(0xFF7A1415), // Dark red
  ];

  final List<String> _sizes = ['S', 'M', 'L', 'XL', 'XXL'];

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final isAr = loc.isArabic;

    // Translations for UI labels
    final appbarTitle = isAr ? 'تفاصيل المنتج' : 'Product Details';
    final hurryText = isAr
        ? 'سارع متبقي 5 قطع فقط'
        : 'Hurry, only 5 pieces left!';
    final colorLabel = isAr ? 'اللون' : 'Color';
    final sizeLabel = isAr ? 'المقاس' : 'Size';
    final descTitle = isAr ? 'وصف المنتج' : 'Product Description';
    final descText = isAr
        ? 'عباية فاخرة مصنوعة من الحرير الطبيعي، تتميز بتصميم كلاسيكي عصري وتطريز دقيق على الأطراف. خفيفة الوزن ومثالية للمناسبات الرسمية والزيارات اليومية الراقية. تأتي مع طرحة مطابقة وتصميم يضمن الراحة والتميز.'
        : 'A luxury abaya made of natural silk, featuring a modern classic design and fine embroidery on the edges. Lightweight and ideal for formal occasions and high-end daily visits. Comes with a matching veil and design that guarantees comfort and distinction.';
    final careTitle = isAr ? 'تعليمات العناية' : 'Care Instructions';
    final careText = isAr
        ? 'غسيل جاف فقط لضمان جودة الحرير'
        : 'Dry clean only to maintain silk quality';
    final buyNowText = isAr ? 'اشترِ الآن' : 'Buy Now';

    final relatedProducts = [
      RelatedProductItem(
        imageUrl:
            'https://images.unsplash.com/photo-1509631179647-0177331693ae?w=500&q=80',
        brandName: loc.translate('brandJuba'),
        title: loc.translate('brandProductDesertRose'),
        price: loc.translate('brandProductPrice1250'),
        rating: loc.translate('brandProductRatingText'),
      ),
      RelatedProductItem(
        imageUrl:
            'https://images.unsplash.com/photo-1529139574466-a303027c1d8b?w=500&q=80',
        brandName: loc.translate('brandAnbar'),
        title: loc.translate('brandProductBlackSilk'),
        price: loc.translate('brandProductPrice1250'),
        rating: loc.translate('brandProductRatingText'),
      ),
      RelatedProductItem(
        imageUrl:
            'https://images.unsplash.com/photo-1515886657613-9f3515b0c78f?w=500&q=80',
        brandName: loc.translate('brandJuba'),
        title: loc.translate('brandProductCrepeAbaya'),
        price: loc.translate('brandProductPrice780'),
        rating: loc.translate('brandProductRatingText'),
      ),
      RelatedProductItem(
        imageUrl:
            'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=500&q=80',
        brandName: loc.translate('brandAnbar'),
        title: loc.translate('brandProductLinenSet'),
        price: loc.translate('brandProductPrice450'),
        rating: loc.translate('brandProductRatingText'),
      ),
    ];

    return BlocProvider.value(
      value: _productDetailBloc,
      child: BlocBuilder<ProductDetailBloc, ProductDetailState>(
        builder: (context, detailState) {
          return BlocBuilder<DashboardBloc, DashboardState>(
            builder: (context, state) {
        final productName =
            state.selectedProductName ??
            (isAr ? 'وردة الصحراء المطرزة' : 'Embroidered Desert Rose');
        final productImage =
            state.selectedProductImage ??
            'https://images.unsplash.com/photo-1509631179647-0177331693ae?w=800&q=80';
        final productPrice =
            state.selectedProductPrice ?? (isAr ? '1,250 ر.س.' : '1,250 SAR');
        final productRating =
            state.selectedProductRating ??
            (isAr ? '4.9 · 85 تقييماً' : '4.9 · 85 reviews');
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
                    context.read<DashboardBloc>().add(
                      const CacheCurrentTabEvent(),
                    );
                    context.read<DashboardBloc>().add(const ChangeTabEvent(5));
                  },
                ),
                BlocBuilder<FavoritesBloc, FavoritesState>(
                  builder: (context, favState) {
                    final favProduct = FavoriteProduct(
                      title: productName,
                      imageUrl: productImage,
                      price: productPrice,
                      rating: productRating,
                    );
                    final isFav = favState.favorites.contains(favProduct);
                    return IconButton(
                      icon: SvgPicture.asset(
                        isFav ? AssetsConstants.heartFilled : AssetsConstants.heart2,
                        colorFilter: ColorFilter.mode(
                          isFav ? AppColors.primary : AppColors.textcolor,
                          BlendMode.srcIn,
                        ),
                        width: 22,
                        height: 22,
                      ),
                      onPressed: () {
                        context.read<FavoritesBloc>().add(ToggleFavoriteEvent(favProduct));
                      },
                    );
                  },
                ),
              ],
            ),
            title: Text(
              appbarTitle,
              style: AppStyle.headerHeading.copyWith(
                fontSize: 18,
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
                  context.read<DashboardBloc>().add(
                    const RestorePreviousTabEvent(),
                  );
                },
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Huge Product Image with dots overlay
                Stack(
                  children: [
                    CachedNetworkImage(
                      imageUrl: productImage,
                      height: 520,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      placeholder: (_, __) =>
                          Container(color: Colors.grey[200]),
                      errorWidget: (_, __, ___) =>
                          Container(color: Colors.grey[200]),
                    ),
                    Positioned(
                      bottom: 16,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(3, (i) {
                          return Container(
                            width: i == 0 ? 20 : 6,
                            height: 6,
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(3),
                              color: i == 0
                                  ? Colors.white
                                  : Colors.white.withOpacity(0.5),
                            ),
                          );
                        }),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // 2. Title & Price Row
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Right: Product Title (Arabic right, English left)
                      Expanded(
                        child: Text(
                          productName,
                          textAlign: isAr ? TextAlign.right : TextAlign.left,
                          style: AppStyle.headerHeading.copyWith(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textcolor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Left: Price
                      Text(
                        productPrice,
                        style: AppStyle.bodyText.copyWith(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFFC19E68), // Gold/Beige color
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // 3. Hurry alert pill
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFFE57373),
                        width: 1,
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 16,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.access_time_filled,
                          size: 15,
                          color: Color(0xFFE57373),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          hurryText,
                          style: AppStyle.bodyText.copyWith(
                            fontSize: 12.5,
                            color: const Color(0xFFE57373),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // 4. Brand Name & Rating Row
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Brand (Icon & Name)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFFAF2E6),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: const Color(0xFFD49E4B),
                                width: 1,
                              ),
                            ),
                            padding: const EdgeInsets.all(8),
                            child: SvgPicture.asset(
                              AssetsConstants.store3,
                              width: 16,
                              height: 16,
                              colorFilter: const ColorFilter.mode(
                                Color(0xFFD49E4B),
                                BlendMode.srcIn,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            resolvedBrandName,
                            style: AppStyle.bodyText.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: AppColors.textcolor,
                            ),
                          ),
                        ],
                      ),

                      // Rating (Star & text)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star, size: 14, color: Colors.amber),
                          const SizedBox(width: 4),
                          Text(
                            productRating,
                            style: AppStyle.bodyText.copyWith(
                              fontSize: 11.5,
                              color: AppColors.textcolor_50,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),
                const Divider(
                  indent: 16,
                  endIndent: 16,
                  height: 1,
                  thickness: 0.5,
                  color: Color(0xFFEFEFEF),
                ),

                // 5. Color Selection
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        colorLabel,
                        style: AppStyle.bodyText.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: AppColors.textcolor,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: List.generate(_colors.length, (i) {
                          final isSelected = detailState.selectedColorIndex == i;
                          return GestureDetector(
                            onTap: () =>
                                _productDetailBloc.add(SelectColorEvent(i)),
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 6),
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _colors[i],
                                border: isSelected
                                    ? Border.all(
                                        color: const Color(0xFFC19E68),
                                        width: 2,
                                      )
                                    : Border.all(
                                        color: Colors.transparent,
                                        width: 0,
                                      ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),
                const Divider(
                  indent: 16,
                  endIndent: 16,
                  height: 1,
                  thickness: 0.5,
                  color: Color(0xFFEFEFEF),
                ),

                // Shipping details widget
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFFD49E4B),
                            width: 1,
                          ),
                        ),
                        child: Center(
                          child: SvgPicture.asset(
                            AssetsConstants.truck,
                            width: 20,
                            height: 20,
                            colorFilter: const ColorFilter.mode(
                              Color(0xFFD49E4B),
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              loc.translate('shippingFromSaudi'),
                              textAlign: TextAlign.start,
                              style: AppStyle.bodyText.copyWith(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textcolor,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  '${loc.translate('shippingDaysTo')} ',
                                  textAlign: TextAlign.start,
                                  style: AppStyle.bodyText.copyWith(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w300,
                                    color: AppColors.textcolor.withOpacity(0.60),
                                  ),
                                ),
                                Text(
                                  ' ${loc.translate('chooseCityLabel')}',
                                  textAlign: TextAlign.start,
                                  style: AppStyle.bodyText.copyWith(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w300,
                                    color: AppColors.textcolor.withOpacity(0.60),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Theme(
                                  data: Theme.of(context).copyWith(
                                    cardColor: Colors.white,
                                  ),
                                  child: PopupMenuButton<String>(
                                    offset: const Offset(0, 24),
                                    color: Colors.white,
                                    elevation: 2,
                                    onSelected: (String newValue) {
                                      _productDetailBloc.add(SelectCityEvent(newValue));
                                    },
                                    itemBuilder: (BuildContext context) {
                                      return <String>[
                                        'cityRiyadh',
                                        'cityJeddah',
                                        'cityDammam',
                                        'cityMecca',
                                        'cityMedina',
                                      ].map((String value) {
                                        return PopupMenuItem<String>(
                                          value: value,
                                          height: 38,
                                          child: Text(
                                            loc.translate(value),
                                            style: AppStyle.bodyText.copyWith(
                                              fontSize: 13,
                                              color: AppColors.textcolor,
                                            ),
                                          ),
                                        );
                                      }).toList();
                                    },
                                    child: Text(
                                      loc.translate(detailState.selectedCity),
                                      style: AppStyle.bodyText.copyWith(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFFD49E4B),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),
                const Divider(
                  indent: 16,
                  endIndent: 16,
                  height: 1,
                  thickness: 0.5,
                  color: Color(0xFFEFEFEF),
                ),

                // 6. Size Selection
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        sizeLabel,
                        style: AppStyle.bodyText.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: AppColors.textcolor,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: List.generate(_sizes.length, (i) {
                          final isSelected = detailState.selectedSizeIndex == i;
                          return GestureDetector(
                            onTap: () => _productDetailBloc.add(SelectSizeEvent(i)),
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              width: 44,
                              height: 32,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primary
                                    : Colors.grey[100],
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                child: Text(
                                  _sizes[i],
                                  style: AppStyle.bodyText.copyWith(
                                    fontSize: 12,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    color: isSelected
                                        ? Colors.white
                                        : AppColors.textcolor,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),
                const Divider(
                  indent: 16,
                  endIndent: 16,
                  height: 1,
                  thickness: 0.5,
                  color: Color(0xFFEFEFEF),
                ),

                // 7. Product Description
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        descTitle,
                        style: AppStyle.bodyText.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: AppColors.textcolor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        descText,
                        textAlign: TextAlign.start,
                        style: AppStyle.bodyText.copyWith(
                          fontSize: 13,
                          color: AppColors.textcolor.withOpacity(0.70),
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),
                const Divider(
                  indent: 16,
                  endIndent: 16,
                  height: 1,
                  thickness: 0.5,
                  color: Color(0xFFEFEFEF),
                ),

                // 8. Care Instructions
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        careTitle,
                        style: AppStyle.bodyText.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: AppColors.textcolor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SvgPicture.asset(
                            AssetsConstants.info,
                            width: 14,
                            height: 14,
                            colorFilter: ColorFilter.mode(
                              AppColors.textcolor.withOpacity(0.70),
                              BlendMode.srcIn,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            careText,
                            style: AppStyle.bodyText.copyWith(
                              fontSize: 12,
                              color: AppColors.textcolor.withOpacity(0.70),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),
                const Divider(
                  indent: 16,
                  endIndent: 16,
                  height: 1,
                  thickness: 0.5,
                  color: Color(0xFFEFEFEF),
                ),

                // Free Delivery & Return widget
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        loc.translate('freeDeliveryTitle'),
                        style: AppStyle.bodyText.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: AppColors.textcolor,
                        ),
                      ),
                      const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SvgPicture.asset(
                                  AssetsConstants.info,
                                  width: 14,
                                  height: 14,
                                  colorFilter: ColorFilter.mode(
                                    AppColors.textcolor.withOpacity(0.70),
                                    BlendMode.srcIn,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text.rich(
                                    TextSpan(
                                      children: [
                                        TextSpan(
                                          text: loc.translate('viewDeliveryTermsPrefix'),
                                          style: AppStyle.bodyText.copyWith(
                                            fontSize: 12,
                                            color: AppColors.textcolor.withOpacity(0.70),
                                          ),
                                        ),
                                        TextSpan(
                                          text: loc.translate('viewDeliveryTermsHighlight'),
                                          style: AppStyle.bodyText.copyWith(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.primary,
                                            decoration: TextDecoration.underline,
                                            decorationColor: AppColors.primary,
                                          ),
                                        ),
                                        TextSpan(
                                          text: loc.translate('viewDeliveryTermsSuffix'),
                                          style: AppStyle.bodyText.copyWith(
                                            fontSize: 12,
                                            color: AppColors.textcolor.withOpacity(0.70),
                                          ),
                                        ),
                                      ],
                                    ),
                                    textAlign: TextAlign.start,
                                  ),
                                ),
                              ],
                            ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // 9. Buy Now Button
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 0,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            buyNowText,
                            style: AppStyle.bodyText.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 15.5,
                              color: Colors.white,
                            ),
                          ),
                          SvgPicture.asset(
                            AssetsConstants.shoppingBag2,
                            width: 18,
                            height: 18,
                            colorFilter: const ColorFilter.mode(
                              Colors.white,
                              BlendMode.srcIn,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Related Products Title
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: Text(
                      loc.translate('relatedProducts'),
                      style: AppStyle.bodyText.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: AppColors.textcolor,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Related Products Grid (2 columns)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: relatedProducts.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.65,
                        ),
                    itemBuilder: (context, index) {
                      final item = relatedProducts[index];
                      return GestureDetector(
                        onTap: () {
                          context.read<DashboardBloc>().add(
                            SelectProductEvent(
                              name: item.title,
                              imageUrl: item.imageUrl,
                              price: item.price,
                              rating: item.rating,
                            ),
                          );
                          _scrollController.animateTo(
                            0,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOut,
                          );
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: CachedNetworkImage(
                                      imageUrl: item.imageUrl,
                                      width: double.infinity,
                                      height: double.infinity,
                                      fit: BoxFit.cover,
                                      placeholder: (_, __) =>
                                          Container(color: Colors.grey[100]),
                                      errorWidget: (_, __, ___) =>
                                          Container(color: Colors.grey[100]),
                                    ),
                                  ),
                                  Positioned(
                                    top: 8,
                                    right: isAr ? null : 8,
                                    left: isAr ? 8 : null,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.85),
                                        shape: BoxShape.circle,
                                      ),
                                      child: IconButton(
                                        constraints: const BoxConstraints(),
                                        padding: const EdgeInsets.all(6),
                                        icon: SvgPicture.asset(
                                          AssetsConstants.heart2,
                                          width: 16,
                                          height: 16,
                                          colorFilter: ColorFilter.mode(
                                            AppColors.textcolor,
                                            BlendMode.srcIn,
                                          ),
                                        ),
                                        onPressed: () {},
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            // Brand name (e.g. جوبا or عنبر)
                            Text(
                              item.brandName,
                              style: AppStyle.bodyText.copyWith(
                                fontSize: 12,
                                color: AppColors.textcolor.withOpacity(0.60),
                              ),
                            ),
                            const SizedBox(height: 2),
                            // Title
                            Text(
                              item.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppStyle.bodyText.copyWith(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textcolor,
                              ),
                            ),
                            const SizedBox(height: 2),
                            // Price
                            Text(
                              item.price,
                              style: AppStyle.bodyText.copyWith(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textcolor.withOpacity(0.80),
                              ),
                            ),
                            const SizedBox(height: 2),
                            // Rating (Star & Text)
                            Row(
                              children: [
                                const Icon(
                                  Icons.star,
                                  size: 13,
                                  color: Colors.amber,
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  item.rating,
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
    },
  ),
);
  }
}
