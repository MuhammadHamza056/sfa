import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:sfa/core/localization/app_localizations.dart';
import 'package:sfa/utils/app_style.dart';
import 'package:sfa/utils/assets_constants.dart';
import 'package:sfa/utils/color_constants.dart';
import 'package:sfa/utils/phone_number_formatter.dart';
import 'package:sfa/features/checkout/bloc/checkout_bloc.dart';
import 'package:sfa/features/checkout/bloc/checkout_event.dart';
import 'package:sfa/features/checkout/bloc/checkout_state.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _cityController = TextEditingController();
  final _addressController = TextEditingController();
  bool _saveAddress = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _cityController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final isAr = loc.isArabic;
    final textDir = isAr ? TextDirection.rtl : TextDirection.ltr;

    final regions = isAr
        ? ['الرياض', 'جدة', 'الدمام', 'مكة المكرمة', 'المدينة المنورة']
        : ['Riyadh', 'Jeddah', 'Dammam', 'Makkah', 'Madinah'];

    final paymentOptions = ['PayTaps', 'TapPayments', 'Moyasar'];

    return BlocProvider(
      create: (context) => CheckoutBloc(),
      child: BlocBuilder<CheckoutBloc, CheckoutState>(
        builder: (context, state) {
          return Directionality(
            textDirection: textDir,
            child: GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: Scaffold(
                backgroundColor: Colors.white,

                // ──────────────────────────────────────────────────────────────
                // AppBar — same style as DashboardScreen
                // ──────────────────────────────────────────────────────────────
                appBar: AppBar(
                  backgroundColor: Colors.white,
                  elevation: 0,
                  scrolledUnderElevation: 0,
                  automaticallyImplyLeading: false,
                  leadingWidth: 100,
                  // Leading: cart badge + heart (always LTR order in AppBar)
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
                  // Title: page title
                  title: Text(
                    loc.translate('secureCheckout'),
                    style: AppStyle.welcomeTitle.copyWith(fontSize: 18),
                  ),
                  centerTitle: true,
                  // Actions: search + back arrow
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
                      onTap: () => context.pop(),
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

                // ──────────────────────────────────────────────────────────────
                // Body
                // ──────────────────────────────────────────────────────────────
                body: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // ─── Shipping Address Section Header ──────────────────
                        Align(
                          alignment: isAr
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: Text(
                            loc.translate('shippingAddress'),
                            style: AppStyle.sectionHeader,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Divider(color: AppColors.textcolor_40, thickness: 0.8),
                        const SizedBox(height: 12),
                        Align(
                          alignment: isAr
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: Text(
                            loc.translate('fillFormToReceive'),
                            style: AppStyle.inputHint,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // ─── Full Name ────────────────────────────────────────
                        _buildLabel(loc.translate('fullNameLabel')),
                        const SizedBox(height: 6),
                        _buildTextField(
                          controller: _nameController,
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? loc.translate('fieldRequired')
                              : null,
                        ),
                        const SizedBox(height: 14),

                        // ─── Phone Number ─────────────────────────────────────
                        _buildLabel(loc.translate('phoneLabel')),
                        const SizedBox(height: 6),
                        _buildPhoneField(),
                        const SizedBox(height: 14),

                        // ─── Region ───────────────────────────────────────────
                        _buildLabel(loc.translate('regionLabel')),
                        const SizedBox(height: 6),
                        _buildRegionChips(context, state, regions, isAr),
                        const SizedBox(height: 14),

                        // ─── City ─────────────────────────────────────────────
                        _buildLabel(loc.translate('cityLabel')),
                        const SizedBox(height: 6),
                        _buildTextField(
                          controller: _cityController,
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? loc.translate('fieldRequired')
                              : null,
                        ),
                        const SizedBox(height: 14),

                        // ─── Map ──────────────────────────────────────────────
                        Align(
                          alignment: isAr
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: Text(
                            loc.translate('addressByMap'),
                            style: AppStyle.fieldLabel,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _CheckoutMap(),
                        const SizedBox(height: 14),
                        _buildLabel(loc.translate('detailedAddressLabel')),
                        const SizedBox(height: 6),
                        _buildTextField(
                          controller: _addressController,
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? loc.translate('fieldRequired')
                              : null,
                        ),
                        const SizedBox(height: 12),

                        // ─── Save address checkbox ────────────────────────
                        Directionality(
                          textDirection: TextDirection.ltr,
                          child: InkWell(
                            onTap: () =>
                                setState(() => _saveAddress = !_saveAddress),
                            borderRadius: BorderRadius.circular(8),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              child: Row(
                                children: isAr
                                    ? [
                                        SizedBox(
                                          width: 22,
                                          height: 22,
                                          child: Checkbox(
                                            value: _saveAddress,
                                            onChanged: (v) => setState(
                                              () => _saveAddress = v ?? false,
                                            ),
                                            activeColor: AppColors.primary,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            side: BorderSide(
                                              color: AppColors.textcolor_40,
                                              width: 1.5,
                                            ),
                                            materialTapTargetSize:
                                                MaterialTapTargetSize
                                                    .shrinkWrap,
                                            visualDensity:
                                                VisualDensity.compact,
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Align(
                                            alignment: Alignment.centerRight,
                                            child: Text(
                                              loc.translate(
                                                'saveAddressForFuture',
                                              ),
                                              style: AppStyle.labelText,
                                              textDirection: TextDirection.rtl,
                                            ),
                                          ),
                                        ),
                                      ]
                                    : [
                                        SizedBox(
                                          width: 22,
                                          height: 22,
                                          child: Checkbox(
                                            value: _saveAddress,
                                            onChanged: (v) => setState(
                                              () => _saveAddress = v ?? false,
                                            ),
                                            activeColor: AppColors.primary,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            side: BorderSide(
                                              color: AppColors.textcolor_40,
                                              width: 1.5,
                                            ),
                                            materialTapTargetSize:
                                                MaterialTapTargetSize
                                                    .shrinkWrap,
                                            visualDensity:
                                                VisualDensity.compact,
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Text(
                                          loc.translate('saveAddressForFuture'),
                                          style: AppStyle.labelText,
                                        ),
                                      ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // ─── Payment Method Section Header ────────────────────
                        Text(
                          loc.translate('paymentMethod'),
                          style: AppStyle.sectionHeader,
                        ),
                        const SizedBox(height: 16),
                        Divider(color: AppColors.textcolor_40, thickness: 0.8),
                        const SizedBox(height: 16),

                        // ─── Pricing Summary ──────────────────────────────────
                        _buildPricingRow(
                          label: loc.translate('subtotal'),
                          amount: isAr ? '2,500 ر.س' : '2,500 SAR',
                          isPrimary: false,
                          isAr: isAr,
                        ),
                        const SizedBox(height: 8),
                        _buildPricingRow(
                          label: loc.translate('totalAmount'),
                          amount: isAr ? '2,500 ر.س' : '2,500 SAR',
                          isPrimary: true,
                          isAr: isAr,
                        ),
                        const SizedBox(height: 16),

                        Text(
                          loc.translate('choosePayment'),
                          style: AppStyle.inputHint,
                        ),
                        const SizedBox(height: 12),

                        // ─── Payment Options ──────────────────────────────────
                        ...paymentOptions.map(
                          (option) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _buildPaymentOption(
                              context,
                              state,
                              option,
                              isAr,
                              loc,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // ─── Confirm Order Button ─────────────────────────────
                        ElevatedButton(
                          onPressed: _onConfirmOrder,
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
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  loc.translate('confirmOrder'),
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
                              const SizedBox(width: 8),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),

                        // ─── Cancel Button ────────────────────────────────────
                        OutlinedButton(
                          onPressed: () => context.pop(),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 54),
                            side: BorderSide(color: AppColors.textcolor_40),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
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
                              // Mirror the arrow to point LEFT (←) in Arabic
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
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Helper Widgets ─────────────────────────────────────────────────────────

  /// Section label — text flows in the natural direction of the locale
  Widget _buildLabel(String label) {
    return Text(label, style: AppStyle.fieldLabel);
  }

  /// Standard text input — direction inherited from parent Directionality
  Widget _buildTextField({
    required TextEditingController controller,
    String? Function(String?)? validator,
  }) {
    // Wrap in LTR so cursor and typed text always anchor to the left,
    // consistent with the phone field — even inside the Arabic RTL scaffold.
    return Directionality(
      textDirection: TextDirection.ltr,
      child: TextFormField(
        controller: controller,
        validator: validator,
        style: AppStyle.inputText,
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.start,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          filled: true,
          fillColor: Colors.white,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.textcolor_40),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.primary, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red, width: 1.5),
          ),
        ),
      ),
    );
  }

  /// Phone field — prefix country code always stays LTR visually
  Widget _buildPhoneField() {
    // border layout, and cursor all anchor to the left — even inside RTL.
    return Directionality(
      textDirection: TextDirection.ltr,
      child: TextFormField(
        controller: _phoneController,
        keyboardType: TextInputType.phone,
        style: AppStyle.inputText,
        textDirection: TextDirection.ltr,
        // Digits only, max 9 digits for Saudi Arabia (+966)
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          PhoneInputFormatter(maxLength: 9),
        ],
        validator: (v) => PhoneInputValidator.validatePhoneNumber(v, '+966'),
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          filled: true,
          fillColor: Colors.white,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.textcolor_40),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.primary, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red, width: 1.5),
          ),
          prefixIcon: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🇸🇦', style: TextStyle(fontSize: 20)),
                const SizedBox(width: 4),
                Text('+966', style: AppStyle.inputText),
                const SizedBox(width: 4),
                Container(width: 1, height: 24, color: AppColors.textcolor_40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Scrollable region chips — scroll direction respects RTL
  Widget _buildRegionChips(
    BuildContext context,
    CheckoutState state,
    List<String> regions,
    bool isAr,
  ) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      reverse: isAr,
      child: Row(
        textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
        children: List.generate(regions.length, (i) {
          final isSelected = state.selectedRegionIndex == i;
          return Padding(
            padding: EdgeInsetsDirectional.only(end: 8),
            child: GestureDetector(
              onTap: () =>
                  context.read<CheckoutBloc>().add(ChangeRegionIndexEvent(i)),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  // Selected: subtle grey background, no border
                  // Unselected: fully transparent, no border
                  color: isSelected
                      ? const Color(0xFFF0F0F0)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  regions[i],
                  style: AppStyle.regionChip.copyWith(
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildPricingRow({
    required String label,
    required String amount,
    required bool isPrimary,
    required bool isAr,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Label first → appears on the RIGHT in RTL (no swap needed)
        Text(
          label,
          style: AppStyle.pricingLabel.copyWith(
            color: AppColors.textcolor.withValues(alpha: 0.6),
          ),
        ),
        Directionality(
          textDirection: TextDirection.ltr,
          child: Text(
            amount,
            style: isPrimary ? AppStyle.valuePrimary : AppStyle.pricingValue,
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentOption(
    BuildContext context,
    CheckoutState state,
    String option,
    bool isAr,
    AppLocalizations loc,
  ) {
    final isSelected = state.selectedPayment == option;
    // Map options to localization keys: 'PayTaps' -> 'paymentPayTaps', etc.
    final locKey = 'payment$option';
    final translatedLabel = loc.translate(locKey);

    return GestureDetector(
      onTap: () => context.read<CheckoutBloc>().add(ChangePaymentEvent(option)),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          // Same border color for both states — no color change on selection
          border: Border.all(color: AppColors.textcolor_40, width: 1),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          children: [
            Text(
              translatedLabel.isEmpty ? option : translatedLabel,
              style: AppStyle.paymentOption,
            ),
            const Spacer(),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected
                    ? Colors.transparent
                    : const Color(0xFFF0F0F0),
                border: isSelected
                    ? Border.all(color: AppColors.primary, width: 1.5)
                    : null,
              ),
              child: isSelected
                  ? Center(
                      child: Icon(
                        Icons.check,
                        color: AppColors.primary,
                        size: 15,
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  void _onConfirmOrder() {
    if (_formKey.currentState?.validate() ?? false) {
      context.push('/payment-success');
    }
  }
}

/// A static map widget showing a pinned Kuwait City location.
/// Uses flutter_map + OpenStreetMap tiles — no API key required.
class _CheckoutMap extends StatefulWidget {
  const _CheckoutMap();

  @override
  State<_CheckoutMap> createState() => _CheckoutMapState();
}

class _CheckoutMapState extends State<_CheckoutMap> {
  // Kuwait City — Salmiya area (random but recognisable Kuwait location)
  static const LatLng _location = LatLng(29.3375, 48.0750);
  final MapController _mapController = MapController();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        height: 120,
        child: FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: _location,
            initialZoom: 14,
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.pinchZoom | InteractiveFlag.drag,
            ),
          ),
          children: [
            // OpenStreetMap tile layer — free, no API key needed
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.sfa.app',
            ),
            // Marker at the Kuwait location
            MarkerLayer(
              markers: [
                Marker(
                  point: _location,
                  width: 40,
                  height: 40,
                  child: Icon(
                    Icons.location_pin,
                    color: AppColors.primary,
                    size: 40,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
