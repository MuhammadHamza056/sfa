import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:sfa/core/localization/app_localizations.dart';
import 'package:sfa/utils/app_style.dart';
import 'package:sfa/utils/assets_constants.dart';
import 'package:sfa/utils/color_constants.dart';
import 'package:sfa/utils/currency_formatter.dart';
import 'package:sfa/utils/loader.dart';
import 'package:sfa/features/wallet/providers/wallet_providers.dart';
import 'package:sfa/features/wallet/presentation/widgets/transaction_tile.dart';
import 'package:sfa/core/theme/app_palette.dart';

class WalletScreen extends ConsumerWidget {
  const WalletScreen({super.key});

  Future<void> _onWithdraw(BuildContext context, WidgetRef ref, AppLocalizations loc) async {
    final amountController = TextEditingController();
    final bankController = TextEditingController();
    final ibanController = TextEditingController();
    final nameController = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(loc.translate('transferToBank')),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(hintText: loc.isArabic ? 'المبلغ (ر.س.)' : 'Amount (SAR)'),
              ),
              TextField(
                controller: nameController,
                decoration: InputDecoration(hintText: loc.isArabic ? 'اسم صاحب الحساب' : 'Account holder name'),
              ),
              TextField(
                controller: bankController,
                decoration: InputDecoration(hintText: loc.isArabic ? 'اسم البنك' : 'Bank name'),
              ),
              TextField(
                controller: ibanController,
                textDirection: TextDirection.ltr,
                decoration: const InputDecoration(hintText: 'IBAN'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => context.pop(false), child: Text(loc.translate('cancel'))),
          TextButton(onPressed: () => context.pop(true), child: Text(loc.translate('transferToBank'))),
        ],
      ),
    );
    if (confirmed != true) return;

    final amountSar = double.tryParse(amountController.text.trim());
    if (amountSar == null || ibanController.text.trim().isEmpty) {
      Loader.showError(loc.translate('fieldRequired'));
      return;
    }

    final result = await ref.read(walletRepositoryProvider).withdraw(
          amountFils: (amountSar * 100).round(),
          bankName: bankController.text.trim(),
          iban: ibanController.text.trim(),
          accountHolderName: nameController.text.trim(),
        );
    result.when(
      success: (_) {
        ref.invalidate(walletBalanceProvider);
        ref.invalidate(walletTransactionsProvider);
        Loader.showSuccess(loc.isArabic ? 'تم إرسال طلب السحب' : 'Withdrawal request sent');
      },
      failure: (error) => Loader.showError(error.message),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context);
    final isAr = loc.isArabic;

    final availableBalance = loc.translate('availableBalance');
    final transferToBank = loc.translate('transferToBank');
    final latestTransactions = loc.translate('latestTransactions');
    final viewAllTransactions = loc.translate('viewAllTransactions');

    final balanceAsync = ref.watch(walletBalanceProvider);
    final transactionsAsync = ref.watch(walletTransactionsProvider);

    return Scaffold(
      backgroundColor: context.palette.background,
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
                    BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 16, offset: const Offset(0, 8)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(availableBalance, style: AppStyle.walletBalanceLabel),
                    const SizedBox(height: 8),
                    balanceAsync.when(
                      loading: () => const SizedBox(
                        height: 32,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      ),
                      error: (error, _) => Text(
                        error.toString(),
                        style: AppStyle.walletTxDate.copyWith(color: Colors.white),
                      ),
                      data: (balance) => Text(
                        CurrencyFormatter.fromHalalas(balance.balanceFils, isAr: isAr),
                        style: AppStyle.walletBalanceAmount.copyWith(height: 1.1),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Material(
                      color: context.palette.textPrimary,
                      borderRadius: BorderRadius.circular(20),
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        onTap: () => _onWithdraw(context, ref, loc),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(transferToBank, style: AppStyle.walletTransferButton),
                              SvgPicture.asset(
                                AssetsConstants.landmark,
                                width: 18,
                                height: 18,
                                colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
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

              Text(latestTransactions, style: AppStyle.walletSectionHeader),
              const SizedBox(height: 16),

              transactionsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => Text(
                  error.toString(),
                  style: AppStyle.bodyText.copyWith(color: context.palette.textMuted),
                ),
                data: (transactions) {
                  if (transactions.isEmpty) {
                    return Text(
                      isAr ? 'لا توجد عمليات بعد' : 'No transactions yet',
                      style: AppStyle.bodyText.copyWith(color: context.palette.textMuted),
                    );
                  }
                  return Column(
                    children: transactions.take(5).map((tx) => TransactionTile(tx: tx, isAr: isAr)).toList(),
                  );
                },
              ),

              const SizedBox(height: 24),

              TextButton(
                onPressed: () => context.push('/all-transactions'),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(viewAllTransactions, style: AppStyle.walletViewAll),
                    const SizedBox(width: 8),
                    Transform.rotate(
                      angle: isAr ? 3.14159 : 0,
                      child: SvgPicture.asset(
                        AssetsConstants.moveLeft,
                        width: 18,
                        height: 18,
                        colorFilter: const ColorFilter.mode(Color(0xFFC79A52), BlendMode.srcIn),
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
