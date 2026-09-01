import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sfa/utils/app_style.dart';
import 'package:sfa/utils/assets_constants.dart';
import 'package:sfa/utils/currency_formatter.dart';
import 'package:sfa/core/theme/app_palette.dart';
import 'package:sfa/features/wallet/data/wallet_models.dart';

class TransactionTile extends StatelessWidget {
  final WalletTransaction tx;
  final bool isAr;

  const TransactionTile({super.key, required this.tx, required this.isAr});

  @override
  Widget build(BuildContext context) {
    final amountText =
        '${tx.isCredit ? '+' : '-'}${CurrencyFormatter.fromHalalas(tx.amountFils, isAr: isAr)}';
    final date = tx.createdAt;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.palette.backgroundSubtle,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: context.palette.divider, width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              SvgPicture.asset(
                tx.isCredit ? AssetsConstants.frame52 : AssetsConstants.frame53,
                width: 45,
                height: 45,
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: isAr ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  Text(tx.description, style: AppStyle.walletTxTitle),
                  const SizedBox(height: 4),
                  Text(
                    date != null ? '${date.year}/${date.month}/${date.day}' : '',
                    style: AppStyle.walletTxDate.copyWith(color: context.palette.textMuted),
                  ),
                ],
              ),
            ],
          ),
          Text(
            amountText,
            style: AppStyle.walletTxAmount.copyWith(
              color: tx.isCredit ? const Color(0xFF2E7D32) : const Color(0xFFD32F2F),
            ),
          ),
        ],
      ),
    );
  }
}
