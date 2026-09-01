import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:sfa/core/localization/app_localizations.dart';
import 'package:sfa/utils/app_style.dart';
import 'package:sfa/utils/assets_constants.dart';
import 'package:sfa/utils/color_constants.dart';
import 'package:sfa/core/theme/app_palette.dart';
import '../../data/checkout_models.dart';

class PaymentSuccessScreen extends StatelessWidget {
  final CheckoutConfirmResult? order;

  const PaymentSuccessScreen({super.key, this.order});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final isAr = loc.isArabic;

    return Directionality(
      textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: context.palette.backgroundSubtle,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 12),

                // ── Title ─────────────────────────────────────────────
                Center(
                  child: Text(
                    loc.translate('paymentSuccess'),
                    style: AppStyle.screenTitle,
                  ),
                ),
                const SizedBox(height: 16),
                Divider(thickness: 0.8, color: context.palette.divider),
                const SizedBox(height: 60),

                // ── Thumbs-up SVG icon ───────────────────────────────
                Center(
                  child: SvgPicture.asset(
                    AssetsConstants.thumbsUp,
                    width: 160,
                    height: 160,
                  ),
                ),
                const SizedBox(height: 52),

                // ── Success Message ───────────────────────────────────
                Text(
                  loc.translate('paymentSuccessMessage'),
                  textAlign: TextAlign.center,
                  style: AppStyle.valueText.copyWith(
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (order != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    '#${order!.orderNumber}',
                    textAlign: TextAlign.center,
                    style: AppStyle.valueText.copyWith(
                      fontSize: 15,
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
                const SizedBox(height: 48),

                // ── Track Orders Button ───────────────────────────────
                ElevatedButton(
                  onPressed: () => context.go('/order-tracking/${order?.orderId ?? ''}'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    minimumSize: const Size(double.infinity, 54),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          loc.translate('trackOrders'),
                          textAlign: TextAlign.start,
                          style: AppStyle.buttonTextPrimary,
                        ),
                      ),
                      isAr
                          ? Transform(
                              alignment: Alignment.center,
                              transform: Matrix4.rotationY(3.141592653589793),
                              child: SvgPicture.asset(
                                AssetsConstants.moveLeft,
                                width: 18,
                                height: 18,
                                colorFilter: const ColorFilter.mode(
                                  Colors.white,
                                  BlendMode.srcIn,
                                ),
                              ),
                            )
                          : SvgPicture.asset(
                              AssetsConstants.moveLeft,
                              width: 18,
                              height: 18,
                              colorFilter: const ColorFilter.mode(
                                Colors.white,
                                BlendMode.srcIn,
                              ),
                            ),
                      const SizedBox(width: 12),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
