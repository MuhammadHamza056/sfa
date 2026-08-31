import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:sfa/core/localization/app_localizations.dart';
import 'package:sfa/utils/assets_constants.dart';
import 'package:sfa/utils/color_constants.dart';
import 'package:sfa/utils/app_style.dart';
import 'package:sfa/features/orders/providers/previous_orders_provider.dart';
import 'package:sfa/core/theme/app_palette.dart';
import 'package:sfa/core/widgets/primary_app_bar.dart';

class PreviousOrdersScreen extends ConsumerStatefulWidget {
  const PreviousOrdersScreen({super.key});

  @override
  ConsumerState<PreviousOrdersScreen> createState() =>
      _PreviousOrdersScreenState();
}

class _PreviousOrdersScreenState extends ConsumerState<PreviousOrdersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this, initialIndex: 0);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final isAr = loc.isArabic;
    final textDir = isAr ? TextDirection.rtl : TextDirection.ltr;

    ref.listen<PreviousOrdersState>(previousOrdersProvider, (previous, next) {
      if (previous?.selectedTab != next.selectedTab) {
        _tabController.animateTo(next.selectedTab);
      }
    });
    final state = ref.watch(previousOrdersProvider);
    final selectedTab = state.selectedTab;

    return Directionality(
      textDirection: textDir,
      child: Scaffold(
        backgroundColor: context.palette.background,

        // ─── Top App Bar ──────────────────────────────────────────────
        appBar: PrimaryAppBar(
          title: loc.isArabic ? 'الطلبات' : 'Orders',
          fontSize: 22,
          letterSpacing: 0,
          onCartTap: () => context.go('/cart'),
          onHeartTap: () => context.go('/favorites'),
        ),

        // ─── Body ─────────────────────────────────────────────────────
        body: Column(
          children: [
            const SizedBox(height: 16),

            // Tab Custom Switch (matching the design image with separate containers)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  // Current Orders Tab Container
                  Expanded(
                    child: GestureDetector(
                      onTap: () => ref
                          .read(previousOrdersProvider.notifier)
                          .changeTab(0),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        height: 48,
                        decoration: BoxDecoration(
                          color: selectedTab == 0
                              ? AppColors.goldAccent
                              : context.palette.surfaceMuted,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          loc.translate('currentOrders'),
                          style: TextStyle(
                            color: selectedTab == 0
                                ? Colors.white
                                : context.palette.textPrimary.withValues(
                                    alpha: 0.6,
                                  ),
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(
                    width: 16,
                  ), // Spacing between separate container tabs
                  // Previous Orders Tab Container
                  Expanded(
                    child: GestureDetector(
                      onTap: () => ref
                          .read(previousOrdersProvider.notifier)
                          .changeTab(1),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        height: 48,
                        decoration: BoxDecoration(
                          color: selectedTab == 1
                              ? AppColors.goldAccent
                              : context.palette.surfaceMuted,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          loc.translate('previousTab'),
                          style: TextStyle(
                            color: selectedTab == 1
                                ? Colors.white
                                : context.palette.textPrimary.withValues(
                                    alpha: 0.6,
                                  ),
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Tabs Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  // Current Orders page content matching the design mockup image
                  _buildOrdersList(
                    loc,
                    isAr,
                    state.expandedCardKeys,
                    _currentOrders,
                    _BadgeStyle(
                      backgroundColor: const Color(0xFFE6F7F4),
                      textColor: AppColors.greenAccent,
                      labelKey: 'orderPlacedSuccess',
                    ),
                  ),

                  // Previous orders list
                  _buildOrdersList(
                    loc,
                    isAr,
                    state.expandedCardKeys,
                    _previousOrders,
                    _BadgeStyle(
                      backgroundColor: AppColors.primary.withValues(
                        alpha: 0.08,
                      ),
                      textColor: AppColors.primary,
                      labelKey: 'deliveredSuccess',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static const List<_OrderCardData> _currentOrders = [
    _OrderCardData(
      cardKey: 'current_1',
      orderNumber: '#123456889',
      amountAr: '2,500 ر.س.',
      amountEn: '2,500 SAR',
      orderId: '123456889',
      isDelivered: false,
      deliveredTime: '--:--',
    ),
    _OrderCardData(
      cardKey: 'current_2',
      orderNumber: '#234558',
      amountAr: '1,300 ر.س.',
      amountEn: '1,300 SAR',
      orderId: '234558',
      isDelivered: false,
      deliveredTime: '--:--',
    ),
  ];

  static const List<_OrderCardData> _previousOrders = [
    _OrderCardData(
      cardKey: 'prev_1',
      orderNumber: '#123456889',
      amountAr: '2,500 ر.س.',
      amountEn: '2,500 SAR',
      orderId: '84739201',
      isDelivered: true,
      deliveredTime: '02/08/26 12:45',
    ),
    _OrderCardData(
      cardKey: 'prev_2',
      orderNumber: '#234558',
      amountAr: '1,300 ر.س.',
      amountEn: '1,300 SAR',
      orderId: '84739201',
      isDelivered: true,
      deliveredTime: '02/08/26 12:45',
    ),
  ];

  Widget _buildOrdersList(
    AppLocalizations loc,
    bool isAr,
    Set<String> expandedCardKeys,
    List<_OrderCardData> orders,
    _BadgeStyle badgeStyle,
  ) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      children: [
        for (final order in orders)
          _buildOrderCard(loc, isAr, expandedCardKeys, order, badgeStyle),
      ],
    );
  }

  Widget _buildOrderCard(
    AppLocalizations loc,
    bool isAr,
    Set<String> expandedCardKeys,
    _OrderCardData order,
    _BadgeStyle badgeStyle,
  ) {
    final isExpanded = expandedCardKeys.contains(order.cardKey);
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: context.palette.backgroundSubtle,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            onTap: () => context.push('/order-tracking'),
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.3),
                ),
              ),
              child: Center(
                child: SvgPicture.asset(
                  AssetsConstants.shoppingBag2,
                  width: 20,
                  colorFilter: ColorFilter.mode(
                    AppColors.primary,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  loc.translate('orderNumberPrefix'),
                  style: TextStyle(
                    fontSize: 14,
                    color: context.palette.textMuted,
                  ),
                ),
                Text(
                  order.orderNumber,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: context.palette.textPrimary,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ],
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    loc.translate('totalAmountPrefix'),
                    style: TextStyle(
                      fontSize: 14,
                      color: context.palette.textMuted,
                    ),
                  ),
                  Text(
                    isAr ? order.amountAr : order.amountEn,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            trailing: IconButton(
              icon: Transform.rotate(
                // Points DOWN (angle = 0.0) when closed (collapsed), points UP (angle = 3.14159) when open (expanded)
                angle: isExpanded ? 3.14159 : 0.0,
                child: SvgPicture.asset(
                  AssetsConstants.chevronLeft,
                  width: 14,
                  colorFilter: ColorFilter.mode(
                    context.palette.icon,
                    BlendMode.srcIn,
                  ),
                ),
              ),
              onPressed: () {
                ref
                    .read(previousOrdersProvider.notifier)
                    .toggleCardExpanded(order.cardKey);
              },
            ),
          ),
          if (isExpanded) ...[
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Divider(height: 1),
            ),
            _buildTrackingDetailsSection(
              loc: loc,
              isAr: isAr,
              isDelivered: order.isDelivered,
              deliveredTime: order.deliveredTime,
              orderId: order.orderId,
              statusBadge: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: badgeStyle.backgroundColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  loc.translate(badgeStyle.labelKey),
                  style: AppStyle.navLabel.copyWith(
                    color: badgeStyle.textColor,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTrackingDetailsSection({
    required AppLocalizations loc,
    required bool isAr,
    required bool isDelivered,
    required String deliveredTime,
    required Widget statusBadge,
    required String orderId,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Row with status info columns
          Row(
            children: [
              // Left/Right: "تم الشحن"
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.greenAccent),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.check,
                          size: 14,
                          color: AppColors.greenAccent,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            loc.translate('shippedSuccess'),
                            style: AppStyle.timelineSubtitle.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '02/08/26 12:00',
                            style: AppStyle.infoChipText.copyWith(
                              color: context.palette.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Vertical line connector separating the two milestones
              Container(width: 1, height: 32, color: context.palette.divider),
              const SizedBox(width: 16),

              // Left/Right: "تم التوصيل"
              Expanded(
                child: Row(
                  children: [
                    isDelivered
                        ? Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.greenAccent),
                            ),
                            child: Center(
                              child: Icon(
                                Icons.check,
                                size: 14,
                                color: AppColors.greenAccent,
                              ),
                            ),
                          )
                        : Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.primary.withValues(alpha: 0.6),
                              ),
                            ),
                          ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            loc.translate('deliveredSuccess'),
                            style: AppStyle.timelineSubtitle.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            deliveredTime,
                            style: AppStyle.infoChipText.copyWith(
                              color: context.palette.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 12),

          // Bottom Action: Refund request / status badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              statusBadge,

              // Refund Request Text Button with directional Arrow
              InkWell(
                onTap: () => context.push('/refund-request/$orderId'),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      loc.translate('requestRefund'),
                      style: AppStyle.cardSubtitle.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 6),
                    // Arrow points right (0.0) in English (LTR) and left (3.14159) in Arabic (RTL)
                    Transform.rotate(
                      angle: isAr ? 3.14159 : 0.0,
                      child: SvgPicture.asset(
                        AssetsConstants.moveLeft,
                        width: 14,
                        colorFilter: ColorFilter.mode(
                          AppColors.primary,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _OrderCardData {
  final String cardKey;
  final String orderNumber;
  final String amountAr;
  final String amountEn;
  final String orderId;
  final bool isDelivered;
  final String deliveredTime;

  const _OrderCardData({
    required this.cardKey,
    required this.orderNumber,
    required this.amountAr,
    required this.amountEn,
    required this.orderId,
    required this.isDelivered,
    required this.deliveredTime,
  });
}

class _BadgeStyle {
  final Color backgroundColor;
  final Color textColor;
  final String labelKey;

  const _BadgeStyle({
    required this.backgroundColor,
    required this.textColor,
    required this.labelKey,
  });
}
