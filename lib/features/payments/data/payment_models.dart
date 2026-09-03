/// M44 — the guide gives no response example for saved payment methods;
/// modeled defensively after common card-on-file shapes (Mada/Visa/etc via
/// MyFatoorah tokenization).
class SavedPaymentMethod {
  final String id;
  final String type;
  final String? brand;
  final String? last4;
  final bool isDefault;

  const SavedPaymentMethod({
    required this.id,
    required this.type,
    this.brand,
    this.last4,
    this.isDefault = false,
  });

  factory SavedPaymentMethod.fromJson(Map<String, dynamic> json) {
    return SavedPaymentMethod(
      id: json['id']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      brand: json['brand'] as String?,
      last4: json['last4']?.toString(),
      isDefault: json['isDefault'] as bool? ?? false,
    );
  }
}

/// M46 — live, priced payment method options for the current cart total,
/// quoted through MyFatoorah. `code` is the same enum create-order and
/// `/payments/methods/initiate` expect (`WALLET/CARD/KNET/APPLE_PAY/
/// GOOGLE_PAY`), and `id` is the `methodMyfatoorahId` initiate needs back
/// alongside it.
class MyFatoorahPaymentMethod {
  final int id;
  final String nameAr;
  final String nameEn;
  final String code;
  final bool isDirectPayment;
  final double serviceCharge;
  final double totalAmount;
  final String currencyIso;
  final String imageUrl;
  final bool isEmbeddedSupported;

  const MyFatoorahPaymentMethod({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    required this.code,
    this.isDirectPayment = false,
    this.serviceCharge = 0,
    this.totalAmount = 0,
    this.currencyIso = 'SAR',
    this.imageUrl = '',
    this.isEmbeddedSupported = false,
  });

  factory MyFatoorahPaymentMethod.fromJson(Map<String, dynamic> json) {
    return MyFatoorahPaymentMethod(
      id: (json['PaymentMethodId'] as num?)?.toInt() ?? 0,
      nameAr: json['PaymentMethodAr']?.toString() ?? '',
      nameEn: json['PaymentMethodEn']?.toString() ?? '',
      code: json['PaymentMethodCode']?.toString() ?? '',
      isDirectPayment: json['IsDirectPayment'] as bool? ?? false,
      serviceCharge: (json['ServiceCharge'] as num?)?.toDouble() ?? 0,
      totalAmount: (json['TotalAmount'] as num?)?.toDouble() ?? 0,
      currencyIso: json['CurrencyIso']?.toString() ?? 'SAR',
      imageUrl: json['ImageUrl']?.toString() ?? '',
      isEmbeddedSupported: json['IsEmbeddedSupported'] as bool? ?? false,
    );
  }
}

/// M45 — matches the guide's response example exactly.
class PaymentInitiateResult {
  final String paymentUrl;
  final String invoiceId;

  const PaymentInitiateResult({required this.paymentUrl, required this.invoiceId});

  factory PaymentInitiateResult.fromJson(Map<String, dynamic> json) {
    return PaymentInitiateResult(
      paymentUrl: json['paymentUrl']?.toString() ?? '',
      invoiceId: json['invoiceId']?.toString() ?? '',
    );
  }
}
