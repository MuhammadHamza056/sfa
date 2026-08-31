import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:video_player/video_player.dart';
import 'package:sfa/core/localization/app_localizations.dart';
import 'package:sfa/core/models/product_detail_args.dart';
import 'package:sfa/core/providers/nav_providers.dart';
import 'package:sfa/core/widgets/cart_icon_button.dart';
import 'package:sfa/utils/app_style.dart';
import 'package:sfa/utils/assets_constants.dart';
import 'package:sfa/utils/color_constants.dart';
import 'package:sfa/features/reels/providers/reels_provider.dart';
import 'package:sfa/core/theme/app_palette.dart';

class ReelModel {
  final String videoUrl;
  final String brandName;
  final String avatarUrl;
  final String description;
  final String likesCount;
  final String productName;
  final String productPrice;
  final String productImage;

  const ReelModel({
    required this.videoUrl,
    required this.brandName,
    required this.avatarUrl,
    required this.description,
    required this.likesCount,
    required this.productName,
    required this.productPrice,
    required this.productImage,
  });
}

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

  late List<ReelModel> _reels;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final loc = AppLocalizations.of(context);
    _initReels(loc);
  }

  void _initReels(AppLocalizations loc) {
    _reels = [
      ReelModel(
        videoUrl: 'https://lorem.video/720p',
        brandName: loc.translate('reelNajdDesign'),
        avatarUrl:
            'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150&q=80',
        description: loc.translate('reelDescription'),
        likesCount: '2.4K',
        productName: loc.translate('reelProductName'),
        productPrice: loc.translate('reelProductPrice'),
        productImage:
            'https://images.unsplash.com/photo-1509631179647-0177331693ae?w=500&q=80',
      ),
      ReelModel(
        videoUrl: 'https://lorem.video/720p',
        brandName: loc.translate('brandJuba'),
        avatarUrl:
            'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150&q=80',
        description: loc.translate('brandDescription'),
        likesCount: '1.8K',
        productName: loc.translate('brandProductBlackSilk'),
        productPrice: loc.translate('brandProductPrice1250'),
        productImage:
            'https://images.unsplash.com/photo-1529139574466-a303027c1d8b?w=500&q=80',
      ),
      ReelModel(
        videoUrl: 'https://lorem.video/720p',
        brandName: loc.translate('brandAnbar'),
        avatarUrl:
            'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150&q=80',
        description: loc.translate('brandDescription'),
        likesCount: '3.2K',
        productName: loc.translate('brandProductCrepeAbaya'),
        productPrice: loc.translate('brandProductPrice780'),
        productImage:
            'https://images.unsplash.com/photo-1515886657613-9f3515b0c78f?w=500&q=80',
      ),
      ReelModel(
        videoUrl: 'https://lorem.video/720p',
        brandName: loc.translate('brandSummerShop'),
        avatarUrl:
            'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150&q=80',
        description: loc.translate('brandDescription'),
        likesCount: '4.1K',
        productName: loc.translate('brandProductLinenSet'),
        productPrice: loc.translate('brandProductPrice450'),
        productImage:
            'https://images.unsplash.com/photo-1529139574466-a303027c1d8b?w=500&q=80',
      ),
      ReelModel(
        videoUrl: 'https://lorem.video/720p',
        brandName: loc.translate('brandNaseej'),
        avatarUrl:
            'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150&q=80',
        description: loc.translate('brandDescription'),
        likesCount: '1.2K',
        productName: loc.translate('brandProductDesertRose'),
        productPrice: loc.translate('brandProductPrice1250'),
        productImage:
            'https://images.unsplash.com/photo-1509631179647-0177331693ae?w=500&q=80',
      ),
      ReelModel(
        videoUrl: 'https://lorem.video/720p',
        brandName: loc.translate('brandThawbi'),
        avatarUrl:
            'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150&q=80',
        description: loc.translate('brandDescription'),
        likesCount: '5.0K',
        productName: loc.translate('brandProductCrepeAbaya'),
        productPrice: loc.translate('brandProductPrice780'),
        productImage:
            'https://images.unsplash.com/photo-1515886657613-9f3515b0c78f?w=500&q=80',
      ),
    ];

    // Preload the first and second videos
    _preloadController(0);
    _preloadController(1);
  }

  void _preloadController(int index) {
    if (index < 0 || index >= _reels.length) return;
    if (_controllers.containsKey(index)) return;

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

    ref.watch(reelsProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Vertical PageView of Reels
          PageView.builder(
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
          ),

          // Top Header Overlay (Bag, Wishlist, Logo, Search, Menu)
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Left Side (Bag & Heart)
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
                      onTap: () {},
                    ),
                  ],
                ),

                // Centered SFA text logo
                Text(
                  'SFA',
                  style: AppStyle.headerHeading.copyWith(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),

                // Right Side (Search & Menu)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // _buildTopHeaderButton(
                    //   icon: AssetsConstants.search,
                    //   onTap: () {},
                    // ),
                    // const SizedBox(width: 12),
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
          color: Colors.black.withOpacity(0.2),
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
  final ReelModel reel;
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

  @override
  Widget build(BuildContext context) {
    final reel = widget.reel;
    final controller = widget.controller;
    final loc = widget.loc;
    final isAr = loc.isArabic;
    final state = ref.watch(reelsProvider);

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
                    const Icon(
                      Icons.error_outline,
                      color: Colors.white,
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      loc.translate('videoError'),
                      style: const TextStyle(color: Colors.white),
                    ),
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
            else
              const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),

            // Dark overlay for readability
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withOpacity(0.4),
                    Colors.transparent,
                    Colors.black.withOpacity(0.5),
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
                        color: Colors.black.withOpacity(0.55),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        state.playPauseIcon,
                        size: 48,
                        color: Colors.white,
                      ),
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
                  // Heart button (Likes)
                  _buildSidebarButton(
                    icon: AssetsConstants.heart2,
                    label: reel.likesCount,
                    onTap: () {},
                  ),
                  const SizedBox(height: 16),
                  // Bookmark button
                  _buildSidebarButton(
                    icon: AssetsConstants.bookmark,
                    label: loc.translate('reelSave'),
                    onTap: () {},
                  ),
                  const SizedBox(height: 16),
                  // Share button
                  _buildSidebarButton(
                    icon: AssetsConstants.iconShare2,
                    label: loc.translate('reelShare'),
                    onTap: () {},
                  ),
                  const SizedBox(height: 20),
                  // Brand Avatar
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.goldAccent,
                        width: 1.5,
                      ),
                      image: DecorationImage(
                        image: CachedNetworkImageProvider(reel.avatarUrl),
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
                  // Brand Row (Avatar, Name, Verified check, انتقل للمنتج)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.goldAccent,
                            width: 1,
                          ),
                          image: DecorationImage(
                            image: CachedNetworkImageProvider(reel.avatarUrl),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Verified badge
                      SvgPicture.asset(
                        AssetsConstants.badgeCheck,
                        width: 16,
                        height: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        reel.brandName,
                        style: AppStyle.bodyText.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 10),
                      // انتقل للمنتج Button
                      GestureDetector(
                        onTap: () {
                          context.push(
                            '/product-detail',
                            extra: ProductDetailArgs(
                              name: reel.productName,
                              imageUrl: reel.productImage,
                              price: reel.productPrice,
                              rating: '4.9 · 85 reviews',
                            ),
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.goldAccent,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          child: Text(
                            loc.translate('reelGoToProduct'),
                            style: AppStyle.bodyText.copyWith(
                              color: context.palette.textPrimary,
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Description Text
                  Text(
                    reel.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppStyle.bodyText.copyWith(
                      color: Colors.white.withOpacity(0.95),
                      fontSize: 12.5,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),

            // Floating Bottom Product Banner
            Positioned(
              bottom: kToolbarHeight + 60,
              left: 16,
              right: 16,
              child: GestureDetector(
                onTap: () {
                  context.push(
                    '/product-detail',
                    extra: ProductDetailArgs(
                      name: reel.productName,
                      imageUrl: reel.productImage,
                      price: reel.productPrice,
                      rating: '4.9 · 85 reviews',
                    ),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.black_50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.goldAccent_25,
                      width: 1,
                    ),
                  ),
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    textDirection: TextDirection.ltr,
                    children: [
                      // Gold Shopping Bag icon container
                      Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                          color: Color(0xFFD49E4B),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: SvgPicture.asset(
                            AssetsConstants.shoppingBag,
                            colorFilter: const ColorFilter.mode(
                              Color(0xFF451425),
                              BlendMode.srcIn,
                            ),
                            width: 18,
                            height: 18,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Product details text
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              reel.productName,
                              textAlign: TextAlign.center,
                              style: AppStyle.bodyText.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13.5,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              reel.productPrice,
                              textAlign: TextAlign.center,
                              style: AppStyle.bodyText.copyWith(
                                color: const Color(0xFFD49E4B),
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Small Image preview
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: CachedNetworkImage(
                          imageUrl: reel.productImage,
                          width: 48,
                          height: 48,
                          fit: BoxFit.cover,
                        ),
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
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.35),
              shape: BoxShape.circle,
            ),
            padding: const EdgeInsets.all(10),
            child: SvgPicture.asset(
              icon,
              width: 24,
              height: 24,
              colorFilter: const ColorFilter.mode(
                Colors.white,
                BlendMode.srcIn,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppStyle.bodyText.copyWith(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
