import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sfa/core/localization/app_localizations.dart';
import 'package:sfa/core/theme/app_palette.dart';
import 'package:sfa/utils/color_constants.dart';
import 'package:sfa/utils/loader.dart';
import '../../models/address.dart';
import '../../providers/address_provider.dart';

/// Add/Edit screen for an entry of the address list shown on
/// [AddressScreen]. Pass an existing [Address] to pre-fill the form in edit
/// mode; omit it to add a new address.
///
/// On save, writes through [addressProvider] (M40 create / inferred update)
/// and pops once the API confirms — [AddressScreen] picks up the change
/// automatically via `ref.watch`.
class AddEditAddressScreen extends ConsumerStatefulWidget {
  final Address? address;

  const AddEditAddressScreen({super.key, this.address});

  bool get isEditMode => address != null;

  @override
  ConsumerState<AddEditAddressScreen> createState() =>
      _AddEditAddressScreenState();
}

class _AddEditAddressScreenState extends ConsumerState<AddEditAddressScreen> {
  late final TextEditingController _labelController;
  late final TextEditingController _contactNumberController;
  late final TextEditingController _governorateController;
  late final TextEditingController _areaController;
  late final TextEditingController _blockController;
  late final TextEditingController _streetController;
  late final TextEditingController _houseNumberController;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final address = widget.address;
    _labelController = TextEditingController(text: address?.name ?? '');
    _contactNumberController = TextEditingController(text: address?.contactNumber ?? '');
    _governorateController = TextEditingController(text: address?.governorate ?? '');
    _areaController = TextEditingController(text: address?.area ?? '');
    _blockController = TextEditingController(text: address?.block ?? '');
    _streetController = TextEditingController(text: address?.street ?? '');
    _houseNumberController = TextEditingController(text: address?.houseNumber ?? '');
  }

  @override
  void dispose() {
    _labelController.dispose();
    _contactNumberController.dispose();
    _governorateController.dispose();
    _areaController.dispose();
    _blockController.dispose();
    _streetController.dispose();
    _houseNumberController.dispose();
    super.dispose();
  }

  Future<void> _onSave(AppLocalizations loc) async {
    final label = _labelController.text.trim();
    final contactNumber = _contactNumberController.text.trim();
    final governorate = _governorateController.text.trim();
    final area = _areaController.text.trim();
    final block = _blockController.text.trim();
    final street = _streetController.text.trim();
    final houseNumber = _houseNumberController.text.trim();

    if (label.isEmpty ||
        contactNumber.isEmpty ||
        governorate.isEmpty ||
        area.isEmpty ||
        block.isEmpty ||
        street.isEmpty ||
        houseNumber.isEmpty) {
      Loader.showError(loc.translate('fieldRequired'));
      return;
    }

    setState(() => _saving = true);

    final existing = widget.address;
    final address = Address(
      id: existing?.id ?? '',
      name: label,
      contactNumber: contactNumber,
      governorate: governorate,
      area: area,
      block: block,
      street: street,
      houseNumber: houseNumber,
      latitude: 0,
      longitude: 0,
      isDefault: existing?.isDefault ?? false,
    );

    final ok = widget.isEditMode
        ? await ref.read(addressProvider.notifier).updateAddress(address)
        : await ref.read(addressProvider.notifier).addAddress(address);

    if (!mounted) return;
    setState(() => _saving = false);

    if (ok) {
      Loader.showSuccess(loc.translate('addressSavedSuccess'));
      context.pop();
    } else {
      Loader.showError(loc.isArabic ? 'تعذر حفظ العنوان' : 'Could not save address');
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final isAr = loc.isArabic;
    final textAlign = isAr ? TextAlign.right : TextAlign.left;

    return Directionality(
      textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: context.palette.background,
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _FormField(
                label: isAr ? 'اسم العنوان' : 'Address Label',
                hint: isAr ? 'مثل: المنزل، العمل' : 'e.g. Home, Work',
                controller: _labelController,
                textAlign: textAlign,
              ),
              const SizedBox(height: 20),
              _FormField(
                label: loc.translate('phoneLabel'),
                hint: loc.translate('phoneHint'),
                controller: _contactNumberController,
                keyboardType: TextInputType.phone,
                textDirection: TextDirection.ltr,
                textAlign: TextAlign.left,
              ),
              const SizedBox(height: 20),
              _FormField(
                label: isAr ? 'المحافظة' : 'Governorate',
                hint: isAr ? 'مثل: العاصمة' : 'e.g. Al Asimah',
                controller: _governorateController,
                textAlign: textAlign,
              ),
              const SizedBox(height: 20),
              _FormField(
                label: isAr ? 'المنطقة' : 'Area',
                hint: isAr ? 'مثل: السالمية' : 'e.g. Salmiya',
                controller: _areaController,
                textAlign: textAlign,
              ),
              const SizedBox(height: 20),
              _FormField(
                label: isAr ? 'القطعة' : 'Block',
                hint: isAr ? 'مثل: 4' : 'e.g. 4',
                controller: _blockController,
                textAlign: textAlign,
              ),
              const SizedBox(height: 20),
              _FormField(
                label: isAr ? 'الشارع' : 'Street',
                hint: isAr ? 'مثل: شارع سالم المبارك' : 'e.g. Salem Al Mubarak St.',
                controller: _streetController,
                textAlign: textAlign,
              ),
              const SizedBox(height: 20),
              _FormField(
                label: isAr ? 'رقم المنزل' : 'House Number',
                hint: isAr ? 'مثل: 12' : 'e.g. 12',
                controller: _houseNumberController,
                textAlign: textAlign,
              ),
              const SizedBox(height: 32),

              // Save button — mirrors the "Add New Address" CTA on AddressScreen.
              Container(
                height: 54,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(27),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _saving ? null : () => _onSave(loc),
                    borderRadius: BorderRadius.circular(27),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: _saving
                          ? const Center(
                              child: SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  widget.isEditMode
                                      ? loc.translate('saveChanges')
                                      : loc.translate('addAddress'),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Icon(Icons.check, color: Colors.white, size: 20),
                              ],
                            ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Cancel button.
              SizedBox(
                height: 54,
                child: OutlinedButton(
                  onPressed: () => context.pop(),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: context.palette.divider,
                      width: 1.5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(27),
                    ),
                    backgroundColor: context.palette.background,
                  ),
                  child: Text(
                    loc.translate('cancel'),
                    style: TextStyle(
                      color: context.palette.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FormField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final TextDirection? textDirection;
  final TextAlign textAlign;

  const _FormField({
    required this.label,
    required this.hint,
    required this.controller,
    required this.textAlign,
    this.keyboardType,
    this.textDirection,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          textAlign: textAlign,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: context.palette.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          textDirection: textDirection,
          textAlign: textAlign,
          inputFormatters: keyboardType == TextInputType.phone
              ? [FilteringTextInputFormatter.allow(RegExp(r'[0-9+\s]'))]
              : null,
          style: TextStyle(color: context.palette.textPrimary),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: context.palette.textMuted,
              fontSize: 13,
            ),
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
                color: context.palette.divider,
                width: 1.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: AppColors.primary, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
