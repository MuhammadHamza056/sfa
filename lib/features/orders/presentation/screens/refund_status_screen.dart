import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sfa/core/localization/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sfa/features/orders/data/refund_models.dart';
import 'package:sfa/features/orders/providers/orders_provider.dart';
import 'package:sfa/features/orders/providers/refunds_providers.dart';
import 'package:sfa/utils/order_id_formatter.dart';
import 'package:sfa/utils/currency_formatter.dart';
import 'package:sfa/core/theme/app_palette.dart';
import 'package:sfa/core/widgets/primary_app_bar.dart';

/// [refundId] is the id returned by `POST /orders/:id/refund-request`
/// (M57), not the order id — [RefundRequestScreen] navigates here with it.
class RefundStatusScreen extends ConsumerStatefulWidget {
  final String refundId;

  const RefundStatusScreen({super.key, required this.refundId});

  @override
  ConsumerState<RefundStatusScreen> createState() => _RefundStatusScreenState();
}

class _RefundStatusScreenState extends ConsumerState<RefundStatusScreen> {
  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final isAr = loc.isArabic;
    final textDir = isAr ? TextDirection.rtl : TextDirection.ltr;

    final orderNumLabel = loc.translate('orderNumberLabel');
    final orderDateLabel = loc.translate('orderDateLabel');
    final trackRefundStatusLabel = loc.translate('trackRefundStatus');
    final returnedProductsLabel = loc.translate('returnedProducts');

    final milestoneLabels = [
      loc.translate('statusRefundProcessing'),
      loc.translate('statusProductsReceived'),
      loc.translate('statusRefundSuccessful'),
    ];

    final state = ref.watch(ordersProvider);
    final detailAsync = ref.watch(refundDetailProvider(widget.refundId));
    final itemsAsync = ref.watch(refundItemsProvider(widget.refundId));

    return Directionality(
      textDirection: textDir,
      child: Scaffold(
        backgroundColor: context.palette.background,
        appBar: PrimaryAppBar(
          title: 'SFA',
          showBackButton: true,
          onCartTap: () => context.go('/cart'),
          onHeartTap: () => context.go('/favorites'),
        ),
        body: detailAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(
            child: Text(error.toString(), style: TextStyle(color: context.palette.textMuted)),
          ),
          data: (refund) {
            final titleText =
                '${loc.translate('refundRequestTitle')} #${OrderIdFormatter.shorten(refund.orderId)}';
            // Map the refund's real status onto the 3-milestone UI: doc
            // gives no per-refund timeline (unlike orders' M52), so this is
            // a best-faith reduction of `stageIndex` into 3 buckets.
            final bucket = (refund.stageIndex * 3 / RefundDetail.stages.length).floor().clamp(0, 2);

            return ListView(
              padding: const EdgeInsets.all(24.0),
              children: [
                Text(
                  titleText,
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: context.palette.textPrimary),
                  textAlign: isAr ? TextAlign.right : TextAlign.left,
                ),
                const SizedBox(height: 8),
                Divider(thickness: 1, color: context.palette.divider),
                const SizedBox(height: 12),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '#${refund.orderId}',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: context.palette.textPrimary),
                    ),
                    Text(orderNumLabel, style: TextStyle(fontSize: 14, color: context.palette.textMuted)),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      refund.createdAt != null
                          ? '${refund.createdAt!.year}/${refund.createdAt!.month}/${refund.createdAt!.day}'
                          : '—',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: context.palette.textPrimary),
                    ),
                    Text(orderDateLabel, style: TextStyle(fontSize: 14, color: context.palette.textMuted)),
                  ],
                ),
                if (refund.refundAmountFils > 0) ...[
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        CurrencyFormatter.fromHalalas(refund.refundAmountFils, isAr: isAr),
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: context.palette.textPrimary),
                      ),
                      Text(
                        isAr ? 'مبلغ الاسترجاع' : 'Refund Amount',
                        style: TextStyle(fontSize: 14, color: context.palette.textMuted),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 24),

                Align(
                  alignment: isAr ? Alignment.centerRight : Alignment.centerLeft,
                  child: Text(
                    trackRefundStatusLabel,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: context.palette.textPrimary),
                  ),
                ),
                const SizedBox(height: 16),

                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: context.palette.backgroundSubtle,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: List.generate(milestoneLabels.length, (i) {
                      final isDone = i <= bucket;
                      final isLast = i == milestoneLabels.length - 1;
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            children: [
                              Container(
                                width: 14,
                                height: 14,
                                decoration: BoxDecoration(
                                  color: isDone ? Colors.green : context.palette.textMuted,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              if (!isLast)
                                Container(
                                  width: 2,
                                  height: 48,
                                  color: i < bucket ? Colors.green : context.palette.textMuted,
                                ),
                            ],
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 24),
                              child: Text(
                                milestoneLabels[i],
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: isDone ? FontWeight.bold : FontWeight.w600,
                                  color: isDone ? context.palette.textPrimary : context.palette.textMuted,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    }),
                  ),
                ),
                const SizedBox(height: 16),

                GestureDetector(
                  onTap: () => ref.read(ordersProvider.notifier).toggleProductsExpanded(),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        returnedProductsLabel,
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: context.palette.textPrimary),
                      ),
                      Icon(
                        state.isProductsExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                        color: context.palette.textPrimary,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                if (state.isProductsExpanded)
                  itemsAsync.when(
                    loading: () => const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                    error: (error, _) => Text(
                      error.toString(),
                      style: TextStyle(color: context.palette.textMuted),
                    ),
                    data: (items) => Column(
                      children: items.map((item) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            border: Border(bottom: BorderSide(color: context.palette.divider, width: 1)),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  item.image,
                                  width: 110,
                                  height: 110,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) =>
                                      Container(width: 110, height: 110, color: context.palette.surfaceMuted),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.name.resolve(isAr),
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: context.palette.textPrimary,
                                      ),
                                      textAlign: isAr ? TextAlign.right : TextAlign.left,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      isAr ? 'الكمية: ${item.quantity}' : 'Qty: ${item.quantity}',
                                      style: TextStyle(fontSize: 13, color: context.palette.textMuted),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                const SizedBox(height: 24),
              ],
            );
          },
        ),
      ),
    );
  }
}
