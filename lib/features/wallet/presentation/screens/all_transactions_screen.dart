import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sfa/core/localization/app_localizations.dart';
import 'package:sfa/utils/app_style.dart';
import 'package:sfa/utils/assets_constants.dart';

class AllTransactionsScreen extends StatelessWidget {
  const AllTransactionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final isAr = loc.isArabic;
    final sarText = isAr ? 'ر.س.' : 'SAR';

    // Mock Full Transactions History Data
    final transactions = [
      {
        'title': loc.translate('refundForOrder').replaceAll('{id}', '100234'),
        'date': loc.translate('may15'),
        'amount': 2500.00,
        'isAdd': true,
      },
      {
        'title': loc.translate('orderLabel').replaceAll('{id}', '2245'),
        'date': loc.translate('may04'),
        'amount': -1300.00,
        'isAdd': false,
      },
      {
        'title': loc.translate('refundForOrder').replaceAll('{id}', '100234'),
        'date': loc.translate('may15'),
        'amount': 2500.00,
        'isAdd': true,
      },
      {
        'title': loc.translate('refundForOrder').replaceAll('{id}', '100233'),
        'date': '12 مايو 2026', // Keep mock dates simple or localize if necessary
        'dateEn': '12 May 2026',
        'amount': 150.00,
        'isAdd': true,
      },
      {
        'title': loc.translate('orderLabel').replaceAll('{id}', '2188'),
        'date': '29 أبريل 2026',
        'dateEn': '29 Apr 2026',
        'amount': -450.00,
        'isAdd': false,
      },
      {
        'title': loc.translate('refundForOrder').replaceAll('{id}', '100210'),
        'date': '20 أبريل 2026',
        'dateEn': '20 Apr 2026',
        'amount': 990.00,
        'isAdd': true,
      },
      {
        'title': loc.translate('orderLabel').replaceAll('{id}', '1904'),
        'date': '10 مارس 2026',
        'dateEn': '10 Mar 2026',
        'amount': -310.00,
        'isAdd': false,
      },
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: Directionality(
        textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          itemCount: transactions.length,
          itemBuilder: (context, index) {
            final tx = transactions[index];
            final title = tx['title'] as String;
            // Handle localized/fallback dates
            final date = (isAr ? tx['date'] ?? tx['dateAr'] : tx['dateEn'] ?? tx['date']) as String;
            final amount = tx['amount'] as double;
            final isAdd = tx['isAdd'] as bool;

            final amountText = '${isAdd ? '+' : '-'}${amount.abs().toStringAsFixed(2)} $sarText';

            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF9F9F9),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: const Color(0xFFF1F1F1),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Details and Arrow Icon (Left side in LTR, Right side in RTL)
                  Row(
                    children: [
                      SvgPicture.asset(
                        isAdd ? AssetsConstants.frame52 : AssetsConstants.frame53,
                        width: 45,
                        height: 45,
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: isAr ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: AppStyle.walletTxTitle,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            date,
                            style: AppStyle.walletTxDate,
                          ),
                        ],
                      ),
                    ],
                  ),

                  // Amount (Right side in LTR, Left side in RTL)
                  Text(
                    amountText,
                    style: AppStyle.walletTxAmount.copyWith(
                      color: isAdd ? const Color(0xFF2E7D32) : const Color(0xFFD32F2F),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
