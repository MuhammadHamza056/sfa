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
import 'package:sfa/core/models/product_detail_args.dart';
import 'package:sfa/core/widgets/primary_app_bar.dart';
import 'package:sfa/core/widgets/product_card.dart';
import 'package:sfa/features/brands/presentation/widgets/delivery_terms_bottom_sheet.dart';
import 'package:sfa/features/brands/providers/product_detail_provider.dart';
import 'package:sfa/features/cart/providers/cart_provider.dart';
import 'package:sfa/features/catalog/data/catalog_models.dart';
import 'package:sfa/features/catalog/providers/catalog_providers.dart';
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

  static CatalogProductOption? _findOption(
    List<CatalogProductOption> options,
    bool Function(CatalogProductOption) test,
  ) {
    for (final option in options) {
      if (test(option)) return option;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final id = widget.args?.id;
    final appbarTitle = loc.isArabic ? 'تفاصيل المنتج' : 'Product Details';

    if (id == null) {
      return Scaffold(
        backgroundColor: context.palette.background,
        appBar: PrimaryAppBar(
          title: appbarTitle,
          fontSize: 18,
          showBackButton: true,
        ),
        body: Center(
          child: Text(
            loc.isArabic ? 'المنتج غير متاح' : 'Product not found',
            style: AppStyle.bodyText.copyWith(color: context.palette.textMuted),
          ),
        ),
      );
    }

    final productAsync = ref.watch(catalogProductDetailProvider(id));

    return productAsync.when(
      loading: () => Scaffold(
        backgroundColor: context.palette.background,
        appBar: PrimaryAppBar(title: appbarTitle, fontSize: 18, showBackButton: true),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Scaffold(
        backgroundColor: context.palette.background,
        appBar: PrimaryAppBar(title: appbarTitle, fontSize: 18, showBackButton: true),
        body: Center(
          child: Text(
            error.toString(),
            style: AppStyle.bodyText.copyWith(color: context.palette.textMuted),
          ),
        ),
      ),
      data: (product) => _ProductDetailBody(
        product: product,
        appbarTitle: appbarTitle,
        scrollController: _scrollController,
        deliveryTermsRecognizer: _deliveryTermsRecognizer,
        findOption: _findOption,
      ),
    );
  }
}

class _ProductDetailBody extends ConsumerWidget {
  final CatalogProduct product;
  final String appbarTitle;
  final ScrollController scrollController;
  final TapGestureRecognizer deliveryTermsRecognizer;
  final CatalogProductOption? Function(
    List<CatalogProductOption>,
    bool Function(CatalogProductOption),
  ) findOption;

  const _ProductDetailBody({
    required this.product,
    required this.appbarTitle,
    required this.scrollController,
    required this.deliveryTermsRecognizer,
    required this.findOption,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context);
    final isAr = loc.isArabic;

    final colorLabel = isAr ? 'اللون' : 'Color';
    final sizeLabel = isAr ? 'المقاس' : 'Size';
    final descTitle = isAr ? 'وصف المنتج' : 'Product Description';
    final careTitle = isAr ? 'تعليمات العناية' : 'Care Instructions';
    final careText = isAr
        ? 'غسيل جاف فقط لضمان الجودة'
        : 'Dry clean only to maintain quality';
    final buyNowText = isAr ? 'اشترِ الآن' : 'Buy Now';

    final displayProduct = product.toProduct(isAr);
    final productImage = displayProduct.imageUrl;

    final colorOption = findOption(product.options, (o) => o.isColorOption);
    final sizeOption = findOption(product.options, (o) => !o.isColorOption);

    final detailState = ref.watch(productDetailProvider(product.id));
    final detailNotifier = ref.read(productDetailProvider(product.id).notifier);

    final selectedColorIndex = colorOption != null && colorOption.values.isNotEmpty
        ? detailState.selectedColorIndex.clamp(0, colorOption.values.length - 1)
        : 0;
    final selectedSizeIndex = sizeOption != null && sizeOption.values.isNotEmpty
        ? detailState.selectedSizeIndex.clamp(0, sizeOption.values.length - 1)
        : 0;

    final favoriteEntry = FavoriteProduct(
      productId: product.id,
      title: displayProduct.title,
      imageUrl: productImage,
      price: displayProduct.price,
      rating: displayProduct.rating,
      brandName: displayProduct.brandName,
    );

    final relatedAsync = ref.watch(relatedProductsProvider(product.id));

    return Scaffold(
      backgroundColor: context.palette.background,
      appBar: PrimaryAppBar(
        title: appbarTitle,
        fontSize: 18,
        letterSpacing: 0,
        showBackButton: true,
        heartIcon: ref.watch(favoritesProvider).favorites.contains(favoriteEntry)
            ? AssetsConstants.heartFilled
            : AssetsConstants.heart2,
        onHeartTap: () =>
            ref.read(favoritesProvider.notifier).toggle(favoriteEntry),
      ),
      body: SingleChildScrollView(
        controller: scrollController,
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
                  placeholder: (_, __) => Container(color: context.palette.surfaceMuted),
                  errorWidget: (_, __, ___) => Container(color: context.palette.surfaceMuted),
                ),
                if (product.images.length > 1)
                  Positioned(
                    bottom: 16,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(product.images.length, (i) {
                        return Container(
                          width: i == 0 ? 20 : 6,
                          height: 6,
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(3),
                            color: i == 0 ? Colors.white : Colors.white.withValues(alpha: 0.5),
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
                  Expanded(
                    child: Text(
                      displayProduct.title,
                      textAlign: isAr ? TextAlign.right : TextAlign.left,
                      style: AppStyle.headerHeading.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: context.palette.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    displayProduct.price,
                    style: AppStyle.bodyText.copyWith(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFC19E68),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // 3. Hurry alert pill — only when stock is genuinely low
            if (product.stock > 0 && product.stock <= 10)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  decoration: BoxDecoration(
                    color: context.palette.background,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFE57373), width: 1),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.access_time_filled, size: 15, color: Color(0xFFE57373)),
                      const SizedBox(width: 6),
                      Text(
                        isAr
                            ? 'سارع متبقي ${product.stock} قطع فقط'
                            : 'Hurry, only ${product.stock} pieces left!',
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
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: context.palette.surfaceAlt,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: const Color(0xFFD49E4B), width: 1),
                        ),
                        padding: const EdgeInsets.all(8),
                        child: SvgPicture.asset(
                          AssetsConstants.store3,
                          width: 16,
                          height: 16,
                          colorFilter: const ColorFilter.mode(Color(0xFFD49E4B), BlendMode.srcIn),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        product.brand?.name ?? '',
                        style: AppStyle.bodyText.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: context.palette.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () => context.push(
                      '/product-reviews',
                      extra: displayProduct.toDetailArgs(),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star, size: 14, color: Colors.amber),
                        const SizedBox(width: 4),
                        Text(
                          displayProduct.reviewsLabel != null
                              ? '${displayProduct.rating} · ${displayProduct.reviewsLabel}'
                              : displayProduct.rating,
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
            Divider(indent: 16, endIndent: 16, height: 1, thickness: 0.5, color: context.palette.divider),

            // 5. Color Selection
            if (colorOption != null) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      colorOption.name.resolve(isAr).isEmpty ? colorLabel : colorOption.name.resolve(isAr),
                      style: AppStyle.bodyText.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: context.palette.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: List.generate(colorOption.values.length, (i) {
                        final isSelected = selectedColorIndex == i;
                        final swatchColor =
                            _parseHexColor(colorOption.values[i]) ?? context.palette.surfaceMuted;
                        return GestureDetector(
                          onTap: () => detailNotifier.selectColor(i),
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 6),
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: swatchColor,
                              border: isSelected
                                  ? Border.all(color: const Color(0xFFC19E68), width: 2)
                                  : Border.all(color: Colors.transparent, width: 0),
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Divider(indent: 16, endIndent: 16, height: 1, thickness: 0.5, color: context.palette.divider),
            ],

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
                      border: Border.all(color: const Color(0xFFD49E4B), width: 1),
                    ),
                    child: Center(
                      child: SvgPicture.asset(
                        AssetsConstants.truck,
                        width: 20,
                        height: 20,
                        colorFilter: const ColorFilter.mode(Color(0xFFD49E4B), BlendMode.srcIn),
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
                        Text(
                          '${loc.translate('shippingDaysTo')} ${loc.translate(detailState.selectedCity)}',
                          textAlign: TextAlign.start,
                          style: AppStyle.bodyText.copyWith(
                            fontSize: 13,
                            fontWeight: FontWeight.w300,
                            color: context.palette.textPrimary.withValues(alpha: 0.60),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),
            Divider(indent: 16, endIndent: 16, height: 1, thickness: 0.5, color: context.palette.divider),

            // 6. Size Selection
            if (sizeOption != null) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      sizeOption.name.resolve(isAr).isEmpty ? sizeLabel : sizeOption.name.resolve(isAr),
                      style: AppStyle.bodyText.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: context.palette.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      children: List.generate(sizeOption.values.length, (i) {
                        final isSelected = selectedSizeIndex == i;
                        return GestureDetector(
                          onTap: () => detailNotifier.selectSize(i),
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                            width: 44,
                            height: 32,
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.primary : context.palette.surfaceMuted,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: Text(
                                sizeOption.values[i],
                                style: AppStyle.bodyText.copyWith(
                                  fontSize: 12,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  color: isSelected ? Colors.white : context.palette.textPrimary,
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
              Divider(indent: 16, endIndent: 16, height: 1, thickness: 0.5, color: context.palette.divider),
            ],

            // 7. Product Description
            if (product.description != null) ...[
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
                      product.description!.resolve(isAr),
                      textAlign: TextAlign.start,
                      style: AppStyle.bodyText.copyWith(
                        fontSize: 13,
                        color: context.palette.textPrimary.withValues(alpha: 0.70),
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Divider(indent: 16, endIndent: 16, height: 1, thickness: 0.5, color: context.palette.divider),
            ],

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
                          context.palette.textPrimary.withValues(alpha: 0.70),
                          BlendMode.srcIn,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        careText,
                        style: AppStyle.bodyText.copyWith(
                          fontSize: 12,
                          color: context.palette.textPrimary.withValues(alpha: 0.70),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),
            Divider(indent: 16, endIndent: 16, height: 1, thickness: 0.5, color: context.palette.divider),

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
                          context.palette.textPrimary.withValues(alpha: 0.70),
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
                                  color: context.palette.textPrimary.withValues(alpha: 0.70),
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
                                recognizer: deliveryTermsRecognizer,
                              ),
                              TextSpan(
                                text: loc.translate('viewDeliveryTermsSuffix'),
                                style: AppStyle.bodyText.copyWith(
                                  fontSize: 12,
                                  color: context.palette.textPrimary.withValues(alpha: 0.70),
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
                onPressed: !product.isAvailable
                    ? null
                    : () async {
                        await ref.read(cartProvider.notifier).addItem(
                              productId: product.id,
                              selectedColor: colorOption != null && colorOption.values.isNotEmpty
                                  ? colorOption.values[selectedColorIndex]
                                  : null,
                              selectedSize: sizeOption != null && sizeOption.values.isNotEmpty
                                  ? sizeOption.values[selectedSizeIndex]
                                  : null,
                            );
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(loc.translate('itemAddedToCart'))),
                        );
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
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
                        colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Related Products
            relatedAsync.maybeWhen(
              data: (related) => related.isEmpty
                  ? const SizedBox.shrink()
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
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
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: related.length,
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 16,
                              childAspectRatio: 0.65,
                            ),
                            itemBuilder: (context, index) {
                              final item = related[index].toProduct(isAr);
                              return ProductCard(
                                product: item,
                                isAr: isAr,
                                onTap: () {
                                  context.push('/product-detail', extra: item.toDetailArgs());
                                  scrollController.animateTo(
                                    0,
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeOut,
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),
              orElse: () => const SizedBox.shrink(),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  static Color? _parseHexColor(String hex) {
    var value = hex.replaceFirst('#', '');
    if (value.length == 6) value = 'FF$value';
    final parsed = int.tryParse(value, radix: 16);
    return parsed == null ? null : Color(parsed);
  }
}
