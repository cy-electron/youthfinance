import 'package:dio/dio.dart';

import '../../../core/network/api_endpoints.dart';
import '../../../core/network/dio_client.dart';
import 'app_notification.dart';

class NotificationRepository {
  final Dio _dio = DioClient.instance;

  Future<List<AppNotification>> getNotifications() async {
    final response = await _dio.get(ApiEndpoints.notifications);
    final body = response.data as Map<String, dynamic>;
    return (body['data'] as List<dynamic>)
        .map((item) => AppNotification.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<int> getUnreadCount() async {
    final response = await _dio.get('${ApiEndpoints.notifications}/unread-count');
    final body = response.data as Map<String, dynamic>;
    return (body['data']['count'] as num).toInt();
  }

  Future<AppNotification> markRead(int id) async {
    final response = await _dio.patch('${ApiEndpoints.notifications}/$id/read');
    final body = response.data as Map<String, dynamic>;
    return AppNotification.fromJson(body['data'] as Map<String, dynamic>);
  }

  Future<void> markAllRead() async {
    await _dio.post('${ApiEndpoints.notifications}/read-all');
  }

  Future<NotificationPreference> getPreferences() async {
    final response = await _dio.get('${ApiEndpoints.notifications}/preferences');
    final body = response.data as Map<String, dynamic>;
    return NotificationPreference.fromJson(body['data'] as Map<String, dynamic>);
  }

  Future<NotificationPreference> updatePreferences({
    required bool emergencyFundEnabled,
  }) async {
    final response = await _dio.patch(
      '${ApiEndpoints.notifications}/preferences',
      data: {'emergency_fund_enabled': emergencyFundEnabled},
    );
    final body = response.data as Map<String, dynamic>;
    return NotificationPreference.fromJson(body['data'] as Map<String, dynamic>);
  }
}
