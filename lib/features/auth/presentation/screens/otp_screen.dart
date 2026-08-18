import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:pinput/pinput.dart';
import 'package:sfa/core/localization/app_localizations.dart';
import 'package:sfa/utils/assets_constants.dart';
import 'package:sfa/utils/color_constants.dart';
import 'package:sfa/utils/app_style.dart';
import 'package:sfa/core/theme/app_palette.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final TextEditingController _pinController = TextEditingController();

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    // Default pin theme matching the screen design
    final defaultPinTheme = PinTheme(
      width: 58,
      height: 58,
      textStyle: AppStyle.welcomeTitle.copyWith(fontSize: 20),
      decoration: BoxDecoration(
        color: context.palette.backgroundSubtle,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.palette.divider, width: 1.2),
      ),
    );

    final Widget verifyBtn = ElevatedButton(
      onPressed: () {
        // Go to success page upon successful verification
        context.go('/success');
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        elevation: 0,
      ),
      child: Row(
        children: [
          const SizedBox(width: 18),
          Expanded(
            child: Text(
              loc.translate('verify'),
              textAlign: loc.isArabic ? TextAlign.right : TextAlign.left,
              style: AppStyle.buttonTextPrimary,
            ),
          ),
          if (loc.isArabic)
            Transform(
              alignment: Alignment.center,
              transform: Matrix4.rotationY(math.pi), // Mirror horizontally so it points left (←)
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

    final Widget loginBtn = OutlinedButton(
      onPressed: () {
        context.go('/login');
      },
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        side: BorderSide(color: context.palette.outlineStrong, width: 1.2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
      child: Row(
        children: [
          const SizedBox(width: 18),
          Expanded(
            child: Text(
              loc.translate('login'),
              textAlign: loc.isArabic ? TextAlign.right : TextAlign.left,
              style: AppStyle.buttonTextSecondary,
            ),
          ),
          if (loc.isArabic)
            Transform(
              alignment: Alignment.center,
              transform: Matrix4.rotationY(math.pi), // Mirror horizontally so it points left (←)
              child: SvgPicture.asset(
                AssetsConstants.moveLeft,
                width: 18,
                colorFilter: ColorFilter.mode(
                  context.palette.textPrimary,
                  BlendMode.srcIn,
                ),
              ),
            )
          else
            SvgPicture.asset(
              AssetsConstants.moveLeft,
              width: 18,
              colorFilter: ColorFilter.mode(
                context.palette.textPrimary,
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
                const SizedBox(height: 12),
                // Top Header Title
                Center(
                  child: Text(
                    loc.translate('verifyIdentity'),
                    style: AppStyle.screenTitle,
                  ),
                ),
                const SizedBox(height: 16),
                Divider(thickness: 1, color: context.palette.divider),
                const SizedBox(height: 32),

                // OTP Title and Subtitle instruction
                Text(
                  loc.translate('otpTitle'),
                  style: AppStyle.welcomeTitle,
                  textAlign: loc.isArabic ? TextAlign.right : TextAlign.left,
                ),
                const SizedBox(height: 8),
                Text(
                  loc.translate('otpSubtitle'),
                  style: AppStyle.subtitleDesc.copyWith(color: context.palette.textPrimary.withValues(alpha: 0.7)),
                  textAlign: loc.isArabic ? TextAlign.right : TextAlign.left,
                ),
                const SizedBox(height: 32),

                // Pin Input fields using Pinput
                Center(
                  child: Directionality(
                    textDirection: TextDirection.ltr,
                    child: Pinput(
                      length: 4,
                      controller: _pinController,
                      defaultPinTheme: defaultPinTheme,
                      focusedPinTheme: defaultPinTheme.copyWith(
                        decoration: defaultPinTheme.decoration!.copyWith(
                          border: Border.all(color: AppColors.primary, width: 1.5),
                        ),
                      ),
                      submittedPinTheme: defaultPinTheme,
                    ),
                  ),
                ),
                const SizedBox(height: 36),

                verifyBtn,
                const SizedBox(height: 20),

                // Verify using Email Link
                Center(
                  child: TextButton(
                    onPressed: () {
                      // Action for verifying using email
                    },
                    child: Text(
                      loc.translate('verifyEmail'),
                      style: AppStyle.switchTextLink,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                Divider(thickness: 1, color: context.palette.divider),
                const SizedBox(height: 24),

                loginBtn,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
