import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/notifications/providers/notifications_providers.dart';
import '../../features/orders/providers/orders_data_provider.dart';
import '../localization/app_localizations.dart';
import '../network/realtime_events.dart';
import '../providers/realtime_providers.dart';
import '../theme/app_palette.dart';

/// Wraps the whole app (from `MyApp`'s router builder) so socket events are
/// handled once, wherever the user happens to be.
///
/// Two jobs, both of which every screen would otherwise have to repeat:
/// - refresh the providers an event invalidates, so an open orders list or
///   tracking page re-renders with the new status instead of showing stale
///   data until the user pulls to refresh;
/// - surface the event as a snackbar, since a foreground push is not shown
///   by the OS.
///
/// The notification *list* isn't refreshed here — `NotificationsNotifier`
/// merges pushed notifications into its own state (see
/// [notificationsListProvider]); this widget only shows the banner.
class RealtimeListener extends ConsumerWidget {
  final Widget child;

  const RealtimeListener({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(orderStatusUpdatesProvider, (_, next) {
      final update = next.valueOrNull;
      if (update == null) return;
      _refreshOrder(ref, update);
      _showBanner(context, _orderMessage(context, update));
    });

    ref.listen(realtimeNotificationProvider, (_, next) {
      final notification = next.valueOrNull;
      if (notification == null) return;
      final title = notification.title.trim();
      final body = notification.body.trim();
      _showBanner(context, [title, body].where((t) => t.isNotEmpty).join('\n'));
    });

    return child;
  }

  /// Drops every cached view of the order the event names, plus the lists
  /// that summarize it. Each one is `autoDispose`, so this is a no-op
  /// unless a screen is actually showing that data.
  void _refreshOrder(WidgetRef ref, RealtimeOrderUpdate update) {
    if (update.orderId.isNotEmpty) {
      ref.invalidate(orderDetailProvider(update.orderId));
      ref.invalidate(orderTrackingDataProvider(update.orderId));
    }
    ref.invalidate(ordersDataProvider);
    ref.invalidate(orderStatisticsProvider);
  }

  String _orderMessage(BuildContext context, RealtimeOrderUpdate update) {
    final loc = AppLocalizations.of(context);
    final status = loc.translate(_statusKey(update.status));
    final reference = update.orderNumber.isNotEmpty
        ? update.orderNumber
        : update.orderId;
    return loc.translate(
      'orderStatusUpdatedToast',
      params: {'order': reference, 'status': status},
    );
  }

  /// Maps the gateway's snake_case status onto an .arb key, falling back to
  /// the raw status so an unknown stage still reads as something.
  static String _statusKey(String status) {
    const keys = {
      'pending': 'orderStatusPending',
      'confirmed': 'orderStatusConfirmed',
      'processing': 'orderStatusPreparing',
      'preparing': 'orderStatusPreparing',
      'ready': 'orderStatusReady',
      'shipped': 'statusShipped',
      'out_for_delivery': 'orderStatusOutForDelivery',
      'delivered': 'statusDelivered',
      'cancelled': 'orderCancelledBadge',
      'canceled': 'orderCancelledBadge',
    };
    return keys[status.toLowerCase()] ?? status;
  }

  void _showBanner(BuildContext context, String message) {
    if (message.isEmpty) return;
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: TextStyle(color: context.palette.textPrimary),
          ),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 4),
          backgroundColor: context.palette.surfaceAlt,
        ),
      );
  }
}
