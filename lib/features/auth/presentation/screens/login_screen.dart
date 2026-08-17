import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:sfa/core/localization/app_localizations.dart';
import 'package:sfa/utils/assets_constants.dart';
import 'package:sfa/utils/color_constants.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sfa/utils/app_style.dart';
import 'package:sfa/features/auth/bloc/auth_bloc.dart';
import 'package:sfa/features/auth/bloc/auth_event.dart';
import 'package:sfa/features/auth/bloc/auth_state.dart';
import 'package:sfa/features/auth/presentation/widgets/phone_input_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
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
              loc.translate('login'),
              textAlign: TextAlign.center,
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

    final Widget signUpBtn = OutlinedButton(
      onPressed: () {
        context.go('/signup');
      },
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        side: BorderSide(color: AppColors.textcolor, width: 1.2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
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
              transform: Matrix4.rotationY(math.pi), // Mirror horizontally so it points left (←)
              child: SvgPicture.asset(
                AssetsConstants.moveLeft,
                width: 18,
                colorFilter: ColorFilter.mode(
                  AppColors.textcolor,
                  BlendMode.srcIn,
                ),
              ),
            )
          else
            SvgPicture.asset(
              AssetsConstants.moveLeft,
              width: 18,
              colorFilter: ColorFilter.mode(
                AppColors.textcolor,
                BlendMode.srcIn,
              ),
            ),
        ],
      ),
    );

    return BlocProvider(
      create: (context) => AuthBloc(),
      child: Scaffold(
        backgroundColor: AppColors.grey, // Background color 0xffF6F6F6 from AppColors.grey
        body: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state.status == AuthStatus.success) {
              Fluttertoast.showToast(
                msg: loc.isArabic ? "تسجيل الدخول بنجاح!" : "Login Successful!",
                backgroundColor: AppColors.greencolor,
                textColor: Colors.white,
              );
              context.go('/dashboard');
            } else if (state.status == AuthStatus.failure && state.errorMessage != null) {
              Fluttertoast.showToast(
                msg: state.errorMessage!,
                backgroundColor: AppColors.redcolor,
                textColor: Colors.white,
              );
            }
          },
          builder: (context, state) {
            return SafeArea(
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
                      const Divider(thickness: 1, color: Colors.black12),
                      const SizedBox(height: 24),

                      // Welcome Subtitle Section
                      Text(
                        loc.translate('welcome'),
                        style: AppStyle.welcomeTitle,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        loc.translate('loginSubtitle'),
                        style: AppStyle.subtitleDesc,
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
                                side: BorderSide(color: AppColors.textcolor, width: 1.2),
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
                                side: BorderSide(color: AppColors.textcolor, width: 1.2),
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
                        style: AppStyle.inputLabelSub,
                      ),
                      const SizedBox(height: 16),

                      // Phone Input Field (Modular Component)
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
                            context.read<AuthBloc>().add(
                                  ToggleAuthModeEvent(isEmailMode: !state.isEmailMode),
                                );
                          },
                          child: Text(
                            loc.translate('switchEmail'),
                             style: AppStyle.switchTextLink,
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),

                      const Divider(thickness: 1, color: Colors.black12),
                      const SizedBox(height: 24),

                      // Create Account Pill Button
                      signUpBtn,
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
