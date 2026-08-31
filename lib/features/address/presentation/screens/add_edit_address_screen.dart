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
/// On save, writes directly to [addressProvider] and pops — [AddressScreen]
/// picks up the change automatically via `ref.watch`.
class AddEditAddressScreen extends ConsumerStatefulWidget {
  final Address? address;

  const AddEditAddressScreen({super.key, this.address});

  bool get isEditMode => address != null;

  @override
  ConsumerState<AddEditAddressScreen> createState() =>
      _AddEditAddressScreenState();
}

class _AddEditAddressScreenState extends ConsumerState<AddEditAddressScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressLine1Controller;
  late final TextEditingController _cityAreaController;

  @override
  void initState() {
    super.initState();
    final address = widget.address;
    _nameController = TextEditingController(text: address?.titleEn ?? '');
    _phoneController = TextEditingController(text: address?.phone ?? '');
    _addressLine1Controller = TextEditingController(
      text: address?.line1En ?? '',
    );
    _cityAreaController = TextEditingController(text: address?.line2En ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressLine1Controller.dispose();
    _cityAreaController.dispose();
    super.dispose();
  }

  void _onSave(AppLocalizations loc) {
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final line1 = _addressLine1Controller.text.trim();
    final line2 = _cityAreaController.text.trim();

    if (name.isEmpty || phone.isEmpty || line1.isEmpty || line2.isEmpty) {
      Loader.showError(loc.translate('fieldRequired'));
      return;
    }

    final existing = widget.address;
    final address = Address(
      id: existing?.id ?? DateTime.now().microsecondsSinceEpoch.toString(),
      titleAr: name,
      titleEn: name,
      line1Ar: line1,
      line1En: line1,
      line2Ar: line2,
      line2En: line2,
      phone: phone,
    );

    if (widget.isEditMode) {
      ref.read(addressProvider.notifier).updateAddress(address);
    } else {
      ref.read(addressProvider.notifier).addAddress(address);
    }

    Loader.showSuccess(loc.translate('addressSavedSuccess'));
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final isAr = loc.isArabic;

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
                label: loc.translate('fullNameLabel'),
                hint: loc.translate('fullNameHint'),
                controller: _nameController,
                textAlign: isAr ? TextAlign.right : TextAlign.left,
              ),
              const SizedBox(height: 20),
              _FormField(
                label: loc.translate('phoneLabel'),
                hint: loc.translate('phoneHint'),
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                textDirection: TextDirection.ltr,
                textAlign: TextAlign.left,
              ),
              const SizedBox(height: 20),
              _FormField(
                label: loc.translate('addressLine1Label'),
                hint: loc.translate('addressLine1Hint'),
                controller: _addressLine1Controller,
                textAlign: isAr ? TextAlign.right : TextAlign.left,
              ),
              const SizedBox(height: 20),
              _FormField(
                label: loc.translate('cityAreaLabel'),
                hint: loc.translate('cityAreaHint'),
                controller: _cityAreaController,
                textAlign: isAr ? TextAlign.right : TextAlign.left,
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
                    onTap: () => _onSave(loc),
                    borderRadius: BorderRadius.circular(27),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            widget.isEditMode
                                ? loc.translate('saveChanges')
                                : loc.translate('addAddress'),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 20,
                          ),
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
