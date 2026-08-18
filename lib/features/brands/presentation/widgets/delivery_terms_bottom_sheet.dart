import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sfa/core/localization/app_localizations.dart';
import 'package:sfa/core/theme/app_palette.dart';
import 'package:sfa/utils/app_style.dart';
import 'package:sfa/utils/assets_constants.dart';
import 'package:sfa/utils/color_constants.dart';

/// Bottom sheet showing the delivery time tiers and free-return policy,
/// matching the Figma "Delivery and free returns conditions" sheet
/// (node 434:462).
class DeliveryTermsBottomSheet extends StatelessWidget {
  const DeliveryTermsBottomSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const DeliveryTermsBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return SafeArea(
      top: false,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        decoration: BoxDecoration(
          color: context.palette.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _Header(title: loc.translate('freeDeliveryTitle')),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      loc.translate('deliveryTermsIntro'),
                      textAlign: TextAlign.start,
                      style: AppStyle.bodyText.copyWith(
                        fontSize: 15,
                        height: 1.9,
                        color: context.palette.textPrimary,
                      ),
                    ),
                    _DeliveryTier(
                      title: loc.translate('delivery3HoursTitle'),
                      freeText: loc.translate('deliveryFreeOver500Sar'),
                      paidText: loc.translate('delivery3HoursPaid'),
                      extraText: loc.translate('delivery3HoursWindow'),
                    ),
                    _DeliveryTier(
                      title: loc.translate('deliverySameDayTitle'),
                      freeText: loc.translate('deliveryFreeOver500Sar'),
                      paidText: loc.translate('deliverySameDayPaid'),
                    ),
                    _DeliveryTier(
                      title: loc.translate('deliveryNextDayTitle'),
                      freeText: loc.translate('deliveryFreeOver500Sar'),
                      paidText: loc.translate('deliveryNextDayPaid'),
                    ),
                    const SizedBox(height: 8),
                    Divider(
                      height: 1,
                      thickness: 1,
                      color: context.palette.divider,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      loc.translate('freeReturnsTitle'),
                      textAlign: TextAlign.start,
                      style: AppStyle.bodyText.copyWith(
                        fontSize: 18,
                        color: context.palette.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      loc.translate('freeReturnsDescription'),
                      textAlign: TextAlign.start,
                      style: AppStyle.bodyText.copyWith(
                        fontSize: 15,
                        height: 1.9,
                        color: context.palette.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SvgPicture.asset(
                            AssetsConstants.moveLeft,
                            width: 18,
                            height: 18,
                            colorFilter: ColorFilter.mode(
                              AppColors.primary,
                              BlendMode.srcIn,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            loc.translate('freeReturnsMoreLink'),
                            style: AppStyle.bodyText.copyWith(
                              fontSize: 13,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final String title;

  const _Header({required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: context.palette.divider, width: 1),
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 56, vertical: 20),
            child: Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppStyle.bodyText.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: context.palette.textPrimary,
              ),
            ),
          ),
          Positioned(
            right: 4,
            child: IconButton(
              icon: Icon(
                Icons.close,
                color: context.palette.textPrimary,
                size: 22,
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ],
      ),
    );
  }
}

class _DeliveryTier extends StatelessWidget {
  final String title;
  final String freeText;
  final String paidText;
  final String? extraText;

  const _DeliveryTier({
    required this.title,
    required this.freeText,
    required this.paidText,
    this.extraText,
  });

  @override
  Widget build(BuildContext context) {
    final bodyStyle = AppStyle.bodyText.copyWith(
      fontSize: 15,
      height: 1.9,
      color: context.palette.textPrimary,
    );

    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 5,
                height: 5,
                margin: const EdgeInsets.only(top: 12),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: context.palette.textPrimary,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  textAlign: TextAlign.start,
                  style: bodyStyle.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsetsDirectional.only(start: 13),
            child: Text(freeText, textAlign: TextAlign.start, style: bodyStyle),
          ),
          Padding(
            padding: const EdgeInsetsDirectional.only(start: 13),
            child: Text(paidText, textAlign: TextAlign.start, style: bodyStyle),
          ),
          if (extraText != null)
            Padding(
              padding: const EdgeInsetsDirectional.only(start: 13),
              child: Text(
                extraText!,
                textAlign: TextAlign.start,
                style: bodyStyle,
              ),
            ),
        ],
      ),
    );
  }
}
