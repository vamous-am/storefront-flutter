import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/user.dart';
import '../data/profile_repository.dart';

/// Fetches the profile of the currently logged-in user.
///
/// Uses [AsyncNotifier] because the fetch requires a network call and must
/// model loading, error, and data states explicitly.
class ProfileNotifier extends AsyncNotifier<User?> {
  @override
  FutureOr<User?> build() {
    return ref.watch(profileRepositoryProvider).getProfile();
  }

  /// Re-fetches the profile from the network, bypassing the cache by clearing
  /// it first and then rebuilding the provider state.
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(profileRepositoryProvider);
      await repo.clearCachedUser();
      return repo.getProfile();
    });
  }
}

final profileProvider =
    AsyncNotifierProvider<ProfileNotifier, User?>(ProfileNotifier.new);
