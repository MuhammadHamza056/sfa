import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sfa/core/localization/app_localizations.dart';
import 'package:sfa/utils/app_style.dart';
import 'package:sfa/utils/assets_constants.dart';
import 'package:sfa/utils/color_constants.dart';
import 'package:sfa/core/theme/app_palette.dart';
import 'package:sfa/core/widgets/primary_app_bar.dart';

class AIChatScreen extends StatefulWidget {
  const AIChatScreen({super.key});

  @override
  State<AIChatScreen> createState() => _AIChatScreenState();
}

class _AIChatScreenState extends State<AIChatScreen> {
  final TextEditingController _messageController = TextEditingController();

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final isAr = loc.isArabic;

    // Suggestions List
    final List<Map<String, dynamic>> suggestions = [
      {
        'text': loc.translate('suggestionGiftWife'),
        'icon': AssetsConstants.gift,
      },
      {
        'text': loc.translate('suggestionSummerOutfits'),
        'icon': AssetsConstants.parasol,
      },
      {
        'text': loc.translate('suggestionGeneral'),
        'icon': AssetsConstants.gift,
      },
    ];

    return Scaffold(
      backgroundColor: context.palette.background,
      appBar: PrimaryAppBar(
        title: loc.translate('aiChatTitle'),
        fontSize: 20,
        letterSpacing: 0,
        showBackButton: true,
      ),
      body: SafeArea(
        child: Directionality(
          textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
          child: Stack(
            children: [
              // Main Scrollable Content
              Positioned.fill(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 16),

                      // Glowing circular AI orb background
                      Center(
                        child: Container(
                          width: 250,
                          height: 250,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: const Color(
                                  0xFFFF4081,
                                ).withValues(alpha: 0.15),
                                blurRadius: 40,
                                spreadRadius: 10,
                              ),
                              BoxShadow(
                                color: const Color(
                                  0xFFCA9A4E,
                                ).withValues(alpha: 0.1),
                                blurRadius: 50,
                                spreadRadius: 15,
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: Image.asset(
                              AssetsConstants.aiPng,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 48),

                      // Welcome Headers
                      Text(
                        loc.translate('welcomeAIChat'),
                        style: AppStyle.welcomeTitle.copyWith(
                          fontSize: 42,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Text(
                          loc.translate('howCanIHelpYouToday'),
                          style: AppStyle.subtitleDesc.copyWith(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: context.palette.textPrimary.withValues(
                              alpha: 0.9,
                            ),
                            height: 1.4,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),

                      // Spacing for horizontal list & input
                      const SizedBox(height: 180),
                    ],
                  ),
                ),
              ),

              // Floating Stylist Avatar on the right side

              // Sticky suggestions and input area at bottom
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  color: context.palette.background.withValues(alpha: 0.95),
                  padding: const EdgeInsets.only(bottom: 16, top: 8),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Suggestions Carousel
                      SizedBox(
                        height: 110,
                        child: ListView.builder(
                          reverse: isAr,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          scrollDirection: Axis.horizontal,
                          itemCount: suggestions.length,
                          itemBuilder: (context, index) {
                            final item = suggestions[index];
                            return Container(
                              width: 150,
                              margin: EdgeInsets.only(
                                left: isAr ? 12 : 0,
                                right: isAr ? 0 : 12,
                              ),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: context.palette.surface,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: context.palette.divider,
                                  width: 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: context.palette.shadow,
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Align(
                                    alignment: isAr
                                        ? Alignment.centerRight
                                        : Alignment.centerLeft,
                                    child: SvgPicture.asset(
                                      item['icon'],
                                      width: 24,
                                      height: 24,
                                      colorFilter: ColorFilter.mode(
                                        context.palette.icon,
                                        BlendMode.srcIn,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Align(
                                    alignment: isAr
                                        ? Alignment.centerRight
                                        : Alignment.centerLeft,
                                    child: Text(
                                      item['text'],
                                      style: AppStyle.bodyText.copyWith(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: isAr
                                          ? TextAlign.right
                                          : TextAlign.left,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Chat Input Stadium bar
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Container(
                          decoration: BoxDecoration(
                            color: context.palette.backgroundSubtle,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: context.palette.divider,
                              width: 1,
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          child: Row(
                            children: [
                              // Mic Icon Svg
                              SvgPicture.asset(
                                AssetsConstants.mic,
                                width: 22,
                                height: 22,
                                colorFilter: ColorFilter.mode(
                                  context.palette.icon,
                                  BlendMode.srcIn,
                                ),
                              ),
                              const SizedBox(width: 8),

                              // Chat Input Field
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                  ),
                                  child: TextField(
                                    controller: _messageController,
                                    decoration: InputDecoration(
                                      hintText: loc.translate(
                                        'aiChatInputHint',
                                      ),
                                      hintStyle: AppStyle.inputHint.copyWith(
                                        fontSize: 13,
                                      ),
                                      border: InputBorder.none,
                                      isDense: true,
                                      contentPadding: EdgeInsets.zero,
                                    ),
                                    style: AppStyle.bodyText.copyWith(
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),

                              // Send Button Svg
                              GestureDetector(
                                onTap: () {
                                  if (_messageController.text
                                      .trim()
                                      .isNotEmpty) {
                                    _messageController.clear();
                                  }
                                },
                                child: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColors.primary,
                                  ),
                                  alignment: Alignment.center,
                                  child: Transform(
                                    transform: Matrix4.rotationY(
                                      isAr ? 0 : 3.14159,
                                    ),
                                    alignment: Alignment.center,
                                    child: SvgPicture.asset(
                                      AssetsConstants.send,
                                      width: 18,
                                      height: 18,
                                      colorFilter: const ColorFilter.mode(
                                        Colors.white,
                                        BlendMode.srcIn,
                                      ),
                                    ),
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
