import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:sfa/core/localization/app_localizations.dart';
import 'package:sfa/core/models/product_detail_args.dart';
import 'package:sfa/core/providers/realtime_providers.dart';
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
  }

  /// Whether the view is close enough to the end that following the stream
  /// is what the user wants. Scrolling up to re-read an earlier answer
  /// parks the view there instead of being yanked back down every chunk.
  bool get _isNearBottom {
    if (!_scrollController.hasClients) return true;
    final position = _scrollController.position;
    return position.maxScrollExtent - position.pixels < 160;
  }

  /// Keeps the newest content in view as the reply grows.
  ///
  /// New bubbles animate, but chunks jump: a chunk arrives every few
  /// frames, and overlapping scroll animations fight each other into a
  /// visible stutter, which is exactly the flicker streaming is supposed
  /// to avoid.
  void _followStream({required bool animate}) {
    if (!_isNearBottom) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) return;
      final target = _scrollController.position.maxScrollExtent;
      if (animate) {
        _scrollController.animateTo(
          target,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      } else {
        _scrollController.jumpTo(target);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final isAr = loc.isArabic;
    final chatState = ref.watch(aiChatProvider);
    final isConnected = ref.watch(socketConnectedProvider).value ?? true;

    ref.listen<AiChatState>(aiChatProvider, (previous, next) {
      final grew = (previous?.messages.length ?? 0) != next.messages.length;
      _followStream(animate: grew);
    });

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
              Positioned.fill(child: _buildThread(loc, chatState, isAr)),

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
                      if (!isConnected)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: _ReconnectingChip(label: loc.translate('aiChatReconnecting')),
                        ),

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
                                        alignment: AlignmentDirectional.centerStart,
                                        child: SvgPicture.asset(
                                          item['icon'],
                                          width: 24,
                                          height: 24,
                                          colorFilter: ColorFilter.mode(context.palette.icon, BlendMode.srcIn),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Align(
                                        alignment: AlignmentDirectional.centerStart,
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
                        )
                      else
                        // The suggestion rail's slot is free once the thread
                        // has content, so the "start over" affordance takes it.
                        Align(
                          alignment: AlignmentDirectional.centerStart,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: TextButton.icon(
                              onPressed: chatState.isSending
                                  ? null
                                  : () => ref.read(aiChatProvider.notifier).startNewConversation(),
                              icon: const Icon(Icons.add_comment_outlined, size: 16),
                              label: Text(
                                loc.translate('aiChatNewConversation'),
                                style: AppStyle.bodyText.copyWith(fontSize: 12),
                              ),
                              style: TextButton.styleFrom(
                                foregroundColor: context.palette.textSecondary,
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                visualDensity: VisualDensity.compact,
                              ),
                            ),
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
                                    enabled: !chatState.isSending,
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
                                onTap: chatState.isSending
                                    ? null
                                    : () => _send(_messageController.text),
                                child: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: chatState.isSending
                                        ? AppColors.primary.withValues(alpha: 0.4)
                                        : AppColors.primary,
                                  ),
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

  Widget _buildThread(AppLocalizations loc, AiChatState chatState, bool isAr) {
    // A stored conversation is being replayed — showing the welcome hero
    // first would flash it away the moment the thread lands.
    if (chatState.messages.isEmpty && chatState.isLoadingHistory) {
      return const Center(child: CircularProgressIndicator(strokeWidth: 2));
    }
    if (chatState.messages.isEmpty) return _buildWelcome(loc);

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 180),
      itemCount: chatState.messages.length,
      itemBuilder: (context, index) {
        return _ChatBubble(
          message: chatState.messages[index],
          isAr: isAr,
          onRetry: () => ref.read(aiChatProvider.notifier).retryLast(),
        );
      },
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
  final VoidCallback onRetry;

  const _ChatBubble({
    required this.message,
    required this.isAr,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final isUser = message.role == ChatRole.user;
    final palette = context.palette;

    return Column(
      // Directional, so the user's own bubbles sit on the trailing edge in
      // both languages — right in English, left in Arabic.
      crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Align(
          alignment: isUser
              ? AlignmentDirectional.centerEnd
              : AlignmentDirectional.centerStart,
          child: Container(
            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
            margin: const EdgeInsets.symmetric(vertical: 6),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: message.isError
                  ? palette.danger.withValues(alpha: 0.1)
                  : isUser
                      ? AppColors.primary
                      : palette.surfaceMuted,
              borderRadius: BorderRadius.circular(16),
              border: message.isError
                  ? Border.all(color: palette.danger.withValues(alpha: 0.4))
                  : null,
            ),
            child: _buildContent(context, loc, isUser),
          ),
        ),

        if (message.isError)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: TextButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh, size: 16),
              label: Text(
                loc.translate('aiChatRetry'),
                style: AppStyle.bodyText.copyWith(fontSize: 12),
              ),
              style: TextButton.styleFrom(
                foregroundColor: palette.danger,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                visualDensity: VisualDensity.compact,
              ),
            ),
          ),

        if (message.recommendedProducts.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.only(top: 2, bottom: 6),
            child: Text(
              loc.translate('aiChatRecommendations'),
              style: AppStyle.bodyText.copyWith(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: palette.textSecondary,
              ),
            ),
          ),
          SizedBox(
            height: 178,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: message.recommendedProducts.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                return _ProductCard(
                  product: message.recommendedProducts[index],
                  isAr: isAr,
                );
              },
            ),
          ),
          const SizedBox(height: 6),
        ],
      ],
    );
  }

  Widget _buildContent(BuildContext context, AppLocalizations loc, bool isUser) {
    final palette = context.palette;

    if (message.isError) {
      return Text(
        _errorText(loc),
        style: AppStyle.bodyText.copyWith(fontSize: 14, color: palette.danger),
      );
    }

    final style = AppStyle.bodyText.copyWith(
      fontSize: 14,
      color: isUser ? Colors.white : palette.textPrimary,
    );

    // Nothing has arrived yet: the bubble holds the place in the thread and
    // shows that the assistant is composing.
    if (message.isStreaming && message.text.isEmpty) {
      return _TypingDots(color: palette.textSecondary);
    }
    if (!message.isStreaming) return Text(message.text, style: style);

    // A caret riding the end of the text as it grows. Inline rather than
    // trailing the bubble so it stays glued to the last word on every line
    // break, in both text directions.
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(text: message.text),
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: _BlinkingCaret(color: style.color ?? palette.textPrimary),
          ),
        ],
      ),
      style: style,
    );
  }

  /// Only [AiChatErrorKind.server] carries a message of its own, and the
  /// gateway sometimes sends an empty one — everything else is localized.
  String _errorText(AppLocalizations loc) {
    switch (message.errorKind) {
      case AiChatErrorKind.timeout:
        return loc.translate('aiChatErrorTimeout');
      case AiChatErrorKind.offline:
        return loc.translate('aiChatErrorOffline');
      case AiChatErrorKind.server:
      case AiChatErrorKind.none:
        return message.text.isNotEmpty
            ? message.text
            : loc.translate('aiChatErrorGeneric');
    }
  }
}

class _ProductCard extends StatelessWidget {
  final AiRecommendedProduct product;
  final bool isAr;

  const _ProductCard({required this.product, required this.isAr});

  @override
  Widget build(BuildContext context) {
    final name = product.name.resolve(isAr);
    return GestureDetector(
      onTap: () => context.push(
        '/product-detail',
        extra: ProductDetailArgs(
          id: product.id,
          name: name,
          imageUrl: product.image,
          price: CurrencyFormatter.fromHalalas(product.priceFils, isAr: isAr),
          rating: '',
        ),
      ),
      child: Container(
        width: 120,
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
                errorBuilder: (_, _, _) => Container(
                  color: context.palette.surfaceMuted,
                  alignment: Alignment.center,
                  child: Icon(Icons.image_not_supported_outlined,
                      size: 20, color: context.palette.icon),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(6, 6, 6, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: AppStyle.bodyText.copyWith(fontSize: 11, height: 1.3),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    CurrencyFormatter.fromHalalas(product.priceFils, isAr: isAr),
                    style: AppStyle.bodyText.copyWith(fontSize: 11, fontWeight: FontWeight.bold),
                    maxLines: 1,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The caret trailing a reply while it streams.
class _BlinkingCaret extends StatefulWidget {
  final Color color;

  const _BlinkingCaret({required this.color});

  @override
  State<_BlinkingCaret> createState() => _BlinkingCaretState();
}

class _BlinkingCaretState extends State<_BlinkingCaret>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 550),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _controller,
      child: Container(
        width: 2,
        height: 14,
        margin: const EdgeInsetsDirectional.only(start: 2),
        decoration: BoxDecoration(
          color: widget.color,
          borderRadius: BorderRadius.circular(1),
        ),
      ),
    );
  }
}

/// Composing indicator shown before the first token lands.
class _TypingDots extends StatefulWidget {
  final Color color;

  const _TypingDots({required this.color});

  @override
  State<_TypingDots> createState() => _TypingDotsState();
}

class _TypingDotsState extends State<_TypingDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 16,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(3, (index) {
          // Staggered so the dots ripple rather than pulse together.
          final start = index * 0.2;
          final animation = CurvedAnimation(
            parent: _controller,
            curve: Interval(start, start + 0.5, curve: Curves.easeInOut),
          );
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: FadeTransition(
              opacity: Tween<double>(begin: 0.3, end: 1).animate(animation),
              child: Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(color: widget.color, shape: BoxShape.circle),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _ReconnectingChip extends StatelessWidget {
  final String label;

  const _ReconnectingChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: context.palette.surfaceMuted,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 12,
            height: 12,
            child: CircularProgressIndicator(strokeWidth: 1.5, color: context.palette.icon),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: AppStyle.bodyText.copyWith(fontSize: 12, color: context.palette.textSecondary),
          ),
        ],
      ),
    );
  }
}
