import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pinput/pinput.dart';
import 'package:sfa/core/localization/app_localizations.dart';
import 'package:sfa/core/theme/app_palette.dart';
import 'package:sfa/core/widgets/primary_app_bar.dart';
import 'package:sfa/features/orders/providers/orders_data_provider.dart';
import 'package:sfa/utils/app_style.dart';
import 'package:sfa/utils/color_constants.dart';

/// Route args for `/delivery-otp/:id` — carries the OTP the backend echoed
/// back from [OrdersRepository.sendDeliveryOtp] just before navigating here,
/// so it can be prefilled the same way auth's OTP screen does on
/// non-production backends.
class DeliveryOtpArgs {
  final String? debugOtp;

  const DeliveryOtpArgs({this.debugOtp});
}

class DeliveryOtpScreen extends ConsumerStatefulWidget {
  final String orderId;
  final String? debugOtp;

  const DeliveryOtpScreen({super.key, required this.orderId, this.debugOtp});

  @override
  ConsumerState<DeliveryOtpScreen> createState() => _DeliveryOtpScreenState();
}

class _DeliveryOtpScreenState extends ConsumerState<DeliveryOtpScreen> {
  static const int _resendCooldownSeconds = 60;

  final TextEditingController _pinController = TextEditingController();
  Timer? _resendTimer;
  int _secondsRemaining = _resendCooldownSeconds;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    if (widget.debugOtp != null) _pinController.text = widget.debugOtp!;
    _startResendTimer();
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    _pinController.dispose();
    super.dispose();
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

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _onResend() async {
    setState(() => _busy = true);
    final result = await ref
        .read(ordersRepositoryProvider)
        .sendDeliveryOtp(widget.orderId);
    if (!mounted) return;
    setState(() => _busy = false);
    if (result.isSuccess) {
      final debugOtp = result.dataOrNull?.debugOtp;
      if (debugOtp != null) _pinController.text = debugOtp;
      _startResendTimer();
    } else {
      _showMessage(result.errorOrNull?.message ?? '');
    }
  }

  Future<void> _onVerify() async {
    final otp = _pinController.text;
    if (otp.length < 4 || _busy) return;
    setState(() => _busy = true);
    final result = await ref
        .read(ordersRepositoryProvider)
        .verifyDeliveryOtp(widget.orderId, otp: otp);
    if (!mounted) return;
    setState(() => _busy = false);
    if (result.isSuccess) {
      context.pop(true);
    } else {
      _showMessage(result.errorOrNull?.message ?? '');
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final isAr = loc.isArabic;

    final defaultPinTheme = PinTheme(
      width: 50,
      height: 54,
      textStyle: AppStyle.welcomeTitle.copyWith(fontSize: 20),
      decoration: BoxDecoration(
        color: context.palette.backgroundSubtle,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.palette.divider, width: 1.2),
      ),
    );

    return Directionality(
      textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: context.palette.background,
        appBar: PrimaryAppBar(
          title: loc.translate('deliveryOtpTitle'),
          fontSize: 18,
          letterSpacing: 0,
          showBackButton: true,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  loc.translate('deliveryOtpSubtitle'),
                  style: AppStyle.subtitleDesc.copyWith(
                    color: context.palette.textPrimary.withValues(alpha: 0.7),
                  ),
                  textAlign: isAr ? TextAlign.right : TextAlign.left,
                ),
                const SizedBox(height: 32),
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
                ElevatedButton(
                  onPressed: _busy ? null : _onVerify,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    minimumSize: const Size(double.infinity, 54),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 0,
                  ),
                  child: _busy
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
                      : Text(
                          loc.translate('verify'),
                          style: AppStyle.buttonTextPrimary,
                        ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: TextButton(
                    onPressed: _secondsRemaining == 0 && !_busy
                        ? _onResend
                        : null,
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
