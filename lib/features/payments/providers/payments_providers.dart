import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../data/payment_models.dart';
import '../data/payments_repository.dart';

final paymentsRepositoryProvider = Provider<PaymentsRepository>((ref) {
  return PaymentsRepository(ApiClient.instance);
});

/// M44
final savedPaymentMethodsProvider = FutureProvider<List<SavedPaymentMethod>>((ref) async {
  final result = await ref.read(paymentsRepositoryProvider).getPaymentMethods();
  return result.when(success: (data) => data, failure: (e) => throw e);
});

/// M46 — keyed by the current cart total so it refetches whenever the
/// checkout amount/currency changes; a zero amount short-circuits so this
/// doesn't fire before a checkout preview has loaded.
final myFatoorahPaymentMethodsProvider = FutureProvider.family<List<MyFatoorahPaymentMethod>,
    ({double amount, String currency})>((ref, args) async {
  if (args.amount <= 0) return const [];
  final result = await ref
      .read(paymentsRepositoryProvider)
      .getLiveMyFatoorahMethods(amount: args.amount, currency: args.currency);
  return result.when(
    success: (data) => data.where(_isSupportedOnThisPlatform).toList(),
    failure: (e) => throw e,
  );
});

/// MyFatoorah's method list isn't platform-aware — it always returns Apple
/// Pay and Google Pay regardless of device, so the wallet that can't exist
/// on this OS has to be filtered out here instead.
bool _isSupportedOnThisPlatform(MyFatoorahPaymentMethod method) {
  if (Platform.isAndroid && method.code == 'APPLE_PAY') return false;
  if (Platform.isIOS && method.code == 'GOOGLE_PAY') return false;
  return true;
}
