import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sfa/core/localization/app_localizations.dart';
import 'package:sfa/core/widgets/gulf_country_code_picker.dart';
import 'package:sfa/utils/color_constants.dart';
import 'package:sfa/utils/phone_number_formatter.dart';
import 'package:sfa/features/auth/providers/auth_provider.dart';
import 'package:sfa/core/theme/app_palette.dart';

class PhoneInputField extends ConsumerWidget {
  final TextEditingController controller;

  const PhoneInputField({super.key, required this.controller});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context);
    final state = ref.watch(authProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Directionality(
          textDirection: loc.isArabic ? TextDirection.rtl : TextDirection.ltr,
          child: Text(
            loc.translate('phoneLabel'),
            style: TextStyle(
              color: context.palette.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Directionality(
          textDirection: TextDirection.ltr,
          child: Container(
            decoration: BoxDecoration(
              color: context.palette.backgroundSubtle,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: state.phoneValidationError != null
                    ? AppColors.redcolor
                    : context.palette.divider,
              ),
            ),
            child: Row(
              children: [
                GulfCountryCodePicker(
                  initialSelection: state.dialCode,
                  onChanged: (country) {
                    final code = country.dialCode ?? '+965';
                    ref
                        .read(authProvider.notifier)
                        .changeCountryCode(
                          countryCode: country.code ?? 'KW',
                          dialCode: code,
                        );
                  },
                ),
                Container(height: 24, width: 1, color: context.palette.divider),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: controller,
                    keyboardType: TextInputType.phone,
                    inputFormatters: [
                      PhoneInputFormatter(
                        maxLength: gulfPhoneLengths[state.dialCode] ?? 9,
                      ),
                    ],
                    onChanged: (val) {
                      ref.read(authProvider.notifier).changePhone(val);
                    },
                    decoration: InputDecoration(
                      hintText: 'Phone number',
                      hintStyle: TextStyle(
                        color: context.palette.textMuted,
                        fontSize: 14,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (state.phoneValidationError != null) ...[
          const SizedBox(height: 4),
          Text(
            state.phoneValidationError!,
            style: TextStyle(color: AppColors.redcolor, fontSize: 12),
          ),
        ],
      ],
    );
  }
}
