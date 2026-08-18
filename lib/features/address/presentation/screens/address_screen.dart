import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sfa/core/localization/app_localizations.dart';
import 'package:sfa/utils/assets_constants.dart';
import 'package:sfa/utils/color_constants.dart';
import 'package:sfa/utils/app_style.dart';
import 'package:sfa/core/theme/app_palette.dart';

class AddressScreen extends StatefulWidget {
  const AddressScreen({super.key});

  @override
  State<AddressScreen> createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen> {
  // Mock data for addresses
  final List<Map<String, String>> _addresses = [
    {
      'titleAr': 'أحمد عبد الله',
      'titleEn': 'Ahmed Abdullah',
      'line1Ar': 'شارع التحلية، مبنى 45، شقة 16',
      'line1En': 'Tahlia Street, Building 45, Apt 16',
      'line2Ar': 'الرياض، المملكة العربية السعودية',
      'line2En': 'Riyadh, Kingdom of Saudi Arabia',
      'phone': '+966 2667990',
    },
    {
      'titleAr': 'أحمد عبد الله (العمل)',
      'titleEn': 'Ahmed Abdullah (Work)',
      'line1Ar': 'طريق الملك فهد، برج الفيصلية، الطابق 15',
      'line1En': 'King Fahd Road, Al Faisaliah Tower, Floor 15',
      'line2Ar': 'الرياض، المملكة العربية السعودية',
      'line2En': 'Riyadh, Kingdom of Saudi Arabia',
      'phone': '+966 2667990',
    }
  ];

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final isAr = loc.isArabic;

    return Scaffold(
      backgroundColor: context.palette.background,
      body: Directionality(
        textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _addresses.length,
                separatorBuilder: (context, index) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final item = _addresses[index];
                  return _buildAddressCard(item, isAr);
                },
              ),
              const SizedBox(height: 24),
              // Button: إضافة عنوان جديد / Add New Address (inline under list)
              Container(
                height: 54,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(27),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      // Add new address action
                    },
                    borderRadius: BorderRadius.circular(27),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            loc.translate('addAddress'),
                            style: GoogleFonts.cairo(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Icon(
                            Icons.add,
                            color: Colors.white,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddressCard(Map<String, String> address, bool isAr) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.palette.surfaceMuted,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Location PIN indicator (Start: Right in RTL, Left in LTR)
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: context.palette.background,
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.primary,
                width: 1,
              ),
            ),
            child: Center(
              child: SvgPicture.asset(
                AssetsConstants.mapPin,
                width: 20,
                colorFilter: ColorFilter.mode(
                  AppColors.primary,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // 2. Middle part: Address Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isAr ? address['titleAr']! : address['titleEn']!,
                  style: GoogleFonts.cairo(
                    color: context.palette.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isAr ? address['line1Ar']! : address['line1En']!,
                  style: AppStyle.subtitleDesc.copyWith(
                    color: context.palette.textMuted,
                    fontSize: 13,
                  ),
                ),
                Text(
                  isAr ? address['line2Ar']! : address['line2En']!,
                  style: AppStyle.subtitleDesc.copyWith(
                    color: context.palette.textMuted,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    SvgPicture.asset(
                      AssetsConstants.phone,
                      width: 14,
                      colorFilter: ColorFilter.mode(
                        AppColors.primary,
                        BlendMode.srcIn,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      address['phone']!,
                      style: GoogleFonts.cairo(
                        color: context.palette.textMuted,
                        fontSize: 13,
                      ),
                      textDirection: TextDirection.ltr,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // 3. Actions part (End: Left in RTL, Right in LTR)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () {
                  // Edit action
                },
                child: SvgPicture.asset(
                  AssetsConstants.edit,
                  width: 20,
                  colorFilter: ColorFilter.mode(
                    context.palette.textPrimary,
                    BlendMode.srcIn,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () {
                  // Delete action
                },
                child: SvgPicture.asset(
                  AssetsConstants.trash2,
                  width: 20,
                  colorFilter: ColorFilter.mode(
                    context.palette.icon,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
