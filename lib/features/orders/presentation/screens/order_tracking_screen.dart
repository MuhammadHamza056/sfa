import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:sfa/core/localization/app_localizations.dart';
import 'package:sfa/utils/app_style.dart';
import 'package:sfa/utils/assets_constants.dart';
import 'package:sfa/utils/color_constants.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sfa/features/orders/bloc/order_tracking_bloc.dart';
import 'package:sfa/features/orders/bloc/order_tracking_state.dart';

class OrderTrackingScreen extends StatefulWidget {
  const OrderTrackingScreen({super.key});

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final isAr = loc.isArabic;
    final textDir = isAr ? TextDirection.rtl : TextDirection.ltr;

    return BlocProvider(
      create: (context) => OrderTrackingBloc(),
      child: BlocBuilder<OrderTrackingBloc, OrderTrackingState>(
        builder: (context, state) {
          return Directionality(
            textDirection: textDir,
            child: Scaffold(
              backgroundColor: Colors.white,

              // ─── AppBar ───────────────────────────────────────────────────
              appBar: AppBar(
                backgroundColor: Colors.white,
                elevation: 0,
                scrolledUnderElevation: 0,
                automaticallyImplyLeading: false,
                leadingWidth: 100,
                leading: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          SvgPicture.asset(
                            AssetsConstants.shoppingBag,
                            width: 22,
                            colorFilter: ColorFilter.mode(
                              AppColors.textcolor,
                              BlendMode.srcIn,
                            ),
                          ),
                          Positioned(
                            right: -6,
                            top: -6,
                            child: Container(
                              padding: const EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 15,
                                minHeight: 15,
                              ),
                              child: const Center(
                                child: Text(
                                  '2',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    height: 1.0,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 16),
                      SvgPicture.asset(
                        AssetsConstants.heart2,
                        width: 22,
                        colorFilter: ColorFilter.mode(
                          AppColors.textcolor,
                          BlendMode.srcIn,
                        ),
                      ),
                    ],
                  ),
                ),
                title: Text(
                  loc.translate('orderTracking'),
                  style: AppStyle.welcomeTitle.copyWith(fontSize: 18),
                ),
                centerTitle: true,
                actions: [
                  GestureDetector(
                    onTap: () {},
                    child: SvgPicture.asset(
                      AssetsConstants.search,
                      width: 22,
                      colorFilter: ColorFilter.mode(
                        AppColors.textcolor,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  GestureDetector(
                    onTap: () {
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.go('/dashboard');
                      }
                    },
                    child: SvgPicture.asset(
                      AssetsConstants.back,
                      width: 22,
                      matchTextDirection: true,
                      colorFilter: ColorFilter.mode(
                        AppColors.textcolor,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                ],
              ),

              // ─── Body ─────────────────────────────────────────────────────
              body: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ─── Order Info Header ───
                    Align(
                      alignment: isAr
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Text(
                        loc.translate('orderInfo'),
                        style: AppStyle.sectionHeader,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Divider(color: AppColors.textcolor_40, thickness: 0.8),
                    const SizedBox(height: 24),
                    _buildInfoRow(
                      loc.translate('orderNumberLabel'),
                      '#84739201',
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow(
                      loc.translate('orderDateLabel'),
                      loc.translate('orderDateValue'),
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow(
                      loc.translate('totalAmountLabel'),
                      isAr ? '2,500 ر.س.' : '2,500 SAR',
                      valueColor: AppColors.primary,
                    ),
                    const SizedBox(height: 20),

                    // ─── Cancel Order Button ───
                    _buildCancelButton(loc, isAr),
                    const SizedBox(height: 32),

                    // ─── Order Status Header ───
                    Align(
                      alignment: isAr
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Text(
                        loc.translate('orderStatus'),
                        style: AppStyle.sectionHeader,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Divider(color: AppColors.textcolor_40, thickness: 0.8),
                    const SizedBox(height: 24),

                    // ─── Vertical Timeline (Right-aligned tracker for Arabic, Left-aligned for English) ───
                    _buildTrackerTimeline(loc, isAr),
                    const SizedBox(height: 32),

                    // ─── Confirm Delivery Button ───
                    ElevatedButton(
                      onPressed: () {
                        if (context.canPop()) {
                          context.pop();
                        } else {
                          context.go('/dashboard');
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        minimumSize: const Size(double.infinity, 54),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
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
                            colorFilter: const ColorFilter.mode(
                              Colors.white,
                              BlendMode.srcIn,
                            ),
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
                    Center(
                      child: Text(
                        loc.translate('deliveryInfo'),
                        style: AppStyle.sectionHeader,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Divider(color: AppColors.textcolor_40, thickness: 0.8),
                    const SizedBox(height: 24),

                    // ─── Expected Delivery ───
                    _buildInfoRow(
                      loc.translate('expectedDeliveryLabel'),
                      loc.translate('orderDateValue'),
                      forceValueLtr: false,
                    ),
                    const SizedBox(height: 24),

                    // ─── SMSA Express Delivery Card ───
                    _buildDeliveryCard(loc, isAr),
                    const SizedBox(height: 24),

                    // ─── Final Cancel Button ───
                    _buildCancelButton(loc, isAr),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Helper Widgets ──

  Widget _buildInfoRow(
    String label,
    String value, {
    Color? valueColor,
    bool forceValueLtr = true,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppStyle.labelText.copyWith(
            color: AppColors.textcolor.withValues(alpha: 0.6),
          ),
        ),
        forceValueLtr
            ? Directionality(
                textDirection: TextDirection.ltr,
                child: Text(
                  value,
                  style: AppStyle.valueText.copyWith(
                    color: valueColor ?? AppColors.textcolor,
                  ),
                ),
              )
            : Text(
                value,
                style: AppStyle.valueText.copyWith(
                  color: valueColor ?? AppColors.textcolor,
                ),
              ),
      ],
    );
  }

  Widget _buildCancelButton(AppLocalizations loc, bool isAr) {
    return OutlinedButton(
      onPressed: () {
        if (context.canPop()) {
          context.pop();
        } else {
          context.go('/dashboard');
        }
      },
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, 54),
        side: BorderSide(color: AppColors.textcolor_40),
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
                    colorFilter: ColorFilter.mode(
                      AppColors.textcolor,
                      BlendMode.srcIn,
                    ),
                  ),
                )
              : SvgPicture.asset(
                  AssetsConstants.moveLeft,
                  width: 18,
                  height: 18,
                  colorFilter: ColorFilter.mode(
                    AppColors.textcolor,
                    BlendMode.srcIn,
                  ),
                ),
          const SizedBox(width: 12),
        ],
      ),
    );
  }

  Widget _buildTrackerTimeline(AppLocalizations loc, bool isAr) {
    // 3 states: Processing, Shipped, Delivered
    final steps = [
      _TimelineStep(
        title: loc.translate('statusProcessing'),
        subtitle: '09:15',
        isCompleted: true,
      ),
      _TimelineStep(
        title: loc.translate('statusShipped'),
        subtitle: '12:00',
        isCompleted: true,
      ),
      _TimelineStep(
        title: loc.translate('statusDelivered'),
        subtitle: '--:--',
        isCompleted: false,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(steps.length, (index) {
        final step = steps[index];
        final isLast = index == steps.length - 1;

        // No custom RTL logic needed here — the parent Directionality(rtl)
        // already mirrors MainAxisAlignment.start to the right side in Arabic.
        // Indicator is always first → appears on right in AR, left in EN.
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

  Widget _buildTimelineIndicatorColumn(_TimelineStep step, bool isLast) {
    return Column(
      children: [
        // Indicator circle check
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            border: Border.all(
              color: step.isCompleted
                  ? const Color(0xFF5CC0A7)
                  : AppColors.primary.withValues(alpha: 0.4),
              width: 1.5,
            ),
          ),
          child: step.isCompleted
              ? const Center(
                  child: Icon(Icons.check, color: Color(0xFF5CC0A7), size: 16),
                )
              : null,
        ),
        // Timeline Connector Line
        if (!isLast)
          Container(
            width: 1.5,
            height: 50,
            color: step.isCompleted
                ? const Color(0xFF5CC0A7)
                : AppColors.primary.withValues(alpha: 0.4),
          ),
      ],
    );
  }

  Widget _buildStepText(_TimelineStep step, {bool alignRight = false}) {
    return Column(
      crossAxisAlignment: alignRight
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Text(step.title, style: AppStyle.timelineTitle),
        Text(
          step.subtitle,
          style: AppStyle.timelineSubtitle.copyWith(
            color: AppColors.textcolor.withValues(alpha: 0.5),
          ),
        ),
      ],
    );
  }

  Widget _buildDeliveryCard(AppLocalizations loc, bool isAr) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        // Circle Truck Icon — on the left
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.4),
              width: 1.2,
            ),
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

        // Agent name + company — tight to the right of the icon
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('أحمد محمد', style: AppStyle.cardTitle),
            Text(
              loc.translate('deliveryCompanyValue'),
              style: AppStyle.cardSubtitle,
            ),
          ],
        ),
      ],
    );
  }
}

class _TimelineStep {
  final String title;
  final String subtitle;
  final bool isCompleted;

  _TimelineStep({
    required this.title,
    required this.subtitle,
    required this.isCompleted,
  });
}
