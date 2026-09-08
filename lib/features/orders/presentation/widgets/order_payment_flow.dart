import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sfa/core/localization/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:sfa/core/theme/app_palette.dart';
import 'package:sfa/features/checkout/data/checkout_models.dart';
import 'package:sfa/features/checkout/presentation/screens/payment_webview_screen.dart';
import 'package:sfa/features/payments/data/payment_models.dart';
import 'package:sfa/features/payments/providers/payments_providers.dart';
import 'package:sfa/utils/app_style.dart';
import 'package:sfa/utils/color_constants.dart';
import 'package:sfa/utils/currency_formatter.dart';

/// Pays an order that was created but never paid (`paymentStatus: PENDING`).
/// This is checkout's confirm-button path from `/payments/methods/initiate`
/// onwards — the order already exists, so only the create-order step is
/// skipped, and the payment screens are shared with checkout.
///
/// Returns true once the customer has been through the gateway, so callers
/// can refetch the order; false if they backed out or initiation failed.
Future<bool> startOrderPayment({
  required BuildContext context,
  required WidgetRef ref,
  required String orderId,
  required String orderNumber,
  required int totalFils,
  String currency = 'SAR',
  ValueChanged<bool>? onBusyChanged,
}) async {
  final method = await showOrderPaymentMethodSheet(
    context: context,
    amountFils: totalFils,
    currency: currency,
  );
  if (method == null || !context.mounted) return false;

  onBusyChanged?.call(true);
  final result = await ref.read(paymentsRepositoryProvider).initiatePayment(
        orderId: orderId,
        methodKey: method.code,
        methodMyfatoorahId: method.id,
      );
  if (!context.mounted) return false;
  onBusyChanged?.call(false);

  return result.when(
    success: (payment) async {
      // The payment screens describe their order with checkout's
      // CheckoutConfirmResult — rebuild one from the order being paid.
      final confirmed = CheckoutConfirmResult(
        orderId: orderId,
        orderNumber: orderNumber,
        totalFils: totalFils,
      );
      if (payment.paymentUrl.isEmpty) {
        await context.push('/payment-success', extra: confirmed);
      } else {
        await context.push(
          '/payment-webview',
          extra: PaymentWebviewArgs(paymentUrl: payment.paymentUrl, order: confirmed),
        );
      }
      return true;
    },
    failure: (error) async {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.message)));
      return false;
    },
  );
}

/// Lets the customer pick a MyFatoorah method for an order that was created
/// but never paid (`paymentStatus: PENDING`). Checkout picks the method
/// inline on its own screen; from the orders list there's no such screen, so
/// the same M46 method list is offered in a sheet instead. Returns the
/// chosen method, or null if the customer backed out.
Future<MyFatoorahPaymentMethod?> showOrderPaymentMethodSheet({
  required BuildContext context,
  required int amountFils,
  required String currency,
}) {
  return showModalBottomSheet<MyFatoorahPaymentMethod>(
    context: context,
    isScrollControlled: true,
    backgroundColor: context.palette.background,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => _OrderPaymentMethodSheet(amountFils: amountFils, currency: currency),
  );
}

class _OrderPaymentMethodSheet extends ConsumerStatefulWidget {
  final int amountFils;
  final String currency;

  const _OrderPaymentMethodSheet({required this.amountFils, required this.currency});

  @override
  ConsumerState<_OrderPaymentMethodSheet> createState() => _OrderPaymentMethodSheetState();
}

class _OrderPaymentMethodSheetState extends ConsumerState<_OrderPaymentMethodSheet> {
  MyFatoorahPaymentMethod? _selected;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final isAr = loc.isArabic;
    final methodsAsync = ref.watch(
      myFatoorahPaymentMethodsProvider(
        (amount: widget.amountFils / 100.0, currency: widget.currency),
      ),
    );

    return Directionality(
      textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Text(loc.translate('choosePayment'), style: AppStyle.cardTitle),
                  const Spacer(),
                  Text(
                    CurrencyFormatter.fromHalalas(widget.amountFils, isAr: isAr),
                    style: AppStyle.valuePrimary,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              methodsAsync.when(
                loading: () => const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (error, _) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    error.toString(),
                    style: AppStyle.bodyText.copyWith(color: context.palette.textMuted),
                  ),
                ),
                data: (methods) {
                  if (methods.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                        isAr ? 'لا توجد وسائل دفع متاحة' : 'No payment methods available',
                        style: AppStyle.bodyText.copyWith(color: context.palette.textMuted),
                      ),
                    );
                  }
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ConstrainedBox(
                        constraints: BoxConstraints(
                          maxHeight: MediaQuery.of(context).size.height * 0.4,
                        ),
                        child: ListView(
                          shrinkWrap: true,
                          children: [
                            for (final method in methods)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: _buildPaymentOption(method, isAr),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: _selected == null
                            ? null
                            : () => Navigator.of(context).pop(_selected),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          minimumSize: const Size(double.infinity, 54),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          elevation: 0,
                        ),
                        child: Text(loc.translate('payNow'), style: AppStyle.buttonTextPrimary),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Mirrors checkout's payment option tile so the two entry points into the
  /// same MyFatoorah flow look identical.
  Widget _buildPaymentOption(MyFatoorahPaymentMethod method, bool isAr) {
    final isSelected = _selected?.code == method.code;
    return GestureDetector(
      onTap: () => setState(() => _selected = method),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: context.palette.background,
          border: Border.all(color: context.palette.divider, width: 1),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(isAr ? method.nameAr : method.nameEn, style: AppStyle.paymentOption),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? Colors.transparent : context.palette.surfaceMuted,
                border: isSelected ? Border.all(color: AppColors.primary, width: 1.5) : null,
              ),
              child: isSelected
                  ? Center(child: Icon(Icons.check, color: AppColors.primary, size: 15))
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
