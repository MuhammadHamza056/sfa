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
import 'package:sfa/core/theme/app_palette.dart';

class RefundStatusScreen extends StatefulWidget {
  final String orderId;

  const RefundStatusScreen({super.key, required this.orderId});

  @override
  State<RefundStatusScreen> createState() => _RefundStatusScreenState();
}

class _RefundStatusScreenState extends State<RefundStatusScreen> {
  final List<Map<String, dynamic>> _returnedProducts = [
    {
      'brand': 'جوبا',
      'brandEn': 'Juba',
      'title': 'وردة الصحراء المطرزة',
      'titleEn': 'Embroidered Desert Rose',
      'price': 1250,
      'size': 'M',
      'colorName': 'اللون',
      'colorNameEn': 'Color',
      'color': const Color(0xFFD6B5A7),
      'imageUrl':
          'https://images.unsplash.com/photo-1509631179647-0177331693ae?w=400&q=80',
    },
    {
      'brand': 'جوبا',
      'brandEn': 'Juba',
      'title': 'وردة الصحراء المطرزة',
      'titleEn': 'Embroidered Desert Rose',
      'price': 1250,
      'size': 'M',
      'colorName': 'اللون',
      'colorNameEn': 'Color',
      'color': const Color(0xFFD6B5A7),
      'imageUrl':
          'https://images.unsplash.com/photo-1529139574466-a303027c1d8b?w=400&q=80',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final isAr = loc.isArabic;
    final textDir = isAr ? TextDirection.rtl : TextDirection.ltr;

    // Localized values
    final titleText =
        '${loc.translate('refundRequestTitle')} #${widget.orderId}';
    final orderNumLabel = loc.translate('orderNumberLabel');
    final orderDateLabel = loc.translate('orderDateLabel');
    final orderDateValue = loc.translate('orderDateValue');
    final trackRefundStatusLabel = loc.translate('trackRefundStatus');
    final returnedProductsLabel = loc.translate('returnedProducts');
    final returnedProductsCountLabel = loc.translate('returnedProductsCount');
    final sizeLabel = loc.translate('sizeLabel');

    // Stepper Milestones
    final milestones = [
      {'title': loc.translate('statusRefundProcessing'), 'time': '09:15'},
      {'title': loc.translate('statusProductsReceived'), 'time': '12:00'},
      {'title': loc.translate('statusRefundSuccessful'), 'time': '12:30'},
    ];

    return BlocBuilder<OrdersBloc, OrdersState>(
      builder: (context, state) {
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
                'SFA',
                style: AppStyle.welcomeTitle.copyWith(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: context.palette.textPrimary,
                  letterSpacing: 2,
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
                  onTap: () => context.pop(),
                  child: SvgPicture.asset(
                    AssetsConstants.back,
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
            body: ListView(
              padding: const EdgeInsets.all(24.0),
              children: [
                // Title: "طلب إرجاع #84739201"
                Text(
                  titleText,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: context.palette.textPrimary,
                  ),
                  textAlign: isAr ? TextAlign.right : TextAlign.left,
                ),
                const SizedBox(height: 8),
                Divider(thickness: 1, color: context.palette.divider),
                const SizedBox(height: 12),

                // Order Info Grid (Order Number & Date)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '#${widget.orderId}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: context.palette.textPrimary,
                      ),
                    ),
                    Text(
                      orderNumLabel,
                      style: TextStyle(
                        fontSize: 14,
                        color: context.palette.textMuted,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      orderDateValue,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: context.palette.textPrimary,
                      ),
                    ),
                    Text(
                      orderDateLabel,
                      style: TextStyle(
                        fontSize: 14,
                        color: context.palette.textMuted,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Track Refund Status block
                Align(
                  alignment: isAr ? Alignment.centerRight : Alignment.centerLeft,
                  child: Text(
                    trackRefundStatusLabel,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: context.palette.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Standard Vertical Stepper
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: context.palette.backgroundSubtle,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Builder(builder: (context) {
                    final isAr = loc.isArabic;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Step 1: Refund Processing
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              children: [
                                Container(
                                  width: 14,
                                  height: 14,
                                  decoration: const BoxDecoration(
                                    color: Colors.green,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                Container(
                                  width: 2,
                                  height: 48,
                                  color: Colors.green,
                                ),
                              ],
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    milestones[0]['title']!,
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: context.palette.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    milestones[0]['time']!,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: context.palette.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        // Step 2: Products Received
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              children: [
                                Container(
                                  width: 14,
                                  height: 14,
                                  decoration: const BoxDecoration(
                                    color: Colors.green,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                Container(
                                  width: 2,
                                  height: 48,
                                  color: context.palette.textMuted,
                                ),
                              ],
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    milestones[1]['title']!,
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: context.palette.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    milestones[1]['time']!,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: context.palette.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        // Step 3: Refund Successful
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              children: [
                                Container(
                                  width: 14,
                                  height: 14,
                                  decoration: BoxDecoration(
                                    color: context.palette.textMuted,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    milestones[2]['title']!,
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: context.palette.textMuted,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    milestones[2]['time']!,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: context.palette.textMuted,
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  }),
                ),
                const SizedBox(height: 16),

                // Returned Products Section Title
                GestureDetector(
                  onTap: () {
                    context.read<OrdersBloc>().add(const ToggleProductsExpandedEvent());
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        returnedProductsLabel,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: context.palette.textPrimary,
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: isAr
                            ? [
                                Text(
                                  returnedProductsCountLabel,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: context.palette.textMuted,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Icon(
                                  state.isProductsExpanded
                                      ? Icons.keyboard_arrow_up
                                      : Icons.keyboard_arrow_down,
                                  color: context.palette.textPrimary,
                                ),
                              ]
                            : [
                                Text(
                                  returnedProductsCountLabel,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: context.palette.textMuted,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Icon(
                                  state.isProductsExpanded
                                      ? Icons.keyboard_arrow_up
                                      : Icons.keyboard_arrow_down,
                                  color: context.palette.textPrimary,
                                ),
                              ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                if (state.isProductsExpanded) ...[
                  // Products List (NO Checkboxes)
                  ..._returnedProducts.map((product) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: context.palette.divider, width: 1),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Product Image: rendered on left for LTR, right for RTL
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              product['imageUrl'] as String,
                              width: 110,
                              height: 110,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isAr
                                      ? product['brand'] as String
                                      : product['brandEn'] as String,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  isAr
                                      ? product['title'] as String
                                      : product['titleEn'] as String,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: context.palette.textPrimary,
                                  ),
                                  textAlign:
                                      isAr ? TextAlign.right : TextAlign.left,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  isAr
                                      ? '${product['price']} ر.س.'
                                      : '${product['price']} SAR',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.goldAccent,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: isAr
                                      ? MainAxisAlignment.end
                                      : MainAxisAlignment.start,
                                  children: isAr
                                      ? [
                                          Text(
                                            product['colorName'] as String,
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: context.palette.textMuted,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Container(
                                            width: 24,
                                            height: 24,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: product['color'] as Color,
                                              border: Border.all(
                                                color: context.palette.divider,
                                                width: 1,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          Text(
                                            sizeLabel,
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: context.palette.textMuted,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: context.palette.surfaceMuted,
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              product['size'] as String,
                                              style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.bold,
                                                color: context.palette.textPrimary,
                                              ),
                                            ),
                                          ),
                                        ]
                                      : [
                                          Container(
                                            width: 24,
                                            height: 24,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: product['color'] as Color,
                                              border: Border.all(
                                                color: context.palette.divider,
                                                width: 1,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            product['colorNameEn'] as String,
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: context.palette.textMuted,
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          Text(
                                            sizeLabel,
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: context.palette.textMuted,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: context.palette.surfaceMuted,
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              product['size'] as String,
                                              style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.bold,
                                                color: context.palette.textPrimary,
                                              ),
                                            ),
                                          ),
                                        ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ],
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }
}
