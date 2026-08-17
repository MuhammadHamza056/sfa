import 'package:flutter/material.dart';
import 'package:sfa/core/localization/app_localizations.dart';
import 'package:sfa/utils/assets_constants.dart';
import 'package:sfa/utils/color_constants.dart';
import 'package:sfa/utils/app_style.dart';
import '../widgets/order_stats_card.dart';
import '../widgets/promo_card.dart';
import '../widgets/notification_item_tile.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Directionality(
          textDirection: loc.isArabic ? TextDirection.rtl : TextDirection.ltr,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Order Statistics Header
                Text(
                  loc.translate('orderStatistics'),
                  style: AppStyle.welcomeTitle.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Divider(
                  height: 1,
                  thickness: 0.5,
                  color: AppColors.textcolor_40,
                ),
                const SizedBox(height: 16),

                // Order Statistics Grid
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 2.1,
                  children: [
                    OrderStatsCard(
                      iconPath: AssetsConstants.package,
                      count: '3',
                      label: loc.translate('activeOrders'),
                      backgroundColor: const Color(0xFFF4ECE1),
                      iconColor: const Color(0xFF3F1B24),
                    ),
                    OrderStatsCard(
                      iconPath: AssetsConstants.circleCheckBig,
                      count: '12',
                      label: loc.translate('delivered'),
                      backgroundColor: const Color(0xFFF8F8F8),
                      iconColor: const Color(0xFF3F1B24),
                    ),
                    OrderStatsCard(
                      iconPath: AssetsConstants.truck,
                      count: '2',
                      label: loc.translate('inShipping'),
                      backgroundColor: const Color(0xFFF8F8F8),
                      iconColor: const Color(0xFF3F1B24),
                    ),
                    OrderStatsCard(
                      iconPath: AssetsConstants.rotateCcw,
                      count: '1',
                      label: loc.translate('returned'),
                      backgroundColor: const Color(0xFFF8F8F8),
                      iconColor: const Color(0xFF3F1B24),
                    ),
                  ],
                ),
                const SizedBox(height: 28),

                // 2. Offers & Discounts Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      loc.translate('offersAndDiscounts'),
                      style: AppStyle.welcomeTitle.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {},
                      child: Row(
                        children: [
                          Text(
                            loc.translate('viewAll'),
                            style: AppStyle.subtitleDesc.copyWith(
                              fontSize: 13,
                              color: AppColors.textcolor_40,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Directionality(
                            textDirection: TextDirection.ltr,
                            child: Icon(
                              loc.isArabic
                                  ? Icons.arrow_back_ios_new
                                  : Icons.arrow_forward_ios,
                              size: 12,
                              color: AppColors.textcolor_40,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Divider(
                  height: 1,
                  thickness: 0.5,
                  color: AppColors.textcolor_40,
                ),
                const SizedBox(height: 16),

                // Large Hero Banner
                const NationalDayHeroBanner(),
                const SizedBox(height: 16),

                // Horizontal scroll promo cards
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      PromoCard(
                        badgeText: loc.isArabic ? 'عرض خاص' : 'SPECIAL OFFER',
                        titleText: loc.isArabic
                            ? 'اشتري ٢ واحصلي على ١ مجاناً'
                            : 'Buy 2 Get 1 Free',
                        backgroundColor: AppColors.grey,
                        badgeColor: AppColors.primary,
                        titleColor: AppColors.textcolor,
                        border: Border.all(
                          color: Colors.grey.shade200,
                          width: 1.2,
                        ),
                      ),
                      const SizedBox(width: 16),
                      PromoCard(
                        badgeText: loc.isArabic ? 'خصم ٦٠٪' : '60% OFF',
                        titleText: loc.isArabic
                            ? 'تخفيضات نهاية الموسم'
                            : 'End of Season Sale',
                        backgroundColor: const Color(0xFF3F1B24),
                        badgeColor: const Color(0xFFC5A880),
                        titleColor: Colors.white,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // 3. Recent Notifications Header
                Text(
                  loc.translate('recentNotifications'),
                  style: AppStyle.welcomeTitle.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Divider(
                  height: 1,
                  thickness: 0.5,
                  color: AppColors.textcolor_40,
                ),
                const SizedBox(height: 16),

                // Notifications List
                ListView(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    NotificationItemTile(
                      iconPath: AssetsConstants.package,
                      title: loc.isArabic
                          ? 'تم شحن طلبك #1234'
                          : 'Your order #1234 has been shipped',
                      body: loc.isArabic
                          ? 'طلبك الآن في طريقه إليك، توقعي وصوله خلال يومين عمل.'
                          : 'Your order is on its way to you, expect delivery within two working days.',
                      time: loc.isArabic ? 'منذ ساعتين' : '2 hours ago',
                      iconColor: const Color(0xFF8C6239),
                    ),
                    Divider(
                      height: 1,
                      thickness: 0.5,
                      color: AppColors.textcolor_40,
                    ),
                    NotificationItemTile(
                      iconPath: AssetsConstants.truck,
                      title: loc.isArabic
                          ? 'تم توصيل طلبك بنجاح'
                          : 'Your order was successfully delivered',
                      body: loc.isArabic
                          ? 'طلبك #1230 تم تسليمه. نأمل أن تنال المنتجات إعجابك!'
                          : 'Your order #1230 has been delivered. We hope you love the products!',
                      time: loc.isArabic ? 'أمس' : 'Yesterday',
                      iconColor: const Color(0xFF8C6239),
                    ),
                    Divider(
                      height: 1,
                      thickness: 0.5,
                      color: AppColors.textcolor_40,
                    ),
                    NotificationItemTile(
                      iconPath: AssetsConstants.frame,
                      title: loc.isArabic
                          ? 'انخفاض في السعر!'
                          : 'Price drop alert!',
                      body: loc.isArabic
                          ? 'منتج من قائمة أمنياتك متوفر الآن بسعر أقل، لا تفوتي الفرصة!'
                          : 'An item from your wishlist is now available at a lower price, do not miss out!',
                      time: loc.isArabic ? 'منذ ٣ أيام' : '3 days ago',
                      iconColor: const Color(0xFF8C6239),
                    ),
                    Divider(
                      height: 1,
                      thickness: 0.5,
                      color: AppColors.textcolor_40,
                    ),
                    NotificationItemTile(
                      iconPath: AssetsConstants.frame2,
                      title: loc.isArabic
                          ? 'مجموعة الخريف متاحة الآن'
                          : 'Autumn collection available now',
                      body: loc.isArabic
                          ? 'اكتشفي أرقى التصاميم الجديدة لخريف ٢٠٢٥ حصرياً في تطبيقنا.'
                          : 'Discover the most premium new designs for Autumn 2025 exclusively in our app.',
                      time: loc.isArabic ? 'منذ ٥ أيام' : '5 days ago',
                      iconColor: const Color(0xFF8C6239),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
