import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:sfa/core/localization/app_localizations.dart';
import 'package:sfa/features/auth/providers/forgot_password_provider.dart';
import 'package:sfa/utils/assets_constants.dart';
import 'package:sfa/utils/color_constants.dart';
import 'package:sfa/utils/app_style.dart';
import 'package:sfa/core/theme/app_palette.dart';

/// M11 — final step of the forgot-password flow: sets a new password using
/// the `resetToken` [ForgotPasswordNotifier.verifyOtp] obtained. On success
/// the session was never authenticated here, so this returns straight to
/// `/login` rather than into the app.
class ResetPasswordScreen extends ConsumerStatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  ConsumerState<ResetPasswordScreen> createState() =>
      _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onSubmit() {
    final loc = AppLocalizations.of(context);
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (password.isEmpty || password.length < 8) {
      Fluttertoast.showToast(
        msg: loc.isArabic
            ? "يجب أن تتكون كلمة المرور من 8 أحرف على الأقل"
            : "Password must be at least 8 characters",
        backgroundColor: AppColors.redcolor,
        textColor: Colors.white,
      );
      return;
    }
    if (password != confirmPassword) {
      Fluttertoast.showToast(
        msg: loc.isArabic
            ? "كلمتا المرور غير متطابقتين"
            : "Passwords do not match",
        backgroundColor: AppColors.redcolor,
        textColor: Colors.white,
      );
      return;
    }
    ref.read(forgotPasswordProvider.notifier).resetPassword(password);
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final state = ref.watch(forgotPasswordProvider);
    final isLoading = state.status == ForgotPasswordStatus.loading;

    ref.listen<ForgotPasswordState>(forgotPasswordProvider, (previous, next) {
      if (next.status == ForgotPasswordStatus.success) {
        Fluttertoast.showToast(
          msg: loc.translate('passwordResetSuccess'),
          backgroundColor: AppColors.greencolor,
          textColor: Colors.white,
        );
        context.go('/login');
      } else if (next.status == ForgotPasswordStatus.failure &&
          next.errorMessage != null) {
        Fluttertoast.showToast(
          msg: next.errorMessage!,
          backgroundColor: AppColors.redcolor,
          textColor: Colors.white,
        );
      }
    });

    final Widget submitBtn = ElevatedButton(
      onPressed: isLoading ? null : _onSubmit,
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
                    loc.translate('resetPassword'),
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
                Center(
                  child: Text(
                    loc.translate('resetPassword'),
                    style: AppStyle.screenTitle,
                  ),
                ),
                const SizedBox(height: 16),
                Divider(thickness: 1, color: context.palette.divider),
                const SizedBox(height: 28),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    loc.translate("newPasswordLabel"),
                    style: AppStyle.fieldLabel,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: context.palette.backgroundSubtle,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: context.palette.divider),
                  ),
                  child: TextField(
                    controller: _passwordController,
                    obscureText: true,
                    style: AppStyle.inputText,
                    onTapOutside: (event) =>
                        FocusManager.instance.primaryFocus?.unfocus(),
                    decoration: InputDecoration(
                      hintText: loc.isArabic
                          ? 'أدخل كلمة المرور الجديدة'
                          : 'Enter new password',
                      hintStyle: AppStyle.inputHint.copyWith(
                        color: context.palette.textPrimary.withValues(alpha: 0.4),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    loc.translate("confirmPasswordLabel"),
                    style: AppStyle.fieldLabel,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: context.palette.backgroundSubtle,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: context.palette.divider),
                  ),
                  child: TextField(
                    controller: _confirmPasswordController,
                    obscureText: true,
                    style: AppStyle.inputText,
                    onTapOutside: (event) =>
                        FocusManager.instance.primaryFocus?.unfocus(),
                    decoration: InputDecoration(
                      hintText: loc.isArabic
                          ? 'أعد إدخال كلمة المرور'
                          : 'Re-enter new password',
                      hintStyle: AppStyle.inputHint.copyWith(
                        color: context.palette.textPrimary.withValues(alpha: 0.4),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                const SizedBox(height: 28),

                submitBtn,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
