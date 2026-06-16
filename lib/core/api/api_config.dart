class ApiConfig {
  const ApiConfig._();

  static const String baseUrl = String.fromEnvironment(
    'ERP_BASE_URL',
    defaultValue: 'https://sanskruti.duxdigitech.in',
  );

  static Uri get baseUri {
    final uri = Uri.tryParse(baseUrl);
    if (uri == null || !uri.hasScheme || uri.host.isEmpty) {
      throw const ApiConfigurationException('ERP_BASE_URL is invalid.');
    }
    if (uri.scheme != 'https') {
      throw const ApiConfigurationException(
        'ERP_BASE_URL must use HTTPS for production security.',
      );
    }
    return uri;
  }
}

class ApiConfigurationException implements Exception {
  const ApiConfigurationException(this.message);

  final String message;

  @override
  String toString() => message;
}
