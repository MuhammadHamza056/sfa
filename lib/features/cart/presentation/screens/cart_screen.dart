import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:sfa/core/localization/app_localizations.dart';
import 'package:sfa/features/cart/data/cart_models.dart';
import 'package:sfa/features/cart/providers/cart_provider.dart';
import 'package:sfa/utils/assets_constants.dart';
import 'package:sfa/utils/color_constants.dart';
import 'package:sfa/utils/currency_formatter.dart';
import 'package:sfa/utils/app_style.dart';
import 'package:sfa/core/theme/app_palette.dart';
import '../widgets/cart_item_card.dart';
import '../widgets/coupon_code_field.dart';
import '../widgets/pricing_summary.dart';

class CartScreen extends ConsumerStatefulWidget {
  const CartScreen({super.key});

  @override
  ConsumerState<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends ConsumerState<CartScreen> {
  final TextEditingController _giftCardController = TextEditingController();
  final TextEditingController _couponController = TextEditingController();

  @override
  void dispose() {
    _giftCardController.dispose();
    _couponController.dispose();
    super.dispose();
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final cartAsync = ref.watch(cartProvider);

    ref.listen(cartProvider, (previous, next) {
      final error = next.hasError ? next.error : null;
      if (error != null && previous?.hasError != true) {
        _showError(error.toString());
      }
    });

    return Container(
      color: context.palette.background,
      child: SafeArea(
        child: Directionality(
          textDirection: loc.isArabic ? TextDirection.rtl : TextDirection.ltr,
          child: RefreshIndicator(
            onRefresh: () => ref.read(cartProvider.notifier).refresh(),
            child: cartAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => ListView(
                padding: const EdgeInsets.symmetric(vertical: 96),
                children: [
                  Center(
                    child: Text(
                      error.toString(),
                      style: AppStyle.labelText.copyWith(color: context.palette.textMuted),
                    ),
                  ),
                ],
              ),
              data: (cart) => _CartBody(
                cart: cart,
                giftCardController: _giftCardController,
                couponController: _couponController,
                onError: _showError,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CartBody extends ConsumerStatefulWidget {
  final CartData cart;
  final TextEditingController giftCardController;
  final TextEditingController couponController;
  final void Function(String message) onError;

  const _CartBody({
    required this.cart,
    required this.giftCardController,
    required this.couponController,
    required this.onError,
  });

  @override
  ConsumerState<_CartBody> createState() => _CartBodyState();
}

class _CartBodyState extends ConsumerState<_CartBody> {
  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final cart = widget.cart;
    final isAr = loc.isArabic;

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: cart.isEmpty
            ? [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 96),
                  child: Center(
                    child: Text(
                      loc.translate('cartEmpty'),
                      style: AppStyle.labelText.copyWith(color: context.palette.textMuted),
                    ),
                  ),
                ),
              ]
            : [
                // Cart Items List
                ...cart.items.asMap().entries.map((entry) {
                  final int index = entry.key;
                  final item = entry.value;
                  return Column(
                    children: [
                      CartItemCard(
                        imageUrl: item.imageUrl,
                        brand: item.brandName ?? '',
                        title: item.name.resolve(isAr),
                        price: CurrencyFormatter.fromHalalas(item.priceFils, isAr: isAr),
                        itemColor: item.colorValue ?? context.palette.surfaceMuted,
                        size: item.selectedSize ?? '',
                        quantity: item.quantity,
                        showWarning: false,
                        onDelete: () =>
                            ref.read(cartProvider.notifier).removeItem(item.id),
                        onFavorite: () =>
                            ref.read(cartProvider.notifier).moveToFavorite(item.id),
                      ),
                      if (index < cart.items.length - 1)
                        Divider(height: 24, thickness: 0.5, color: context.palette.divider),
                    ],
                  );
                }),
                const SizedBox(height: 12),

                // ── Free Gift Wrap ────────────────────────────────────────
                _CartCheckboxRow(
                  value: cart.giftWrap,
                  onChanged: (v) => ref
                      .read(cartProvider.notifier)
                      .setGiftWrap(
                        giftWrap: v ?? false,
                        giftMessage: widget.giftCardController.text.isEmpty
                            ? null
                            : widget.giftCardController.text,
                      ),
                  svgPath: AssetsConstants.gift,
                  label: loc.translate('freeGiftWrap'),
                ),
                // Expandable gift-wrap detail
                AnimatedCrossFade(
                  duration: const Duration(milliseconds: 250),
                  crossFadeState:
                      cart.giftWrap ? CrossFadeState.showFirst : CrossFadeState.showSecond,
                  firstChild: Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _BulletText(loc.translate('giftWrapBullet1')),
                        const SizedBox(height: 8),
                        _BulletText(loc.translate('giftWrapBullet2')),
                        const SizedBox(height: 16),
                        Text(
                          loc.translate('giftCardMessageLabel'),
                          style: AppStyle.labelText.copyWith(fontWeight: FontWeight.w600),
                          textAlign: isAr ? TextAlign.right : TextAlign.left,
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: widget.giftCardController,
                          minLines: 4,
                          maxLines: 6,
                          textAlign: isAr ? TextAlign.right : TextAlign.left,
                          textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
                          onSubmitted: (value) => ref
                              .read(cartProvider.notifier)
                              .setGiftWrap(
                                giftWrap: true,
                                giftMessage: value,
                              ),
                          decoration: InputDecoration(
                            hintText: loc.translate('giftCardMessageHint'),
                            contentPadding: const EdgeInsets.all(12),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: context.palette.divider),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: context.palette.divider),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: AppColors.primary),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                  secondChild: const SizedBox.shrink(),
                ),
                Divider(height: 1, thickness: 0.5, color: context.palette.divider),
                const SizedBox(height: 12),

                // ── Earn & Redeem ─────────────────────────────────────────
                _CartCheckboxRow(
                  value: cart.pointsRedeemed > 0,
                  onChanged: (v) => ref
                      .read(cartProvider.notifier)
                      .redeemPoints(v == true ? 500 : 0),
                  svgPath: AssetsConstants.ticketCheck,
                  label: loc.translate('earnAndRedeem'),
                  trailingLabel: loc.translate('earnAndRedeemPoints'),
                ),
                if (cart.pointsRedeemed > 0) ...[
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _PointsDiscountText(
                      isAr
                          ? 'تم خصم ${CurrencyFormatter.fromHalalas(cart.pointsDiscountFils, isAr: true)} بواسطة النقط'
                          : '${CurrencyFormatter.fromHalalas(cart.pointsDiscountFils, isAr: false)} discount applied from points',
                      isArabic: isAr,
                    ),
                  ),
                ],
                Divider(height: 1, thickness: 0.5, color: context.palette.divider),
                const SizedBox(height: 16),

                // Coupon Code Box
                CouponCodeField(
                  controller: widget.couponController,
                  onApply: () async {
                    final code = widget.couponController.text.trim();
                    if (code.isEmpty) return;
                    await ref.read(cartProvider.notifier).applyCoupon(code);
                  },
                ),
                if (cart.couponCode != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          isAr
                              ? 'تم تطبيق الكود: ${cart.couponCode}'
                              : 'Applied: ${cart.couponCode}',
                          style: AppStyle.labelText.copyWith(color: AppColors.greencolor),
                        ),
                      ),
                      TextButton(
                        onPressed: () =>
                            ref.read(cartProvider.notifier).removeCoupon(),
                        child: Text(loc.translate('delete')),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 28),

                // Pricing Summary
                PricingSummary(
                  subtotal: CurrencyFormatter.fromHalalas(cart.subtotalFils, isAr: isAr),
                  total: CurrencyFormatter.fromHalalas(cart.totalFils, isAr: isAr),
                  pointsDiscount: cart.pointsDiscountFils > 0
                      ? '-${CurrencyFormatter.fromHalalas(cart.pointsDiscountFils, isAr: isAr)}'
                      : null,
                ),
                const SizedBox(height: 32),

                // Checkout Button
                ElevatedButton(
                  onPressed: () => context.push('/checkout'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    minimumSize: const Size(double.infinity, 54),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    elevation: 0,
                  ),
                  child: Row(
                    textDirection: TextDirection.ltr,
                    children: [
                      const SizedBox(width: 8),
                      SvgPicture.asset(
                        AssetsConstants.shoppingBag,
                        width: 18,
                        height: 18,
                        colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Text(
                            loc.translate('secureCheckout'),
                            textAlign: TextAlign.right,
                            style: AppStyle.buttonTextPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
      ),
    );
  }
}

/// A single row with a rounded checkbox, an SVG icon, a primary label,
/// and an optional gold trailing label (used for the points count).
///
/// Arabic (RTL): checkbox on the LEFT, icon + label pushed to the RIGHT.
/// English (LTR): icon + label on the LEFT, checkbox on the RIGHT.
class _CartCheckboxRow extends StatelessWidget {
  const _CartCheckboxRow({
    required this.value,
    required this.onChanged,
    required this.svgPath,
    required this.label,
    this.trailingLabel,
  });

  final bool value;
  final ValueChanged<bool?> onChanged;
  final String svgPath;
  final String label;
  final String? trailingLabel;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final isArabic = loc.isArabic;

    // Icon + label block — wrapped in Directionality(ltr) so physical order
    // is always respected. For Arabic we reverse the children so the SVG
    // sits on the right side next to the label.
    final svgIcon = SvgPicture.asset(
      svgPath,
      width: 22,
      height: 22,
      colorFilter: ColorFilter.mode(
        context.palette.textPrimary,
        BlendMode.srcIn,
      ),
    );

    final labelWidgets = <Widget>[
      Text(label, style: AppStyle.labelText),
      if (trailingLabel != null) ...[
        const SizedBox(width: 6),
        Text(
          trailingLabel!,
          style: AppStyle.labelText.copyWith(color: AppColors.primary),
        ),
      ],
    ];

    final content = Directionality(
      textDirection: TextDirection.ltr,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: isArabic
            // Arabic: text first (rightmost), then SVG on the far right
            ? [...labelWidgets, const SizedBox(width: 8), svgIcon]
            // English: SVG on the left, then text
            : [svgIcon, const SizedBox(width: 8), ...labelWidgets],
      ),
    );

    // Rounded checkbox
    final checkbox = SizedBox(
      width: 24,
      height: 24,
      child: Checkbox(
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        side: BorderSide(color: context.palette.divider, width: 1.5),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
      ),
    );

    return InkWell(
      onTap: () => onChanged(!value),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        // Force LTR on the Row so our explicit child order is always
        // respected physically on screen, regardless of parent Directionality.
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: Row(
            children: isArabic
                // Arabic: checkbox physically LEFT — label/icon pushed RIGHT
                ? [
                    checkbox,
                    const SizedBox(width: 12),
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: content,
                      ),
                    ),
                  ]
                // English: label/icon LEFT — checkbox pushed RIGHT
                : [content, const Spacer(), checkbox],
          ),
        ),
      ),
    );
  }
}

// ── Helper widgets ────────────────────────────────────────────────────────────

/// A bullet-point text row.
/// Arabic: dot on the RIGHT, text right-aligned.
/// English: dot on the LEFT, text left-aligned.
class _BulletText extends StatelessWidget {
  const _BulletText(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    final isArabic = AppLocalizations.of(context).isArabic;

    final dot = Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Icon(Icons.circle, size: 6, color: context.palette.textPrimary),
    );

    final label = Expanded(
      child: Text(
        text,
        style: AppStyle.subtitleDesc.copyWith(
          color: context.palette.textPrimary.withValues(alpha: 0.7),
        ),
        textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
        textAlign: isArabic ? TextAlign.right : TextAlign.left,
      ),
    );

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: isArabic
            // Arabic: text fills right side, dot sits on the far right
            ? [label, const SizedBox(width: 8), dot]
            // English: dot on the left, text fills the rest
            : [dot, const SizedBox(width: 8), label],
      ),
    );
  }
}

/// The discount amount rendered in primary gold within the sentence.
class _PointsDiscountText extends StatelessWidget {
  const _PointsDiscountText(this.fullText, {required this.isArabic});
  final String fullText;
  final bool isArabic;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isArabic ? Alignment.centerRight : Alignment.centerLeft,
      child: Text(
        fullText,
        textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
        style: AppStyle.labelText.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
