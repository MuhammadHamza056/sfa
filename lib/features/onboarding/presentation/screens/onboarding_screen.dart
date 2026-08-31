import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:sfa/core/localization/app_localizations.dart';
import 'package:sfa/utils/assets_constants.dart';
import 'package:sfa/utils/color_constants.dart';
import 'package:sfa/utils/app_style.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sfa/features/onboarding/providers/onboarding_provider.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final Widget loginBtn = Expanded(
      flex: 6,
      child: ElevatedButton(
        onPressed: () => context.go('/login'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SizedBox(width: 4),
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
                transform: Matrix4.rotationY(
                  math.pi,
                ), // Mirror horizontally so it points left (←)
                child: SvgPicture.asset(
                  AssetsConstants.moveLeft,
                  width: 16,
                  colorFilter: const ColorFilter.mode(
                    Colors.white,
                    BlendMode.srcIn,
                  ),
                ),
              )
            else
              SvgPicture.asset(
                AssetsConstants.moveLeft,
                width: 16,
                colorFilter: const ColorFilter.mode(
                  Colors.white,
                  BlendMode.srcIn,
                ),
              ),
          ],
        ),
      ),
    );

    final Widget homeBtn = Expanded(
      flex: 5,
      child: OutlinedButton(
        onPressed: () => context.go('/dashboard'),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          side: BorderSide(color: AppColors.primary, width: 1.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              AssetsConstants.house,
              width: 18,
              colorFilter: ColorFilter.mode(AppColors.primary, BlendMode.srcIn),
            ),
            const SizedBox(width: 6),
            Text(loc.translate('home'), style: AppStyle.buttonTextHome),
          ],
        ),
      ),
    );

    final List<Widget> buttonsList = [
      homeBtn,
      const SizedBox(width: 12),
      loginBtn,
    ];

    final state = ref.watch(onboardingProvider);

    return Scaffold(
      backgroundColor: AppColors.textcolor,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),
            // Header SFA Logo
            Center(
              child: Image.asset(
                AssetsConstants.unionPng,
                width: 140,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('SFA', style: AppStyle.logoTitleSmall),
                    Text('SAUDI FASHION', style: AppStyle.logoSubtitleSmall),
                  ],
                ),
              ),
            ),

            // PageView content (2 slides localized)
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  ref.read(onboardingProvider.notifier).changePage(index);
                },
                children: [
                  // Slide 1: Saudi Vision 2030 (vector.png)
                  _buildOnboardingPage(
                    imagePath: AssetsConstants.vectorPng,
                    title: loc.translate('vision2030Title'),
                    description: loc.translate('vision2030Desc'),
                  ),

                  // Slide 2: Cultural Arts Heritage (Group.png)
                  _buildOnboardingPage(
                    imagePath: AssetsConstants.groupPng,
                    title: loc.translate('cultureArtsTitle'),
                    description: loc.translate('cultureArtsDesc'),
                  ),
                ],
              ),
            ),

            // Page Indicator Dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                2,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: state.currentPage == index ? 24 : 8,
                  height: 6,
                  decoration: BoxDecoration(
                    color: state.currentPage == index
                        ? AppColors.primary
                        : AppColors.primary.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 28),

            // Bottom Action Buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(children: buttonsList),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildOnboardingPage({
    required String imagePath,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),

          // Slide Graphic Image (Vector.png or Group.png)
          Image.asset(
            imagePath,
            height: 210,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) =>
                Icon(Icons.auto_awesome, size: 100, color: AppColors.primary),
          ),
          const SizedBox(height: 28),

          // Title
          Text(
            title,
            textAlign: TextAlign.center,
            style: AppStyle.onboardingTitle,
          ),
          const SizedBox(height: 14),

          // Description
          Text(
            description,
            textAlign: TextAlign.center,
            style: AppStyle.onboardingDesc,
          ),
          const Spacer(),
        ],
      ),
    );
  }
}
