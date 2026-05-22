import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/user_profile.dart';

class SecureStorageService {
  SecureStorageService(this._storage);

  final FlutterSecureStorage _storage;

  static const _sessionCookieKey = 'session_cookie';
  static const _csrfTokenKey = 'csrf_token';
  static const _userIdKey = 'user_id';
  static const _rememberedUserKey = 'remembered_user';
  static const _profileKey = 'cached_user_profile';

  Future<void> saveSession({
    required String cookie,
    required String userId,
    String? csrfToken,
  }) async {
    await _storage.write(key: _sessionCookieKey, value: cookie);
    await _storage.write(key: _userIdKey, value: userId);
    if (csrfToken != null && csrfToken.isNotEmpty) {
      await _storage.write(key: _csrfTokenKey, value: csrfToken);
    }
  }

  Future<String?> readSessionCookie() => _storage.read(key: _sessionCookieKey);

  Future<String?> readCsrfToken() => _storage.read(key: _csrfTokenKey);

  Future<String?> readUserId() => _storage.read(key: _userIdKey);

  Future<bool> hasSession() async {
    final cookie = await readSessionCookie();
    return cookie != null && cookie.isNotEmpty;
  }

  Future<void> saveRememberedUser(String user) {
    return _storage.write(key: _rememberedUserKey, value: user);
  }

  Future<String?> readRememberedUser() =>
      _storage.read(key: _rememberedUserKey);

  Future<void> clearRememberedUser() {
    return _storage.delete(key: _rememberedUserKey);
  }

  Future<void> cacheProfile(UserProfile profile) {
    return _storage.write(
      key: _profileKey,
      value: jsonEncode(profile.toJson()),
    );
  }

  Future<UserProfile?> readCachedProfile() async {
    final raw = await _storage.read(key: _profileKey);
    if (raw == null || raw.isEmpty) return null;
    final decoded = jsonDecode(raw);
    if (decoded is! Map<String, dynamic>) return null;
    return UserProfile.fromJson(decoded);
  }

  Future<void> clearSession() async {
    await _storage.delete(key: _sessionCookieKey);
    await _storage.delete(key: _csrfTokenKey);
    await _storage.delete(key: _userIdKey);
    await _storage.delete(key: _profileKey);
  }
}
