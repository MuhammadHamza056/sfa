import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/network/api_result.dart';
import 'profile_models.dart';

/// M73-M76 from the guide.
class ProfileRepository {
  ProfileRepository(this._client);

  final ApiClient _client;

  /// M73: Current customer profile
  Future<ApiResult<ProfileData>> getProfile() {
    return _client.get<ProfileData>(
      ApiEndpoints.myProfile,
      fromJson: (data) => ProfileData.fromJson(data as Map<String, dynamic>),
    );
  }

  /// M74: Loyalty points & VIP tier status
  Future<ApiResult<MembershipData>> getMembership() {
    return _client.get<MembershipData>(
      ApiEndpoints.myMembership,
      fromJson: (data) => MembershipData.fromJson(data as Map<String, dynamic>),
    );
  }

  /// M75: Update profile (name, avatar, email, dob)
  Future<ApiResult<ProfileData>> updateProfile({
    String? name,
    String? email,
    String? avatar,
    String? dob,
  }) {
    return _client.patch<ProfileData>(
      ApiEndpoints.myProfile,
      data: {
        if (name != null) 'name': name,
        if (email != null) 'email': email,
        if (avatar != null) 'avatar': avatar,
        if (dob != null) 'dob': dob,
      },
      fromJson: (data) => ProfileData.fromJson(data as Map<String, dynamic>),
    );
  }

  /// M76: Update language / theme / push flags
  Future<ApiResult<void>> updatePreferences({
    String? language,
    String? theme,
    bool? notificationsEnabled,
  }) {
    return _client.patch<void>(
      ApiEndpoints.myPreferences,
      data: {
        if (language != null) 'language': language,
        if (theme != null) 'theme': theme,
        if (notificationsEnabled != null) 'notificationsEnabled': notificationsEnabled,
      },
      fromJson: (_) {},
    );
  }
}
