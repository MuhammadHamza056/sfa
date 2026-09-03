import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sfa/core/localization/app_localizations.dart';
import 'package:sfa/utils/color_constants.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sfa/features/orders/providers/orders_data_provider.dart';
import 'package:sfa/features/orders/providers/orders_provider.dart';
import 'package:sfa/features/orders/providers/refunds_providers.dart';
import 'package:sfa/utils/loader.dart';
import 'package:sfa/utils/order_id_formatter.dart';
import 'package:sfa/core/theme/app_palette.dart';
import 'package:sfa/core/widgets/primary_app_bar.dart';

class RefundRequestScreen extends ConsumerStatefulWidget {
  final String orderId;

  const RefundRequestScreen({super.key, required this.orderId});

  @override
  ConsumerState<RefundRequestScreen> createState() =>
      _RefundRequestScreenState();
}

class _RefundRequestScreenState extends ConsumerState<RefundRequestScreen> {
  bool _submitting = false;

  Future<void> _onSubmit(AppLocalizations loc, OrdersState state) async {
    final selectedIds = state.selectedProducts.entries
        .where((e) => e.value)
        .map((e) => e.key)
        .toList();
    if (selectedIds.isEmpty) {
      Loader.showError(loc.translate('selectAtLeastOneProduct'));
      return;
    }
    if (state.selectedReason == null) {
      Loader.showError(loc.translate('reasonPlaceholder'));
      return;
    }

    setState(() => _submitting = true);
    final result = await ref.read(refundsRepositoryProvider).submitRefundRequest(
          orderId: widget.orderId,
          reason: state.selectedReason!,
          items: selectedIds.map((id) => {'itemId': id, 'quantity': 1}).toList(),
        );
    if (!mounted) return;
    setState(() => _submitting = false);

    result.when(
      success: (refund) => context.push('/refund-status/${refund.refundId}'),
      failure: (error) => Loader.showError(error.message),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final isAr = loc.isArabic;
    final textDir = isAr ? TextDirection.rtl : TextDirection.ltr;

    final titleText =
        '${loc.translate('refundRequestTitle')} #${OrderIdFormatter.shorten(widget.orderId)}';
    final orderNumLabel = loc.translate('orderNumberLabel');
    final orderDateLabel = loc.translate('orderDateLabel');
    final sectionTitle = loc.translate('productsToReturn');
    final reasonLabel = loc.translate('reasonForReturn');

    final state = ref.watch(ordersProvider);
    final returnableAsync = ref.watch(returnableItemsProvider(widget.orderId));
    final reasonsAsync = ref.watch(refundReasonsProvider);
    final ordersAsync = ref.watch(ordersDataProvider);
    final order = ordersAsync.valueOrNull?.where((o) => o.id == widget.orderId).firstOrNull;

    // The three sources above load independently; without this each one
    // popped its own inline spinner into the page as it resolved, so the
    // user briefly saw two or three loaders at once. Wait for all of them
    // before rendering anything so only a single top-level loader shows.
    final isLoading =
        returnableAsync.isLoading || reasonsAsync.isLoading || ordersAsync.isLoading;

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
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
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
                  '#${order?.orderNumber ?? widget.orderId}',
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
                  order?.createdAt != null
                      ? '${order!.createdAt!.year}/${order.createdAt!.month}/${order.createdAt!.day}'
                      : '—',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: context.palette.textPrimary),
                ),
                Text(orderDateLabel, style: TextStyle(fontSize: 14, color: context.palette.textMuted)),
              ],
            ),
            const SizedBox(height: 24),

            GestureDetector(
              onTap: () => ref.read(ordersProvider.notifier).toggleProductsExpanded(),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    sectionTitle,
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
              returnableAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => Text(
                  error.toString(),
                  style: TextStyle(color: context.palette.textMuted),
                ),
                data: (items) {
                  if (items.isEmpty) {
                    return Text(
                      isAr ? 'لا توجد عناصر قابلة للإرجاع' : 'No returnable items',
                      style: TextStyle(color: context.palette.textMuted),
                    );
                  }
                  return Column(
                    children: items.map((item) {
                      final isSelected = state.selectedProducts[item.itemId] ?? false;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: context.palette.backgroundSubtle,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected ? AppColors.primary : Colors.transparent,
                            width: 1.5,
                          ),
                        ),
                        child: Opacity(
                          opacity: item.eligible ? 1 : 0.5,
                          child: Row(
                            textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
                            children: [
                              Checkbox(
                                value: isSelected,
                                activeColor: AppColors.primary,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                side: BorderSide(color: context.palette.textMuted, width: 1.5),
                                onChanged: item.eligible
                                    ? (val) => ref
                                        .read(ordersProvider.notifier)
                                        .toggleProductSelection(item.itemId, val ?? false)
                                    : null,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      isAr ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.name.resolve(isAr),
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: context.palette.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'x${item.quantity}',
                                      style: TextStyle(fontSize: 13, color: context.palette.textMuted),
                                    ),
                                    if (!item.eligible && item.reason != null)
                                      Text(
                                        item.reason!,
                                        style: const TextStyle(fontSize: 12, color: Colors.redAccent),
                                      ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  item.image,
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) =>
                                      Container(width: 80, height: 80, color: context.palette.surfaceMuted),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),

            const SizedBox(height: 24),

            Align(
              alignment: isAr ? Alignment.centerRight : Alignment.centerLeft,
              child: Text(
                reasonLabel,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: context.palette.textPrimary),
              ),
            ),
            const SizedBox(height: 8),
            reasonsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Text(error.toString(), style: TextStyle(color: context.palette.textMuted)),
              data: (reasons) => DropdownButtonFormField<String>(
                initialValue: state.selectedReason,
                hint: Align(
                  alignment: isAr ? Alignment.centerRight : Alignment.centerLeft,
                  child: Text(
                    loc.translate('reasonPlaceholder'),
                    style: TextStyle(color: context.palette.textMuted),
                  ),
                ),
                icon: Icon(Icons.keyboard_arrow_down, color: context.palette.textPrimary),
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: context.palette.divider, width: 1.5),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: context.palette.textMuted, width: 1.5),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: context.palette.textPrimary, width: 1.5),
                  ),
                ),
                items: reasons.map((reason) {
                  return DropdownMenuItem<String>(
                    value: reason.code,
                    child: Align(
                      alignment: isAr ? Alignment.centerRight : Alignment.centerLeft,
                      child: Text(reason.name.resolve(isAr)),
                    ),
                  );
                }).toList(),
                onChanged: (val) => ref.read(ordersProvider.notifier).changeRefundReason(val),
              ),
            ),
            const SizedBox(height: 32),

            ElevatedButton(
              onPressed: _submitting ? null : () => _onSubmit(loc, state),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.goldAccent,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                elevation: 0,
              ),
              child: _submitting
                  ? const Center(
                      child: SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            loc.translate('confirmReturnRequest'),
                            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          Icon(isAr ? Icons.west : Icons.east, color: Colors.white, size: 20),
                        ],
                      ),
                    ),
            ),
            const SizedBox(height: 16),

            OutlinedButton(
              onPressed: () => context.pop(),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 56),
                side: BorderSide(color: context.palette.textMuted, width: 1.5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                backgroundColor: context.palette.background,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      loc.translate('cancel'),
                      style: TextStyle(color: context.palette.textPrimary, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Icon(isAr ? Icons.west : Icons.east, color: context.palette.textPrimary, size: 20),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
