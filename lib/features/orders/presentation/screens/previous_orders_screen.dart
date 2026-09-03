import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:sfa/core/localization/app_localizations.dart';
import 'package:sfa/utils/assets_constants.dart';
import 'package:sfa/utils/color_constants.dart';
import 'package:sfa/utils/currency_formatter.dart';
import 'package:sfa/utils/app_style.dart';
import 'package:sfa/features/orders/data/order_models.dart';
import 'package:sfa/features/orders/providers/orders_data_provider.dart';
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
    final ordersAsync = ref.watch(ordersDataProvider);

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

                  const SizedBox(width: 16),

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
              child: ordersAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => Center(
                  child: Text(
                    error.toString(),
                    style: AppStyle.bodyText.copyWith(color: context.palette.textMuted),
                  ),
                ),
                data: (orders) {
                  final current = orders.where((o) => o.isActive).toList();
                  final previous = orders.where((o) => !o.isActive).toList();
                  return TabBarView(
                    controller: _tabController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _buildOrdersList(loc, isAr, state.expandedCardKeys, current),
                      _buildOrdersList(loc, isAr, state.expandedCardKeys, previous),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrdersList(
    AppLocalizations loc,
    bool isAr,
    Set<String> expandedCardKeys,
    List<Order> orders,
  ) {
    if (orders.isEmpty) {
      return Center(
        child: Text(
          isAr ? 'لا توجد طلبات' : 'No orders yet',
          style: AppStyle.labelText.copyWith(color: context.palette.textMuted),
        ),
      );
    }
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      children: [
        for (final order in orders) _buildOrderCard(loc, isAr, expandedCardKeys, order),
      ],
    );
  }

  // `orderNumber` falls back to the raw Mongo order id when the API sends
  // no dedicated order-number field, which is too long for the tile without
  // wrapping/overflowing — show just enough to disambiguate visually.
  String _shortOrderNumber(String orderNumber) {
    return orderNumber.length > 4 ? orderNumber.substring(orderNumber.length - 4) : orderNumber;
  }

  Widget _buildOrderCard(
    AppLocalizations loc,
    bool isAr,
    Set<String> expandedCardKeys,
    Order order,
  ) {
    final isExpanded = expandedCardKeys.contains(order.id);
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: context.palette.backgroundSubtle,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            onTap: () => context.push('/order-tracking/${order.id}'),
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
              ),
              child: Center(
                child: SvgPicture.asset(
                  AssetsConstants.shoppingBag2,
                  width: 20,
                  colorFilter: ColorFilter.mode(AppColors.primary, BlendMode.srcIn),
                ),
              ),
            ),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  loc.translate('orderNumberPrefix'),
                  style: TextStyle(fontSize: 14, color: context.palette.textMuted),
                ),
                Text(
                  '#${_shortOrderNumber(order.orderNumber)}',
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
                    style: TextStyle(fontSize: 14, color: context.palette.textMuted),
                  ),
                  Text(
                    CurrencyFormatter.fromHalalas(order.totalFils, isAr: isAr),
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
                angle: isExpanded ? 3.14159 : 0.0,
                child: SvgPicture.asset(
                  AssetsConstants.chevronLeft,
                  width: 14,
                  colorFilter: ColorFilter.mode(context.palette.icon, BlendMode.srcIn),
                ),
              ),
              onPressed: () =>
                  ref.read(previousOrdersProvider.notifier).toggleCardExpanded(order.id),
            ),
          ),
          if (isExpanded) ...[
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Divider(height: 1),
            ),
            _buildOrderDetails(loc: loc, isAr: isAr, order: order),
          ],
        ],
      ),
    );
  }

  Widget _buildOrderDetails({
    required AppLocalizations loc,
    required bool isAr,
    required Order order,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final item in order.items)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Image.network(
                      item.image,
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          Container(width: 40, height: 40, color: context.palette.surfaceMuted),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      item.name.resolve(isAr),
                      style: AppStyle.bodyText.copyWith(fontSize: 13),
                    ),
                  ),
                  Text('x${item.quantity}', style: AppStyle.bodyText.copyWith(fontSize: 13)),
                ],
              ),
            ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  order.status,
                  style: AppStyle.navLabel.copyWith(color: AppColors.primary),
                ),
              ),
              InkWell(
                onTap: () => context.push('/refund-request/${order.id}'),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      loc.translate('requestRefund'),
                      style: AppStyle.cardSubtitle.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 6),
                    Transform.rotate(
                      angle: isAr ? 3.14159 : 0.0,
                      child: SvgPicture.asset(
                        AssetsConstants.moveLeft,
                        width: 14,
                        colorFilter: ColorFilter.mode(AppColors.primary, BlendMode.srcIn),
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
