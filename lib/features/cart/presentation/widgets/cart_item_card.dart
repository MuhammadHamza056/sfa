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
  final Color? itemColor;
  final String? size;
  final int quantity;
  final bool showWarning;
  final bool isDeleting;
  final bool isFavoriting;
  final VoidCallback? onDelete;
  final VoidCallback? onFavorite;
  final ValueChanged<int>? onQuantityChanged;

  const CartItemCard({
    super.key,
    required this.imageUrl,
    required this.brand,
    required this.title,
    required this.price,
    this.itemColor,
    this.size,
    required this.quantity,
    required this.showWarning,
    this.isDeleting = false,
    this.isFavoriting = false,
    this.onDelete,
    this.onFavorite,
    this.onQuantityChanged,
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

                      for (final row in _buildRows(context, loc))
                        row,
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
              Expanded(
                child: _buildActionButton(
                  context: context,
                  iconPath: AssetsConstants.heartPlus,
                  label: loc.translate('favorite'),
                  onPressed: onFavorite,
                  isLoading: isFavoriting,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionButton(
                  context: context,
                  iconPath: AssetsConstants.trash,
                  label: loc.translate('delete'),
                  onPressed: onDelete,
                  isLoading: isDeleting,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required String iconPath,
    required String label,
    required bool isLoading,
    VoidCallback? onPressed,
  }) {
    return OutlinedButton(
      onPressed: isLoading ? null : onPressed,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        side: BorderSide(color: context.palette.divider, width: 1.2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
      child: isLoading
          ? SizedBox(
              height: 18,
              width: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(context.palette.textMuted),
              ),
            )
          : Row(
              textDirection: TextDirection.ltr,
              children: [
                SvgPicture.asset(
                  iconPath,
                  width: 22,
                  height: 22,
                  colorFilter: ColorFilter.mode(context.palette.textMuted, BlendMode.srcIn),
                ),
                Expanded(
                  child: Text(
                    label,
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
    );
  }

  /// Color/size rows only appear when the line actually has that
  /// attribute — plenty of products carry neither. Quantity always shows.
  /// A divider separates each row that's actually rendered, with none
  /// trailing the last one.
  List<Widget> _buildRows(BuildContext context, AppLocalizations loc) {
    final attributeRows = <Widget>[
      if (itemColor != null)
        _buildAttributeRow(
          label: loc.translate('colorLabel'),
          valueWidget: Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(color: itemColor, shape: BoxShape.circle),
          ),
        ),
      if (size != null && size!.isNotEmpty)
        _buildAttributeRow(
          label: loc.translate('sizeLabel'),
          valueWidget: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: context.palette.surfaceMuted,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              size!,
              style: AppStyle.fieldLabel.copyWith(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      _buildAttributeRow(
        label: loc.translate('quantityLabel'),
        valueWidget: _buildQuantityPicker(context),
      ),
    ];

    final rows = <Widget>[];
    for (var i = 0; i < attributeRows.length; i++) {
      rows.add(attributeRows[i]);
      if (i != attributeRows.length - 1) {
        rows.add(Divider(height: 1, thickness: 0.5, color: context.palette.divider));
      }
    }
    return rows;
  }

  /// Offers quantity-5..quantity+5 (clamped to a minimum of 1) rather than
  /// an open-ended list, since re-picking a wildly different quantity is
  /// rare — most edits are a small nudge up or down from what's in the cart.
  Widget _buildQuantityPicker(BuildContext context) {
    return PopupMenuButton<int>(
      enabled: onQuantityChanged != null,
      onSelected: onQuantityChanged,
      itemBuilder: (context) {
        final lowest = quantity - 5 < 1 ? 1 : quantity - 5;
        return [
          for (var q = lowest; q <= quantity + 5; q++)
            PopupMenuItem<int>(value: q, child: Text(q.toString())),
        ];
      },
      child: Container(
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
              style: AppStyle.fieldLabel.copyWith(fontSize: 12, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 4),
            Icon(Icons.keyboard_arrow_down, size: 14, color: context.palette.textPrimary),
          ],
        ),
      ),
    );
  }

  Widget _buildAttributeRow({
    required String label,
    required Widget valueWidget,
  }) {
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
