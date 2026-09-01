import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:sfa/core/localization/app_localizations.dart';
import 'package:sfa/core/widgets/primary_app_bar.dart';
import 'package:sfa/utils/Values.dart';
import 'package:sfa/utils/assets_constants.dart';
import 'package:sfa/utils/currency_formatter.dart';
import 'package:sfa/core/theme/app_palette.dart';
import 'package:sfa/utils/color_constants.dart';
import 'package:sfa/utils/app_style.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sfa/features/auth/providers/auth_provider.dart';
import 'package:sfa/features/profile/data/profile_models.dart';
import 'package:sfa/features/profile/providers/profile_data_provider.dart';
import 'package:sfa/features/profile/providers/profile_provider.dart';
import 'package:sfa/features/wallet/providers/wallet_providers.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final isAr = loc.isArabic;

    final Widget tileArrow = Directionality(
      textDirection: TextDirection.ltr,
      child: Icon(
        loc.isArabic ? Icons.arrow_back_ios_new : Icons.arrow_forward_ios,
        size: 14,
        color: context.palette.icon,
      ),
    );

    final profileAsync = ref.watch(profileDataProvider);
    final membershipAsync = ref.watch(membershipProvider);
    final balanceAsync = ref.watch(walletBalanceProvider);
    final state = ref.watch(profileProvider);

    // Profile Picture with Gold Border
    final Widget profileHeader = Column(
      children: [
        const SizedBox(height: 20),
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.primary, width: 2),
          ),
          child: CircleAvatar(
            radius: 54,
            backgroundColor: context.palette.surfaceMuted,
            backgroundImage: profileAsync.valueOrNull?.avatarUrl != null
                ? NetworkImage(profileAsync.value!.avatarUrl!)
                : null,
            child: profileAsync.valueOrNull?.avatarUrl == null
                ? Icon(Icons.person, size: 48, color: context.palette.textMuted)
                : null,
          ),
        ),
        const SizedBox(height: 12),
        profileAsync.when(
          loading: () => const SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          error: (error, _) => Text(
            error.toString(),
            style: AppStyle.subtitleDesc.copyWith(color: context.palette.textMuted),
          ),
          data: (profile) => Column(
            children: [
              Text(profile.name, style: AppStyle.welcomeTitle),
              if (profile.email != null) ...[
                const SizedBox(height: 4),
                Text(
                  profile.email!,
                  style: AppStyle.subtitleDesc.copyWith(color: context.palette.textMuted),
                ),
              ],
            ],
          ),
        ),
      ],
    );

    // Points Progress Card
    Widget buildPointsProgressCard(MembershipData? membership) {
      final tierLabel = membership?.tierName.resolve(isAr) ?? '';
      final pointsLabel = membership != null
          ? (isAr ? '${membership.pointsBalance} نقطة' : '${membership.pointsBalance} Points')
          : '';

      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.palette.surfaceAlt,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: context.palette.border, width: 1),
          boxShadow: [
            BoxShadow(color: context.palette.shadow, blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
              children: [
                Row(
                  children: [
                    SvgPicture.asset(
                      AssetsConstants.frame2,
                      width: 18,
                      colorFilter: ColorFilter.mode(AppColors.primary, BlendMode.srcIn),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      tierLabel,
                      style: AppStyle.fieldLabel.copyWith(color: context.palette.textPrimary, fontSize: 15),
                    ),
                  ],
                ),
                Text(pointsLabel, style: AppStyle.fieldLabel.copyWith(color: AppColors.primary, fontSize: 15)),
              ],
            ),
            const SizedBox(height: 12),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => ref.read(profileProvider.notifier).toggleTooltip(),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      height: 8,
                      decoration: BoxDecoration(
                        color: context.palette.surfaceMuted,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    FractionallySizedBox(
                      widthFactor: membership?.progress ?? 0,
                      child: Container(
                        height: 8,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [AppColors.primary.withValues(alpha: 0.6), AppColors.primary],
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Available Balance Card
    Widget buildBalanceCard() {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(color: AppColors.primary.withValues(alpha: 0.2), blurRadius: 12, offset: const Offset(0, 6)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Align(
              alignment: isAr ? Alignment.centerRight : Alignment.centerLeft,
              child: Text(
                isAr ? 'الرصيد المتاح' : 'Available Balance',
                style: GoogleFonts.cairo(color: Colors.white.withValues(alpha: 0.9), fontSize: 15, fontWeight: FontWeight.w500),
              ),
            ),
            const SizedBox(height: 4),
            Align(
              alignment: isAr ? Alignment.centerRight : Alignment.centerLeft,
              child: balanceAsync.when(
                loading: () => const SizedBox(
                  height: 32,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                ),
                error: (error, _) => Text(error.toString(), style: GoogleFonts.cairo(color: Colors.white)),
                data: (balance) => Text(
                  CurrencyFormatter.fromHalalas(balance.balanceFils, isAr: isAr),
                  style: GoogleFonts.cairo(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              height: 54,
              decoration: BoxDecoration(color: AppColors.textcolor, borderRadius: BorderRadius.circular(27)),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => context.push('/wallet'),
                  borderRadius: BorderRadius.circular(27),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          isAr ? 'سحب إلى الحساب البنكي' : 'Withdraw to bank account',
                          style: AppStyle.walletTransferButton,
                        ),
                        SvgPicture.asset(
                          AssetsConstants.landmark,
                          width: 18,
                          height: 18,
                          colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // AI Agent button
    final Widget aiAgentBtn = Container(
      height: 52,
      decoration: BoxDecoration(gradient: AppColors.primaryGradient, borderRadius: BorderRadius.circular(30)),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.push('/ai-chat'),
          borderRadius: BorderRadius.circular(30),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  AssetsConstants.astroid,
                  width: 18,
                  colorFilter: ColorFilter.mode(AppColors.textcolor, BlendMode.srcIn),
                ),
                const SizedBox(width: 8),
                Text(
                  loc.translate('aiAgent'),
                  style: AppStyle.buttonTextSecondary.copyWith(color: AppColors.textcolor),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    // Logout button
    final Widget logoutBtn = OutlinedButton(
      onPressed: () async {
        await ref.read(authProvider.notifier).logout();
        if (context.mounted) context.go('/login');
      },
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        side: BorderSide(color: AppColors.redcolor, width: 1.2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(loc.translate('logout'), style: AppStyle.buttonTextSecondary.copyWith(color: AppColors.redcolor)),
          SvgPicture.asset(
            AssetsConstants.logOut,
            width: 18,
            colorFilter: ColorFilter.mode(AppColors.redcolor, BlendMode.srcIn),
          ),
        ],
      ),
    );

    return Scaffold(
      appBar: PrimaryAppBar(title: loc.translate('myAccount')),
      backgroundColor: context.palette.backgroundSubtle,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: Values.horizontalPadding, vertical: 20),
          child: Directionality(
            textDirection: loc.isArabic ? TextDirection.rtl : TextDirection.ltr,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(child: profileHeader),
                const SizedBox(height: 24),

                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        membershipAsync.when(
                          loading: () => buildPointsProgressCard(null),
                          error: (error, _) => Text(
                            error.toString(),
                            style: AppStyle.bodyText.copyWith(color: context.palette.textMuted),
                          ),
                          data: (membership) => buildPointsProgressCard(membership),
                        ),
                        const SizedBox(height: 16),
                        buildBalanceCard(),
                      ],
                    ),
                    if (state.showTooltip)
                      Positioned(
                        left: loc.isArabic ? 24 : null,
                        right: loc.isArabic ? null : 24,
                        top: 74,
                        child: Stack(
                          alignment: Alignment.topCenter,
                          clipBehavior: Clip.none,
                          children: [
                            Positioned(
                              top: -4,
                              left: loc.isArabic ? 16 : null,
                              right: loc.isArabic ? null : 16,
                              child: Transform.rotate(
                                angle: 3.14159 / 4,
                                child: Container(
                                  width: 10,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    color: context.palette.surface,
                                    border: Border(
                                      top: BorderSide(color: context.palette.divider, width: 0.8),
                                      left: BorderSide(color: context.palette.divider, width: 0.8),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: context.palette.surface,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(color: context.palette.shadow, blurRadius: 8, offset: const Offset(0, 4)),
                                ],
                                border: Border.all(color: context.palette.divider, width: 0.8),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: loc.isArabic ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    membershipAsync.valueOrNull != null
                                        ? (isAr
                                            ? '${membershipAsync.value!.nextTierPoints} نقطة للترقية'
                                            : '${membershipAsync.value!.nextTierPoints} points to next tier')
                                        : '',
                                    style: GoogleFonts.cairo(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 24),

                _buildMenuTile(
                  icon: AssetsConstants.mapPin,
                  title: loc.translate('addresses'),
                  trailing: tileArrow,
                  onTap: () => context.push('/addresses'),
                ),
                _buildMenuTile(
                  icon: AssetsConstants.package,
                  title: loc.translate('previousOrders'),
                  trailing: tileArrow,
                  onTap: () => context.push('/previous-orders'),
                ),
                _buildMenuTile(
                  icon: AssetsConstants.heart,
                  title: loc.translate('favorites'),
                  trailing: tileArrow,
                  onTap: () => context.push('/favorites'),
                ),
                _buildMenuTile(
                  icon: AssetsConstants.moon,
                  title: loc.translate('darkMode'),
                  trailing: Switch(
                    value: state.darkMode,
                    activeTrackColor: AppColors.primary,
                    activeColor: Colors.white,
                    inactiveThumbColor: Colors.white,
                    inactiveTrackColor: Colors.grey.shade200,
                    trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
                    onChanged: (val) => ref.read(profileProvider.notifier).toggleDarkMode(val),
                  ),
                  onTap: () {},
                ),

                const SizedBox(height: 28),
                aiAgentBtn,
                const SizedBox(height: 16),
                logoutBtn,
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuTile({
    required String icon,
    required String title,
    required Widget trailing,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        ListTile(
          onTap: onTap,
          contentPadding: const EdgeInsets.symmetric(vertical: 4),
          leading: SvgPicture.asset(
            icon,
            width: 22,
            colorFilter: ColorFilter.mode(context.palette.icon, BlendMode.srcIn),
          ),
          title: Text(title, style: AppStyle.fieldLabel.copyWith(fontSize: 15)),
          trailing: trailing,
        ),
        Divider(height: 1, thickness: 0.5, color: context.palette.divider),
      ],
    );
  }
}
