class NotificationModel {
  final String title;
  final String time;
  final String orderId;
  final bool isSelected;

  NotificationModel({
    required this.title,
    required this.time,
    required this.orderId,
    this.isSelected = false,
  });

  NotificationModel copyWith({bool? isSelected}) {
    return NotificationModel(
      title: title,
      time: time,
      orderId: orderId,
      isSelected: isSelected ?? this.isSelected,
    );
  }

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      title: json['title'] ?? '',
      time: json['time'] ?? '',
      orderId: json['orderId'] ?? '',
      isSelected: json['isSelected'] ?? false,
    );
  }
}