class NotificationModel {
  final String id;
  final String title;
  final String message;
  final String createdAt;
  final bool isRead;
  final bool isDelivered;
  final bool isSelected;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.createdAt,
    this.isRead = false,
    this.isDelivered = false,
    this.isSelected = false,
  });

  NotificationModel copyWith({
    String? id,
    String? title,
    String? message,
    String? createdAt,
    bool? isRead,
    bool? isDelivered,
    bool? isSelected,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      isDelivered: isDelivered ?? this.isDelivered,
      isSelected: isSelected ?? this.isSelected,
    );
  }

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id']?.toString() ?? json['notificationId']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      message: json['message']?.toString() ?? json['body']?.toString() ?? '',
      createdAt: json['createdAt']?.toString() ?? json['time']?.toString() ?? '',
      isRead: json['isRead'] ?? false,
      isDelivered: json['isDelivered'] ?? false,
      isSelected: false,
    );
  }
}