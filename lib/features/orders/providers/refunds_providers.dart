import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../data/refund_models.dart';
import '../data/refunds_repository.dart';

final refundsRepositoryProvider = Provider<RefundsRepository>((ref) {
  return RefundsRepository(ApiClient.instance);
});

/// M56 — `autoDispose` so re-opening the refund-request page after leaving
/// it hits the API again instead of serving the first visit's cached list
/// forever (a plain `FutureProvider` is never disposed).
final refundReasonsProvider = FutureProvider.autoDispose<List<RefundReason>>((ref) async {
  final result = await ref.read(refundsRepositoryProvider).getReasons();
  return result.when(success: (data) => data, failure: (e) => throw e);
});

/// M58 — keyed by refund id. `autoDispose` for the same reason as
/// [refundReasonsProvider].
final refundDetailProvider = FutureProvider.autoDispose.family<RefundDetail, String>((ref, id) async {
  final result = await ref.read(refundsRepositoryProvider).getRefundDetail(id);
  return result.when(success: (data) => data, failure: (e) => throw e);
});

/// M59 — keyed by refund id. Separate from [refundDetailProvider] since
/// M58's response doesn't embed items. `autoDispose` for the same reason as
/// [refundReasonsProvider].
final refundItemsProvider = FutureProvider.autoDispose.family<List<RefundItem>, String>((ref, id) async {
  final result = await ref.read(refundsRepositoryProvider).getRefundItems(id);
  return result.when(success: (data) => data, failure: (e) => throw e);
});
