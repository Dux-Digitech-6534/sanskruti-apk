import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../services/secure_storage_service.dart';
import '../constants/app_constants.dart';
import 'api_config.dart';
import 'api_exception.dart';

final secureStorageProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService(const FlutterSecureStorage());
});

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(ref.watch(secureStorageProvider));
});

class ApiClient {
  ApiClient(this._storage)
    : dio = Dio(
        BaseOptions(
          baseUrl: ApiConfig.baseUri.toString(),
          connectTimeout: AppConstants.requestTimeout,
          receiveTimeout: AppConstants.requestTimeout,
          sendTimeout: AppConstants.requestTimeout,
          responseType: ResponseType.json,
          headers: const {
            'Accept': 'application/json',
            'X-Requested-With': 'XMLHttpRequest',
          },
        ),
      ) {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final cookie = await _storage.readSessionCookie();
          if (cookie != null && cookie.isNotEmpty) {
            options.headers['Cookie'] = cookie;
          }
          final csrf = await _storage.readCsrfToken();
          if (csrf != null && csrf.isNotEmpty) {
            options.headers['X-Frappe-CSRF-Token'] = csrf;
          }
          if (kDebugMode) {
            debugPrint('[ERPNext API] --> ${options.method} ${options.uri}');
            debugPrint(
              '[ERPNext API] headers: ${_redactHeaders(options.headers)}',
            );
            debugPrint('[ERPNext API] body: ${_redactBody(options.data)}');
          }
          handler.next(options);
        },
        onResponse: (response, handler) async {
          await persistCookies(response);
          if (kDebugMode) {
            debugPrint(
              '[ERPNext API] <-- ${response.statusCode} '
              '${response.requestOptions.uri}',
            );
            debugPrint('[ERPNext API] response: ${response.data}');
          }
          handler.next(response);
        },
        onError: (error, handler) async {
          if (kDebugMode) {
            debugPrint(
              '[ERPNext API] !! ${error.response?.statusCode} '
              '${error.requestOptions.uri}',
            );
            debugPrint(
              '[ERPNext API] error: ${error.response?.data ?? error.message}',
            );
          }
          if (error.response?.statusCode == 401) {
            await _storage.clearSession();
          }
          handler.next(error);
        },
      ),
    );
  }

  final SecureStorageService _storage;
  final Dio dio;

  Future<Response<dynamic>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      return await dio.get(path, queryParameters: queryParameters);
    } on Object catch (error) {
      throw readableException(error);
    }
  }

  Future<Response<dynamic>> post(
    String path, {
    Object? data,
    Options? options,
  }) async {
    try {
      return await dio.post(path, data: data, options: options);
    } on Object catch (error) {
      throw readableException(error);
    }
  }

  Future<Response<dynamic>> put(
    String path, {
    Object? data,
    Options? options,
  }) async {
    try {
      return await dio.put(path, data: data, options: options);
    } on Object catch (error) {
      throw readableException(error);
    }
  }

  Future<void> persistCookies(Response<dynamic> response) async {
    final setCookie = response.headers.map['set-cookie'];
    if (setCookie == null || setCookie.isEmpty) return;

    final cookie = cookieHeaderFromSetCookie(setCookie);
    if (cookie.isEmpty) return;

    final csrfToken = cookieValue(setCookie, 'csrf_token');
    final currentUser = await _storage.readUserId() ?? '';
    await _storage.saveSession(
      cookie: cookie,
      userId: currentUser,
      csrfToken: csrfToken,
    );
  }

  ApiException readableException(Object error) {
    if (error is ApiConfigurationException) {
      return ApiException(error.message);
    }
    if (error is DioException) {
      return ApiException(
        _messageFromDio(error),
        statusCode: error.response?.statusCode,
      );
    }
    if (error is ApiException) return error;
    return ApiException(error.toString());
  }

  static String cookieHeaderFromSetCookie(List<String> setCookie) {
    return setCookie
        .map((value) => value.split(';').first.trim())
        .where((value) => value.isNotEmpty)
        .join('; ');
  }

  static String? cookieValue(List<String> setCookie, String key) {
    for (final cookie in setCookie) {
      final first = cookie.split(';').first.trim();
      final parts = first.split('=');
      if (parts.length >= 2 && parts.first == key) {
        return parts.sublist(1).join('=');
      }
    }
    return null;
  }

  String _messageFromDio(DioException error) {
    final data = error.response?.data;
    if (data is Map<String, dynamic>) {
      final message = data['message'];
      if (message != null) return _cleanMessage(message.toString());

      final serverMessages = data['_server_messages'];
      if (serverMessages != null) {
        return _serverMessages(serverMessages);
      }
      final exception = data['exception'] ?? data['exc'];
      if (exception != null) return _cleanMessage(exception.toString());
    }

    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout) {
      return 'Connection timed out. Please check your network.';
    }

    return _cleanMessage(error.message ?? 'Request failed. Please try again.');
  }

  String _serverMessages(Object messages) {
    try {
      final decoded = jsonDecode(messages.toString());
      if (decoded is List) {
        return decoded
            .map((entry) {
              final item = entry is String ? jsonDecode(entry) : entry;
              return item is Map ? item['message']?.toString() : null;
            })
            .whereType<String>()
            .map(_cleanMessage)
            .join('\n');
      }
    } on Object {
      return _cleanMessage(messages.toString());
    }
    return _cleanMessage(messages.toString());
  }

  String _cleanMessage(String message) {
    return message
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&amp;', '&')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .trim();
  }

  Map<String, Object?> _redactHeaders(Map<String, dynamic> headers) {
    return headers.map((key, value) {
      final lower = key.toLowerCase();
      if (lower == 'cookie' ||
          lower == 'set-cookie' ||
          lower == 'authorization' ||
          lower == 'x-frappe-csrf-token') {
        return MapEntry(key, '<redacted>');
      }
      return MapEntry(key, value);
    });
  }

  Object? _redactBody(Object? data) {
    if (data is Map) {
      return data.map((key, value) {
        final lower = key.toString().toLowerCase();
        if (lower == 'pwd' || lower == 'password') {
          return MapEntry(key, '<redacted>');
        }
        return MapEntry(key, value);
      });
    }
    return data;
  }
}
