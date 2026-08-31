import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sfa/utils/Values.dart';
import 'package:sfa/utils/app_style.dart';

class CategoryBannersSection extends StatelessWidget {
  final bool isAr;

  const CategoryBannersSection({super.key, required this.isAr});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: Values.horizontalPadding,
        vertical: 12,
      ),
      child: Column(
        children: [
          _buildBannerCard(
            context,
            imageUrl:
                'https://images.unsplash.com/photo-1508214751196-bcfd4ca60f91?w=600&q=80',
            title: isAr ? 'منتجات نسائية' : "Women's Products",
            alignment: isAr ? Alignment.centerRight : Alignment.centerLeft,
            gradientBegin: isAr ? Alignment.centerRight : Alignment.centerLeft,
            gradientEnd: isAr ? Alignment.centerLeft : Alignment.centerRight,
          ),
          const SizedBox(height: 4),
          _buildBannerCard(
            context,
            imageUrl:
                'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=600&q=80',
            title: isAr ? 'منتجات رجالية' : "Men's Products",
            alignment: isAr ? Alignment.centerLeft : Alignment.centerRight,
            gradientBegin: isAr ? Alignment.centerLeft : Alignment.centerRight,
            gradientEnd: isAr ? Alignment.centerRight : Alignment.centerLeft,
          ),
          const SizedBox(height: 4),
          _buildBannerCard(
            context,
            imageUrl:
                'https://images.unsplash.com/photo-1502086223501-7ea6ecd79368?w=600&q=80',
            title: isAr ? 'منتجات للأطفال' : "Kids' Products",
            alignment: isAr ? Alignment.centerRight : Alignment.centerLeft,
            gradientBegin: isAr ? Alignment.centerRight : Alignment.centerLeft,
            gradientEnd: isAr ? Alignment.centerLeft : Alignment.centerRight,
          ),
        ],
      ),
    );
  }

  Widget _buildBannerCard(
    BuildContext context, {
    required String imageUrl,
    required String title,
    required Alignment alignment,
    required Alignment gradientBegin,
    required Alignment gradientEnd,
  }) {
    return GestureDetector(
      onTap: () => context.push('/featured-products'),
      child: Container(
        height: 160,
        width: double.infinity,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(4)),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Background Image
              Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: const Color(0xFF1E1B18),
                    child: const Icon(Icons.image, color: Colors.white24),
                  );
                },
              ),
              // Gradient Overlay (shading on the text side)
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: gradientBegin,
                    end: gradientEnd,
                    colors: [
                      Colors.black.withValues(alpha: 0.55),
                      Colors.black.withValues(alpha: 0.2),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
              // Text Label
              Align(
                alignment: alignment,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    title,
                    style: AppStyle.bannerTitle.copyWith(fontSize: 24),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
