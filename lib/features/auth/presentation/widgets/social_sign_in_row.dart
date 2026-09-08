import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/network/app_config.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../utils/app_style.dart';
import '../../../../utils/assets_constants.dart';
import '../../providers/auth_provider.dart';

/// The "Apple / Google" pill row shared by the login and signup screens.
///
/// Apple drops out of the row on platforms where it can't run — Android
/// without the Services ID pair configured (see
/// [SocialAuthConfig.socialAppleEnabled]) — leaving Google full width
/// rather than a dead button.
class SocialSignInRow extends ConsumerWidget {
  const SocialSignInRow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context);
    final busy = ref.watch(authProvider).status == AuthStatus.loading;
    final notifier = ref.read(authProvider.notifier);

    final googleButton = _SocialButton(
      label: loc.translate('google'),
      iconAsset: AssetsConstants.googlePng,
      onPressed: busy ? null : notifier.signInWithGoogle,
    );

    if (!SocialAuthConfig.socialAppleEnabled) {
      return googleButton;
    }

    return Row(
      children: [
        Expanded(
          child: _SocialButton(
            label: loc.translate('apple'),
            iconAsset: AssetsConstants.applePng,
            onPressed: busy ? null : notifier.signInWithApple,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(child: googleButton),
      ],
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({
    required this.label,
    required this.iconAsset,
    required this.onPressed,
  });

  final String label;
  final String iconAsset;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14),
        side: BorderSide(color: context.palette.outlineStrong, width: 1.2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(iconAsset, width: 18, height: 18),
          const SizedBox(width: 8),
          Text(label, style: AppStyle.buttonTextSocial),
        ],
      ),
    );
  }
}
