import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:sfa/core/localization/app_localizations.dart';
import 'package:sfa/utils/assets_constants.dart';
import 'package:sfa/utils/color_constants.dart';
import 'package:sfa/utils/app_style.dart';
import 'package:sfa/core/theme/app_palette.dart';
import '../widgets/cart_item_card.dart';
import '../widgets/coupon_code_field.dart';
import '../widgets/pricing_summary.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  bool _freeGiftWrap = false;
  bool _earnAndRedeem = false;
  final TextEditingController _giftCardController = TextEditingController();

  @override
  void dispose() {
    _giftCardController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    // Mock cart items
    final List<Map<String, dynamic>> cartItems = [
      {
        'imageUrl':
            'https://images.unsplash.com/photo-1595777457583-95e059d581b8?w=300',
        'brand': loc.translate('jubaBrand'),
        'title': loc.translate('desertRose'),
        'price': loc.isArabic ? '1,250 ر.س.' : '1,250 SAR',
        'color': const Color(0xFFD7B9A9), // beige
        'size': 'M',
        'quantity': 1,
        'showWarning': true,
      },
      {
        'imageUrl':
            'https://images.unsplash.com/photo-1605763240000-7e93b172d754?w=300',
        'brand': loc.translate('jubaBrand'),
        'title': loc.translate('desertRose'),
        'price': loc.isArabic ? '1,250 ر.س.' : '1,250 SAR',
        'color': const Color(0xFF8FA1A6), // slate grey
        'size': 'M',
        'quantity': 1,
        'showWarning': true,
      },
    ];

    return Container(
      color: context.palette.background,
      child: SafeArea(
        child: Directionality(
          textDirection: loc.isArabic ? TextDirection.rtl : TextDirection.ltr,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Cart Items List
                ...cartItems.asMap().entries.map((entry) {
                  final int index = entry.key;
                  final Map<String, dynamic> item = entry.value;
                  return Column(
                    children: [
                      CartItemCard(
                        imageUrl: item['imageUrl'],
                        brand: item['brand'],
                        title: item['title'],
                        price: item['price'],
                        itemColor: item['color'],
                        size: item['size'],
                        quantity: item['quantity'],
                        showWarning: item['showWarning'],
                        onDelete: () {},
                        onFavorite: () {},
                      ),
                      if (index < cartItems.length - 1)
                        Divider(
                          height: 24,
                          thickness: 0.5,
                          color: context.palette.divider,
                        ),
                    ],
                  );
                }),
                const SizedBox(height: 12),

                // ── Free Gift Wrap ────────────────────────────────────────
                _CartCheckboxRow(
                  value: _freeGiftWrap,
                  onChanged: (v) => setState(() => _freeGiftWrap = v ?? false),
                  svgPath: AssetsConstants.gift,
                  label: loc.translate('freeGiftWrap'),
                ),
                // Expandable gift-wrap detail
                AnimatedCrossFade(
                  duration: const Duration(milliseconds: 250),
                  crossFadeState: _freeGiftWrap
                      ? CrossFadeState.showFirst
                      : CrossFadeState.showSecond,
                  firstChild: Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Bullet 1
                        _BulletText(loc.translate('giftWrapBullet1')),
                        const SizedBox(height: 8),
                        // Bullet 2
                        _BulletText(loc.translate('giftWrapBullet2')),
                        const SizedBox(height: 16),
                        // Gift card message label
                        Text(
                          loc.translate('giftCardMessageLabel'),
                          style: AppStyle.labelText.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: loc.isArabic
                              ? TextAlign.right
                              : TextAlign.left,
                        ),
                        const SizedBox(height: 8),
                        // Multiline text field
                        TextField(
                          controller: _giftCardController,
                          minLines: 4,
                          maxLines: 6,
                          textAlign: loc.isArabic
                              ? TextAlign.right
                              : TextAlign.left,
                          textDirection: loc.isArabic
                              ? TextDirection.rtl
                              : TextDirection.ltr,
                          decoration: InputDecoration(
                            hintText: loc.translate('giftCardMessageHint'),
                            contentPadding: const EdgeInsets.all(12),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: context.palette.divider,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: context.palette.divider,
                              ),
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
                Divider(
                  height: 1,
                  thickness: 0.5,
                  color: context.palette.divider,
                ),
                const SizedBox(height: 12),

                // ── Earn & Redeem ─────────────────────────────────────────
                _CartCheckboxRow(
                  value: _earnAndRedeem,
                  onChanged: (v) => setState(() => _earnAndRedeem = v ?? false),
                  svgPath: AssetsConstants.ticketCheck,
                  label: loc.translate('earnAndRedeem'),
                  trailingLabel: loc.translate('earnAndRedeemPoints'),
                ),
                // Expandable points-discount detail
                AnimatedCrossFade(
                  duration: const Duration(milliseconds: 250),
                  crossFadeState: _earnAndRedeem
                      ? CrossFadeState.showFirst
                      : CrossFadeState.showSecond,
                  firstChild: Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _PointsDiscountText(
                      loc.translate('pointsDiscountText'),
                      isArabic: loc.isArabic,
                    ),
                  ),
                  secondChild: const SizedBox.shrink(),
                ),
                Divider(
                  height: 1,
                  thickness: 0.5,
                  color: context.palette.divider,
                ),
                const SizedBox(height: 16),

                // Coupon Code Box
                const CouponCodeField(),
                const SizedBox(height: 28),

                // Pricing Summary
                PricingSummary(
                  subtotal: loc.isArabic ? '2,500 ر.س.' : '2,500 SAR',
                  total: loc.isArabic ? '2,480 ر.س.' : '2,480 SAR',
                  pointsDiscount: loc.isArabic ? '-20 ر.س.' : '-20 SAR',
                ),
                const SizedBox(height: 32),

                // Checkout Button
                ElevatedButton(
                  onPressed: () => context.push('/checkout'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    minimumSize: const Size(double.infinity, 54),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
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
                        colorFilter: const ColorFilter.mode(
                          Colors.white,
                          BlendMode.srcIn,
                        ),
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
          ),
        ),
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
      colorFilter: ColorFilter.mode(context.palette.textPrimary, BlendMode.srcIn),
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
        style: AppStyle.subtitleDesc.copyWith(color: context.palette.textPrimary.withValues(alpha: 0.7)),
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

/// "تم خصم 20 ر.س. بواسطة النقط" — the bold amount rendered in primary gold.
class _PointsDiscountText extends StatelessWidget {
  const _PointsDiscountText(this.fullText, {required this.isArabic});
  final String fullText;
  final bool isArabic;

  @override
  Widget build(BuildContext context) {
    // Split on the amount "20" so we can colour it separately.
    // Works for both Arabic ("تم خصم 20 ر.س.") and English ("20 SAR discount").
    final parts = fullText.split('20');
    final before = parts.first;
    final after = parts.length > 1 ? parts.sublist(1).join('20') : '';

    return Align(
      alignment: isArabic ? Alignment.centerRight : Alignment.centerLeft,
      child: RichText(
        textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
        text: TextSpan(
          style: AppStyle.labelText,
          children: [
            TextSpan(text: before),
            TextSpan(
              text: '20',
              style: AppStyle.labelText.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
            TextSpan(text: after),
          ],
        ),
      ),
    );
  }
}

/// A label + value row used inside the gift-wrap expanded section.
