import 'package:ziya_laundry_deliveryapp/features/Notification/data/Service/notification_service.dart';

import '../model/notification_model.dart';

class NotificationRepository {
  final NotificationService _service;
  NotificationRepository(this._service);

  Future<Map<String, dynamic>> getNotificationsResponse() async {
    return await _service.fetchNotificationsResponse();
  }

  Future<List<NotificationModel>> getNotifications() async {
    final data = await _service.fetchNotificationsFromApi();
    return data.map((json) => NotificationModel.fromJson(json)).toList();
  }

  Future<bool> markAsRead(String notificationId) async {
    try {
      return await _service.markAsRead([notificationId]);
    } catch (e) {
      return false;
    }
  }

  /// Bulk clear notifications
  Future<bool> clearNotifications(List<String> notificationIds) async {
    try {
      return await _service.clearNotifications(notificationIds);
    } catch (e) {
      return false;
    }
  }

  Future<bool> clearNotification(String notificationId) async {
    try {
      return await _service.clearNotifications([notificationId]);
    } catch (e) {
      return false;
    }
  }

  Future<bool> undoClear(String notificationId) async {
    try {
      return await _service.undoNotifications([notificationId]);
    } catch (e) {
      return false;
    }
  }

  Future<bool> undoClearMultiple(List<String> notificationIds) async {
    try {
      return await _service.undoNotifications(notificationIds);
    } catch (e) {
      return false;
    }
  }
}