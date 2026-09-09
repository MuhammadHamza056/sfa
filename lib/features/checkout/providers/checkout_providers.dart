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

/// Everything the summary is priced on. Records compare by value, so the
/// family caches per address *and* per coupon/gift-wrap choice — applying a
/// coupon on the cart re-prices checkout instead of serving the stale total.
typedef CheckoutPreviewArgs = ({
  String addressId,
  String? couponCode,
  bool? giftWrap,
});

/// M38 — an empty address id short-circuits so the screen doesn't fire a
/// preview request before an address is chosen.
final checkoutPreviewProvider =
    FutureProvider.family<CheckoutPreview?, CheckoutPreviewArgs>((ref, args) async {
  if (args.addressId.isEmpty) return null;
  final result = await ref.read(checkoutRepositoryProvider).getCheckoutSummary(
        addressId: args.addressId,
        couponCode: args.couponCode,
        giftWrap: args.giftWrap,
      );
  return result.when(success: (data) => data, failure: (e) => throw e);
});
