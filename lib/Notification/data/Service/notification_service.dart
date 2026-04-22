import 'dart:async';

class NotificationService {
  Future<List<Map<String, dynamic>>> fetchNotificationsFromApi() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      {
        "title": "Order Picked",
        "time": "3 minutes ago",
        "orderId": "Order Id: #ORD-2024-001"
      },
      {
        "title": "Order Delivered",
        "time": "1 hour ago",
        "orderId": "Order Id: #ORD-2024-002"
      },
      {
        "title": "Order Cancelled",
        "time": "Yesterday",
        "orderId": "Order Id: #ORD-2024-003"
      },
    ];
  }
}