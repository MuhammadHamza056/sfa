import 'package:flutter/material.dart';
import 'package:sfa/utils/app_style.dart';
import 'package:sfa/core/theme/app_palette.dart';
import 'package:go_router/go_router.dart';

class ReelsSection extends StatelessWidget {
  final bool isAr;

  const ReelsSection({
    super.key,
    required this.isAr,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: context.palette.background,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        vertical: 24,
        horizontal: 16,
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
                onTap: () => context.push('/featured-products'),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
                  children: [
                    if (isAr) ...[
                      Text(
                        'عرض الكل',
                        style: AppStyle.labelTextMuted.copyWith(
                          color: context.palette.textMuted,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 12,
                        color: context.palette.textMuted,
                      ),
                    ] else ...[
                      Text(
                        'View All',
                        style: AppStyle.labelTextMuted.copyWith(
                          color: context.palette.textMuted,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 12,
                        color: context.palette.textMuted,
                      ),
                    ],
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
                  _buildReelCard(
                    context,
                    imageUrl: 'https://images.unsplash.com/photo-1529139574466-a303027c1d8b?w=400&q=80',
                    avatarUrl: 'https://images.unsplash.com/photo-1607990283143-e81e7a2c93ab?w=100&q=80',
                    name: isAr ? 'سمر_شوب' : 'Summer Shop',
                    isAr: isAr,
                  ),
                  const SizedBox(width: 8),
                  _buildReelCard(
                    context,
                    imageUrl: 'https://images.unsplash.com/photo-1607990283143-e81e7a2c93ab?w=400&q=80',
                    avatarUrl: 'https://images.unsplash.com/photo-1529139574466-a303027c1d8b?w=100&q=80',
                    name: isAr ? 'سمر_شوب' : 'Summer Shop',
                    isAr: isAr,
                  ),
                  const SizedBox(width: 8),
                  _buildReelCard(
                    context,
                    imageUrl: 'https://images.unsplash.com/photo-1609357605129-26f69add5d6e?w=400&q=80',
                    avatarUrl: 'https://images.unsplash.com/photo-1607990283143-e81e7a2c93ab?w=100&q=80',
                    name: isAr ? 'جوبا' : 'Juba',
                    isAr: isAr,
                  ),
                  const SizedBox(width: 8),
                  _buildReelCard(
                    context,
                    imageUrl: 'https://images.unsplash.com/photo-1529139574466-a303027c1d8b?w=400&q=80',
                    avatarUrl: 'https://images.unsplash.com/photo-1607990283143-e81e7a2c93ab?w=100&q=80',
                    name: isAr ? 'سمر_شوب' : 'Summer Shop',
                    isAr: isAr,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReelCard(
    BuildContext context, {
    required String imageUrl,
    required String avatarUrl,
    required String name,
    required bool isAr,
  }) {
    return SizedBox(
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
            // Brand Label
            Positioned(
              left: 8,
              right: 8,
              bottom: 8,
              child: Text(
                name,
                textAlign: isAr ? TextAlign.right : TextAlign.left,
                style: AppStyle.brandCardLabel.copyWith(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ),
            // Circular Avatar/Profile floating on top-right
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFFC29A5B),
                    width: 1.5,
                  ),
                ),
                child: CircleAvatar(
                  radius: 18,
                  backgroundImage: NetworkImage(avatarUrl),
                  backgroundColor: context.palette.surfaceMuted,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
