import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/hive_services.dart';
import '../../../core/network/api_client.dart';
import '../data/address_repository.dart';
import '../models/address.dart';

final addressRepositoryProvider = Provider<AddressRepository>((ref) {
  return AddressRepository(ApiClient.instance);
});

/// M40-M42. Requires auth, so [build] skips the network call for a
/// signed-out session.
class AddressNotifier extends AsyncNotifier<List<Address>> {
  AddressRepository get _repository => ref.read(addressRepositoryProvider);

  @override
  Future<List<Address>> build() async {
    if (!SecureStorage.isAuthenticated) return const [];
    final result = await _repository.getAddresses();
    return result.dataOrNull ?? const [];
  }

  Future<void> refresh() async {
    state = const AsyncLoading<List<Address>>().copyWithPrevious(state);
    state = await AsyncValue.guard(() async {
      final result = await _repository.getAddresses();
      return result.dataOrNull ?? const [];
    });
  }

  /// M40
  Future<bool> addAddress(Address address) async {
    final result = await _repository.createAddress(address);
    final created = result.dataOrNull;
    if (created == null) return false;
    state = AsyncData([...state.valueOrNull ?? const [], created]);
    return true;
  }

  Future<bool> updateAddress(Address address) async {
    final result = await _repository.updateAddress(address);
    final updated = result.dataOrNull;
    if (updated == null) return false;
    state = AsyncData([
      for (final existing in state.valueOrNull ?? const [])
        if (existing.id == updated.id) updated else existing,
    ]);
    return true;
  }

  Future<bool> removeAddress(String id) async {
    final result = await _repository.deleteAddress(id);
    if (!result.isSuccess) return false;
    state = AsyncData(
      (state.valueOrNull ?? const []).where((a) => a.id != id).toList(),
    );
    return true;
  }

  /// M81
  Future<bool> setDefaultAddress(String id) async {
    final result = await _repository.setDefaultAddress(id);
    if (!result.isSuccess) return false;
    state = AsyncData([
      for (final address in state.valueOrNull ?? const [])
        address.copyWith(isDefault: address.id == id),
    ]);
    return true;
  }
}

final addressProvider = AsyncNotifierProvider<AddressNotifier, List<Address>>(
  AddressNotifier.new,
);
