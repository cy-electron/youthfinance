class AppNotification {
  final int id;
  final String type;
  final String title;
  final String message;
  final bool isRead;
  final DateTime createdAt;

  const AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.isRead,
    required this.createdAt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: (json['id'] as num).toInt(),
      type: json['notification_type'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      isRead: json['is_read'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}

class NotificationPreference {
  final bool emergencyFundEnabled;

  const NotificationPreference({required this.emergencyFundEnabled});

  factory NotificationPreference.fromJson(Map<String, dynamic> json) {
    return NotificationPreference(
      emergencyFundEnabled: json['emergency_fund_enabled'] as bool,
    );
  }
}
