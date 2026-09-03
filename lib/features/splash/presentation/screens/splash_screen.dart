import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sfa/core/hive_services.dart';
import 'package:sfa/utils/color_constants.dart';
import 'package:sfa/utils/assets_constants.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        if (SecureStorage.isAuthenticated) {
          context.go('/home');
        } else {
          context.go(SecureStorage.getLanguageSelected() ? '/onboarding' : '/language');
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.textcolor, // Deep burgundy color 0xff451425
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                AssetsConstants.unionPng,
                width: 220,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'SFA',
                      style: TextStyle(
                        fontSize: 72,
                        fontWeight: FontWeight.w400,
                        color: AppColors.primary,
                        fontFamily: 'Serif',
                        letterSpacing: 4.0,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'SAUDI FASHION',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: AppColors.primary,
                        letterSpacing: 6.0,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'APPLICATION',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: AppColors.primary,
                        letterSpacing: 4.0,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
