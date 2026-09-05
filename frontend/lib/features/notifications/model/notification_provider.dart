import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_notification.dart';
import 'notification_repository.dart';

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepository();
});

final notificationProvider =
    AsyncNotifierProvider<NotificationNotifier, List<AppNotification>>(
      NotificationNotifier.new,
    );

final unreadNotificationCountProvider = FutureProvider<int>((ref) {
  return ref.read(notificationRepositoryProvider).getUnreadCount();
});

final notificationPreferenceProvider =
    AsyncNotifierProvider<NotificationPreferenceNotifier, NotificationPreference>(
      NotificationPreferenceNotifier.new,
    );

class NotificationNotifier extends AsyncNotifier<List<AppNotification>> {
  @override
  Future<List<AppNotification>> build() {
    return ref.read(notificationRepositoryProvider).getNotifications();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    try {
      state = AsyncValue.data(
        await ref.read(notificationRepositoryProvider).getNotifications(),
      );
      ref.invalidate(unreadNotificationCountProvider);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> markRead(int id) async {
    final updated = await ref.read(notificationRepositoryProvider).markRead(id);
    final current = state.valueOrNull;
    if (current != null) {
      state = AsyncValue.data([
        for (final notification in current)
          notification.id == id ? updated : notification,
      ]);
    }
    ref.invalidate(unreadNotificationCountProvider);
  }

  Future<void> markAllRead() async {
    await ref.read(notificationRepositoryProvider).markAllRead();
    final current = state.valueOrNull;
    if (current != null) {
      state = AsyncValue.data([
        for (final notification in current)
          AppNotification(
            id: notification.id,
            type: notification.type,
            title: notification.title,
            message: notification.message,
            isRead: true,
            createdAt: notification.createdAt,
          ),
      ]);
    }
    ref.invalidate(unreadNotificationCountProvider);
  }
}

class NotificationPreferenceNotifier
    extends AsyncNotifier<NotificationPreference> {
  @override
  Future<NotificationPreference> build() {
    return ref.read(notificationRepositoryProvider).getPreferences();
  }

  Future<void> updateEmergencyFundEnabled(bool enabled) async {
    state = AsyncValue.data(
      await ref
          .read(notificationRepositoryProvider)
          .updatePreferences(emergencyFundEnabled: enabled),
    );
  }
}
