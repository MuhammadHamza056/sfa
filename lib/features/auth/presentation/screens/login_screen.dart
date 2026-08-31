import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:sfa/core/localization/app_localizations.dart';
import 'package:sfa/utils/assets_constants.dart';
import 'package:sfa/utils/color_constants.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sfa/utils/app_style.dart';
import 'package:sfa/features/auth/providers/auth_provider.dart';
import 'package:sfa/features/auth/presentation/widgets/phone_input_field.dart';
import 'package:sfa/core/theme/app_palette.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    final Widget loginBtn = ElevatedButton(
      onPressed: () {
        context.go('/dashboard');
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        elevation: 0,
      ),
      child: Row(
        children: [
          const SizedBox(width: 18),
          Expanded(
            child: Text(
              loc.translate('login'),
              textAlign: TextAlign.center,
              style: AppStyle.buttonTextPrimary,
            ),
          ),
          if (loc.isArabic)
            Transform(
              alignment: Alignment.center,
              transform: Matrix4.rotationY(math.pi),
              // Mirror horizontally so it points left (←)
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

    final Widget signUpBtn = OutlinedButton(
      onPressed: () {
        context.go('/signup');
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
              loc.translate('signup'),
              textAlign: TextAlign.center,
              style: AppStyle.buttonTextSecondary,
            ),
          ),
          if (loc.isArabic)
            Transform(
              alignment: Alignment.center,
              transform: Matrix4.rotationY(math.pi),
              // Mirror horizontally so it points left (←)
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

    ref.listen<AuthState>(authProvider, (previous, state) {
      if (state.status == AuthStatus.success) {
        Fluttertoast.showToast(
          msg: loc.isArabic ? "تسجيل الدخول بنجاح!" : "Login Successful!",
          backgroundColor: AppColors.greencolor,
          textColor: Colors.white,
        );
        context.go('/dashboard');
      } else if (state.status == AuthStatus.failure &&
          state.errorMessage != null) {
        Fluttertoast.showToast(
          msg: state.errorMessage!,
          backgroundColor: AppColors.redcolor,
          textColor: Colors.white,
        );
      }
    });
    final state = ref.watch(authProvider);

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
                    loc.translate('login'),
                    style: AppStyle.screenTitle,
                  ),
                ),
                const SizedBox(height: 16),
                Divider(thickness: 1, color: context.palette.divider),
                const SizedBox(height: 24),

                // Welcome Subtitle Section
                Text(loc.translate('welcome'), style: AppStyle.welcomeTitle),
                const SizedBox(height: 8),
                Text(
                  loc.translate('loginSubtitle'),
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
                  loc.translate('orPhoneLogin'),
                  style: AppStyle.inputLabelSub.copyWith(
                    color: context.palette.textPrimary.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 16),

                // Phone Input Field (Modular Component)
                if (state.isEmailMode)
                  _emailField()
                else
                  PhoneInputField(controller: _phoneController),
                const SizedBox(height: 28),

                // Submit Login Button
                state.status == AuthStatus.loading
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
                    : loginBtn,
                const SizedBox(height: 20),

                // Switch to Email Login Link
                Center(
                  child: TextButton(
                    onPressed: () {
                      ref
                          .read(authProvider.notifier)
                          .toggleAuthMode(!state.isEmailMode);
                    },
                    child: Text(
                      loc.translate('switchEmail'),
                      style: AppStyle.switchTextLink,
                    ),
                  ),
                ),
                const SizedBox(height: 28),

                Divider(thickness: 1, color: context.palette.divider),
                const SizedBox(height: 24),

                // Create Account Pill Button
                signUpBtn,
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _emailField() {
    final loc = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: .start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(loc.translate("emailLabel"), style: AppStyle.fieldLabel),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: context.palette.backgroundSubtle,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: context.palette.divider),
          ),
          child: TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            style: AppStyle.inputText,
            onTapOutside: (event) =>
                FocusManager.instance.primaryFocus?.unfocus(),
            decoration: InputDecoration(
              hintText: loc.isArabic
                  ? 'أدخل البريد الإلكتروني'
                  : 'Enter email address',
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
      ],
    );
  }
}
