import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/api/api_client.dart';
import '../core/constants/api_endpoints.dart';

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepository(ref.watch(apiClientProvider));
});

class NotificationRepository {
  const NotificationRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<List<AppNotification>> fetchNotifications() async {
    final response = await _apiClient.get(
      '${ApiEndpoints.resource}/Notification Log',
      queryParameters: {
        'fields': jsonEncode(['subject', 'creation', 'read']),
        'order_by': 'creation desc',
        'limit_page_length': 20,
      },
    );
    final data = response.data is Map ? response.data['data'] : null;
    if (data is! List) return const [];
    return data
        .whereType<Map>()
        .map(
          (item) => AppNotification.fromJson(Map<String, dynamic>.from(item)),
        )
        .where((item) => item.subject.isNotEmpty)
        .toList();
  }
}

class AppNotification {
  const AppNotification({
    required this.subject,
    required this.creation,
    required this.read,
  });

  final String subject;
  final String creation;
  final bool read;

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      subject: json['subject']?.toString() ?? '',
      creation: json['creation']?.toString() ?? '-',
      read:
          json['read'] == 1 ||
          json['read'] == true ||
          json['read']?.toString() == '1',
    );
  }
}
