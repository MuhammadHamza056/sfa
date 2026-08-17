import 'package:flutter/material.dart';
import 'package:sfa/core/localization/app_localizations.dart';
import 'package:sfa/utils/color_constants.dart';
import 'package:sfa/utils/app_style.dart';

class PricingSummary extends StatelessWidget {
  final String subtotal;
  final String total;

  /// When provided, an extra "الخصم بالنقط / Points Discount" row is shown
  /// between the subtotal and total rows.
  final String? pointsDiscount;

  const PricingSummary({
    super.key,
    required this.subtotal,
    required this.total,
    this.pointsDiscount,
  });

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Column(
      children: [
        // Subtotal row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              loc.translate('subtotal'),
              style: AppStyle.subtitleDesc.copyWith(fontSize: 14),
            ),
            Text(subtotal, style: AppStyle.fieldLabel.copyWith(fontSize: 14)),
          ],
        ),

        // Points discount row — only shown when pointsDiscount is provided
        if (pointsDiscount != null) ...[
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                loc.translate('pointsDiscountLabel'),
                style: AppStyle.subtitleDesc.copyWith(fontSize: 14),
              ),
              Text(
                pointsDiscount!,
                style: AppStyle.fieldLabel.copyWith(fontSize: 14),
              ),
            ],
          ),
        ],

        const SizedBox(height: 12),

        // Total row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              loc.translate('totalAmount'),
              style: AppStyle.subtitleDesc.copyWith(fontSize: 14),
            ),
            Text(
              total,
              style: AppStyle.welcomeTitle.copyWith(
                color: AppColors.primary,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
