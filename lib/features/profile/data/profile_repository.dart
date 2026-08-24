import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/network/api_client.dart';
import '../../../features/auth/data/auth_repository.dart';
import '../../../models/user.dart';

/// Resolves the currently logged-in user by:
///   1. Returning a cached [User] from SharedPreferences if one exists.
///   2. Fetching all users from GET /users, filtering by the username that was
///      stored at login time, then caching the result.
///
/// FakeStoreAPI does not expose a "get user by username" endpoint, so client-side
/// filtering against the full user list is the only available approach.
class ProfileRepository {
  ProfileRepository(this._apiClient, this._sharedPreferences, this._username);

  final ApiClient _apiClient;
  final SharedPreferences _sharedPreferences;
  final String? _username;

  static const _cachedUserKey = 'cached_user';

  /// Returns the resolved [User] for the current session, or null if the
  /// username is unknown or no matching user is found in the API.
  Future<User?> getProfile() async {
    if (_username == null || _username.isEmpty) return null;

    // Return cached user if available to avoid redundant network calls.
    final cached = _sharedPreferences.getString(_cachedUserKey);
    if (cached != null && cached.isNotEmpty) {
      try {
        return User.fromJson(jsonDecode(cached) as Map<String, dynamic>);
      } catch (_) {
        // Corrupted cache — fall through to fetch from network.
        await _sharedPreferences.remove(_cachedUserKey);
      }
    }

    final rawList = await _apiClient.getJsonList('/users');
    final users = rawList
        .whereType<Map<String, dynamic>>()
        .map(User.fromJson)
        .toList();

    final matched = users.cast<User?>().firstWhere(
          (u) => u?.username.toLowerCase() == _username.toLowerCase(),
          orElse: () => null,
        );

    if (matched != null) {
      await _sharedPreferences.setString(
        _cachedUserKey,
        jsonEncode(matched.toJson()),
      );
    }

    return matched;
  }

  /// Removes the cached user from local storage. Called on logout so the next
  /// session always resolves a fresh profile.
  Future<void> clearCachedUser() async {
    await _sharedPreferences.remove(_cachedUserKey);
  }
}

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository(
    ref.watch(apiClientProvider),
    ref.watch(sharedPreferencesProvider),
    ref.watch(authRepositoryProvider).getStoredUsername(),
  );
});
