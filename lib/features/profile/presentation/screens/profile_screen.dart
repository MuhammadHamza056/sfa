import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:sfa/core/localization/app_localizations.dart';
import 'package:sfa/utils/assets_constants.dart';
import 'package:sfa/utils/color_constants.dart';
import 'package:sfa/utils/app_style.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sfa/features/profile/bloc/profile_bloc.dart';
import 'package:sfa/features/profile/bloc/profile_event.dart';
import 'package:sfa/features/profile/bloc/profile_state.dart';
import 'package:sfa/features/dashboard/bloc/dashboard_bloc.dart';
import 'package:sfa/features/dashboard/bloc/dashboard_event.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    final Widget tileArrow = Directionality(
      textDirection: TextDirection.ltr,
      child: Icon(
        loc.isArabic ? Icons.arrow_back_ios_new : Icons.arrow_forward_ios,
        size: 14,
        color: AppColors.textcolor,
      ),
    );

    // Profile Picture with Gold Border
    final Widget profileHeader = Column(
      children: [
        const SizedBox(height: 20),
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.primary, width: 2),
          ),
          child: const CircleAvatar(
            radius: 54,
            backgroundImage: NetworkImage(
              'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150',
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          loc.isArabic ? 'سارة عبد العزيز' : 'Sara Abdulaziz',
          style: AppStyle.welcomeTitle,
        ),
        const SizedBox(height: 4),
        Text(
          'sara.abdulaziz@example.com',
          style: AppStyle.subtitleDesc.copyWith(color: AppColors.text2color),
        ),
      ],
    );

    // Points Progress Card
    Widget buildPointsProgressCard(BuildContext context, ProfileState state) {
      final isAr = loc.isArabic;
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.membershipBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.primary_25,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Row 1: Bronze Membership (Right in RTL) and Points (Left in RTL)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (isAr) ...[
                  Row(
                    children: [
                      SvgPicture.asset(
                        AssetsConstants.frame2,
                        width: 18,
                        colorFilter: ColorFilter.mode(
                          AppColors.primary,
                          BlendMode.srcIn,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'العضوية البرونزية',
                        style: AppStyle.fieldLabel.copyWith(
                          color: AppColors.textcolor,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '520 نقطة',
                    style: AppStyle.fieldLabel.copyWith(
                      color: AppColors.primary,
                      fontSize: 15,
                    ),
                  ),
                ] else ...[
                  Row(
                    children: [
                      SvgPicture.asset(
                        AssetsConstants.frame2,
                        width: 18,
                        colorFilter: ColorFilter.mode(
                          AppColors.primary,
                          BlendMode.srcIn,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Bronze Membership',
                        style: AppStyle.fieldLabel.copyWith(
                          color: AppColors.textcolor,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '520 Points',
                    style: AppStyle.fieldLabel.copyWith(
                      color: AppColors.primary,
                      fontSize: 15,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 12),
            // Row 2: Progress Indicator (Tappable)
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                context.read<ProfileBloc>().add(const ToggleTooltipEvent());
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    // Progress Fill (520 / 1000 = 52%)
                    FractionallySizedBox(
                      widthFactor: 0.52,
                      child: Container(
                        height: 8,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primary.withValues(alpha: 0.6),
                              AppColors.primary,
                            ],
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
      final isAr = loc.isArabic;
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.2),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Align(
              alignment: isAr ? Alignment.centerRight : Alignment.centerLeft,
              child: Text(
                isAr ? 'الرصيد المتاح' : 'Available Balance',
                style: GoogleFonts.cairo(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                if (isAr) ...[
                  Text(
                    '1478.00',
                    style: GoogleFonts.cairo(
                      color: Colors.white,
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'ر.س.',
                    style: GoogleFonts.cairo(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ] else ...[
                  Text(
                    '1478.00',
                    style: GoogleFonts.cairo(
                      color: Colors.white,
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'SAR',
                    style: GoogleFonts.cairo(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 20),
            Container(
              height: 54,
              decoration: BoxDecoration(
                color: AppColors.textcolor,
                borderRadius: BorderRadius.circular(27),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    // Handle withdrawal
                  },
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
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            context.push('/ai-chat');
          },
          borderRadius: BorderRadius.circular(30),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  AssetsConstants.astroid,
                  width: 18,
                  colorFilter: ColorFilter.mode(
                    AppColors.textcolor,
                    BlendMode.srcIn,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  loc.translate('aiAgent'),
                  style: AppStyle.buttonTextSecondary,
                ),
              ],
            ),
          ),
        ),
      ),
    );

    // Logout button
    final Widget logoutBtn = OutlinedButton(
      onPressed: () {
        context.go('/login');
      },
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        side: BorderSide(color: AppColors.redcolor, width: 1.2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            loc.translate('logout'),
            style: AppStyle.buttonTextSecondary.copyWith(color: AppColors.redcolor),
          ),
          SvgPicture.asset(
            AssetsConstants.logOut,
            width: 18,
            colorFilter: ColorFilter.mode(AppColors.redcolor, BlendMode.srcIn),
          ),
        ],
      ),
    );

    return BlocProvider(
      create: (context) => ProfileBloc(),
      child: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
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
                      Center(child: profileHeader),
                      const SizedBox(height: 24),

                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              buildPointsProgressCard(context, state),
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
                                          color: Colors.white,
                                          border: Border(
                                            top: BorderSide(color: Colors.grey.shade200, width: 0.8),
                                            left: BorderSide(color: Colors.grey.shade200, width: 0.8),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: 0.08),
                                          blurRadius: 8,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                      border: Border.all(
                                        color: Colors.grey.shade200,
                                        width: 0.8,
                                      ),
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment: loc.isArabic ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          loc.isArabic ? '1000 نقطة' : '1000 Points',
                                          style: GoogleFonts.cairo(
                                            color: AppColors.primary,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          loc.isArabic ? 'العضوية الذهبية' : 'Golden Membership',
                                          style: GoogleFonts.cairo(
                                            color: AppColors.textcolor,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
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

                      // Menu items
                      _buildMenuTile(
                        icon: AssetsConstants.circleUser2,
                        title: loc.translate('accountManagement'),
                        trailing: tileArrow,
                        onTap: () {},
                      ),
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
                        onTap: () {
                          context.read<DashboardBloc>().add(const ChangeTabEvent(8));
                        },
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
                          onChanged: (val) {
                            context.read<ProfileBloc>().add(ToggleDarkModeEvent(val));
                          },
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
        },
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
          leading: SvgPicture.asset(icon, width: 22),
          title: Text(title, style: AppStyle.fieldLabel.copyWith(fontSize: 15)),
          trailing: trailing,
        ),
        Divider(
          height: 1,
          thickness: 0.5,
          color: AppColors.text2color_40,
        ),
      ],
    );
  }
}
