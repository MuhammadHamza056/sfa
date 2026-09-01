import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../data/profile_models.dart';
import '../data/profile_repository.dart';

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository(ApiClient.instance);
});

/// M73
final profileDataProvider = FutureProvider<ProfileData>((ref) async {
  final result = await ref.read(profileRepositoryProvider).getProfile();
  return result.when(success: (data) => data, failure: (e) => throw e);
});

/// M74
final membershipProvider = FutureProvider<MembershipData>((ref) async {
  final result = await ref.read(profileRepositoryProvider).getMembership();
  return result.when(success: (data) => data, failure: (e) => throw e);
});
