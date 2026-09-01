import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:sfa/core/localization/app_localizations.dart';
import 'package:sfa/utils/app_style.dart';
import 'package:sfa/utils/assets_constants.dart';
import 'package:sfa/utils/color_constants.dart';
import 'package:sfa/utils/currency_formatter.dart';
import 'package:sfa/features/address/models/address.dart';
import 'package:sfa/features/address/providers/address_provider.dart';
import 'package:sfa/features/cart/providers/cart_provider.dart';
import 'package:sfa/features/checkout/providers/checkout_providers.dart';
import 'package:sfa/core/theme/app_palette.dart';
import 'package:sfa/core/widgets/primary_app_bar.dart';

/// Checkout-level payment methods the guide's M39 confirm example and M45
/// initiate example both reference (`MYFATOORAH`, `APPLE_PAY`) — `MADA`
/// added as the third common Saudi rail. The guide doesn't enumerate the
/// full set, so this list is the best-supported inference rather than a
/// documented enum.
const _kPaymentMethods = ['MYFATOORAH', 'MADA', 'APPLE_PAY'];

String _paymentLabel(String method, bool isAr) {
  switch (method) {
    case 'MYFATOORAH':
      return isAr ? 'ماي فاتورة' : 'MyFatoorah';
    case 'MADA':
      return isAr ? 'مدى' : 'Mada';
    case 'APPLE_PAY':
      return 'Apple Pay';
    default:
      return method;
  }
}

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  String? _selectedAddressId;
  String _selectedPayment = _kPaymentMethods.first;
  bool _confirming = false;

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _onConfirmOrder(AppLocalizations loc) async {
    final addressId = _selectedAddressId;
    if (addressId == null) {
      _showMessage(loc.isArabic ? 'الرجاء اختيار عنوان التوصيل' : 'Please choose a delivery address');
      return;
    }

    setState(() => _confirming = true);
    final result = await ref.read(checkoutRepositoryProvider).confirmCheckout(
          addressId: addressId,
          paymentMethod: _selectedPayment,
        );
    if (!mounted) return;
    setState(() => _confirming = false);

    result.when(
      success: (order) {
        ref.read(cartProvider.notifier).refresh();
        context.push('/payment-success', extra: order);
      },
      failure: (error) => _showMessage(error.message),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final isAr = loc.isArabic;
    final textDir = isAr ? TextDirection.rtl : TextDirection.ltr;
    final addressesAsync = ref.watch(addressProvider);

    // Default to the customer's default (or first) address once loaded.
    addressesAsync.whenData((addresses) {
      if (_selectedAddressId == null && addresses.isNotEmpty) {
        final defaultAddress = addresses.firstWhere(
          (a) => a.isDefault,
          orElse: () => addresses.first,
        );
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && _selectedAddressId == null) {
            setState(() => _selectedAddressId = defaultAddress.id);
          }
        });
      }
    });

    final previewAsync = ref.watch(checkoutPreviewProvider(_selectedAddressId ?? ''));

    return Directionality(
      textDirection: textDir,
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          backgroundColor: context.palette.background,
          appBar: PrimaryAppBar(
            title: loc.translate('secureCheckout'),
            fontSize: 18,
            letterSpacing: 0,
            showBackButton: true,
            cartIcon: AssetsConstants.shoppingBag,
            heartIcon: AssetsConstants.heart2,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ─── Shipping Address Section Header ──────────────────
                Align(
                  alignment: isAr ? Alignment.centerRight : Alignment.centerLeft,
                  child: Text(loc.translate('shippingAddress'), style: AppStyle.sectionHeader),
                ),
                const SizedBox(height: 6),
                Divider(color: context.palette.divider, thickness: 0.8),
                const SizedBox(height: 12),

                addressesAsync.when(
                  loading: () => const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (error, _) => Text(
                    error.toString(),
                    style: AppStyle.bodyText.copyWith(color: context.palette.textMuted),
                  ),
                  data: (addresses) {
                    if (addresses.isEmpty) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            loc.translate('noAddressesYet'),
                            style: AppStyle.bodyText.copyWith(color: context.palette.textMuted),
                          ),
                          const SizedBox(height: 12),
                          OutlinedButton(
                            onPressed: () => context.push('/addresses/add'),
                            child: Text(loc.translate('addAddress')),
                          ),
                        ],
                      );
                    }
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        for (final address in addresses) ...[
                          _AddressOption(
                            address: address,
                            selected: _selectedAddressId == address.id,
                            onTap: () => setState(() => _selectedAddressId = address.id),
                          ),
                          const SizedBox(height: 8),
                        ],
                        Align(
                          alignment: isAr ? Alignment.centerRight : Alignment.centerLeft,
                          child: TextButton(
                            onPressed: () => context.push('/addresses/add'),
                            child: Text(loc.translate('addAddress')),
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 14),

                if (_selectedAddressId != null) ...[
                  Align(
                    alignment: isAr ? Alignment.centerRight : Alignment.centerLeft,
                    child: Text(loc.translate('addressByMap'), style: AppStyle.fieldLabel),
                  ),
                  const SizedBox(height: 8),
                  _CheckoutMap(
                    location: addressesAsync.valueOrNull
                        ?.where((a) => a.id == _selectedAddressId)
                        .firstOrNullWithLocation(),
                  ),
                  const SizedBox(height: 14),
                ],

                // ─── Payment Method Section Header ────────────────────
                Text(loc.translate('paymentMethod'), style: AppStyle.sectionHeader),
                const SizedBox(height: 16),
                Divider(color: context.palette.divider, thickness: 0.8),
                const SizedBox(height: 16),

                // ─── Pricing Summary ──────────────────────────────────
                previewAsync.when(
                  loading: () => const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (error, _) => Text(
                    error.toString(),
                    style: AppStyle.bodyText.copyWith(color: context.palette.textMuted),
                  ),
                  data: (preview) {
                    if (preview == null) {
                      return Text(
                        isAr ? 'اختر عنوانًا لعرض الإجمالي' : 'Choose an address to see the total',
                        style: AppStyle.bodyText.copyWith(color: context.palette.textMuted),
                      );
                    }
                    return Column(
                      children: [
                        _buildPricingRow(
                          label: loc.translate('subtotal'),
                          amount: CurrencyFormatter.fromHalalas(preview.subtotalFils, isAr: isAr),
                          isPrimary: false,
                        ),
                        const SizedBox(height: 8),
                        if (preview.deliveryFeeFils > 0) ...[
                          _buildPricingRow(
                            label: isAr ? 'رسوم التوصيل' : 'Delivery Fee',
                            amount: CurrencyFormatter.fromHalalas(preview.deliveryFeeFils, isAr: isAr),
                            isPrimary: false,
                          ),
                          const SizedBox(height: 8),
                        ],
                        if (preview.taxFils > 0) ...[
                          _buildPricingRow(
                            label: isAr ? 'الضريبة' : 'Tax',
                            amount: CurrencyFormatter.fromHalalas(preview.taxFils, isAr: isAr),
                            isPrimary: false,
                          ),
                          const SizedBox(height: 8),
                        ],
                        _buildPricingRow(
                          label: loc.translate('totalAmount'),
                          amount: CurrencyFormatter.fromHalalas(preview.totalFils, isAr: isAr),
                          isPrimary: true,
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 16),

                Text(
                  loc.translate('choosePayment'),
                  style: AppStyle.inputHint.copyWith(
                    color: context.palette.textPrimary.withValues(alpha: 0.4),
                  ),
                ),
                const SizedBox(height: 12),

                // ─── Payment Options ──────────────────────────────────
                ..._kPaymentMethods.map(
                  (option) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _buildPaymentOption(context, option, isAr),
                  ),
                ),
                const SizedBox(height: 24),

                // ─── Confirm Order Button ─────────────────────────────
                ElevatedButton(
                  onPressed: _confirming ? null : () => _onConfirmOrder(loc),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    minimumSize: const Size(double.infinity, 54),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    elevation: 0,
                  ),
                  child: _confirming
                      ? const Center(
                          child: SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          ),
                        )
                      : Row(
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
                              colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
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
                    side: BorderSide(color: context.palette.divider),
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
                      isAr
                          ? Transform(
                              alignment: Alignment.center,
                              transform: Matrix4.rotationY(math.pi),
                              child: SvgPicture.asset(
                                AssetsConstants.moveLeft,
                                width: 18,
                                height: 18,
                                colorFilter: ColorFilter.mode(
                                  context.palette.textPrimary,
                                  BlendMode.srcIn,
                                ),
                              ),
                            )
                          : SvgPicture.asset(
                              AssetsConstants.moveLeft,
                              width: 18,
                              height: 18,
                              colorFilter: ColorFilter.mode(
                                context.palette.textPrimary,
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
    );
  }

  Widget _buildPricingRow({
    required String label,
    required String amount,
    required bool isPrimary,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppStyle.pricingLabel.copyWith(
            color: context.palette.textPrimary.withValues(alpha: 0.6),
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

  Widget _buildPaymentOption(BuildContext context, String option, bool isAr) {
    final isSelected = _selectedPayment == option;
    return GestureDetector(
      onTap: () => setState(() => _selectedPayment = option),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: context.palette.background,
          border: Border.all(color: context.palette.divider, width: 1),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          children: [
            Text(_paymentLabel(option, isAr), style: AppStyle.paymentOption),
            const Spacer(),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? Colors.transparent : context.palette.surfaceMuted,
                border: isSelected ? Border.all(color: AppColors.primary, width: 1.5) : null,
              ),
              child: isSelected
                  ? Center(child: Icon(Icons.check, color: AppColors.primary, size: 15))
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

class _AddressOption extends StatelessWidget {
  final Address address;
  final bool selected;
  final VoidCallback onTap;

  const _AddressOption({required this.address, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary.withValues(alpha: 0.08) : context.palette.surfaceMuted,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: selected ? AppColors.primary : Colors.transparent, width: 1.5),
        ),
        child: Row(
          children: [
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: selected ? AppColors.primary : context.palette.textMuted,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    address.name,
                    style: AppStyle.fieldLabel.copyWith(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${address.line1}, ${address.line2}',
                    style: AppStyle.bodyText.copyWith(
                      fontSize: 12,
                      color: context.palette.textMuted,
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
}

extension _FirstAddress on Iterable<Address> {
  Address? firstOrNullWithLocation() => isEmpty ? null : first;
}

/// A static map — centers on the selected address when it carries
/// coordinates, otherwise falls back to a generic Riyadh view. No forward
/// geocoding/search endpoint exists in the guide, so this stays read-only.
class _CheckoutMap extends StatelessWidget {
  final Address? location;

  const _CheckoutMap({this.location});

  static const LatLng _fallback = LatLng(24.7136, 46.6753); // Riyadh

  @override
  Widget build(BuildContext context) {
    final point = location?.latitude != null && location?.longitude != null
        ? LatLng(location!.latitude!, location!.longitude!)
        : _fallback;

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        height: 120,
        child: FlutterMap(
          options: MapOptions(
            initialCenter: point,
            initialZoom: 14,
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.pinchZoom | InteractiveFlag.drag,
            ),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.sfa.app',
            ),
            MarkerLayer(
              markers: [
                Marker(
                  point: point,
                  width: 40,
                  height: 40,
                  child: Icon(Icons.location_pin, color: AppColors.primary, size: 40),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
