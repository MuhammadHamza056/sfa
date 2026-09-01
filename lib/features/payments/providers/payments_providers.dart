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
