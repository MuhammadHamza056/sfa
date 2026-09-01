import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../data/wallet_models.dart';
import '../data/wallet_repository.dart';

final walletRepositoryProvider = Provider<WalletRepository>((ref) {
  return WalletRepository(ApiClient.instance);
});

/// M92
final walletBalanceProvider = FutureProvider<WalletBalance>((ref) async {
  final result = await ref.read(walletRepositoryProvider).getBalance();
  return result.when(success: (data) => data, failure: (e) => throw e);
});

/// M93
final walletTransactionsProvider = FutureProvider<List<WalletTransaction>>((ref) async {
  final result = await ref.read(walletRepositoryProvider).getTransactions(limit: 50);
  return result.when(success: (data) => data.items, failure: (e) => throw e);
});
