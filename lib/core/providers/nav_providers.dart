import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The bottom-nav tab index (0-4: Home, Brands, Reels, Profile, Notifications)
/// that should read as "active". Kept in sync with the shell's active branch;
/// screens pushed on top of the shell (cart, brand detail, wallet, ...) leave
/// it untouched so the bottom nav keeps highlighting whichever tab the user
/// came from.
final highlightedTabIndexProvider = StateProvider<int>((ref) => 0);

/// Whether the app drawer is open. Read/set from anywhere (shell tabs open
/// it via the menu icon; the shell itself drives the slide/scrim animation).
final drawerOpenProvider = StateProvider<bool>((ref) => false);
