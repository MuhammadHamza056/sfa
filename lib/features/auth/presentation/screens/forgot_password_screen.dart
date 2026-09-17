import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:sfa/core/localization/app_localizations.dart';
import 'package:sfa/core/widgets/gulf_country_code_picker.dart';
import 'package:sfa/utils/assets_constants.dart';
import 'package:sfa/utils/color_constants.dart';
import 'package:sfa/utils/phone_number_formatter.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sfa/utils/app_style.dart';
import 'package:sfa/features/auth/providers/forgot_password_provider.dart';
import 'package:sfa/core/theme/app_palette.dart';

/// M10 — collects an email or phone number and requests a password-reset
/// OTP. Deliberately a standalone screen/provider (not the login screen's
/// [authProvider]) since this flow never issues a session.
class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final state = ref.watch(forgotPasswordProvider);
    final isLoading = state.status == ForgotPasswordStatus.loading;

    ref.listen<ForgotPasswordState>(forgotPasswordProvider, (previous, next) {
      if (next.status == ForgotPasswordStatus.otpSent) {
        context.push('/reset-otp');
      } else if (next.status == ForgotPasswordStatus.failure &&
          next.errorMessage != null) {
        Fluttertoast.showToast(
          msg: next.errorMessage!,
          backgroundColor: AppColors.redcolor,
          textColor: Colors.white,
        );
      }
    });

    final Widget sendCodeBtn = ElevatedButton(
      onPressed: isLoading
          ? null
          : () => ref.read(forgotPasswordProvider.notifier).requestReset(),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        elevation: 0,
      ),
      child: isLoading
          ? const Center(
              child: SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          : Row(
              children: [
                const SizedBox(width: 18),
                Expanded(
                  child: Text(
                    loc.translate('sendResetCode'),
                    textAlign: TextAlign.center,
                    style: AppStyle.buttonTextPrimary,
                  ),
                ),
                if (loc.isArabic)
                  Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.rotationY(math.pi),
                    child: SvgPicture.asset(
                      AssetsConstants.moveLeft,
                      width: 18,
                      colorFilter: const ColorFilter.mode(
                        Colors.white,
                        BlendMode.srcIn,
                      ),
                    ),
                  )
                else
                  SvgPicture.asset(
                    AssetsConstants.moveLeft,
                    width: 18,
                    colorFilter: const ColorFilter.mode(
                      Colors.white,
                      BlendMode.srcIn,
                    ),
                  ),
              ],
            ),
    );

    return Scaffold(
      backgroundColor: context.palette.backgroundSubtle,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Directionality(
            textDirection: loc.isArabic ? TextDirection.rtl : TextDirection.ltr,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Align(
                  alignment: loc.isArabic
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: IconButton(
                    onPressed: () => context.pop(),
                    icon: Icon(
                      loc.isArabic ? Icons.arrow_forward : Icons.arrow_back,
                      color: context.palette.textPrimary,
                    ),
                  ),
                ),
                Center(
                  child: Text(
                    loc.translate('forgotPasswordTitle'),
                    style: AppStyle.screenTitle,
                  ),
                ),
                const SizedBox(height: 16),
                Divider(thickness: 1, color: context.palette.divider),
                const SizedBox(height: 24),

                Text(
                  loc.translate('forgotPasswordSubtitle'),
                  style: AppStyle.subtitleDesc.copyWith(
                    color: context.palette.textPrimary.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 28),

                _phoneField(loc),
                const SizedBox(height: 20),

                // Center(
                //   child: TextButton(
                //     onPressed: () => ref
                //         .read(forgotPasswordProvider.notifier)
                //         .toggleMode(!state.isEmailMode),
                //     child: Text(
                //       state.isEmailMode
                //           ? loc.translate('switchPhone')
                //           : loc.translate('switchEmail'),
                //       style: AppStyle.switchTextLink,
                //     ),
                //   ),
                // ),
                const SizedBox(height: 20),

                sendCodeBtn,
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _phoneField(AppLocalizations loc) {
    final state = ref.watch(forgotPasswordProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(loc.translate('phoneLabel'), style: AppStyle.fieldLabel),
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
                        .read(forgotPasswordProvider.notifier)
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
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    inputFormatters: [
                      PhoneInputFormatter(
                        maxLength: gulfPhoneLengths[state.dialCode] ?? 9,
                      ),
                    ],
                    onChanged: (val) => ref
                        .read(forgotPasswordProvider.notifier)
                        .changePhone(val),
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
