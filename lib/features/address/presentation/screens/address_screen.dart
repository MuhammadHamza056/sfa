import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:sfa/core/localization/app_localizations.dart';
import 'package:sfa/utils/assets_constants.dart';
import 'package:sfa/utils/color_constants.dart';
import 'package:sfa/utils/app_style.dart';
import 'package:sfa/core/theme/app_palette.dart';
import '../../models/address.dart';
import '../../providers/address_provider.dart';

class AddressScreen extends ConsumerWidget {
  const AddressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context);
    final isAr = loc.isArabic;
    final addressesAsync = ref.watch(addressProvider);

    return Scaffold(
      backgroundColor: context.palette.background,
      body: Directionality(
        textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
        child: RefreshIndicator(
          onRefresh: () => ref.read(addressProvider.notifier).refresh(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                addressesAsync.when(
                  loading: () => const Padding(
                    padding: EdgeInsets.symmetric(vertical: 48),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (error, _) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 48),
                    child: Center(
                      child: Text(
                        error.toString(),
                        style: AppStyle.labelText.copyWith(color: context.palette.textMuted),
                      ),
                    ),
                  ),
                  data: (addresses) => addresses.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.symmetric(vertical: 48),
                          child: Center(
                            child: Text(
                              loc.translate('noAddressesYet'),
                              style: AppStyle.labelText.copyWith(color: context.palette.textMuted),
                            ),
                          ),
                        )
                      : ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: addresses.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 16),
                          itemBuilder: (context, index) {
                            return _buildAddressCard(context, ref, addresses[index]);
                          },
                        ),
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
                      onTap: () => context.push('/addresses/add'),
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
                            const Icon(Icons.add, color: Colors.white, size: 20),
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
      ),
    );
  }

  Widget _buildAddressCard(
    BuildContext context,
    WidgetRef ref,
    Address address,
  ) {
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
              border: Border.all(color: AppColors.primary, width: 1),
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
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        address.name,
                        style: GoogleFonts.cairo(
                          color: context.palette.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (address.isDefault) ...[
                      const SizedBox(width: 6),
                      Icon(Icons.star, size: 14, color: AppColors.primary),
                    ] else ...[
                      const SizedBox(width: 6),
                      GestureDetector(
                        onTap: () =>
                            ref.read(addressProvider.notifier).setDefaultAddress(address.id),
                        child: Icon(Icons.star_border, size: 14, color: context.palette.textMuted),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  address.line1,
                  style: AppStyle.subtitleDesc.copyWith(
                    color: context.palette.textMuted,
                    fontSize: 13,
                  ),
                ),
                Text(
                  address.line2,
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
                      address.phoneNumber,
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
                onTap: () => context.push('/addresses/edit', extra: address),
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
                onTap: () => ref.read(addressProvider.notifier).removeAddress(address.id),
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
