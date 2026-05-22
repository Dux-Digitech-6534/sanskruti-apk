import 'api/api_config.dart';

class AppConstants {
  AppConstants._();

  static const appName = 'Sanskruti Group';
  static const backendBaseUrl = ApiConfig.baseUrl;
  static const loginPath = '/api/method/login';
  static const resourcePath = '/api/resource';
  static const sessionCookieKey = 'session_cookie';
  static const csrfTokenKey = 'csrf_token';
  static const userKey = 'user_id';
  static const approvalThreshold = 50000.0;
  static const requestTimeout = Duration(seconds: 90);

  static const preparedCapabilities = [
    'Push Notifications',
    'Offline Sync',
    'PDF Download',
    'QR Scanner',
    'Signature Upload',
    'Role-based Access',
    'Multi-project Support',
  ];
}
