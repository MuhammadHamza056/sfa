import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:sfa/core/localization/app_localizations.dart';
import 'package:sfa/utils/assets_constants.dart';
import 'package:sfa/utils/color_constants.dart';
import 'package:sfa/utils/app_style.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sfa/features/orders/bloc/orders_bloc.dart';
import 'package:sfa/features/orders/bloc/orders_event.dart';
import 'package:sfa/features/orders/bloc/orders_state.dart';
import 'package:sfa/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:sfa/core/theme/app_palette.dart';

class PreviousOrdersScreen extends StatefulWidget {
  const PreviousOrdersScreen({super.key});

  @override
  State<PreviousOrdersScreen> createState() => _PreviousOrdersScreenState();
}

class _PreviousOrdersScreenState extends State<PreviousOrdersScreen>
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

    return BlocListener<OrdersBloc, OrdersState>(
      listenWhen: (previous, current) => previous.selectedTab != current.selectedTab,
      listener: (context, state) {
        _tabController.animateTo(state.selectedTab);
      },
      child: BlocBuilder<OrdersBloc, OrdersState>(
        builder: (context, state) {
          final selectedTab = state.selectedTab;
          return Directionality(
            textDirection: textDir,
            child: Scaffold(
              backgroundColor: context.palette.background,

              // ─── Top App Bar ──────────────────────────────────────────────
              appBar: AppBar(
                backgroundColor: context.palette.background,
                elevation: 0,
                scrolledUnderElevation: 0,
                automaticallyImplyLeading: false,
                leadingWidth: 108,
                leading: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onTap: () => context.go('/dashboard?tab=5'),
                        child: SvgPicture.asset(
                          AssetsConstants.shoppingBag2,
                          width: 22,
                          colorFilter: ColorFilter.mode(
                            context.palette.textPrimary,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      GestureDetector(
                        onTap: () => context.go('/dashboard?tab=8'),
                        child: SvgPicture.asset(
                          AssetsConstants.heart,
                          width: 22,
                          colorFilter: ColorFilter.mode(
                            context.palette.textPrimary,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                title: Text(
                  loc.isArabic ? 'الطلبات' : 'Orders',
                  style: AppStyle.welcomeTitle.copyWith(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: context.palette.textPrimary,
                  ),
                ),
                centerTitle: true,
                actions: [
                  GestureDetector(
                    onTap: () {},
                    child: SvgPicture.asset(
                      AssetsConstants.search,
                      width: 22,
                      colorFilter: ColorFilter.mode(
                        context.palette.textPrimary,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  GestureDetector(
                    onTap: () {
                      showGeneralDialog(
                        context: context,
                        barrierDismissible: true,
                        barrierLabel: '',
                        barrierColor: Colors.black.withOpacity(0.45),
                        transitionDuration: const Duration(milliseconds: 280),
                        pageBuilder: (context, anim1, anim2) {
                          return AppDrawer(
                            isAr: isAr,
                            loc: loc,
                            onClose: () => Navigator.of(context).pop(),
                          );
                        },
                        transitionBuilder: (context, anim1, anim2, child) {
                          final beginOffset = isAr
                              ? const Offset(1.0, 0.0)
                              : const Offset(-1.0, 0.0);
                          return SlideTransition(
                            position: anim1.drive(
                              Tween<Offset>(
                                begin: beginOffset,
                                end: Offset.zero,
                              ).chain(CurveTween(curve: Curves.easeOutCubic)),
                            ),
                            child: child,
                          );
                        },
                      );
                    },
                    child: SvgPicture.asset(
                      AssetsConstants.menu,
                      width: 22,
                      matchTextDirection: true,
                      colorFilter: ColorFilter.mode(
                        context.palette.textPrimary,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                ],
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
                            onTap: () {
                              context.read<OrdersBloc>().add(const ChangeOrdersTabEvent(0));
                            },
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
                                      : context.palette.textPrimary.withValues(alpha: 0.6),
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
                            onTap: () {
                              context.read<OrdersBloc>().add(const ChangeOrdersTabEvent(1));
                            },
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
                                      : context.palette.textPrimary.withValues(alpha: 0.6),
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
                        _buildCurrentOrdersList(loc, isAr, state),

                        // Previous orders placeholder/list
                        _buildPreviousOrdersList(loc, isAr, state),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCurrentOrdersList(AppLocalizations loc, bool isAr, OrdersState state) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      children: [
        // ─── Card 1 (Collapsed state) ───
        Container(
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
                      style: TextStyle(fontSize: 14, color: context.palette.textMuted),
                    ),
                    Text(
                      '#123456889',
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
                        isAr ? '2,500 ر.س.' : '2,500 SAR',
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
                    angle: state.isFirstCardExpanded ? 3.14159 : 0.0,
                    child: SvgPicture.asset(
                      AssetsConstants.chevronLeft,
                      width: 14,
                      colorFilter: ColorFilter.mode(
                        context.palette.textPrimary,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                  onPressed: () {
                    context.read<OrdersBloc>().add(const ToggleFirstCardExpandedEvent());
                  },
                ),
              ),
              if (state.isFirstCardExpanded) ...[
                const Divider(height: 1),
                _buildTrackingDetailsSection(
                  loc: loc,
                  isAr: isAr,
                  isDelivered: false,
                  deliveredTime: '--:--',
                  orderId: '123456889',
                  statusBadge: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE6F7F4),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      loc.translate('orderPlacedSuccess'),
                      style: AppStyle.navLabel.copyWith(
                        color: AppColors.greenAccent,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),

        // ─── Card 2 (Expanded state showing tracking steps as in the design) ───
        Container(
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
                      style: TextStyle(fontSize: 14, color: context.palette.textMuted),
                    ),
                    Text(
                      '#234558',
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
                        isAr ? '1,300 ر.س.' : '1,300 SAR',
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
                    angle: state.isSecondCardExpanded ? 3.14159 : 0.0,
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
                    context.read<OrdersBloc>().add(const ToggleSecondCardExpandedEvent());
                  },
                ),
              ),
              if (state.isSecondCardExpanded) ...[
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Divider(height: 1),
                ),
                _buildTrackingDetailsSection(
                  loc: loc,
                  isAr: isAr,
                  isDelivered: false,
                  deliveredTime: '--:--',
                  orderId: '234558',
                  statusBadge: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE6F7F4),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      loc.translate('orderPlacedSuccess'),
                      style: AppStyle.navLabel.copyWith(
                        color: AppColors.greenAccent,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
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

  Widget _buildPreviousOrdersList(AppLocalizations loc, bool isAr, OrdersState state) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      children: [
        // ─── Card 1 (Collapsed state) ───
        Container(
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
                      style: TextStyle(fontSize: 14, color: context.palette.textMuted),
                    ),
                    Text(
                      '#123456889',
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
                        isAr ? '2,500 ر.س.' : '2,500 SAR',
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
                    angle: state.isPrevFirstCardExpanded ? 3.14159 : 0.0,
                    child: SvgPicture.asset(
                      AssetsConstants.chevronLeft,
                      width: 14,
                      colorFilter: ColorFilter.mode(
                        context.palette.textPrimary,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                  onPressed: () {
                    context.read<OrdersBloc>().add(const TogglePrevFirstCardExpandedEvent());
                  },
                ),
              ),
              if (state.isPrevFirstCardExpanded) ...[
                const Divider(height: 1),
                _buildTrackingDetailsSection(
                  loc: loc,
                  isAr: isAr,
                  isDelivered: true,
                  deliveredTime: '02/08/26 12:45',
                  orderId: '84739201',
                  statusBadge: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      loc.translate('deliveredSuccess'),
                      style: AppStyle.navLabel.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),

        // ─── Card 2 (Expanded state showing tracking steps as in the design) ───
        Container(
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
                      style: TextStyle(fontSize: 14, color: context.palette.textMuted),
                    ),
                    Text(
                      '#234558',
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
                        isAr ? '1,300 ر.س.' : '1,300 SAR',
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
                    angle: state.isPrevSecondCardExpanded ? 3.14159 : 0.0,
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
                    context.read<OrdersBloc>().add(const TogglePrevSecondCardExpandedEvent());
                  },
                ),
              ),
              if (state.isPrevSecondCardExpanded) ...[
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Divider(height: 1),
                ),
                _buildTrackingDetailsSection(
                  loc: loc,
                  isAr: isAr,
                  isDelivered: true,
                  deliveredTime: '02/08/26 12:45',
                  orderId: '84739201',
                  statusBadge: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      loc.translate('deliveredSuccess'),
                      style: AppStyle.navLabel.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
