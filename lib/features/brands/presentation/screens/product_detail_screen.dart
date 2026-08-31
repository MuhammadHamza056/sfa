import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:sfa/core/localization/app_localizations.dart';
import 'package:sfa/utils/app_style.dart';
import 'package:sfa/utils/assets_constants.dart';
import 'package:sfa/utils/color_constants.dart';
import 'package:sfa/core/models/product.dart';
import 'package:sfa/core/models/product_detail_args.dart';
import 'package:sfa/core/widgets/primary_app_bar.dart';
import 'package:sfa/core/widgets/product_card.dart';
import 'package:sfa/features/brands/presentation/widgets/delivery_terms_bottom_sheet.dart';
import 'package:sfa/features/brands/providers/product_detail_provider.dart';
import 'package:sfa/features/cart/providers/cart_provider.dart';
import 'package:sfa/features/favorites/models/favorite_product.dart';
import 'package:sfa/features/favorites/providers/favorites_provider.dart';
import 'package:sfa/core/theme/app_palette.dart';

class ProductDetailScreen extends ConsumerStatefulWidget {
  final ProductDetailArgs? args;

  const ProductDetailScreen({super.key, this.args});

  @override
  ConsumerState<ProductDetailScreen> createState() =>
      _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  final ScrollController _scrollController = ScrollController();
  late final TapGestureRecognizer _deliveryTermsRecognizer;

  @override
  void initState() {
    super.initState();
    _deliveryTermsRecognizer = TapGestureRecognizer()
      ..onTap = () => DeliveryTermsBottomSheet.show(context);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _deliveryTermsRecognizer.dispose();
    super.dispose();
  }

  static const List<Color> _colors = [
    Color(0xFF141D2B), // Dark blue
    Color(0xFFC9DBCA), // Light green
    Color(0xFF7A1415), // Dark red
  ];

  static const List<String> _sizes = ['S', 'M', 'L', 'XL', 'XXL'];

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
      Product(
        imageUrl:
            'https://images.unsplash.com/photo-1509631179647-0177331693ae?w=500&q=80',
        brandName: loc.translate('brandJuba'),
        title: loc.translate('brandProductDesertRose'),
        price: loc.translate('brandProductPrice1250'),
        rating: loc.translate('brandProductRatingText'),
      ),
      Product(
        imageUrl:
            'https://images.unsplash.com/photo-1529139574466-a303027c1d8b?w=500&q=80',
        brandName: loc.translate('brandAnbar'),
        title: loc.translate('brandProductBlackSilk'),
        price: loc.translate('brandProductPrice1250'),
        rating: loc.translate('brandProductRatingText'),
      ),
      Product(
        imageUrl:
            'https://images.unsplash.com/photo-1515886657613-9f3515b0c78f?w=500&q=80',
        brandName: loc.translate('brandJuba'),
        title: loc.translate('brandProductCrepeAbaya'),
        price: loc.translate('brandProductPrice780'),
        rating: loc.translate('brandProductRatingText'),
      ),
      Product(
        imageUrl:
            'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=500&q=80',
        brandName: loc.translate('brandAnbar'),
        title: loc.translate('brandProductLinenSet'),
        price: loc.translate('brandProductPrice450'),
        rating: loc.translate('brandProductRatingText'),
      ),
    ];

    final productName =
        widget.args?.name ??
        (isAr ? 'وردة الصحراء المطرزة' : 'Embroidered Desert Rose');
    final productImage =
        widget.args?.imageUrl ??
        'https://images.unsplash.com/photo-1509631179647-0177331693ae?w=800&q=80';
    final productPrice =
        widget.args?.price ?? (isAr ? '1,250 ر.س.' : '1,250 SAR');
    final productRating =
        widget.args?.rating ?? (isAr ? '4.9 · 85 تقييماً' : '4.9 · 85 reviews');
    final brandNameKey = widget.args?.brandNameKey ?? 'brandJuba';
    final resolvedBrandName = loc.translate(brandNameKey);
    final currentProduct = Product(
      imageUrl: productImage,
      title: productName,
      price: productPrice,
      rating: productRating,
      brandName: resolvedBrandName,
    );

    final detailKey = productDetailKey(productName, productImage);
    final detailState = ref.watch(productDetailProvider(detailKey));

    return Scaffold(
      backgroundColor: context.palette.background,
      appBar: PrimaryAppBar(
        title: appbarTitle,
        fontSize: 18,
        letterSpacing: 0,
        showBackButton: true,
        heartIcon: ref
                .watch(favoritesProvider)
                .favorites
                .contains(
                  FavoriteProduct(
                    title: productName,
                    imageUrl: productImage,
                    price: productPrice,
                    rating: productRating,
                  ),
                )
            ? AssetsConstants.heartFilled
            : AssetsConstants.heart2,
        onHeartTap: () => ref
            .read(favoritesProvider.notifier)
            .toggle(
              FavoriteProduct(
                title: productName,
                imageUrl: productImage,
                price: productPrice,
                rating: productRating,
              ),
            ),
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
                      Container(color: context.palette.surfaceMuted),
                  errorWidget: (_, __, ___) =>
                      Container(color: context.palette.surfaceMuted),
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
                        color: context.palette.textPrimary,
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
                  color: context.palette.background,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE57373), width: 1),
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
                          color: context.palette.surfaceAlt,
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
                          color: context.palette.textPrimary,
                        ),
                      ),
                    ],
                  ),

                  // Rating (Star & text)
                  GestureDetector(
                    onTap: () => context.push(
                      '/product-reviews',
                      extra: ProductDetailArgs(
                        name: productName,
                        imageUrl: productImage,
                        price: productPrice,
                        rating: productRating,
                        brandNameKey: brandNameKey,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star, size: 14, color: Colors.amber),
                        const SizedBox(width: 4),
                        Text(
                          productRating,
                          style: AppStyle.bodyText.copyWith(
                            fontSize: 11.5,
                            color: context.palette.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),
            Divider(
              indent: 16,
              endIndent: 16,
              height: 1,
              thickness: 0.5,
              color: context.palette.divider,
            ),

            // 5. Color Selection
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    colorLabel,
                    style: AppStyle.bodyText.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: context.palette.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: List.generate(_colors.length, (i) {
                      final isSelected = detailState.selectedColorIndex == i;
                      return GestureDetector(
                        onTap: () => ref
                            .read(productDetailProvider(detailKey).notifier)
                            .selectColor(i),
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
            Divider(
              indent: 16,
              endIndent: 16,
              height: 1,
              thickness: 0.5,
              color: context.palette.divider,
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
                            color: context.palette.textPrimary,
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
                                color: context.palette.textPrimary.withOpacity(
                                  0.60,
                                ),
                              ),
                            ),
                            Text(
                              ' ${loc.translate('chooseCityLabel')}',
                              textAlign: TextAlign.start,
                              style: AppStyle.bodyText.copyWith(
                                fontSize: 13,
                                fontWeight: FontWeight.w300,
                                color: context.palette.textPrimary.withOpacity(
                                  0.60,
                                ),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Theme(
                              data: Theme.of(
                                context,
                              ).copyWith(cardColor: context.palette.surface),
                              child: PopupMenuButton<String>(
                                offset: const Offset(0, 24),
                                color: context.palette.surface,
                                elevation: 2,
                                onSelected: (String newValue) {
                                  ref
                                      .read(
                                        productDetailProvider(
                                          detailKey,
                                        ).notifier,
                                      )
                                      .selectCity(newValue);
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
                                          color: context.palette.textPrimary,
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
            Divider(
              indent: 16,
              endIndent: 16,
              height: 1,
              thickness: 0.5,
              color: context.palette.divider,
            ),

            // 6. Size Selection
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    sizeLabel,
                    style: AppStyle.bodyText.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: context.palette.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: List.generate(_sizes.length, (i) {
                      final isSelected = detailState.selectedSizeIndex == i;
                      return GestureDetector(
                        onTap: () => ref
                            .read(productDetailProvider(detailKey).notifier)
                            .selectSize(i),
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: 44,
                          height: 32,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primary
                                : context.palette.surfaceMuted,
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
                                    : context.palette.textPrimary,
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
            Divider(
              indent: 16,
              endIndent: 16,
              height: 1,
              thickness: 0.5,
              color: context.palette.divider,
            ),

            // 7. Product Description
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    descTitle,
                    style: AppStyle.bodyText.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: context.palette.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    descText,
                    textAlign: TextAlign.start,
                    style: AppStyle.bodyText.copyWith(
                      fontSize: 13,
                      color: context.palette.textPrimary.withOpacity(0.70),
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),
            Divider(
              indent: 16,
              endIndent: 16,
              height: 1,
              thickness: 0.5,
              color: context.palette.divider,
            ),

            // 8. Care Instructions
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    careTitle,
                    style: AppStyle.bodyText.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: context.palette.textPrimary,
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
                          context.palette.textPrimary.withOpacity(0.70),
                          BlendMode.srcIn,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        careText,
                        style: AppStyle.bodyText.copyWith(
                          fontSize: 12,
                          color: context.palette.textPrimary.withOpacity(0.70),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),
            Divider(
              indent: 16,
              endIndent: 16,
              height: 1,
              thickness: 0.5,
              color: context.palette.divider,
            ),

            // Free Delivery & Return widget
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    loc.translate('freeDeliveryTitle'),
                    style: AppStyle.bodyText.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: context.palette.textPrimary,
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
                          context.palette.textPrimary.withOpacity(0.70),
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
                                  color: context.palette.textPrimary
                                      .withOpacity(0.70),
                                ),
                              ),
                              TextSpan(
                                text: loc.translate(
                                  'viewDeliveryTermsHighlight',
                                ),
                                style: AppStyle.bodyText.copyWith(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                  decoration: TextDecoration.underline,
                                  decorationColor: AppColors.primary,
                                ),
                                recognizer: _deliveryTermsRecognizer,
                              ),
                              TextSpan(
                                text: loc.translate('viewDeliveryTermsSuffix'),
                                style: AppStyle.bodyText.copyWith(
                                  fontSize: 12,
                                  color: context.palette.textPrimary
                                      .withOpacity(0.70),
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: ElevatedButton(
                onPressed: () {
                  ref
                      .read(cartProvider.notifier)
                      .addItem(
                        product: currentProduct,
                        color: _colors[detailState.selectedColorIndex],
                        size: _sizes[detailState.selectedSizeIndex],
                      );
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(loc.translate('itemAddedToCart'))),
                  );
                },
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
                    color: context.palette.textPrimary,
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
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.65,
                ),
                itemBuilder: (context, index) {
                  final item = relatedProducts[index];
                  return ProductCard(
                    product: item,
                    isAr: isAr,
                    onTap: () {
                      context.push(
                        '/product-detail',
                        extra: item.toDetailArgs(),
                      );
                      _scrollController.animateTo(
                        0,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                      );
                    },
                  );
                },
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
