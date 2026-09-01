import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:pinput/pinput.dart';
import 'package:sfa/core/localization/app_localizations.dart';
import 'package:sfa/features/auth/providers/auth_provider.dart';
import 'package:sfa/utils/assets_constants.dart';
import 'package:sfa/utils/color_constants.dart';
import 'package:sfa/utils/app_style.dart';
import 'package:sfa/core/theme/app_palette.dart';

class OtpScreen extends ConsumerStatefulWidget {
  const OtpScreen({super.key});

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  static const int _resendCooldownSeconds = 60;

  final TextEditingController _pinController = TextEditingController();
  Timer? _resendTimer;
  int _secondsRemaining = _resendCooldownSeconds;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
  }

  void _startResendTimer() {
    _resendTimer?.cancel();
    _secondsRemaining = _resendCooldownSeconds;
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining <= 1) {
        timer.cancel();
        setState(() => _secondsRemaining = 0);
      } else {
        setState(() => _secondsRemaining--);
      }
    });
  }

  void _onResendOtp() {
    ref.read(authProvider.notifier).resendOtp();
    setState(_startResendTimer);
  }

  void _onVerify() {
    final otp = _pinController.text;
    if (otp.length < 4) return;
    ref.read(authProvider.notifier).verifyOtp(otp);
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    _pinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final state = ref.watch(authProvider);
    final isLoading = state.status == AuthStatus.loading;

    // Non-production backends echo the OTP straight back in the response
    // (see AuthState.debugOtp) — prefill it so testing doesn't need a real
    // SMS. Never present against a real production backend.
    if (state.debugOtp != null && _pinController.text != state.debugOtp) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _pinController.text = state.debugOtp!;
      });
    }

    ref.listen<AuthState>(authProvider, (previous, next) {
      if (next.status == AuthStatus.authenticated) {
        context.go('/success');
      } else if (next.status == AuthStatus.failure &&
          next.errorMessage != null) {
        Fluttertoast.showToast(
          msg: next.errorMessage!,
          backgroundColor: AppColors.redcolor,
          textColor: Colors.white,
        );
      }
    });

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
      onPressed: isLoading ? null : _onVerify,
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
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              ),
            )
          : Row(
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
                    transform: Matrix4.rotationY(
                      math.pi,
                    ), // Mirror horizontally so it points left (←)
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
                  style: AppStyle.subtitleDesc.copyWith(
                    color: context.palette.textPrimary.withValues(alpha: 0.7),
                  ),
                  textAlign: loc.isArabic ? TextAlign.right : TextAlign.left,
                ),
                const SizedBox(height: 32),

                // Pin Input fields using Pinput
                Center(
                  child: Directionality(
                    textDirection: TextDirection.ltr,
                    child: Pinput(
                      length: 6,
                      controller: _pinController,
                      defaultPinTheme: defaultPinTheme,
                      focusedPinTheme: defaultPinTheme.copyWith(
                        decoration: defaultPinTheme.decoration!.copyWith(
                          border: Border.all(
                            color: AppColors.primary,
                            width: 1.5,
                          ),
                        ),
                      ),
                      submittedPinTheme: defaultPinTheme,
                      onCompleted: (_) => _onVerify(),
                    ),
                  ),
                ),
                const SizedBox(height: 36),

                verifyBtn,
                const SizedBox(height: 20),

                // Resend OTP link, greyed out until the cooldown finishes
                Center(
                  child: TextButton(
                    onPressed: _secondsRemaining == 0 ? _onResendOtp : null,
                    child: Text(
                      _secondsRemaining == 0
                          ? loc.translate('resendOtp')
                          : loc
                                .translate('resendOtpTimer')
                                .replaceAll('{seconds}', '$_secondsRemaining'),
                      style: AppStyle.switchTextLink.copyWith(
                        color: _secondsRemaining == 0
                            ? AppColors.primary
                            : context.palette.textMuted,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
