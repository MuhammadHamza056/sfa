import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sfa/utils/color_constants.dart';

class AppStyle {
  BuildContext context;
  AppStyle(this.context);

  static TextStyle loginPageTitle = GoogleFonts.cairo(
    fontSize: 48,
    fontWeight: FontWeight.w600,
    color: AppColors.primary,
  );

  static TextStyle bodyText = GoogleFonts.cairo(
    fontSize: 15,
    fontWeight: FontWeight.w300,
    color: AppColors.textcolor,
  );

  static TextStyle bodyTextBoldUnderline = GoogleFonts.cairo(
    fontSize: 15,
    color: AppColors.textcolor,
    fontWeight: FontWeight.w600,
    decoration: TextDecoration.underline,
  );

  static TextStyle logoTitleLarge = GoogleFonts.cairo(
    fontSize: 72,
    fontWeight: FontWeight.w400,
    color: AppColors.primary,
    letterSpacing: 4.0,
  );

  static TextStyle logoSubtitleLarge = GoogleFonts.cairo(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.primary,
    letterSpacing: 6.0,
  );

  static TextStyle logoTitleSmall = GoogleFonts.cairo(
    fontSize: 36,
    fontWeight: FontWeight.w400,
    color: AppColors.primary,
    letterSpacing: 2.0,
  );

  static TextStyle logoSubtitleSmall = GoogleFonts.cairo(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    color: AppColors.primary,
    letterSpacing: 3.0,
  );

  static TextStyle screenTitle = GoogleFonts.cairo(
    fontSize: 26,
    fontWeight: FontWeight.bold,
    color: AppColors.textcolor,
  );

  static TextStyle welcomeTitle = GoogleFonts.cairo(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: AppColors.textcolor,
  );

  static TextStyle subtitleDesc = GoogleFonts.cairo(
    fontSize: 13,
    color: AppColors.textcolor.withValues(alpha: 0.7),
    height: 1.5,
  );

  static TextStyle buttonTextSocial = GoogleFonts.cairo(
    color: AppColors.textcolor,
    fontWeight: FontWeight.w400,
    fontSize: 18,
  );

  static TextStyle buttonTextPrimary = GoogleFonts.cairo(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  static TextStyle buttonTextSecondary = GoogleFonts.cairo(
    fontSize: 16,
    color: AppColors.textcolor,
    fontWeight: FontWeight.bold,
  );

  static TextStyle inputLabelSub = GoogleFonts.cairo(
    fontSize: 13,
    color: AppColors.textcolor.withValues(alpha: 0.7),
  );

  static TextStyle switchTextLink = GoogleFonts.cairo(
    color: AppColors.textcolor,
    fontWeight: FontWeight.bold,
    fontSize: 13,
    decoration: TextDecoration.underline,
  );

  static TextStyle fieldLabel = GoogleFonts.cairo(
    fontSize: 14,
    fontWeight: FontWeight.bold,
    color: AppColors.textcolor,
  );

  static TextStyle checkboxText = GoogleFonts.cairo(
    fontSize: 15,
    fontWeight: FontWeight.w300,
    color: AppColors.textcolor,
  );

  static TextStyle inputText = GoogleFonts.cairo(
    color: AppColors.textcolor,
    fontSize: 15,
  );

  static TextStyle inputHint = GoogleFonts.cairo(
    color: AppColors.textcolor.withValues(alpha: 0.4),
    fontSize: 14,
  );

  static TextStyle onboardingTitle = GoogleFonts.cairo(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: Colors.white,
    height: 1.3,
  );

  static TextStyle onboardingDesc = GoogleFonts.cairo(
    fontSize: 13,
    color: Colors.grey.shade300,
    height: 1.6,
  );

  static TextStyle buttonTextHome = GoogleFonts.cairo(
    fontSize: 15,
    color: AppColors.primary,
    fontWeight: FontWeight.bold,
  );

  static TextStyle watermarkBase = GoogleFonts.cairo(
    fontSize: 52,
    fontWeight: FontWeight.w900,
    letterSpacing: 2.0,
  );

  static TextStyle buttonTextLang = GoogleFonts.cairo(
    fontSize: 16,
    color: AppColors.primary,
    fontWeight: FontWeight.w500,
  );

  // ── Section / content tokens ──────────────────────────────────────────────

  static TextStyle sectionHeader = GoogleFonts.cairo(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: AppColors.textcolor,
  );

  static TextStyle labelText = GoogleFonts.cairo(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textcolor,
  );

  static TextStyle labelTextMuted = GoogleFonts.cairo(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textcolor,
  );

  static TextStyle valueText = GoogleFonts.cairo(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: AppColors.textcolor,
  );

  static TextStyle valuePrimary = GoogleFonts.cairo(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: AppColors.primary,
  );

  static TextStyle timelineTitle = GoogleFonts.cairo(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: AppColors.textcolor,
  );

  static TextStyle timelineSubtitle = GoogleFonts.cairo(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.textcolor,
  );

  static TextStyle cardTitle = GoogleFonts.cairo(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: AppColors.textcolor,
  );

  static TextStyle cardSubtitle = GoogleFonts.cairo(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: AppColors.primary,
  );

  static TextStyle chipLabel = GoogleFonts.cairo(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: AppColors.textcolor,
  );

  static TextStyle navLabel = GoogleFonts.cairo(
    fontSize: 12,
    fontWeight: FontWeight.bold,
    color: AppColors.textcolor,
  );

  static TextStyle infoChipText = GoogleFonts.cairo(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: AppColors.textcolor,
  );

  static TextStyle productTitle = GoogleFonts.cairo(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: AppColors.textcolor,
  );

  static TextStyle productPrice = GoogleFonts.cairo(
    fontSize: 13,
    fontWeight: FontWeight.bold,
    color: AppColors.primary,
  );

  static TextStyle bannerTitle = GoogleFonts.cairo(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  static TextStyle bannerSubtitle = GoogleFonts.cairo(
    fontSize: 14,
    color: Colors.white70,
  );

  static TextStyle drawerItemLabel = GoogleFonts.cairo(
    fontSize: 15,
    fontWeight: FontWeight.w500,
    color: AppColors.textcolor,
  );

  static TextStyle drawerLanguageTag = GoogleFonts.cairo(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.primary,
  );

  static TextStyle headerHeading = GoogleFonts.cairo(
    fontSize: 17,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  static TextStyle tabSelected = GoogleFonts.cairo(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: Colors.white,
  );

  static TextStyle tabUnselected = GoogleFonts.cairo(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: Colors.white,
  );

  static TextStyle categoryLabel = GoogleFonts.cairo(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: Colors.white,
  );

  static TextStyle brandCardLabel = GoogleFonts.cairo(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  static TextStyle promoBannerTitle = GoogleFonts.cairo(
    fontSize: 26,
    fontWeight: FontWeight.w800,
    color: Colors.white,
    height: 1.2,
  );

  static TextStyle promoBannerSubtitle = GoogleFonts.cairo(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: AppColors.primary,
    height: 1.3,
  );

  static TextStyle promoBannerBrand = GoogleFonts.cairo(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: Colors.white70,
  );

  static TextStyle searchHint = GoogleFonts.cairo(
    fontSize: 13,
    color: Colors.white,
  );

  static TextStyle paymentOption = GoogleFonts.cairo(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: AppColors.textcolor,
  );

  static TextStyle regionChip = GoogleFonts.cairo(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.textcolor,
  );

  static TextStyle pricingLabel = GoogleFonts.cairo(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textcolor,
  );

  static TextStyle pricingLabelLight = GoogleFonts.cairo(
    fontSize: 15,
    fontWeight: FontWeight.w300,
    color: AppColors.textcolor,
  );

  static TextStyle pricingValue = GoogleFonts.cairo(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: AppColors.textcolor,
  );

  static TextStyle notificationTitle = GoogleFonts.cairo(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textcolor,
  );

  static TextStyle notificationBody = GoogleFonts.cairo(
    fontSize: 13,
    fontWeight: FontWeight.w300,
    color: AppColors.textcolor,
  );

  // ── Wallet / Refund Screen Styles ──────────────────────────────────────────
  static TextStyle walletBalanceLabel = GoogleFonts.cairo(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: Colors.white.withValues(alpha: 0.9),
  );

  static TextStyle walletBalanceAmount = GoogleFonts.cairo(
    fontSize: 42,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  static TextStyle walletSarLabel = GoogleFonts.cairo(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: Colors.white.withValues(alpha: 0.9),
  );

  static TextStyle walletTransferButton = GoogleFonts.cairo(
    fontSize: 14,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  static TextStyle walletSectionHeader = GoogleFonts.cairo(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AppColors.textcolor,
  );

  static TextStyle walletTxAmount = GoogleFonts.cairo(
    fontSize: 15,
    fontWeight: FontWeight.w600,
  );

  static TextStyle walletTxTitle = GoogleFonts.cairo(
    fontSize: 15,
    fontWeight: FontWeight.w300,
    color: AppColors.textcolor,
  );

  static TextStyle walletTxDate = GoogleFonts.cairo(
    fontSize: 15,
    fontWeight: FontWeight.w300,
    color: Colors.grey.shade500,
  );

  static TextStyle walletViewAll = GoogleFonts.cairo(
    fontSize: 15,
    fontWeight: FontWeight.bold,
    color: const Color(0xFFC79A52),
  );
}
