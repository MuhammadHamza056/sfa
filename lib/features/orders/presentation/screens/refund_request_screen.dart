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
import 'package:sfa/utils/loader.dart';
import 'package:sfa/core/theme/app_palette.dart';

class RefundRequestScreen extends StatefulWidget {
  final String orderId;

  const RefundRequestScreen({
    super.key,
    required this.orderId,
  });

  @override
  State<RefundRequestScreen> createState() => _RefundRequestScreenState();
}

class _RefundRequestScreenState extends State<RefundRequestScreen> {
  // Mock products list for the refund page
  final List<Map<String, dynamic>> _products = [
    {
      'id': '1',
      'brand': 'جوبا',
      'brandEn': 'Juba',
      'title': 'وردة الصحراء المطرزة',
      'titleEn': 'Embroidered Desert Rose',
      'price': 1250,
      'size': 'M',
      'colorName': 'اللون',
      'colorNameEn': 'Color',
      'color': const Color(0xFFD6B5A7),
      'imageUrl': 'https://images.unsplash.com/photo-1509631179647-0177331693ae?w=400&q=80',
      'isSelected': false,
    },
    {
      'id': '2',
      'brand': 'جوبا',
      'brandEn': 'Juba',
      'title': 'وردة الصحراء المطرزة',
      'titleEn': 'Embroidered Desert Rose',
      'price': 1250,
      'size': 'M',
      'colorName': 'اللون',
      'colorNameEn': 'Color',
      'color': const Color(0xFFD6B5A7),
      'imageUrl': 'https://images.unsplash.com/photo-1529139574466-a303027c1d8b?w=400&q=80',
      'isSelected': false,
    },
  ];

  final TextEditingController _notesController = TextEditingController();

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final isAr = loc.isArabic;
    final textDir = isAr ? TextDirection.rtl : TextDirection.ltr;

    // Localized values
    final titleText = '${loc.translate('refundRequestTitle')} #${widget.orderId}';
    final orderNumLabel = loc.translate('orderNumberLabel');
    final orderDateLabel = loc.translate('orderDateLabel');
    final orderDateValue = loc.translate('orderDateValue');
    final sectionTitle = loc.translate('productsToReturn');
    final productsCountText = loc.translate('productsCountText');
    final sizeLabel = loc.translate('sizeLabel');
    final reasonLabel = loc.translate('reasonForReturn');

    final returnReasons = [
      loc.translate('reasonSizeNotFitting'),
      loc.translate('reasonDefective'),
      loc.translate('reasonNoLongerNeeded'),
      loc.translate('reasonWrongProduct'),
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

                // Products header with dropdown toggle
                GestureDetector(
                  onTap: () {
                    context.read<OrdersBloc>().add(const ToggleProductsExpandedEvent());
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        sectionTitle,
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
                                  productsCountText,
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
                                  productsCountText,
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
                  // Products List
                  ..._products.map((product) {
                    final productId = product['id'] as String;
                    final isProductSelected = state.selectedProducts[productId] ?? false;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: context.palette.backgroundSubtle,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isProductSelected
                              ? AppColors.primary
                              : Colors.transparent,
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
                        children: isAr
                            ? [
                                // RTL (Arabic): Checkbox on the left, Text in middle, Image on the right
                                Checkbox(
                                  value: isProductSelected,
                                  activeColor: AppColors.primary,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  side: BorderSide(
                                    color: context.palette.textMuted,
                                    width: 1.5,
                                  ),
                                  onChanged: (val) {
                                    context.read<OrdersBloc>().add(ToggleProductSelectionEvent(productId, val ?? false));
                                  },
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        product['brand'] as String,
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: context.palette.textMuted,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        product['title'] as String,
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: context.palette.textPrimary,
                                        ),
                                        textAlign: TextAlign.right,
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          Text(
                                            '${product['price']} ر.س.',
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.primary,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: context.palette.divider,
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
                                const SizedBox(width: 12),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(
                                    product['imageUrl'] as String,
                                    width: 110,
                                    height: 110,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ]
                            : [
                                // LTR (English): Image on the left, Text in middle, Checkbox on the right
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(
                                    product['imageUrl'] as String,
                                    width: 110,
                                    height: 110,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        product['brandEn'] as String,
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: context.palette.textMuted,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        product['titleEn'] as String,
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: context.palette.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Text(
                                            '${product['price']} SAR',
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.primary,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: context.palette.divider,
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
                                const SizedBox(width: 12),
                                Checkbox(
                                  value: isProductSelected,
                                  activeColor: AppColors.primary,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  side: BorderSide(
                                    color: context.palette.textMuted,
                                    width: 1.5,
                                  ),
                                  onChanged: (val) {
                                    context.read<OrdersBloc>().add(ToggleProductSelectionEvent(productId, val ?? false));
                                  },
                                ),
                              ],
                      ),
                    );
                  }).toList(),
                ],

                const SizedBox(height: 24),

                // ─── Reason dropdown field styled to match design ───
                Align(
                  alignment: isAr ? Alignment.centerRight : Alignment.centerLeft,
                  child: Text(
                    reasonLabel,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: context.palette.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: state.selectedReason,
                  hint: Align(
                    alignment: isAr ? Alignment.centerRight : Alignment.centerLeft,
                    child: Text(
                      loc.translate('reasonPlaceholder'),
                      style: TextStyle(color: context.palette.textMuted),
                    ),
                  ),
                  icon: Icon(
                    Icons.keyboard_arrow_down,
                    color: context.palette.textPrimary,
                  ),
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: context.palette.divider,
                        width: 1.5,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: context.palette.textMuted,
                        width: 1.5,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: context.palette.textPrimary,
                        width: 1.5,
                      ),
                    ),
                  ),
                  items: returnReasons.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Align(
                        alignment: isAr ? Alignment.centerRight : Alignment.centerLeft,
                        child: Text(value),
                      ),
                    );
                  }).toList(),
                  onChanged: (val) {
                    context.read<OrdersBloc>().add(ChangeRefundReasonEvent(val));
                  },
                ),
                const SizedBox(height: 24),

                // ─── Additional notes text area styled to match design ───
                Align(
                  alignment: isAr ? Alignment.centerRight : Alignment.centerLeft,
                  child: Text(
                    loc.translate('additionalNotesOptional'),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: context.palette.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _notesController,
                  maxLines: 4,
                  textAlign: isAr ? TextAlign.right : TextAlign.left,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: context.palette.divider,
                        width: 1.5,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: context.palette.textMuted,
                        width: 1.5,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: context.palette.textPrimary,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // ─── Confirm Refund Button "تأكيد طلب إرجاع" ───
                ElevatedButton(
                  onPressed: () {
                    final selectedCount = _products.where((p) => state.selectedProducts[p['id']] == true).length;
                    if (selectedCount == 0) {
                      Loader.showError(
                        loc.translate('selectAtLeastOneProduct'),
                      );
                      return;
                    }

                    context.push('/refund-status/${widget.orderId}');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.goldAccent,
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 0,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          loc.translate('confirmReturnRequest'),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Icon(
                          isAr ? Icons.west : Icons.east,
                          color: Colors.white,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // ─── Cancel Button "إلغاء" (Black Color style) ───
                OutlinedButton(
                  onPressed: () => context.pop(),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 56),
                    side: BorderSide(
                      color: context.palette.textMuted,
                      width: 1.5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    backgroundColor: context.palette.background,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          loc.translate('cancel'),
                          style: TextStyle(
                            color: context.palette.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Icon(
                          isAr ? Icons.west : Icons.east,
                          color: context.palette.textPrimary,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }
}
