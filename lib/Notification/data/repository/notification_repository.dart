import 'package:ziya_laundry_deliveryapp/Notification/data/Service/notification_service.dart';

import '../model/notification_model.dart';

class NotificationRepository {
  final NotificationService _service;
  NotificationRepository(this._service);

  Future<List<NotificationModel>> getNotifications() async {
    final data = await _service.fetchNotificationsFromApi();
    return data.map((json) => NotificationModel.fromJson(json)).toList();
  }
}