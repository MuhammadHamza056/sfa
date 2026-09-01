import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:sfa/core/localization/app_localizations.dart';
import 'package:sfa/core/models/product_detail_args.dart';
import 'package:sfa/utils/app_style.dart';
import 'package:sfa/utils/assets_constants.dart';
import 'package:sfa/utils/color_constants.dart';
import 'package:sfa/utils/currency_formatter.dart';
import 'package:sfa/core/theme/app_palette.dart';
import 'package:sfa/core/widgets/primary_app_bar.dart';
import 'package:sfa/features/ai/data/ai_models.dart';
import 'package:sfa/features/ai/providers/ai_chat_provider.dart';

class AIChatScreen extends ConsumerStatefulWidget {
  const AIChatScreen({super.key});

  @override
  ConsumerState<AIChatScreen> createState() => _AIChatScreenState();
}

class _AIChatScreenState extends ConsumerState<AIChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _send(String text) {
    if (text.trim().isEmpty) return;
    ref.read(aiChatProvider.notifier).send(text);
    _messageController.clear();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final isAr = loc.isArabic;
    final chatState = ref.watch(aiChatProvider);

    final List<Map<String, dynamic>> suggestions = [
      {'text': loc.translate('suggestionGiftWife'), 'icon': AssetsConstants.gift},
      {'text': loc.translate('suggestionSummerOutfits'), 'icon': AssetsConstants.parasol},
      {'text': loc.translate('suggestionGeneral'), 'icon': AssetsConstants.gift},
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
              Positioned.fill(
                child: chatState.messages.isEmpty
                    ? _buildWelcome(loc)
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 180),
                        itemCount: chatState.messages.length + (chatState.isSending ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == chatState.messages.length) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                            );
                          }
                          return _ChatBubble(message: chatState.messages[index], isAr: isAr);
                        },
                      ),
              ),

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
                      if (chatState.messages.isEmpty)
                        SizedBox(
                          height: 110,
                          child: ListView.builder(
                            reverse: isAr,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            scrollDirection: Axis.horizontal,
                            itemCount: suggestions.length,
                            itemBuilder: (context, index) {
                              final item = suggestions[index];
                              return GestureDetector(
                                onTap: () => _send(item['text'] as String),
                                child: Container(
                                  width: 150,
                                  margin: EdgeInsets.only(left: isAr ? 12 : 0, right: isAr ? 0 : 12),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: context.palette.surface,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: context.palette.divider, width: 1),
                                    boxShadow: [
                                      BoxShadow(color: context.palette.shadow, blurRadius: 10, offset: const Offset(0, 4)),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Align(
                                        alignment: isAr ? Alignment.centerRight : Alignment.centerLeft,
                                        child: SvgPicture.asset(
                                          item['icon'],
                                          width: 24,
                                          height: 24,
                                          colorFilter: ColorFilter.mode(context.palette.icon, BlendMode.srcIn),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Align(
                                        alignment: isAr ? Alignment.centerRight : Alignment.centerLeft,
                                        child: Text(
                                          item['text'],
                                          style: AppStyle.bodyText.copyWith(fontSize: 12, fontWeight: FontWeight.bold),
                                          textAlign: isAr ? TextAlign.right : TextAlign.left,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
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
                            border: Border.all(color: context.palette.divider, width: 1),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          child: Row(
                            children: [
                              SvgPicture.asset(
                                AssetsConstants.mic,
                                width: 22,
                                height: 22,
                                colorFilter: ColorFilter.mode(context.palette.icon, BlendMode.srcIn),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8),
                                  child: TextField(
                                    controller: _messageController,
                                    onSubmitted: _send,
                                    decoration: InputDecoration(
                                      hintText: loc.translate('aiChatInputHint'),
                                      hintStyle: AppStyle.inputHint.copyWith(fontSize: 13),
                                      border: InputBorder.none,
                                      isDense: true,
                                      contentPadding: EdgeInsets.zero,
                                    ),
                                    style: AppStyle.bodyText.copyWith(fontSize: 14),
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () => _send(_messageController.text),
                                child: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.primary),
                                  alignment: Alignment.center,
                                  child: Transform(
                                    transform: Matrix4.rotationY(isAr ? 0 : 3.14159),
                                    alignment: Alignment.center,
                                    child: SvgPicture.asset(
                                      AssetsConstants.send,
                                      width: 18,
                                      height: 18,
                                      colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
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

  Widget _buildWelcome(AppLocalizations loc) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 16),
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: const Color(0xFFFF4081).withValues(alpha: 0.15), blurRadius: 40, spreadRadius: 10),
                  BoxShadow(color: const Color(0xFFCA9A4E).withValues(alpha: 0.1), blurRadius: 50, spreadRadius: 15),
                ],
              ),
              child: ClipOval(child: Image.asset(AssetsConstants.aiPng, fit: BoxFit.cover)),
            ),
          ),
          const SizedBox(height: 48),
          Text(
            loc.translate('welcomeAIChat'),
            style: AppStyle.welcomeTitle.copyWith(fontSize: 42, fontWeight: FontWeight.w900, letterSpacing: 0.5),
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
                color: context.palette.textPrimary.withValues(alpha: 0.9),
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 180),
        ],
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final AiChatMessage message;
  final bool isAr;

  const _ChatBubble({required this.message, required this.isAr});

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == ChatRole.user;
    return Column(
      crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Align(
          alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
            margin: const EdgeInsets.symmetric(vertical: 6),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isUser ? AppColors.primary : context.palette.surfaceMuted,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              message.text,
              style: AppStyle.bodyText.copyWith(
                fontSize: 14,
                color: isUser ? Colors.white : context.palette.textPrimary,
              ),
            ),
          ),
        ),
        if (message.recommendedProducts.isNotEmpty)
          SizedBox(
            height: 150,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: message.recommendedProducts.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final product = message.recommendedProducts[index];
                return GestureDetector(
                  onTap: () => context.push(
                    '/product-detail',
                    extra: ProductDetailArgs(
                      id: product.id,
                      name: product.name.resolve(isAr),
                      imageUrl: product.image,
                      price: CurrencyFormatter.fromHalalas(product.priceFils, isAr: isAr),
                      rating: '',
                    ),
                  ),
                  child: Container(
                    width: 110,
                    decoration: BoxDecoration(
                      color: context.palette.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: context.palette.divider),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Image.network(
                            product.image,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(color: context.palette.surfaceMuted),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(6),
                          child: Text(
                            CurrencyFormatter.fromHalalas(product.priceFils, isAr: isAr),
                            style: AppStyle.bodyText.copyWith(fontSize: 11, fontWeight: FontWeight.bold),
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}
