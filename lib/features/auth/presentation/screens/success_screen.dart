import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:sfa/core/localization/app_localizations.dart';
import 'package:sfa/utils/assets_constants.dart';
import 'package:sfa/utils/color_constants.dart';
import 'package:sfa/utils/app_style.dart';

class SuccessScreen extends StatelessWidget {
  const SuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    final Widget enterAppBtn = ElevatedButton(
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
              loc.translate('enterApp'),
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

    return Scaffold(
      backgroundColor: AppColors.grey,
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
                const Divider(thickness: 1, color: Colors.black12),
                const SizedBox(height: 60),

                // Success Icon (Thumbs Up in Circle)
                Center(
                  child: SvgPicture.asset(
                    AssetsConstants.thumbsUp,
                    width: 180,
                    height: 180,
                  ),
                ),
                const SizedBox(height: 48),

                // Success Message
                Center(
                  child: Text(
                    loc.translate('accountCreated'),
                    style: AppStyle.welcomeTitle,
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 48),

                enterAppBtn,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
