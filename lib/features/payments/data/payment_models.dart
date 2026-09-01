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
