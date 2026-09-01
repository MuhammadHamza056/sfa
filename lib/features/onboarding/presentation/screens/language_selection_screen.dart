import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:sfa/core/hive_services.dart';
import 'package:sfa/core/localization/app_localizations.dart';
import 'package:sfa/utils/assets_constants.dart';
import 'package:sfa/utils/color_constants.dart';
import 'package:sfa/utils/app_style.dart';

class LanguageSelectionScreen extends StatelessWidget {
  const LanguageSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.textcolor, // Deep burgundy background (#451425)
      body: Stack(
        children: [
          // Background static watermark text filling full screen without left/right padding and with lighter top lines & darker bottom lines
          Positioned.fill(
            child: SingleChildScrollView(
              physics: const NeverScrollableScrollPhysics(),
              child: Column(
                children: List.generate(
                  12,
                  (index) {
                    final double lineOpacity = (0.02 + (index * 0.006)).clamp(0.02, 0.09);
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                        index % 2 == 0 ? 'SAUDI FASHION' : 'FASHION SAUDI',
                        textAlign: TextAlign.center,
                        style: AppStyle.watermarkBase.copyWith(
                          color: Colors.black.withValues(alpha: lineOpacity),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),

          // Main Content Layer
          SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),

                // Center Union / SFA Logo
                Image.asset(
                  AssetsConstants.unionPng,
                  width: 220,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'SFA',
                        style: AppStyle.logoTitleLarge,
                      ),
                      Text(
                        'SAUDI FASHION',
                        style: AppStyle.logoSubtitleLarge,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 80),

                // Language Selection Pill Buttons (English on left with arrow, Arabic on right with arrow)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: [
                      // English Button (Left) - uses move-left.svg on the left
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            localeNotifier.setLocale(const Locale('en'));
                            SecureStorage.putLanguageSelected(true);
                            context.go('/onboarding');
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                            side: BorderSide(
                              color: AppColors.primary,
                              width: 1.2,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SvgPicture.asset(
                                AssetsConstants.moveLeft,
                                width: 18,
                                colorFilter: ColorFilter.mode(
                                  AppColors.primary,
                                  BlendMode.srcIn,
                                ),
                              ),
                              Text(
                                'English',
                                style: AppStyle.buttonTextLang,
                              ),
                              const SizedBox(width: 4),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Arabic Button (Right) - uses move-left.svg rotated 180 degrees on the right
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            localeNotifier.setLocale(const Locale('ar'));
                            SecureStorage.putLanguageSelected(true);
                            context.go('/onboarding');
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                            side: BorderSide(
                              color: AppColors.primary,
                              width: 1.2,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const SizedBox(width: 4),
                              Text(
                                'العربية',
                                style: AppStyle.buttonTextLang,
                              ),
                              Transform.rotate(
                                angle: math.pi,
                                child: SvgPicture.asset(
                                  AssetsConstants.moveLeft,
                                  width: 18,
                                  colorFilter: ColorFilter.mode(
                                    AppColors.primary,
                                    BlendMode.srcIn,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
