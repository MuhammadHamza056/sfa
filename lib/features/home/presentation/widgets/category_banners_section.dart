import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sfa/utils/Values.dart';
import 'package:sfa/utils/app_style.dart';
import 'package:sfa/features/catalog/providers/catalog_providers.dart';
import 'package:sfa/features/brands/models/brand_nav_args.dart';

class CategoryBannersSection extends ConsumerWidget {
  final bool isAr;

  const CategoryBannersSection({super.key, required this.isAr});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bannersAsync = ref.watch(bannersProvider);

    return bannersAsync.maybeWhen(
      data: (banners) {
        if (banners.isEmpty) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: Values.horizontalPadding,
            vertical: 12,
          ),
          child: Column(
            children: [
              for (var i = 0; i < banners.length; i++) ...[
                if (i > 0) const SizedBox(height: 4),
                _buildBannerCard(
                  context,
                  imageUrl: banners[i].imageUrl,
                  title: banners[i].title.resolve(isAr),
                  alignment: i.isEven
                      ? (isAr ? Alignment.centerRight : Alignment.centerLeft)
                      : (isAr ? Alignment.centerLeft : Alignment.centerRight),
                  gradientBegin: i.isEven
                      ? (isAr ? Alignment.centerRight : Alignment.centerLeft)
                      : (isAr ? Alignment.centerLeft : Alignment.centerRight),
                  gradientEnd: i.isEven
                      ? (isAr ? Alignment.centerLeft : Alignment.centerRight)
                      : (isAr ? Alignment.centerRight : Alignment.centerLeft),
                  linkType: banners[i].linkType,
                  linkId: banners[i].linkId,
                ),
              ],
            ],
          ),
        );
      },
      orElse: () => const SizedBox.shrink(),
    );
  }

  Widget _buildBannerCard(
    BuildContext context, {
    required String imageUrl,
    required String title,
    required Alignment alignment,
    required Alignment gradientBegin,
    required Alignment gradientEnd,
    String? linkType,
    String? linkId,
  }) {
    return GestureDetector(
      onTap: () {
        if (linkType == 'category' && linkId != null) {
          context.push('/featured-products');
        } else if (linkType == 'brand' && linkId != null) {
          context.push('/brand-detail', extra: BrandNavArgs(id: linkId, name: title));
        } else {
          context.push('/featured-products');
        }
      },
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
