import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sfa/core/localization/app_localizations.dart';
import 'package:sfa/core/widgets/primary_app_bar.dart';
import 'package:sfa/utils/Values.dart';
import 'package:sfa/utils/assets_constants.dart';
import 'package:sfa/utils/color_constants.dart';
import 'package:sfa/utils/app_style.dart';
import 'package:sfa/core/theme/app_palette.dart';
import 'package:sfa/features/notifications/providers/notifications_providers.dart';
import 'package:sfa/features/orders/providers/orders_data_provider.dart';
import '../widgets/order_stats_card.dart';
import '../widgets/promo_card.dart';
import '../widgets/notification_item_tile.dart';

String _relativeTime(DateTime? time, AppLocalizations loc) {
  if (time == null) return '';
  final diff = DateTime.now().difference(time);
  final isAr = loc.isArabic;
  if (diff.inMinutes < 60) {
    return isAr ? 'منذ ${diff.inMinutes} دقيقة' : '${diff.inMinutes}m ago';
  }
  if (diff.inHours < 24) {
    return isAr ? 'منذ ${diff.inHours} ساعة' : '${diff.inHours}h ago';
  }
  return isAr ? 'منذ ${diff.inDays} يوم' : '${diff.inDays}d ago';
}

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context);
    final statsAsync = ref.watch(orderStatisticsProvider);
    final offersAsync = ref.watch(offerNotificationsProvider);
    final notificationsAsync = ref.watch(notificationsListProvider);

    final Color statActiveBg = context.isDarkMode ? const Color(0xFF631731) : const Color(0xFFF4ECE1);
    final Color statBg = context.isDarkMode ? context.palette.surfaceAlt : const Color(0xFFF8F8F8);
    final Color promoSoftBg = context.isDarkMode ? const Color(0xFF631731) : const Color(0xFFF6F6F6);
    final Color promoStrongBg = context.isDarkMode ? Colors.white : const Color(0xFF3F1B24);
    final Color promoStrongText = context.isDarkMode ? const Color(0xFF451425) : Colors.white;

    return Scaffold(
      backgroundColor: context.palette.background,
      appBar: PrimaryAppBar(title: loc.translate('notifications')),
      body: SafeArea(
        child: Directionality(
          textDirection: loc.isArabic ? TextDirection.rtl : TextDirection.ltr,
          child: RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(orderStatisticsProvider);
              ref.invalidate(offerNotificationsProvider);
              ref.invalidate(notificationsListProvider);
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: Values.horizontalPadding, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Order Statistics Header
                  Text(
                    loc.translate('orderStatistics'),
                    style: AppStyle.welcomeTitle.copyWith(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Divider(height: 1, thickness: 0.5, color: context.palette.divider),
                  const SizedBox(height: 16),

                  statsAsync.when(
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (error, _) => Text(
                      error.toString(),
                      style: AppStyle.bodyText.copyWith(color: context.palette.textMuted),
                    ),
                    data: (stats) => GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 2.1,
                      children: [
                        OrderStatsCard(
                          iconPath: AssetsConstants.package,
                          count: '${stats.activeOrders}',
                          label: loc.translate('activeOrders'),
                          backgroundColor: statActiveBg,
                          iconColor: context.palette.textPrimary,
                        ),
                        OrderStatsCard(
                          iconPath: AssetsConstants.circleCheckBig,
                          count: '${stats.completedOrders}',
                          label: loc.translate('delivered'),
                          backgroundColor: statBg,
                          iconColor: context.palette.textPrimary,
                        ),
                        OrderStatsCard(
                          iconPath: AssetsConstants.truck,
                          count: '${stats.totalOrders}',
                          label: loc.isArabic ? 'إجمالي الطلبات' : 'Total Orders',
                          backgroundColor: statBg,
                          iconColor: context.palette.textPrimary,
                        ),
                        OrderStatsCard(
                          iconPath: AssetsConstants.rotateCcw,
                          count: '${stats.cancelledOrders}',
                          label: loc.isArabic ? 'ملغاة' : 'Cancelled',
                          backgroundColor: statBg,
                          iconColor: context.palette.textPrimary,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),

                  // 2. Offers & Discounts Header
                  Text(
                    loc.translate('offersAndDiscounts'),
                    style: AppStyle.welcomeTitle.copyWith(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Divider(height: 1, thickness: 0.5, color: context.palette.divider),
                  const SizedBox(height: 16),

                  const NationalDayHeroBanner(),
                  const SizedBox(height: 16),

                  offersAsync.when(
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (error, _) => Text(
                      error.toString(),
                      style: AppStyle.bodyText.copyWith(color: context.palette.textMuted),
                    ),
                    data: (offers) {
                      if (offers.isEmpty) return const SizedBox.shrink();
                      return SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            for (var i = 0; i < offers.length; i++) ...[
                              if (i > 0) const SizedBox(width: 16),
                              PromoCard(
                                badgeText: offers[i].badgeText ?? '',
                                titleText: offers[i].title,
                                backgroundColor: i.isEven ? promoSoftBg : promoStrongBg,
                                badgeColor: i.isEven ? AppColors.primary : const Color(0xFFC5A880),
                                titleColor: i.isEven ? context.palette.textPrimary : promoStrongText,
                                border: i.isEven ? Border.all(color: context.palette.divider, width: 1.2) : null,
                              ),
                            ],
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 28),

                  // 3. Recent Notifications Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        loc.translate('recentNotifications'),
                        style: AppStyle.welcomeTitle.copyWith(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      TextButton(
                        onPressed: () async {
                          final result = await ref.read(notificationsRepositoryProvider).markAllRead();
                          if (result.isSuccess) {
                            ref.invalidate(notificationsListProvider);
                          }
                        },
                        child: Text(
                          loc.isArabic ? 'تعليم الكل كمقروء' : 'Mark all read',
                          style: AppStyle.subtitleDesc.copyWith(fontSize: 13, color: AppColors.primary),
                        ),
                      ),
                    ],
                  ),
                  Divider(height: 1, thickness: 0.5, color: context.palette.divider),
                  const SizedBox(height: 16),

                  notificationsAsync.when(
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (error, _) => Text(
                      error.toString(),
                      style: AppStyle.bodyText.copyWith(color: context.palette.textMuted),
                    ),
                    data: (notifications) {
                      if (notifications.isEmpty) {
                        return Text(
                          loc.isArabic ? 'لا توجد إشعارات' : 'No notifications',
                          style: AppStyle.bodyText.copyWith(color: context.palette.textMuted),
                        );
                      }
                      return ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: notifications.length,
                        separatorBuilder: (_, __) =>
                            Divider(height: 1, thickness: 0.5, color: context.palette.divider),
                        itemBuilder: (context, index) {
                          final notification = notifications[index];
                          return Opacity(
                            opacity: notification.isRead ? 0.6 : 1,
                            child: NotificationItemTile(
                              iconPath: _iconFor(notification.type),
                              title: notification.title,
                              body: notification.body,
                              time: _relativeTime(notification.createdAt, loc),
                              iconColor: const Color(0xFF8C6239),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _iconFor(String? type) {
    switch (type) {
      case 'DELIVERY':
      case 'SHIPPED':
        return AssetsConstants.truck;
      case 'PRICE_DROP':
        return AssetsConstants.frame;
      case 'COLLECTION':
        return AssetsConstants.frame2;
      default:
        return AssetsConstants.package;
    }
  }
}
