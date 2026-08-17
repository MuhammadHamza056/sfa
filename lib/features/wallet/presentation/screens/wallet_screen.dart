import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:sfa/core/localization/app_localizations.dart';
import 'package:sfa/utils/app_style.dart';
import 'package:sfa/utils/assets_constants.dart';
import 'package:sfa/utils/color_constants.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final isAr = loc.isArabic;

    // Localized Strings
    final availableBalance = loc.translate('availableBalance');
    final transferToBank = loc.translate('transferToBank');
    final latestTransactions = loc.translate('latestTransactions');
    final viewAllTransactions = loc.translate('viewAllTransactions');
    final sarText = isAr ? 'ر.س.' : 'SAR';

    // Mock Transactions Data
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
        'title': loc.translate('refundForOrder').replaceAll('{id}', '100234'),
        'date': loc.translate('may15'),
        'amount': 2500.00,
        'isAdd': true,
      },
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: Directionality(
        textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Gold Card ──
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  color: AppColors.primary,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Balance Header text
                    Text(availableBalance, style: AppStyle.walletBalanceLabel),
                    const SizedBox(height: 8),
                    // Amount row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          '1478.00',
                          style: AppStyle.walletBalanceAmount.copyWith(
                            height: 1.1,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(sarText, style: AppStyle.walletSarLabel),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Dark Strip button
                    Material(
                      color: AppColors.textcolor, // #451425 brand text color
                      borderRadius: BorderRadius.circular(20),
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        onTap: () {
                          // Handle transfer logic
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                transferToBank,
                                style: AppStyle.walletTransferButton,
                              ),
                              SvgPicture.asset(
                                AssetsConstants.landmark, // Use landmark svg
                                width: 18,
                                height: 18,
                                colorFilter: const ColorFilter.mode(
                                  Colors.white,
                                  BlendMode.srcIn,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // ── Section Title "أحدث العمليات" ──
              Text(latestTransactions, style: AppStyle.walletSectionHeader),
              const SizedBox(height: 16),

              // ── Transactions List ──
              ...transactions.map((tx) {
                final title = tx['title'];
                final date = tx['date'];
                final amount = tx['amount'] as double;
                final isAdd = tx['isAdd'] as bool;

                final amountText = isAr
                    ? '${isAdd ? '+' : '-'}${amount.abs().toStringAsFixed(2)} $sarText'
                    : '${isAdd ? '+' : '-'}${amount.abs().toStringAsFixed(2)} $sarText';

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
                            isAdd
                                ? AssetsConstants.frame52
                                : AssetsConstants.frame53,
                            width: 45,
                            height: 45,
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: isAr
                                ? CrossAxisAlignment.end
                                : CrossAxisAlignment.start,
                            children: [
                              Text(
                                title as String,
                                style: AppStyle.walletTxTitle,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                date as String,
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
                          color: isAdd
                              ? const Color(0xFF2E7D32)
                              : const Color(0xFFD32F2F),
                        ),
                      ),
                    ],
                  ),
                );
              }),

              const SizedBox(height: 24),

              // ── View All Transactions Link ──
              TextButton(
                onPressed: () {
                  context.push('/all-transactions');
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(viewAllTransactions, style: AppStyle.walletViewAll),
                    const SizedBox(width: 8),
                    Transform.rotate(
                      angle: isAr
                          ? 3.14159
                          : 0, // Point left in RTL (Arabic), right in LTR (English)
                      child: SvgPicture.asset(
                        AssetsConstants.moveLeft,
                        width: 18,
                        height: 18,
                        colorFilter: const ColorFilter.mode(
                          Color(0xFFC79A52),
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
