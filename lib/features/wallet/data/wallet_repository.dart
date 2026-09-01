import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/network/api_result.dart';
import 'wallet_models.dart';

/// M92-M94 from the guide.
class WalletRepository {
  WalletRepository(this._client);

  final ApiClient _client;

  /// M92: Get wallet balance & currency
  Future<ApiResult<WalletBalance>> getBalance() {
    return _client.get<WalletBalance>(
      ApiEndpoints.wallet,
      fromJson: (data) => WalletBalance.fromJson(data as Map<String, dynamic>),
    );
  }

  /// M93: Wallet transaction ledger
  Future<ApiResult<WalletTransactionsPage>> getTransactions({int page = 1, int limit = 20}) {
    return _client.get<WalletTransactionsPage>(
      ApiEndpoints.walletTransactions,
      queryParameters: {'page': page, 'limit': limit},
      fromJson: (data) {
        if (data is Map<String, dynamic> && data.containsKey('items')) {
          return WalletTransactionsPage.fromJson(data);
        }
        final items = data is List
            ? data.map((v) => WalletTransaction.fromJson(v as Map<String, dynamic>)).toList()
            : <WalletTransaction>[];
        return WalletTransactionsPage(items: items, total: items.length, page: 1, totalPages: 1);
      },
    );
  }

  /// M94: Request bank IBAN payout. Matches the guide's request example
  /// exactly — bank fields are nested under `bankDetails`, not flat.
  Future<ApiResult<void>> withdraw({
    required int amountFils,
    required String bankName,
    required String iban,
    required String accountHolderName,
  }) {
    return _client.post<void>(
      ApiEndpoints.walletWithdraw,
      data: {
        'amountFils': amountFils,
        'bankDetails': {
          'bankName': bankName,
          'iban': iban,
          'accountHolderName': accountHolderName,
        },
      },
      fromJson: (_) {},
    );
  }
}
