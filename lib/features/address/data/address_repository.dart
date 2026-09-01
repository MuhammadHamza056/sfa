import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/network/api_result.dart';
import '../models/address.dart';
import 'geocode_result.dart';

/// M40-M43 from the guide: the customer's delivery address book plus
/// reverse geocoding.
class AddressRepository {
  AddressRepository(this._client);

  final ApiClient _client;

  static List<Address> _asList(dynamic data) {
    final raw = data is Map<String, dynamic> && data['items'] is List
        ? data['items'] as List
        : (data is List ? data : const []);
    return raw.map((v) => Address.fromJson(v as Map<String, dynamic>)).toList();
  }

  /// M41: List customer delivery addresses
  Future<ApiResult<List<Address>>> getAddresses() {
    return _client.get<List<Address>>(
      ApiEndpoints.addresses,
      fromJson: (data) => _asList(data),
    );
  }

  /// M42: Get single address detail
  Future<ApiResult<Address>> getAddress(String id) {
    return _client.get<Address>(
      ApiEndpoints.addressDetail(id),
      fromJson: (data) => Address.fromJson(data as Map<String, dynamic>),
    );
  }

  /// M40: Save new delivery address
  Future<ApiResult<Address>> createAddress(Address address) {
    return _client.post<Address>(
      ApiEndpoints.addresses,
      data: address.toJson(),
      fromJson: (data) => Address.fromJson(data as Map<String, dynamic>),
    );
  }

  /// M79: Update address details
  Future<ApiResult<Address>> updateAddress(Address address) {
    return _client.put<Address>(
      ApiEndpoints.addressDetail(address.id),
      data: address.toJson(),
      fromJson: (data) => Address.fromJson(data as Map<String, dynamic>),
    );
  }

  /// M80: Delete saved address
  Future<ApiResult<void>> deleteAddress(String id) {
    return _client.delete<void>(
      ApiEndpoints.addressDetail(id),
      fromJson: (_) {},
    );
  }

  /// M81: Set address as default checkout
  Future<ApiResult<void>> setDefaultAddress(String id) {
    return _client.put<void>(
      ApiEndpoints.addressDefault(id),
      fromJson: (_) {},
    );
  }

  /// M42: Reverse geocode map coordinates. The guide's title says
  /// "reverse geocode" (coords → address) but the one query example it
  /// gives is `?address=...` (text → address) — contradictory, so both are
  /// supported here; pass whichever the real backend turns out to want.
  Future<ApiResult<GeocodeResult>> geocode({
    double? lat,
    double? lng,
    String? address,
  }) {
    return _client.get<GeocodeResult>(
      ApiEndpoints.addressGeocode,
      queryParameters: {
        if (lat != null) 'lat': lat,
        if (lng != null) 'lng': lng,
        if (address != null) 'address': address,
      },
      fromJson: (data) => GeocodeResult.fromJson(data as Map<String, dynamic>),
    );
  }
}
