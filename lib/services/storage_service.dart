import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/app_constants.dart';

class StorageService {
  late final SharedPreferences _preferences;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  Future<StorageService> init() async {
    _preferences = await SharedPreferences.getInstance();
    return this;
  }

  Future<void> saveSession({
    required String cookie,
    required String userId,
    String? csrfToken,
  }) async {
    await _secureStorage.write(
      key: AppConstants.sessionCookieKey,
      value: cookie,
    );
    await _secureStorage.write(key: AppConstants.userKey, value: userId);
    if (csrfToken != null && csrfToken.isNotEmpty) {
      await _secureStorage.write(
        key: AppConstants.csrfTokenKey,
        value: csrfToken,
      );
    }
  }

  Future<String?> get sessionCookie =>
      _secureStorage.read(key: AppConstants.sessionCookieKey);

  Future<String?> get csrfToken =>
      _secureStorage.read(key: AppConstants.csrfTokenKey);

  Future<String?> get userId => _secureStorage.read(key: AppConstants.userKey);

  Future<bool> get hasSession async {
    final cookie = await sessionCookie;
    return cookie != null && cookie.isNotEmpty;
  }

  bool get darkModeEnabled => _preferences.getBool('dark_mode') ?? false;

  Future<void> clearSession() async {
    await _secureStorage.delete(key: AppConstants.sessionCookieKey);
    await _secureStorage.delete(key: AppConstants.csrfTokenKey);
    await _secureStorage.delete(key: AppConstants.userKey);
  }
}
