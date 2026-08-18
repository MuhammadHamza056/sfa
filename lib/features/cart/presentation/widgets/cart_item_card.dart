import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sfa/core/localization/app_localizations.dart';
import 'package:sfa/utils/assets_constants.dart';
import 'package:sfa/utils/color_constants.dart';
import 'package:sfa/utils/app_style.dart';
import 'package:sfa/core/theme/app_palette.dart';

class CartItemCard extends StatelessWidget {
  final String imageUrl;
  final String brand;
  final String title;
  final String price;
  final Color itemColor;
  final String size;
  final int quantity;
  final bool showWarning;
  final VoidCallback? onDelete;
  final VoidCallback? onFavorite;

  const CartItemCard({
    super.key,
    required this.imageUrl,
    required this.brand,
    required this.title,
    required this.price,
    required this.itemColor,
    required this.size,
    required this.quantity,
    required this.showWarning,
    this.onDelete,
    this.onFavorite,
  });

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        children: [
          // Top Row: Details & Image
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Details Column
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        brand,
                        style: AppStyle.subtitleDesc.copyWith(
                          color: AppColors.primary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        title,
                        style: AppStyle.welcomeTitle.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        price,
                        style: AppStyle.welcomeTitle.copyWith(
                          color: AppColors.primary,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Low Quantity Warning
                      if (showWarning) ...[
                        Row(
                          children: [
                            SvgPicture.asset(
                              AssetsConstants.clock3,
                              width: 14,
                              height: 14,
                              colorFilter: ColorFilter.mode(
                                AppColors.redcolor,
                                BlendMode.srcIn,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                loc.translate('lowQuantityWarning'),
                                style: AppStyle.subtitleDesc.copyWith(
                                  color: AppColors.redcolor,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                      ],

                      Divider(height: 1, thickness: 0.5, color: context.palette.divider),

                      // Color Row
                      _buildAttributeRow(
                        label: loc.translate('colorLabel'),
                        valueWidget: Container(
                          width: 18,
                          height: 18,
                          decoration: BoxDecoration(
                            color: itemColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      Divider(height: 1, thickness: 0.5, color: context.palette.divider),

                      // Size Row
                      _buildAttributeRow(
                        label: loc.translate('sizeLabel'),
                        valueWidget: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: context.palette.surfaceMuted,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            size,
                            style: AppStyle.fieldLabel.copyWith(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      Divider(height: 1, thickness: 0.5, color: context.palette.divider),

                      // Quantity Row
                      _buildAttributeRow(
                        label: loc.translate('quantityLabel'),
                        valueWidget: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: context.palette.surfaceMuted,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                quantity.toString(),
                                style: AppStyle.fieldLabel.copyWith(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                Icons.keyboard_arrow_down,
                                size: 14,
                                color: context.palette.textPrimary,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),

                // Product Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    imageUrl,
                    width: 120,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 120,
                      color: context.palette.surfaceMuted,
                      child: const Icon(Icons.broken_image, color: Colors.grey),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Bottom Row: Action Buttons
          Row(
            children: [
              // Favorite Button
              Expanded(
                child: OutlinedButton(
                  onPressed: onFavorite,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                    side: BorderSide(color: context.palette.divider, width: 1.2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Row(
                    textDirection: TextDirection.ltr,
                    children: [
                      SvgPicture.asset(
                        AssetsConstants.heartPlus,
                        width: 22,
                        height: 22,
                        colorFilter: ColorFilter.mode(
                          context.palette.textMuted,
                          BlendMode.srcIn,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          loc.translate('favorite'),
                          textAlign: TextAlign.right,
                          style: AppStyle.fieldLabel.copyWith(
                            color: context.palette.textMuted,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Delete Button
              Expanded(
                child: OutlinedButton(
                  onPressed: onDelete,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                    side: BorderSide(color: context.palette.divider, width: 1.2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Row(
                    textDirection: TextDirection.ltr,
                    children: [
                      SvgPicture.asset(
                        AssetsConstants.trash,
                        width: 22,
                        height: 22,
                        colorFilter: ColorFilter.mode(
                          context.palette.textMuted,
                          BlendMode.srcIn,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          loc.translate('delete'),
                          textAlign: TextAlign.right,
                          style: AppStyle.fieldLabel.copyWith(
                            color: context.palette.textMuted,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAttributeRow({required String label, required Widget valueWidget}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppStyle.subtitleDesc.copyWith(fontSize: 13),
          ),
          valueWidget,
        ],
      ),
    );
  }
}
