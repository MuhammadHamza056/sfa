import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:sfa/core/localization/app_localizations.dart';
import 'package:sfa/utils/app_style.dart';
import 'package:sfa/utils/assets_constants.dart';
import 'package:sfa/utils/color_constants.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sfa/features/orders/data/order_models.dart';
import 'package:sfa/features/orders/providers/orders_data_provider.dart';
import 'package:sfa/utils/currency_formatter.dart';
import 'package:sfa/core/theme/app_palette.dart';
import 'package:sfa/core/widgets/primary_app_bar.dart';

class OrderTrackingScreen extends ConsumerStatefulWidget {
  final String orderId;

  const OrderTrackingScreen({super.key, required this.orderId});

  @override
  ConsumerState<OrderTrackingScreen> createState() =>
      _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends ConsumerState<OrderTrackingScreen> {
  bool _busy = false;

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _onCancel(AppLocalizations loc) async {
    final reasonController = TextEditingController();
    final reason = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(loc.translate('cancel')),
        content: TextField(
          controller: reasonController,
          decoration: InputDecoration(hintText: loc.isArabic ? 'سبب الإلغاء' : 'Cancellation reason'),
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: Text(loc.isArabic ? 'إغلاق' : 'Close'),
          ),
          TextButton(
            onPressed: () => context.pop(reasonController.text.trim()),
            child: Text(loc.translate('cancel')),
          ),
        ],
      ),
    );
    if (reason == null || reason.isEmpty || !mounted) return;

    setState(() => _busy = true);
    final result = await ref
        .read(ordersRepositoryProvider)
        .cancelOrder(widget.orderId, reason: reason);
    if (!mounted) return;
    setState(() => _busy = false);
    result.when(
      success: (_) {
        ref.invalidate(orderDetailProvider(widget.orderId));
        ref.invalidate(orderTrackingDataProvider(widget.orderId));
        _showMessage(loc.isArabic ? 'تم إلغاء الطلب' : 'Order cancelled');
      },
      failure: (error) => _showMessage(error.message),
    );
  }

  Future<void> _onConfirmDelivery(AppLocalizations loc) async {
    setState(() => _busy = true);
    final result = await ref.read(ordersRepositoryProvider).confirmDelivery(widget.orderId);
    if (!mounted) return;
    setState(() => _busy = false);
    result.when(
      success: (_) {
        ref.invalidate(orderDetailProvider(widget.orderId));
        ref.invalidate(orderTrackingDataProvider(widget.orderId));
        _showMessage(loc.translate('confirmDelivery'));
      },
      failure: (error) => _showMessage(error.message),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final isAr = loc.isArabic;
    final textDir = isAr ? TextDirection.rtl : TextDirection.ltr;

    final detailAsync = ref.watch(orderDetailProvider(widget.orderId));
    final trackingAsync = ref.watch(orderTrackingDataProvider(widget.orderId));

    return Directionality(
      textDirection: textDir,
      child: Scaffold(
        backgroundColor: context.palette.background,

        // ─── AppBar ───────────────────────────────────────────────────
        appBar: PrimaryAppBar(
          title: loc.translate('orderTracking'),
          fontSize: 18,
          letterSpacing: 0,
          showBackButton: true,
          cartIcon: AssetsConstants.shoppingBag,
          heartIcon: AssetsConstants.heart2,
          onBackTap: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/dashboard');
            }
          },
        ),

        // ─── Body ─────────────────────────────────────────────────────
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ─── Order Info Header ───
              Align(
                alignment: isAr ? Alignment.centerRight : Alignment.centerLeft,
                child: Text(loc.translate('orderInfo'), style: AppStyle.sectionHeader),
              ),
              const SizedBox(height: 6),
              Divider(color: context.palette.divider, thickness: 0.8),
              const SizedBox(height: 24),

              detailAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => Text(
                  error.toString(),
                  style: AppStyle.bodyText.copyWith(color: context.palette.textMuted),
                ),
                data: (order) => Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildInfoRow(loc.translate('orderNumberLabel'), '#${order.orderNumber}'),
                    const SizedBox(height: 12),
                    _buildInfoRow(
                      loc.translate('orderDateLabel'),
                      order.createdAt != null
                          ? '${order.createdAt!.year}/${order.createdAt!.month}/${order.createdAt!.day}'
                          : '—',
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow(
                      loc.translate('totalAmountLabel'),
                      CurrencyFormatter.fromHalalas(order.totalFils, isAr: isAr),
                      valueColor: AppColors.primary,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ─── Cancel Order Button ───
              _buildCancelButton(loc, isAr),
              const SizedBox(height: 32),

              // ─── Order Status Header ───
              Align(
                alignment: isAr ? Alignment.centerRight : Alignment.centerLeft,
                child: Text(loc.translate('orderStatus'), style: AppStyle.sectionHeader),
              ),
              const SizedBox(height: 6),
              Divider(color: context.palette.divider, thickness: 0.8),
              const SizedBox(height: 24),

              // ─── Vertical Timeline ───
              trackingAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => Text(
                  error.toString(),
                  style: AppStyle.bodyText.copyWith(color: context.palette.textMuted),
                ),
                data: (tracking) => _buildTrackerTimeline(tracking, isAr),
              ),
              const SizedBox(height: 32),

              // ─── Confirm Delivery Button ───
              ElevatedButton(
                onPressed: _busy ? null : () => _onConfirmDelivery(loc),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  minimumSize: const Size(double.infinity, 54),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  elevation: 0,
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        loc.translate('confirmDelivery'),
                        textAlign: TextAlign.start,
                        style: AppStyle.buttonTextPrimary,
                      ),
                    ),
                    SvgPicture.asset(
                      AssetsConstants.shoppingBag,
                      width: 18,
                      height: 18,
                      colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                    ),
                    const SizedBox(width: 12),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // ─── Bottom Cancel Button ───
              _buildCancelButton(loc, isAr),
              const SizedBox(height: 32),

              // ─── Delivery Info Header ───
              trackingAsync.maybeWhen(
                data: (tracking) => tracking.driver == null
                    ? const SizedBox.shrink()
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Center(
                            child: Text(loc.translate('deliveryInfo'), style: AppStyle.sectionHeader),
                          ),
                          const SizedBox(height: 6),
                          Divider(color: context.palette.divider, thickness: 0.8),
                          const SizedBox(height: 24),
                          _buildDeliveryCard(tracking.driver!),
                          const SizedBox(height: 24),
                        ],
                      ),
                orElse: () => const SizedBox.shrink(),
              ),

              // ─── Final Cancel Button ───
              _buildCancelButton(loc, isAr),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // ── Helper Widgets ──

  Widget _buildInfoRow(
    String label,
    String value, {
    Color? valueColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppStyle.labelText.copyWith(
            color: context.palette.textPrimary.withValues(alpha: 0.6),
          ),
        ),
        Directionality(
          textDirection: TextDirection.ltr,
          child: Text(
            value,
            style: AppStyle.valueText.copyWith(
              color: valueColor ?? context.palette.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCancelButton(AppLocalizations loc, bool isAr) {
    return OutlinedButton(
      onPressed: _busy ? null : () => _onCancel(loc),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, 54),
        side: BorderSide(color: context.palette.divider),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
      child: Row(
        children: [
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              loc.translate('cancel'),
              textAlign: TextAlign.start,
              style: AppStyle.buttonTextSecondary,
            ),
          ),
          // Arrow pointing LEFT in Arabic, RIGHT in English
          isAr
              ? Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.rotationY(math.pi),
                  child: SvgPicture.asset(
                    AssetsConstants.moveLeft,
                    width: 18,
                    height: 18,
                    colorFilter: ColorFilter.mode(context.palette.textPrimary, BlendMode.srcIn),
                  ),
                )
              : SvgPicture.asset(
                  AssetsConstants.moveLeft,
                  width: 18,
                  height: 18,
                  colorFilter: ColorFilter.mode(context.palette.textPrimary, BlendMode.srcIn),
                ),
          const SizedBox(width: 12),
        ],
      ),
    );
  }

  Widget _buildTrackerTimeline(OrderTracking tracking, bool isAr) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(tracking.timeline.length, (index) {
        final step = tracking.timeline[index];
        final isLast = index == tracking.timeline.length - 1;
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildTimelineIndicatorColumn(step, isLast),
            const SizedBox(width: 16),
            _buildStepText(step, alignRight: isAr),
          ],
        );
      }),
    );
  }

  Widget _buildTimelineIndicatorColumn(OrderTrackingStep step, bool isLast) {
    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: context.palette.background,
            border: Border.all(
              color: step.completed
                  ? const Color(0xFF5CC0A7)
                  : AppColors.primary.withValues(alpha: 0.4),
              width: 1.5,
            ),
          ),
          child: step.completed
              ? const Center(
                  child: Icon(Icons.check, color: Color(0xFF5CC0A7), size: 16),
                )
              : null,
        ),
        if (!isLast)
          Container(
            width: 1.5,
            height: 50,
            color: step.completed
                ? const Color(0xFF5CC0A7)
                : AppColors.primary.withValues(alpha: 0.4),
          ),
      ],
    );
  }

  Widget _buildStepText(OrderTrackingStep step, {bool alignRight = false}) {
    final time = step.timestamp;
    return Column(
      crossAxisAlignment: alignRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(step.label, style: AppStyle.timelineTitle),
        Text(
          time != null
              ? '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}'
              : '--:--',
          style: AppStyle.timelineSubtitle.copyWith(
            color: context.palette.textPrimary.withValues(alpha: 0.5),
          ),
        ),
      ],
    );
  }

  Widget _buildDeliveryCard(OrderDriver driver) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.4), width: 1.2),
          ),
          child: Center(
            child: SvgPicture.asset(
              AssetsConstants.truck,
              width: 26,
              height: 26,
              colorFilter: ColorFilter.mode(AppColors.primary, BlendMode.srcIn),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(driver.name, style: AppStyle.cardTitle),
            Directionality(
              textDirection: TextDirection.ltr,
              child: Text(driver.phone, style: AppStyle.cardSubtitle),
            ),
          ],
        ),
      ],
    );
  }
}
