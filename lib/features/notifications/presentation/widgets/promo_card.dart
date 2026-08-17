import 'package:flutter/material.dart';
import 'package:sfa/utils/app_style.dart';
import 'package:sfa/utils/assets_constants.dart';

class NationalDayHeroBanner extends StatelessWidget {
  final VoidCallback? onTap;

  const NationalDayHeroBanner({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 180,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        image: const DecorationImage(
          image: AssetImage(AssetsConstants.nationalDayBanner),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              Colors.black.withValues(alpha: 0.6),
              Colors.black.withValues(alpha: 0.1),
            ],
            begin: Alignment.bottomRight,
            end: Alignment.topLeft,
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              'إصدار محدود',
              style: AppStyle.fieldLabel.copyWith(
                color: const Color(0xFFC5A880),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'مجموعة اليوم الوطني',
              style: AppStyle.welcomeTitle.copyWith(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: onTap,
              child: Text(
                'تسوق الآن',
                style: AppStyle.buttonTextSecondary.copyWith(
                  color: Colors.white,
                  fontSize: 14,
                  decoration: TextDecoration.underline,
                  decorationColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PromoCard extends StatelessWidget {
  final String badgeText;
  final String titleText;
  final Color backgroundColor;
  final Color badgeColor;
  final Color titleColor;
  final Border? border;

  const PromoCard({
    super.key,
    required this.badgeText,
    required this.titleText,
    required this.backgroundColor,
    required this.badgeColor,
    required this.titleColor,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 170,
      height: 100,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: border,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            badgeText,
            style: AppStyle.subtitleDesc.copyWith(
              color: badgeColor,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            titleText,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppStyle.fieldLabel.copyWith(
              color: titleColor,
              fontSize: 13,
              fontWeight: FontWeight.bold,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}
