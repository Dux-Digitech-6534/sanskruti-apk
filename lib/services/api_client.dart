import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../core/api/api_config.dart';
import '../core/app_constants.dart';
import 'storage_service.dart';

class ApiClient {
  ApiClient(this._storage) {
    dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUri.toString(),
        connectTimeout: AppConstants.requestTimeout,
        receiveTimeout: AppConstants.requestTimeout,
        sendTimeout: AppConstants.requestTimeout,
        contentType: Headers.jsonContentType,
        responseType: ResponseType.json,
        headers: const {
          'Accept': 'application/json',
          'X-Requested-With': 'XMLHttpRequest',
        },
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final cookie = await _storage.sessionCookie;
          if (cookie != null && cookie.isNotEmpty) {
            options.headers['Cookie'] = cookie;
          }
          final csrfToken = await _storage.csrfToken;
          if (csrfToken != null && csrfToken.isNotEmpty) {
            options.headers['X-Frappe-CSRF-Token'] = csrfToken;
          }
          handler.next(options);
        },
        onResponse: (response, handler) async {
          final setCookie = response.headers.map['set-cookie'];
          if (setCookie != null && setCookie.isNotEmpty) {
            final cookie = _cookieHeaderFromSetCookie(setCookie);
            final csrfToken = _cookieValue(setCookie, 'csrf_token');
            final user = await _storage.userId ?? '';
            if (cookie.isNotEmpty) {
              await _storage.saveSession(
                cookie: cookie,
                userId: user,
                csrfToken: csrfToken,
              );
            }
          }
          handler.next(response);
        },
      ),
    );

    dio.interceptors.add(_FrappeDebugLogInterceptor());
  }

  final StorageService _storage;
  late final Dio dio;

  static String cookieHeaderFromSetCookie(List<String> setCookie) =>
      _cookieHeaderFromSetCookie(setCookie);

  static String? csrfFromSetCookie(List<String> setCookie) =>
      _cookieValue(setCookie, 'csrf_token');

  String readableError(Object error) {
    if (error is DioException) {
      final data = error.response?.data;
      if (data is Map && data['message'] != null) {
        return _cleanMessage(data['message'].toString());
      }
      if (data is Map && data['_server_messages'] != null) {
        return _serverMessages(data['_server_messages']);
      }
      if (data is Map && data['exc'] != null) {
        return _cleanMessage(data['exc'].toString());
      }
      if (error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.receiveTimeout) {
        return 'Connection timed out. Please check network connectivity.';
      }
      return _cleanMessage(
        error.message ?? 'Request failed. Please try again.',
      );
    }
    return _cleanMessage(error.toString());
  }

  static String _cookieHeaderFromSetCookie(List<String> setCookie) {
    return setCookie
        .map((value) => value.split(';').first.trim())
        .where((value) => value.isNotEmpty)
        .join('; ');
  }

  static String? _cookieValue(List<String> setCookie, String key) {
    for (final cookie in setCookie) {
      final first = cookie.split(';').first.trim();
      final parts = first.split('=');
      if (parts.length >= 2 && parts.first == key) {
        return parts.sublist(1).join('=');
      }
    }
    return null;
  }

  static String _serverMessages(Object messages) {
    final value = messages.toString();
    final matches = RegExp(r'"message"\s*:\s*"([^"]+)"').allMatches(value);
    final parsed = matches
        .map((match) => match.group(1))
        .whereType<String>()
        .join('\n');
    return _cleanMessage(parsed.isNotEmpty ? parsed : value);
  }

  static String _cleanMessage(String message) {
    return message
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&amp;', '&')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .trim();
  }
}

class _FrappeDebugLogInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint('[Frappe API] --> ${options.method} ${options.uri}');
      debugPrint('[Frappe API] headers: ${_redactHeaders(options.headers)}');
      debugPrint('[Frappe API] body: ${_redactBody(options.data)}');
    }
    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    if (kDebugMode) {
      debugPrint(
        '[Frappe API] <-- ${response.statusCode} ${response.requestOptions.uri}',
      );
      debugPrint(
        '[Frappe API] response headers: ${_redactHeaders(response.headers.map)}',
      );
      debugPrint('[Frappe API] response: ${response.data}');
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint(
        '[Frappe API] !! ${err.response?.statusCode} ${err.requestOptions.uri}',
      );
      debugPrint(
        '[Frappe API] error headers: ${_redactHeaders(err.response?.headers.map ?? const {})}',
      );
      debugPrint('[Frappe API] error: ${err.response?.data ?? err.message}');
    }
    handler.next(err);
  }

  Map<String, Object?> _redactHeaders(Map<String, dynamic> headers) {
    return headers.map((key, value) {
      final lower = key.toLowerCase();
      if (lower == 'cookie' ||
          lower == 'set-cookie' ||
          lower == 'authorization') {
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
