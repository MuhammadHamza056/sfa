import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sfa/utils/Values.dart';
import 'package:sfa/utils/app_style.dart';
import 'package:sfa/core/theme/app_palette.dart';
import 'package:go_router/go_router.dart';
import 'package:sfa/features/catalog/providers/catalog_providers.dart';

class ReelsSection extends ConsumerWidget {
  final bool isAr;

  const ReelsSection({super.key, required this.isAr});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feedAsync = ref.watch(homeFeedProvider);

    return feedAsync.maybeWhen(
      data: (feed) {
        if (feed.reels.isEmpty) return const SizedBox.shrink();
        return Container(
          color: context.palette.background,
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            vertical: 24,
            horizontal: Values.horizontalPadding,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title Row
              Row(
                textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isAr ? 'من الريلز' : 'From Reels',
                    style: AppStyle.sectionHeader.copyWith(
                      color: context.palette.textPrimary,
                      fontSize: 20,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => context.push('/reels'),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
                      children: [
                        Text(
                          isAr ? 'عرض الكل' : 'View All',
                          style: AppStyle.labelTextMuted.copyWith(
                            color: context.palette.textMuted,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(Icons.arrow_forward_ios, size: 12, color: context.palette.textMuted),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Divider(color: context.palette.divider, thickness: 1),
              const SizedBox(height: 16),
              // Reels Horizontal List
              Directionality(
                textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    children: [
                      for (var i = 0; i < feed.reels.length; i++) ...[
                        if (i > 0) const SizedBox(width: 8),
                        _buildReelCard(
                          context,
                          imageUrl: feed.reels[i].thumbnailUrl,
                          likesCount: feed.reels[i].likesCount,
                          isAr: isAr,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
      orElse: () => const SizedBox.shrink(),
    );
  }

  Widget _buildReelCard(
    BuildContext context, {
    required String imageUrl,
    required int likesCount,
    required bool isAr,
  }) {
    return GestureDetector(
      onTap: () => context.push('/reels'),
      child: SizedBox(
        width: 140,
        child: AspectRatio(
          aspectRatio: 0.6,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Background Image
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: const Color(0xFF1E1B18),
                      child: const Icon(Icons.image, color: Colors.white24),
                    );
                  },
                ),
              ),
              // Bottom gradient scrim
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(4),
                    bottomRight: Radius.circular(4),
                  ),
                  child: Container(
                    height: 60,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.85),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              // Likes count
              Positioned(
                left: 8,
                right: 8,
                bottom: 8,
                child: Row(
                  mainAxisAlignment:
                      isAr ? MainAxisAlignment.end : MainAxisAlignment.start,
                  children: [
                    const Icon(Icons.favorite, size: 14, color: Colors.white),
                    const SizedBox(width: 4),
                    Text(
                      '$likesCount',
                      style: AppStyle.brandCardLabel.copyWith(
                        color: Colors.white,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
