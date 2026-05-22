import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/api/api_client.dart';
import '../core/api/api_exception.dart';
import '../core/constants/api_endpoints.dart';
import '../models/user_profile.dart';
import '../services/secure_storage_service.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    apiClient: ref.watch(apiClientProvider),
    storage: ref.watch(secureStorageProvider),
  );
});

class AuthRepository {
  const AuthRepository({
    required ApiClient apiClient,
    required SecureStorageService storage,
  }) : _apiClient = apiClient,
       _storage = storage;

  final ApiClient _apiClient;
  final SecureStorageService _storage;

  Future<UserProfile> login({
    required String username,
    required String password,
    required bool rememberMe,
  }) async {
    final response = await _apiClient.post(
      ApiEndpoints.login,
      data: {'usr': username, 'pwd': password},
      options: Options(contentType: Headers.formUrlEncodedContentType),
    );

    final cookies = response.headers.map['set-cookie'] ?? [];
    final cookie = ApiClient.cookieHeaderFromSetCookie(cookies);
    if (cookie.isEmpty) {
      throw const ApiException(
        'Login succeeded but no Frappe session was returned.',
      );
    }

    await _storage.saveSession(
      cookie: cookie,
      userId: username,
      csrfToken: ApiClient.cookieValue(cookies, 'csrf_token'),
    );

    if (rememberMe) {
      await _storage.saveRememberedUser(username);
    } else {
      await _storage.clearRememberedUser();
    }

    final profile = await fetchLoggedUser(fallbackUser: username);
    await _storage.cacheProfile(profile);
    return profile;
  }

  Future<UserProfile> fetchLoggedUser({String? fallbackUser}) async {
    final response = await _apiClient.get(ApiEndpoints.loggedUser);
    final message = response.data is Map ? response.data['message'] : null;
    final userId = message?.toString() ?? fallbackUser ?? '';
    if (userId.isEmpty) {
      return UserProfile(id: userId, fullName: userId, email: userId);
    }

    try {
      final userResponse = await _apiClient.get(
        '${ApiEndpoints.resource}/User/${Uri.encodeComponent(userId)}',
        queryParameters: {'fields': '["name","full_name","email","user_type"]'},
      );
      final data = userResponse.data is Map ? userResponse.data['data'] : null;
      if (data is Map) {
        return UserProfile.fromJson(Map<String, dynamic>.from(data));
      }
    } on Object {
      // Logged user id is enough for session continuity if User resource access is restricted.
    }

    return UserProfile(id: userId, fullName: userId, email: userId);
  }

  Future<UserProfile?> restoreSession() async {
    if (!await _storage.hasSession()) return null;

    final cached = await _storage.readCachedProfile();
    try {
      final profile = await fetchLoggedUser(fallbackUser: cached?.id);
      await _storage.cacheProfile(profile);
      return profile;
    } on Object {
      return cached;
    }
  }

  Future<String?> rememberedUser() => _storage.readRememberedUser();

  Future<void> logout() async {
    try {
      await _apiClient.post(ApiEndpoints.logout);
    } finally {
      await _storage.clearSession();
    }
  }
}
