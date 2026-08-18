import 'package:flutter/material.dart';

import 'app_palette.dart';
import 'app_theme.dart';

/// Pins its subtree to the light palette.
///
/// The design deliberately keeps some surfaces white in both themes — the
/// product grid cards and the promo panels that sit on top of photography.
/// Wrapping those in [AlwaysLight] keeps `context.palette` and the inherited
/// `DefaultTextStyle` on the light roles, so their labels stay legible when the
/// rest of the app switches to the dark maroon.
class AlwaysLight extends StatelessWidget {
  final Widget child;

  const AlwaysLight({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.light,
      child: DefaultTextStyle.merge(
        style: const TextStyle(color: AppPalette.lightTextPrimary),
        child: child,
      ),
    );
  }
}
