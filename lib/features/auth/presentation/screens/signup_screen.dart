import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';

import 'package:sfa/core/localization/app_localizations.dart';
import 'package:sfa/utils/assets_constants.dart';
import 'package:sfa/utils/color_constants.dart';
import 'package:sfa/utils/app_style.dart';
import 'package:sfa/features/auth/providers/auth_provider.dart';
import 'package:sfa/features/auth/presentation/widgets/phone_input_field.dart';
import 'package:sfa/core/theme/app_palette.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final state = ref.watch(authProvider);
    final isLoading = state.status == AuthStatus.loading;

    final Widget signUpBtn = ElevatedButton(
      onPressed: isLoading
          ? null
          : () {
              ref
                  .read(authProvider.notifier)
                  .submitSignup(
                    name: _fullNameController.text,
                    email: _emailController.text,
                    password: _passwordController.text,
                    confirmPassword: _confirmPasswordController.text,
                  );
            },
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
                    loc.translate('signup'),
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

    final Widget loginBtn = OutlinedButton(
      onPressed: () {
        context.go('/login');
      },
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        side: BorderSide(color: context.palette.outlineStrong, width: 1.2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
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
              transform: Matrix4.rotationY(
                math.pi,
              ), // Mirror horizontally so it points left (←)
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

    ref.listen<AuthState>(authProvider, (previous, next) {
      if (next.status == AuthStatus.otpSent) {
        Fluttertoast.showToast(
          msg: loc.isArabic
              ? "تم إنشاء الحساب بنجاح!"
              : "Account Created Successfully!",
          backgroundColor: AppColors.greencolor,
          textColor: Colors.white,
        );
        context.go('/otp');
      } else if (next.status == AuthStatus.failure &&
          next.errorMessage != null) {
        Fluttertoast.showToast(
          msg: next.errorMessage!,
          backgroundColor: AppColors.redcolor,
          textColor: Colors.white,
        );
      }
    });

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
                    loc.translate('signup'),
                    style: AppStyle.screenTitle,
                  ),
                ),
                const SizedBox(height: 16),
                Divider(thickness: 1, color: context.palette.divider),
                const SizedBox(height: 24),

                // Welcome Subtitle Section
                Text(
                  loc.translate('welcomeSignup'),
                  style: AppStyle.welcomeTitle,
                ),
                const SizedBox(height: 8),
                Text(
                  loc.translate('signupSubtitle'),
                  style: AppStyle.subtitleDesc.copyWith(
                    color: context.palette.textPrimary.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 28),

                // Social Login Pill Buttons
                Row(
                  children: [
                    // Apple Login Button
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: BorderSide(
                            color: context.palette.outlineStrong,
                            width: 1.2,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              AssetsConstants.applePng,
                              width: 18,
                              height: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              loc.translate('apple'),
                              style: AppStyle.buttonTextSocial,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),

                    // Google Login Button
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: BorderSide(
                            color: context.palette.outlineStrong,
                            width: 1.2,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              AssetsConstants.googlePng,
                              width: 18,
                              height: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              loc.translate('google'),
                              style: AppStyle.buttonTextSocial,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),

                // Sub-label Or Phone Login
                Text(
                  loc.translate('orSignupEmailPhone'),
                  style: AppStyle.inputLabelSub.copyWith(
                    color: context.palette.textPrimary.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 16),

                // Full Name Field
                _buildFieldLabel(loc.translate('fullNameLabel')),
                const SizedBox(height: 8),
                _buildTextField(
                  controller: _fullNameController,
                  hintText: loc.isArabic
                      ? 'أدخل اسمك الكامل'
                      : 'Enter your full name',
                ),
                const SizedBox(height: 20),

                // Phone Input Field (Modular Component)
                PhoneInputField(controller: _phoneController),
                const SizedBox(height: 20),

                // Email Field
                _buildFieldLabel(loc.translate('emailLabel')),
                const SizedBox(height: 8),
                _buildTextField(
                  controller: _emailController,
                  hintText: loc.isArabic
                      ? 'أدخل البريد الإلكتروني'
                      : 'Enter email address',
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 20),

                // Password Field
                _buildFieldLabel(loc.translate('passwordLabel')),
                const SizedBox(height: 8),
                _buildTextField(
                  controller: _passwordController,
                  hintText: loc.isArabic
                      ? 'أدخل كلمة المرور'
                      : 'Enter password',
                  obscureText: true,
                ),
                const SizedBox(height: 20),

                // Confirm Password Field
                _buildFieldLabel(loc.translate('confirmPasswordLabel')),
                const SizedBox(height: 8),
                _buildTextField(
                  controller: _confirmPasswordController,
                  hintText: loc.isArabic
                      ? 'تأكيد كلمة المرور'
                      : 'Confirm password',
                  obscureText: true,
                ),
                const SizedBox(height: 24),

                // Checkboxes Section
                Row(
                  children: [
                    Checkbox(
                      value: state.registerAsMerchant,
                      onChanged: (val) {
                        ref
                            .read(authProvider.notifier)
                            .toggleRegisterAsMerchant(val ?? false);
                      },
                      activeColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      side: BorderSide(
                        color: context.palette.textMuted,
                        width: 1.5,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        loc.translate('registerAsMerchant'),
                        style: AppStyle.checkboxText,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                Row(
                  children: [
                    Checkbox(
                      value: state.agreeTerms,
                      onChanged: (val) {
                        ref
                            .read(authProvider.notifier)
                            .toggleAgreeTerms(val ?? false);
                      },
                      activeColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      side: BorderSide(
                        color: context.palette.textMuted,
                        width: 1.5,
                      ),
                    ),
                    Expanded(
                      child: Text.rich(
                        TextSpan(
                          children: loc.isArabic
                              ? [
                                  const TextSpan(text: 'أؤكد أني قرأت '),
                                  TextSpan(
                                    text: 'الشروط والأحكام',
                                    style: AppStyle.bodyTextBoldUnderline,
                                  ),
                                  const TextSpan(text: ' وأوافق عليها'),
                                ]
                              : [
                                  const TextSpan(
                                    text:
                                        'I confirm that I have read and agree to the ',
                                  ),
                                  TextSpan(
                                    text: 'Terms & Conditions',
                                    style: AppStyle.bodyTextBoldUnderline,
                                  ),
                                ],
                        ),
                        style: AppStyle.bodyText,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),

                signUpBtn,
                const SizedBox(height: 28),

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

  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(label, style: AppStyle.fieldLabel),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: context.palette.backgroundSubtle,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.palette.divider),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        style: AppStyle.inputText,
        onTapOutside: (event) => FocusManager.instance.primaryFocus?.unfocus(),
        decoration: InputDecoration(
          hintText: hintText,
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
    );
  }
}
