/// M92 — matches the guide's response example exactly.
class WalletBalance {
  final int balanceFils;
  final String currency;

  const WalletBalance({required this.balanceFils, this.currency = 'SAR'});

  factory WalletBalance.fromJson(Map<String, dynamic> json) {
    return WalletBalance(
      balanceFils: (json['balanceFils'] as num?)?.toInt() ?? 0,
      currency: json['currency'] as String? ?? 'SAR',
    );
  }
}

/// M93 — matches the guide's response example: `{id, type, amountFils,
/// amount, currency, description, createdAt}`, e.g. `type: "REFUND"`.
/// The guide doesn't enumerate the full `type` set or say whether
/// `amountFils` is ever signed, so credit/debit is inferred: an explicit
/// `isCredit` wins if present, then a negative `amountFils`, then a
/// known-debit type name (withdrawals/purchases/payments) — anything else
/// (refunds, cashback, bonuses, top-ups, ...) defaults to credit.
class WalletTransaction {
  final String id;
  final String type;
  final String description;
  final int amountFils;
  final bool isCredit;
  final DateTime? createdAt;

  const WalletTransaction({
    required this.id,
    required this.type,
    required this.description,
    required this.amountFils,
    required this.isCredit,
    this.createdAt,
  });

  static const _debitTypes = {
    'WITHDRAWAL',
    'WITHDRAW',
    'DEBIT',
    'PURCHASE',
    'PAYMENT',
    'DEDUCTION',
  };

  factory WalletTransaction.fromJson(Map<String, dynamic> json) {
    final amount = (json['amountFils'] as num?)?.toInt() ?? 0;
    final type = json['type']?.toString() ?? '';
    final isCredit = json['isCredit'] as bool? ??
        (amount < 0 ? false : !_debitTypes.contains(type.toUpperCase()));
    return WalletTransaction(
      id: json['id']?.toString() ?? '',
      type: type,
      description: json['description']?.toString() ?? json['title']?.toString() ?? '',
      amountFils: amount.abs(),
      isCredit: isCredit,
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? ''),
    );
  }
}

class WalletTransactionsPage {
  final List<WalletTransaction> items;
  final int total;
  final int page;
  final int totalPages;

  const WalletTransactionsPage({
    required this.items,
    required this.total,
    required this.page,
    required this.totalPages,
  });

  factory WalletTransactionsPage.fromJson(Map<String, dynamic> json) {
    return WalletTransactionsPage(
      items: (json['items'] as List? ?? const [])
          .map((v) => WalletTransaction.fromJson(v as Map<String, dynamic>))
          .toList(),
      total: (json['total'] as num?)?.toInt() ?? 0,
      page: (json['page'] as num?)?.toInt() ?? 1,
      totalPages: (json['totalPages'] as num?)?.toInt() ?? 1,
    );
  }
}
