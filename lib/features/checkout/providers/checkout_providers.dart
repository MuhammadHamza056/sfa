import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../data/checkout_models.dart';
import '../data/checkout_repository.dart';

final checkoutRepositoryProvider = Provider<CheckoutRepository>((ref) {
  return CheckoutRepository(ApiClient.instance);
});

/// M37
final regionsProvider = FutureProvider<List<Region>>((ref) async {
  final result = await ref.read(checkoutRepositoryProvider).getRegions();
  return result.when(success: (data) => data, failure: (e) => throw e);
});

/// M38 — keyed by the selected address id; empty id short-circuits so the
/// screen doesn't fire a preview request before an address is chosen.
final checkoutPreviewProvider =
    FutureProvider.family<CheckoutPreview?, String>((ref, addressId) async {
  if (addressId.isEmpty) return null;
  final result =
      await ref.read(checkoutRepositoryProvider).getCheckoutSummary(addressId: addressId);
  return result.when(success: (data) => data, failure: (e) => throw e);
});
