import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:sfa/utils/app_style.dart';
import 'package:sfa/core/localization/app_localizations.dart';

class BrandCard extends StatelessWidget {
  final String imageUrl;
  final String brandName;
  final VoidCallback? onTap;

  const BrandCard({
    super.key,
    required this.imageUrl,
    required this.brandName,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // ── Background image ──
          CachedNetworkImage(
            imageUrl: imageUrl,
            fit: BoxFit.cover,
            placeholder: (_, __) => Container(
              color: const Color(0xFF1A1A1A),
              child: const Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 1.5,
                    color: Colors.white38,
                  ),
                ),
              ),
            ),
            errorWidget: (_, __, ___) => Container(
              color: const Color(0xFF1A1A1A),
              child: const Icon(
                Icons.image_not_supported_outlined,
                color: Colors.white24,
                size: 28,
              ),
            ),
          ),

          // ── Gradient scrim at bottom ──
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              height: 50,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Color(0x99000000), Colors.transparent],
                ),
              ),
            ),
          ),

          // ── Brand name label ──
          Positioned(
            left: 6,
            right: 6,
            bottom: 8,
            child: Text(
              loc.translate(brandName),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppStyle.brandCardLabel.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                shadows: [
                  const Shadow(
                    color: Colors.black54,
                    blurRadius: 4,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
