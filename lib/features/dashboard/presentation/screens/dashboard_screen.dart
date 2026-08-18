import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:sfa/core/localization/app_localizations.dart';
import 'package:sfa/core/theme/app_palette.dart';
import 'package:sfa/utils/app_style.dart';
import 'package:sfa/utils/assets_constants.dart';
import 'package:sfa/utils/color_constants.dart';
import 'package:sfa/features/home/presentation/screens/home_screen.dart';
import 'package:sfa/features/home/bloc/home_bloc.dart';
import 'package:sfa/features/brands/presentation/screens/brands_screen.dart';
import 'package:sfa/features/reels/presentation/screens/reels_screen.dart';
import 'package:sfa/features/profile/presentation/screens/profile_screen.dart';
import 'package:sfa/features/notifications/presentation/screens/notifications_screen.dart';
import 'package:sfa/features/cart/presentation/screens/cart_screen.dart';
import 'package:sfa/features/brands/presentation/screens/brand_detail_screen.dart';
import 'package:sfa/features/brands/presentation/screens/product_detail_screen.dart';
import 'package:sfa/features/dashboard/bloc/dashboard_bloc.dart';
import 'package:sfa/features/dashboard/bloc/dashboard_event.dart';
import 'package:sfa/features/dashboard/bloc/dashboard_state.dart';
import 'package:sfa/features/favorites/presentation/screens/favorites_screen.dart';
import 'package:sfa/features/wallet/presentation/screens/wallet_screen.dart';
import 'package:sfa/features/wallet/presentation/screens/all_transactions_screen.dart';
import 'package:sfa/features/address/presentation/screens/address_screen.dart';
import 'package:sfa/features/address/presentation/screens/add_edit_address_screen.dart';
import 'package:sfa/features/brands/presentation/screens/product_reviews_screen.dart';
import 'package:sfa/features/brands/presentation/screens/write_review_screen.dart';

import 'package:sfa/features/favorites/bloc/favorites_bloc.dart';
import 'package:sfa/features/favorites/bloc/favorites_event.dart';

class DashboardScreen extends StatefulWidget {
  final int? initialTab;
  final bool openDrawerOnStart;
  final Widget? body;
  final int? customIndex;

  const DashboardScreen({
    super.key,
    this.initialTab,
    this.openDrawerOnStart = false,
    this.body,
    this.customIndex,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  late final DashboardBloc _bloc;
  late final AnimationController _drawerController;
  late final Animation<double> _drawerSlide;
  late final Animation<double> _scrimOpacity;

  final List<Widget> _pages = [
    BlocProvider(
      create: (context) => HomeBloc(),
      child: const HomeScreen(),
    ),
    const BrandsScreen(),
    const ReelsScreen(),
    const ProfileScreen(),
    const NotificationsScreen(),
    const CartScreen(),
    const BrandDetailScreen(),
    const ProductDetailScreen(),
    const FavoritesScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _bloc = DashboardBloc();
    if (widget.initialTab != null) {
      _bloc.add(ChangeTabEvent(widget.initialTab!));
    }
    _drawerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    _drawerSlide = CurvedAnimation(
      parent: _drawerController,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
    _scrimOpacity = Tween<double>(begin: 0, end: 0.45).animate(_drawerSlide);

    if (widget.openDrawerOnStart) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _openDrawer();
      });
    }
  }

  @override
  void didUpdateWidget(covariant DashboardScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialTab != null &&
        widget.initialTab != _bloc.state.currentIndex) {
      _bloc.add(ChangeTabEvent(widget.initialTab!));
    }
  }

  @override
  void dispose() {
    _drawerController.dispose();
    _bloc.close();
    super.dispose();
  }

  void _openDrawer() {
    _bloc.add(const SetDrawerOpenEvent(true));
    _drawerController.forward();
  }

  void _closeDrawer() {
    _drawerController.reverse().then((_) {
      if (mounted) _bloc.add(const SetDrawerOpenEvent(false));
    });
  }

  void _toggleDrawer() {
    final isOpen = _bloc.state.drawerOpen;
    if (isOpen) {
      _closeDrawer();
    } else {
      _openDrawer();
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final isAr = loc.isArabic;

    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _bloc),
        BlocProvider(
          create: (context) => FavoritesBloc()..add(const LoadFavoritesEvent()),
        ),
      ],
      child: BlocListener<DashboardBloc, DashboardState>(
        listenWhen: (previous, current) =>
            previous.drawerOpen != current.drawerOpen,
        listener: (context, state) {
          if (state.drawerOpen) {
            _drawerController.forward();
          } else {
            _drawerController.reverse();
          }
        },
        child: BlocBuilder<DashboardBloc, DashboardState>(
          builder: (context, state) {
            final isReel = state.currentIndex == 2 && !state.drawerOpen;
            Color getTabIconColor(int index) {
              final activeIndex =
                  widget.customIndex ??
                  ((state.currentIndex == 5 ||
                          state.currentIndex == 6 ||
                          state.currentIndex == 7 ||
                          state.currentIndex == 8)
                      ? state.previousIndex
                      : state.currentIndex);
              final isSelected = activeIndex == index;
              if (isReel) {
                return isSelected
                    ? Colors.white
                    : Colors.white.withValues(alpha: 0.5);
              }
              return isSelected
                  ? context.palette.textPrimary
                  : context.palette.textMuted;
            }

            return Directionality(
              textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
              child: Scaffold(
                backgroundColor: context.palette.background,
                extendBody: state.currentIndex == 2 && !state.drawerOpen,
                  appBar: (() {
                    if (widget.body != null) {
                      return widget.body is WalletScreen ||
                             widget.body is AllTransactionsScreen ||
                             widget.body is AddressScreen ||
                             widget.body is AddEditAddressScreen ||
                             widget.body is ProductReviewsScreen ||
                             widget.body is WriteReviewScreen;
                    }
                    return !(state.currentIndex == 0 ||
                             state.currentIndex == 1 ||
                             state.currentIndex == 2 ||
                             state.currentIndex == 6 ||
                             state.currentIndex == 7);
                  })()
                      ? PreferredSize(
                         preferredSize: const Size.fromHeight(56),
                         child: Container(
                           color: context.palette.background,
                           child: SafeArea(
                             bottom: false,
                             child: Container(
                               height: 56,
                               padding: const EdgeInsets.symmetric(horizontal: 16),
                               child: Stack(
                                 alignment: Alignment.center,
                                 children: [
                                   // Centered Title
                                   Text(
                                     widget.body is WalletScreen
                                         ? loc.translate('refundWallet')
                                         : widget.body is AllTransactionsScreen
                                             ? loc.translate('allTransactionsTitle')
                                             : widget.body is AddressScreen
                                                 ? loc.translate('drawerMyAddresses')
                                                 : widget.body is AddEditAddressScreen
                                                     ? ((widget.body as AddEditAddressScreen).isEditMode
                                                         ? loc.translate('editAddressTitle')
                                                         : loc.translate('addAddress'))
                                                     : widget.body is ProductReviewsScreen
                                                         ? loc.translate('ratingsAndReviews')
                                                         : widget.body is WriteReviewScreen
                                                             ? loc.translate('addReview')
                                                             : 'SFA',
                                     style: GoogleFonts.cairo(
                                       fontSize: (widget.body is WalletScreen ||
                                               widget.body is AllTransactionsScreen ||
                                               widget.body is AddressScreen ||
                                               widget.body is AddEditAddressScreen ||
                                               widget.body is ProductReviewsScreen ||
                                               widget.body is WriteReviewScreen)
                                           ? 20
                                           : 24,
                                       fontWeight: FontWeight.bold,
                                       letterSpacing: (widget.body is WalletScreen ||
                                               widget.body is AllTransactionsScreen ||
                                               widget.body is AddressScreen ||
                                               widget.body is AddEditAddressScreen ||
                                               widget.body is ProductReviewsScreen ||
                                               widget.body is WriteReviewScreen)
                                           ? 0
                                           : 2.0,
                                       color: context.palette.textPrimary,
                                     ),
                                   ),
                                  // Left & Right Controls
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      // Left side (relative to screen space): Shopping Bag & Heart
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          GestureDetector(
                                            onTap: () {
                                              if (widget.body != null) {
                                                context.pop();
                                              }
                                              context.read<DashboardBloc>().add(
                                                const CacheCurrentTabEvent(),
                                              );
                                              context.read<DashboardBloc>().add(
                                                const ChangeTabEvent(5),
                                              );
                                            },
                                            child: Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: SvgPicture.asset(
                                                AssetsConstants.shoppingBag,
                                                width: 22,
                                                colorFilter: ColorFilter.mode(
                                                  context.palette.icon,
                                                  BlendMode.srcIn,
                                                ),
                                              ),
                                            ),
                                          ),
                                          GestureDetector(
                                            onTap: () {
                                              if (widget.body != null) {
                                                context.pop();
                                              }
                                              context.read<DashboardBloc>().add(
                                                const CacheCurrentTabEvent(),
                                              );
                                              context.read<DashboardBloc>().add(
                                                const ChangeTabEvent(8),
                                              );
                                            },
                                            child: Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: SvgPicture.asset(
                                                AssetsConstants.heart,
                                                width: 22,
                                                colorFilter: ColorFilter.mode(
                                                  context.palette.icon,
                                                  BlendMode.srcIn,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      // Right side (relative to screen space): Search & Menu/Back
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          GestureDetector(
                                            onTap: () {},
                                            child: Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: SvgPicture.asset(
                                                AssetsConstants.search,
                                                width: 22,
                                                colorFilter: ColorFilter.mode(
                                                  context.palette.icon,
                                                  BlendMode.srcIn,
                                                ),
                                              ),
                                            ),
                                          ),
                                          GestureDetector(
                                            onTap: () {
                                              if (state.currentIndex == 5 || widget.body is WalletScreen || widget.body is AllTransactionsScreen || widget.body is AddressScreen || widget.body is AddEditAddressScreen || widget.body is ProductReviewsScreen || widget.body is WriteReviewScreen) {
                                                if (widget.body is WalletScreen || widget.body is AllTransactionsScreen || widget.body is AddressScreen || widget.body is AddEditAddressScreen || widget.body is ProductReviewsScreen || widget.body is WriteReviewScreen) {
                                                  context.pop();
                                                } else {
                                                  context.read<DashboardBloc>().add(
                                                    const RestorePreviousTabEvent(),
                                                  );
                                                }
                                              } else {
                                                _toggleDrawer();
                                              }
                                            },
                                            child: Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: SvgPicture.asset(
                                                (state.currentIndex == 5 || widget.body is WalletScreen || widget.body is AllTransactionsScreen || widget.body is AddressScreen || widget.body is AddEditAddressScreen || widget.body is ProductReviewsScreen || widget.body is WriteReviewScreen)
                                                    ? AssetsConstants.back
                                                    : AssetsConstants.menu,
                                                width: 22,
                                                colorFilter: ColorFilter.mode(
                                                  context.palette.icon,
                                                  BlendMode.srcIn,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ) : null,

                // ─── Body + Drawer overlay ────────────────────────────────────
                body: Stack(
                  children: [
                    // Main pages
                    widget.body ??
                        IndexedStack(
                          index: state.currentIndex,
                          children: _pages,
                        ),

                    // Scrim — only rendered when drawer is open or animating
                    if (state.drawerOpen)
                      AnimatedBuilder(
                        animation: _scrimOpacity,
                        builder: (_, __) => GestureDetector(
                          onTap: _closeDrawer,
                          child: Container(
                            color: Colors.black.withValues(
                              alpha: _scrimOpacity.value,
                            ),
                          ),
                        ),
                      ),

                    // Drawer panel
                    if (state.drawerOpen)
                      AnimatedBuilder(
                        animation: _drawerSlide,
                        builder: (_, child) {
                          final offset = isAr
                              ? Offset(1.0 - _drawerSlide.value, 0)
                              : Offset(_drawerSlide.value - 1.0, 0);
                          return FractionalTranslation(
                            translation: offset,
                            child: child,
                          );
                        },
                        child: AppDrawer(
                          isAr: isAr,
                          loc: loc,
                          onClose: _closeDrawer,
                        ),
                      ),
                  ],
                ),

                bottomNavigationBar: BottomNavigationBar(
                  currentIndex:
                      widget.customIndex ??
                      ((state.currentIndex == 5 ||
                              state.currentIndex == 6 ||
                              state.currentIndex == 7 ||
                              state.currentIndex == 8)
                          ? state.previousIndex
                          : state.currentIndex),
                  onTap: (index) {
                    if (state.drawerOpen) {
                      _closeDrawer();
                    }
                    if (widget.body != null) {
                      context.go('/dashboard?tab=$index');
                    } else {
                      _bloc.add(ChangeTabEvent(index));
                    }
                  },
                  type: BottomNavigationBarType.fixed,
                  backgroundColor: isReel
                      ? Colors.white.withValues(alpha: 0.05)
                      : context.palette.surface,
                  elevation: isReel ? 0 : 8,
                  selectedItemColor: isReel
                      ? Colors.white
                      : context.palette.textPrimary,
                  unselectedItemColor: isReel
                      ? Colors.white.withValues(alpha: 0.5)
                      : context.palette.textMuted,
                  selectedLabelStyle: AppStyle.navLabel.copyWith(
                    color: isReel ? Colors.white : context.palette.textPrimary,
                  ),
                  unselectedLabelStyle: AppStyle.navLabel.copyWith(
                    fontWeight: FontWeight.normal,
                    color: isReel
                        ? Colors.white.withValues(alpha: 0.5)
                        : context.palette.textMuted,
                  ),
                  items: [
                    BottomNavigationBarItem(
                      icon: SvgPicture.asset(
                        AssetsConstants.house3,
                        width: 22,
                        colorFilter: ColorFilter.mode(
                          getTabIconColor(0),
                          BlendMode.srcIn,
                        ),
                      ),
                      label: loc.translate('home'),
                    ),
                    BottomNavigationBarItem(
                      icon: SvgPicture.asset(
                        AssetsConstants.store2,
                        width: 22,
                        colorFilter: ColorFilter.mode(
                          getTabIconColor(1),
                          BlendMode.srcIn,
                        ),
                      ),
                      label: loc.translate('brands'),
                    ),
                    BottomNavigationBarItem(
                      icon: SvgPicture.asset(
                        AssetsConstants.tvMinimalPlay,
                        width: 22,
                        colorFilter: ColorFilter.mode(
                          getTabIconColor(2),
                          BlendMode.srcIn,
                        ),
                      ),
                      label: loc.translate('reels'),
                    ),
                    BottomNavigationBarItem(
                      icon: SvgPicture.asset(
                        AssetsConstants.circleUser3,
                        width: 22,
                        colorFilter: ColorFilter.mode(
                          getTabIconColor(3),
                          BlendMode.srcIn,
                        ),
                      ),
                      label: loc.translate('myAccount'),
                    ),
                    BottomNavigationBarItem(
                      icon: SvgPicture.asset(
                        AssetsConstants.bell,
                        width: 22,
                        colorFilter: ColorFilter.mode(
                          getTabIconColor(4),
                          BlendMode.srcIn,
                        ),
                      ),
                      label: loc.translate('notifications'),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Drawer Widget
// ─────────────────────────────────────────────────────────────────────────────

class AppDrawer extends StatelessWidget {
  final bool isAr;
  final AppLocalizations loc;
  final VoidCallback onClose;

  const AppDrawer({
    required this.isAr,
    required this.loc,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // warm off-white in light, raised maroon in dark
      backgroundColor: context.palette.surfaceWarm,
      body: SafeArea(
        child: Directionality(
          textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),

              // ── Menu items ──
              _DrawerItem(
                icon: AssetsConstants.circleUser2,
                label: loc.translate('drawerLoginRegister'),
                isAr: isAr,
                onTap: () {
                  onClose();
                  context.push('/login');
                },
              ),
              _buildDivider(context),

              _DrawerItem(
                icon: AssetsConstants.globe,
                label: loc.translate('drawerChangeLanguage'),
                isAr: isAr,
                trailing: Text(
                  isAr ? 'English' : 'عربي',
                  style: AppStyle.drawerLanguageTag,
                ),
                onTap: () {
                  onClose();
                  localeNotifier.toggleLanguage();
                },
              ),
              _buildDivider(context),

              _DrawerItem(
                icon: AssetsConstants.shoppingBag2,
                label: loc.translate('drawerBrowseProducts'),
                isAr: isAr,
                onTap: () {
                  onClose();
                },
              ),
              _buildDivider(context),

              _DrawerItem(
                icon: AssetsConstants.trackOrder,
                label: loc.translate('drawerTrackOrders'),
                isAr: isAr,
                onTap: () {
                  onClose();
                  context.push('/order-tracking');
                },
              ),
              _buildDivider(context),

              _DrawerItem(
                icon: AssetsConstants.mapPin,
                label: loc.translate('drawerMyAddresses'),
                isAr: isAr,
                onTap: () {
                  onClose();
                  context.push('/addresses');
                },
              ),
              _buildDivider(context),

              _DrawerItem(
                icon: AssetsConstants.walletCards,
                label: loc.translate('refundWallet'),
                isAr: isAr,
                onTap: () {
                  onClose();
                  context.push('/wallet');
                },
              ),
              _buildDivider(context),

              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDivider(BuildContext context) => Divider(
    color: context.palette.divider,
    thickness: 0.8,
    height: 0,
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Single Drawer Row
// ─────────────────────────────────────────────────────────────────────────────

class _DrawerItem extends StatelessWidget {
  final String icon;
  final String label;
  final bool isAr;
  final Widget? trailing;
  final VoidCallback onTap;

  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.isAr,
    required this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    // Arabic:  [icon] [label + trailing]  [←]
    // English: [icon] [label + trailing]  [→]
    final chevron = Directionality(
      textDirection: TextDirection.ltr,
      child: Icon(
        isAr ? Icons.chevron_left_rounded : Icons.chevron_right_rounded,
        color: context.palette.textMuted,
        size: 22,
      ),
    );

    final iconWidget = SvgPicture.asset(
      icon,
      width: 22,
      height: 22,
      colorFilter: ColorFilter.mode(context.palette.icon, BlendMode.srcIn),
    );

    return InkWell(
      onTap: onTap,
      splashColor: AppColors.primary.withValues(alpha: 0.08),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        child: Row(
          children: [
            // Icon always on the left edge
            iconWidget,
            const SizedBox(width: 12),
            // Label + optional trailing fills remaining space
            Expanded(
              child: Row(
                children: [
                  Text(label, style: AppStyle.drawerItemLabel),
                  if (trailing != null) ...[
                    const SizedBox(width: 8),
                    trailing!,
                  ],
                ],
              ),
            ),
            // Arrow on the right edge — direction depends on locale
            chevron,
          ],
        ),
      ),
    );
  }
}
