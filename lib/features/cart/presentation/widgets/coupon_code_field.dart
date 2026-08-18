import 'package:flutter/material.dart';
import 'package:sfa/core/localization/app_localizations.dart';
import 'package:sfa/utils/color_constants.dart';
import 'package:sfa/utils/app_style.dart';
import 'package:sfa/core/theme/app_palette.dart';

class CouponCodeField extends StatelessWidget {
  final TextEditingController? controller;
  final VoidCallback? onApply;

  const CouponCodeField({
    super.key,
    this.controller,
    this.onApply,
  });

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          loc.translate('couponCode'),
          style: AppStyle.fieldLabel.copyWith(
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: context.palette.backgroundSubtle,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: context.palette.divider, width: 1.2),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 10),
                  ),
                  style: AppStyle.fieldLabel.copyWith(fontSize: 14),
                ),
              ),
              OutlinedButton(
                onPressed: onApply,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                  side: BorderSide(color: AppColors.primary, width: 1.2),
                  backgroundColor: context.palette.surfaceMuted,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  loc.translate('apply'),
                  style: AppStyle.fieldLabel.copyWith(
                    color: AppColors.primary,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
