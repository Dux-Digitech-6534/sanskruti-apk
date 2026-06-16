import 'package:dio/dio.dart';

import '../core/app_constants.dart';
import 'api_client.dart';
import 'storage_service.dart';

class AuthService {
  AuthService(this._apiClient, this._storage);

  final ApiClient _apiClient;
  final StorageService _storage;

  Future<void> login({
    required String username,
    required String password,
  }) async {
    final response = await _apiClient.dio.post(
      AppConstants.loginPath,
      data: {'usr': username, 'pwd': password},
      options: Options(contentType: Headers.formUrlEncodedContentType),
    );
    final cookies = response.headers.map['set-cookie'] ?? [];
    final cookie = ApiClient.cookieHeaderFromSetCookie(cookies);
    final csrfToken = ApiClient.csrfFromSetCookie(cookies);
    if (cookie.isEmpty) {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        message: 'Login succeeded but no Frappe session cookie was returned.',
      );
    }
    await _storage.saveSession(
      cookie: cookie,
      userId: username,
      csrfToken: csrfToken,
    );
  }

  Future<String?> getLoggedUser() async {
    final response = await _apiClient.dio.get(
      '/api/method/frappe.auth.get_logged_user',
    );
    return response.data['message']?.toString();
  }

  Future<void> logout() async {
    try {
      await _apiClient.dio.get('/api/method/logout');
    } finally {
      await _storage.clearSession();
    }
  }
}
