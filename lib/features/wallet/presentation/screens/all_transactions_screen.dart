import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sfa/core/localization/app_localizations.dart';
import 'package:sfa/utils/app_style.dart';
import 'package:sfa/core/theme/app_palette.dart';
import 'package:sfa/features/wallet/providers/wallet_providers.dart';
import 'package:sfa/features/wallet/presentation/widgets/transaction_tile.dart';

class AllTransactionsScreen extends ConsumerWidget {
  const AllTransactionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context);
    final isAr = loc.isArabic;
    final transactionsAsync = ref.watch(walletTransactionsProvider);

    return Scaffold(
      backgroundColor: context.palette.background,
      body: Directionality(
        textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
        child: transactionsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(
            child: Text(error.toString(), style: AppStyle.bodyText.copyWith(color: context.palette.textMuted)),
          ),
          data: (transactions) {
            if (transactions.isEmpty) {
              return Center(
                child: Text(
                  isAr ? 'لا توجد عمليات بعد' : 'No transactions yet',
                  style: AppStyle.bodyText.copyWith(color: context.palette.textMuted),
                ),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              itemCount: transactions.length,
              itemBuilder: (context, index) => TransactionTile(tx: transactions[index], isAr: isAr),
            );
          },
        ),
      ),
    );
  }
}
