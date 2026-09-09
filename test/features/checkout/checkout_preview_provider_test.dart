import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sfa/core/network/api_client.dart';
import 'package:sfa/core/network/api_result.dart';
import 'package:sfa/features/checkout/data/checkout_models.dart';
import 'package:sfa/features/checkout/data/checkout_repository.dart';
import 'package:sfa/features/checkout/providers/checkout_providers.dart';

typedef _SummaryCall = ({String addressId, String? couponCode, bool? giftWrap});

class _RecordingCheckoutRepository extends CheckoutRepository {
  _RecordingCheckoutRepository() : super(ApiClient.instance);

  final List<_SummaryCall> calls = [];

  @override
  Future<ApiResult<CheckoutPreview>> getCheckoutSummary({
    required String addressId,
    String? couponCode,
    bool? giftWrap,
  }) async {
    calls.add((addressId: addressId, couponCode: couponCode, giftWrap: giftWrap));
    return const ApiSuccess(
      CheckoutPreview(
        subtotalFils: 10000,
        discountFils: 2000,
        pointsDiscountFils: 0,
        deliveryFeeFils: 0,
        totalFils: 8000,
      ),
    );
  }
}

/// The summary used to be keyed on the address alone, so a coupon applied
/// on the cart never reached `GET /checkout/summary` and checkout showed an
/// undiscounted total.
void main() {
  late _RecordingCheckoutRepository repository;
  late ProviderContainer container;

  setUp(() {
    repository = _RecordingCheckoutRepository();
    container = ProviderContainer(
      overrides: [checkoutRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);
  });

  test('forwards the cart coupon and gift wrap to the summary request', () async {
    await container.read(
      checkoutPreviewProvider((
        addressId: 'addr-1',
        couponCode: 'SAFA10',
        giftWrap: true,
      )).future,
    );

    expect(repository.calls, [
      (addressId: 'addr-1', couponCode: 'SAFA10', giftWrap: true),
    ]);
  });

  test('re-prices when the coupon changes instead of serving the cached total',
      () async {
    const args = (addressId: 'addr-1', couponCode: null, giftWrap: false);
    await container.read(checkoutPreviewProvider(args).future);
    await container.read(
      checkoutPreviewProvider((
        addressId: 'addr-1',
        couponCode: 'SAFA10',
        giftWrap: false,
      )).future,
    );

    expect(repository.calls.length, 2);
    expect(repository.calls.last.couponCode, 'SAFA10');
  });

  test('no address means no request', () async {
    final preview = await container.read(
      checkoutPreviewProvider((
        addressId: '',
        couponCode: 'SAFA10',
        giftWrap: true,
      )).future,
    );

    expect(preview, isNull);
    expect(repository.calls, isEmpty);
  });
}
