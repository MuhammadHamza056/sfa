import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:video_player/video_player.dart';
import 'package:sfa/core/localization/app_localizations.dart';
import 'package:sfa/core/models/product_detail_args.dart';
import 'package:sfa/core/providers/nav_providers.dart';
import 'package:sfa/core/widgets/cart_icon_button.dart';
import 'package:sfa/utils/app_style.dart';
import 'package:sfa/utils/assets_constants.dart';
import 'package:sfa/utils/color_constants.dart';
import 'package:sfa/utils/currency_formatter.dart';
import 'package:sfa/features/reels/data/reel_models.dart';
import 'package:sfa/features/reels/providers/reels_feed_provider.dart';
import 'package:sfa/features/reels/providers/reels_provider.dart';
import 'package:sfa/core/theme/app_palette.dart';

class ReelsScreen extends ConsumerStatefulWidget {
  const ReelsScreen({super.key});

  @override
  ConsumerState<ReelsScreen> createState() => _ReelsScreenState();
}

class _ReelsScreenState extends ConsumerState<ReelsScreen> {
  late PageController _pageController;

  // Cache/Store active initialized VideoPlayerControllers
  final Map<int, VideoPlayerController> _controllers = {};
  final Map<int, Future<void>> _initializeFutures = {};

  List<Reel> _reels = [];
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  void _initReels(List<Reel> reels) {
    _reels = reels;
    _preloadController(0);
    _preloadController(1);
  }

  void _preloadController(int index) {
    if (index < 0 || index >= _reels.length) return;
    if (_controllers.containsKey(index)) return;
    if (_reels[index].videoUrl.isEmpty) return;

    final controller = VideoPlayerController.networkUrl(
      Uri.parse(_reels[index].videoUrl),
    );
    _controllers[index] = controller;
    _initializeFutures[index] = controller
        .initialize()
        .then((_) {
          controller.setLooping(true);
          final isReelsActive = ref.read(highlightedTabIndexProvider) == 2;
          final isDrawerOpen = ref.read(drawerOpenProvider);
          if (index == ref.read(reelsProvider).focusedIndex &&
              isReelsActive &&
              !isDrawerOpen) {
            controller.play();
            ref.read(reelsProvider.notifier).videoControllerUpdated();
          }
        })
        .catchError((error) {
          debugPrint(
            'Error initializing video player for index $index: $error',
          );
          ref.read(reelsProvider.notifier).videoControllerUpdated();
        });
  }

  void _onPageChanged(int index) {
    ref.read(reelsProvider.notifier).changeFocusedIndex(index);

    // Play current focused video, pause others
    _controllers.forEach((idx, ctrl) {
      if (idx == index) {
        if (ctrl.value.isInitialized) {
          ctrl.play();
        }
      } else {
        ctrl.pause();
      }
    });

    // Preload adjacent videos
    _preloadController(index + 1);
    _preloadController(index - 1);

    // Fetch the next page once the user is a few reels away from the end.
    if (index >= _reels.length - 3) {
      ref.read(reelsFeedProvider.notifier).loadMore();
    }

    // Clean up far away controllers
    final indicesToDispose = <int>[];
    _controllers.keys.forEach((idx) {
      if ((idx - index).abs() > 1) {
        indicesToDispose.add(idx);
      }
    });

    for (final idx in indicesToDispose) {
      _controllers[idx]?.dispose();
      _controllers.remove(idx);
      _initializeFutures.remove(idx);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _controllers.forEach((_, ctrl) => ctrl.dispose());
    super.dispose();
  }

  void _onActiveTabOrDrawerChanged() {
    final isReelsActive = ref.read(highlightedTabIndexProvider) == 2;
    final isDrawerOpen = ref.read(drawerOpenProvider);
    if (!isReelsActive || isDrawerOpen) {
      _controllers.forEach((_, ctrl) {
        if (ctrl.value.isInitialized && ctrl.value.isPlaying) {
          ctrl.pause();
        }
      });
      ref.read(reelsProvider.notifier).videoControllerUpdated();
    } else {
      final focusedIndex = ref.read(reelsProvider).focusedIndex;
      final activeCtrl = _controllers[focusedIndex];
      if (activeCtrl != null && activeCtrl.value.isInitialized) {
        activeCtrl.play();
        ref.read(reelsProvider.notifier).videoControllerUpdated();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    ref.listen<int>(
      highlightedTabIndexProvider,
      (previous, next) => _onActiveTabOrDrawerChanged(),
    );
    ref.listen<bool>(
      drawerOpenProvider,
      (previous, next) => _onActiveTabOrDrawerChanged(),
    );
    ref.listen<AsyncValue<ReelsFeedState>>(reelsFeedProvider, (previous, next) {
      next.whenData((feedState) {
        if (!_initialized) {
          setState(() {
            _initialized = true;
            _initReels(feedState.items);
          });
        } else if (feedState.items.length != _reels.length) {
          setState(() => _reels = feedState.items);
        }
      });
    });

    ref.watch(reelsProvider);
    final feedAsync = ref.watch(reelsFeedProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          feedAsync.when(
            loading: () => const Center(child: CircularProgressIndicator(color: Colors.white)),
            error: (error, _) => Center(
              child: Text(error.toString(), style: const TextStyle(color: Colors.white)),
            ),
            data: (feedState) {
              if (!_initialized) {
                return const Center(child: CircularProgressIndicator(color: Colors.white));
              }
              if (_reels.isEmpty) {
                return Center(
                  child: Text(
                    loc.translate('noReelsYet'),
                    style: const TextStyle(color: Colors.white),
                  ),
                );
              }
              return PageView.builder(
                scrollDirection: Axis.vertical,
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemCount: _reels.length,
                itemBuilder: (context, index) {
                  return _ReelPageItem(
                    reel: _reels[index],
                    controller: _controllers[index],
                    loc: loc,
                    onControllerUpdate: () {
                      ref.read(reelsProvider.notifier).videoControllerUpdated();
                    },
                  );
                },
              );
            },
          ),

          // Top Header Overlay (Bag, Wishlist, Logo, Search, Menu)
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      padding: const EdgeInsets.all(8),
                      child: CartIconButton(
                        icon: AssetsConstants.shoppingBag,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    _buildTopHeaderButton(
                      icon: AssetsConstants.heart2,
                      onTap: () => context.push('/favorites'),
                    ),
                  ],
                ),
                Text(
                  'SFA',
                  style: AppStyle.headerHeading.copyWith(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildTopHeaderButton(
                      icon: AssetsConstants.menu,
                      onTap: () =>
                          ref.read(drawerOpenProvider.notifier).state = true,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopHeaderButton({
    required String icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.2),
          shape: BoxShape.circle,
        ),
        padding: const EdgeInsets.all(8),
        child: SvgPicture.asset(
          icon,
          width: 20,
          height: 20,
          colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
        ),
      ),
    );
  }
}

class _ReelPageItem extends ConsumerStatefulWidget {
  final Reel reel;
  final VideoPlayerController? controller;
  final AppLocalizations loc;
  final VoidCallback onControllerUpdate;

  const _ReelPageItem({
    required this.reel,
    required this.controller,
    required this.loc,
    required this.onControllerUpdate,
  });

  @override
  ConsumerState<_ReelPageItem> createState() => _ReelPageItemState();
}

class _ReelPageItemState extends ConsumerState<_ReelPageItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _onTapVideo(BuildContext context) {
    final ctrl = widget.controller;
    if (ctrl != null && ctrl.value.isInitialized) {
      final wasPlaying = ctrl.value.isPlaying;
      if (wasPlaying) {
        ctrl.pause();
        ref.read(reelsProvider.notifier).togglePlayPauseIcon(true, Icons.pause);
      } else {
        ctrl.play();
        ref
            .read(reelsProvider.notifier)
            .togglePlayPauseIcon(true, Icons.play_arrow);
      }
      _animationController.forward(from: 0);
      _timer?.cancel();
      _timer = Timer(Duration(seconds: wasPlaying ? 3 : 1), () {
        if (mounted) {
          _animationController.reverse().then((_) {
            if (mounted) {
              ref
                  .read(reelsProvider.notifier)
                  .togglePlayPauseIcon(false, Icons.play_arrow);
            }
          });
        }
      });
      widget.onControllerUpdate();
    }
  }

  ProductDetailArgs? _productArgs(bool isAr) {
    final product = widget.reel.taggedProduct;
    if (product == null) return null;
    return ProductDetailArgs(
      id: product.id,
      name: product.name.resolve(isAr),
      imageUrl: product.image,
      price: CurrencyFormatter.fromHalalas(product.priceFils, isAr: isAr),
      rating: '',
    );
  }

  @override
  Widget build(BuildContext context) {
    final reel = widget.reel;
    final controller = widget.controller;
    final loc = widget.loc;
    final isAr = loc.isArabic;
    final state = ref.watch(reelsProvider);
    final product = reel.taggedProduct;

    return Directionality(
      textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
      child: GestureDetector(
        onTap: () => _onTapVideo(context),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Video Player or Fallbacks
            if (controller != null && controller.value.hasError)
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, color: Colors.white, size: 48),
                    const SizedBox(height: 16),
                    Text(loc.translate('videoError'), style: const TextStyle(color: Colors.white)),
                  ],
                ),
              )
            else if (controller != null && controller.value.isInitialized)
              SizedBox.expand(
                child: FittedBox(
                  fit: BoxFit.cover,
                  clipBehavior: Clip.hardEdge,
                  child: SizedBox(
                    width: controller.value.size.width,
                    height: controller.value.size.height,
                    child: VideoPlayer(controller),
                  ),
                ),
              )
            else if (reel.thumbnailUrl.isNotEmpty)
              CachedNetworkImage(imageUrl: reel.thumbnailUrl, fit: BoxFit.cover)
            else
              const Center(child: CircularProgressIndicator(color: Colors.white)),

            // Dark overlay for readability
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withValues(alpha: 0.4),
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.5),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),

            // Centered Play/Pause Icon Indicator Overlay
            if (state.showPlayPauseIcon)
              Center(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.55),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(state.playPauseIcon, size: 48, color: Colors.white),
                    ),
                  ),
                ),
              ),

            // Sidebar actions overlay
            Positioned(
              bottom: 220,
              left: isAr ? null : 16,
              right: isAr ? 16 : null,
              child: Column(
                children: [
                  _buildSidebarButton(
                    icon: reel.isLiked ? AssetsConstants.heartFilled : AssetsConstants.heart2,
                    label: formatReelCount(reel.likesCount),
                    tint: reel.isLiked ? AppColors.primary : Colors.white,
                    onTap: () => ref.read(reelsFeedProvider.notifier).toggleLike(reel.id),
                  ),
                  const SizedBox(height: 16),
                  _buildSidebarButton(
                    icon: AssetsConstants.bookmark,
                    label: reel.isSaved ? loc.translate('reelSaved') : loc.translate('reelSave'),
                    tint: reel.isSaved ? AppColors.primary : Colors.white,
                    onTap: () => ref.read(reelsFeedProvider.notifier).toggleSave(reel.id),
                  ),
                  const SizedBox(height: 16),
                  _buildSidebarButton(
                    icon: AssetsConstants.iconShare2,
                    label: loc.translate('reelShare'),
                    onTap: () async {
                      final result =
                          await ref.read(reelsRepositoryProvider).getShareLink(reel.id);
                      final link = result.dataOrNull;
                      if (link != null && link.isNotEmpty) {
                        Share.share(link);
                      }
                    },
                  ),
                  const SizedBox(height: 20),
                  if (reel.brand?.logo != null)
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.goldAccent, width: 1.5),
                        image: DecorationImage(
                          image: CachedNetworkImageProvider(reel.brand!.logo!),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Brand & description overlay
            Positioned(
              bottom: 210,
              left: isAr ? 16 : 90,
              right: isAr ? 90 : 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (reel.brand?.logo != null)
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.goldAccent, width: 1),
                            image: DecorationImage(
                              image: CachedNetworkImageProvider(reel.brand!.logo!),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      const SizedBox(width: 8),
                      SvgPicture.asset(AssetsConstants.badgeCheck, width: 16, height: 16),
                      const SizedBox(width: 6),
                      Text(
                        reel.brand?.name.resolve(isAr) ?? '',
                        style: AppStyle.bodyText.copyWith(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      if (product != null) ...[
                        const SizedBox(width: 10),
                        GestureDetector(
                          onTap: () => context.push('/product-detail', extra: _productArgs(isAr)),
                          child: Container(
                            decoration: BoxDecoration(color: AppColors.goldAccent, borderRadius: BorderRadius.circular(20)),
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            child: Text(
                              loc.translate('reelGoToProduct'),
                              style: AppStyle.bodyText.copyWith(color: context.palette.textPrimary, fontWeight: FontWeight.bold, fontSize: 11),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    reel.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppStyle.bodyText.copyWith(color: Colors.white.withValues(alpha: 0.95), fontSize: 12.5, height: 1.4),
                  ),
                ],
              ),
            ),

            // Floating Bottom Product Banner
            if (product != null)
              Positioned(
                bottom: kToolbarHeight + 60,
                left: 16,
                right: 16,
                child: GestureDetector(
                  onTap: () => context.push('/product-detail', extra: _productArgs(isAr)),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.black_50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.goldAccent_25, width: 1),
                    ),
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      textDirection: TextDirection.ltr,
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: const BoxDecoration(color: Color(0xFFD49E4B), shape: BoxShape.circle),
                          child: Center(
                            child: SvgPicture.asset(
                              AssetsConstants.shoppingBag,
                              colorFilter: const ColorFilter.mode(Color(0xFF451425), BlendMode.srcIn),
                              width: 18,
                              height: 18,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                product.name.resolve(isAr),
                                textAlign: TextAlign.center,
                                style: AppStyle.bodyText.copyWith(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13.5),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                CurrencyFormatter.fromHalalas(product.priceFils, isAr: isAr),
                                textAlign: TextAlign.center,
                                style: AppStyle.bodyText.copyWith(color: const Color(0xFFD49E4B), fontWeight: FontWeight.w600, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: CachedNetworkImage(imageUrl: product.image, width: 48, height: 48, fit: BoxFit.cover),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSidebarButton({
    required String icon,
    required String label,
    required VoidCallback onTap,
    Color tint = Colors.white,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.35),
              shape: BoxShape.circle,
            ),
            padding: const EdgeInsets.all(10),
            child: SvgPicture.asset(
              icon,
              width: 24,
              height: 24,
              colorFilter: ColorFilter.mode(tint, BlendMode.srcIn),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppStyle.bodyText.copyWith(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
