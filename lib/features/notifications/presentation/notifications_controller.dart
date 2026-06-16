import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../repositories/notification_repository.dart';

final notificationsControllerProvider =
    NotifierProvider<NotificationsController, NotificationsState>(
      NotificationsController.new,
    );

class NotificationsState {
  const NotificationsState({
    this.items = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  final List<AppNotification> items;
  final bool isLoading;
  final String? errorMessage;

  NotificationsState copyWith({
    List<AppNotification>? items,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return NotificationsState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

class NotificationsController extends Notifier<NotificationsState> {
  NotificationRepository get _repository =>
      ref.read(notificationRepositoryProvider);

  @override
  NotificationsState build() => const NotificationsState();

  Future<void> load() async {
    if (state.isLoading) return;
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final items = await _repository.fetchNotifications();
      state = state.copyWith(items: items, isLoading: false);
    } on Object catch (error) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: error.toString().replaceFirst('Exception: ', ''),
      );
    }
  }
}
