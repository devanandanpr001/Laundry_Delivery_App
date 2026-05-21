import 'package:ziya_laundry_deliveryapp/core/dio_client.dart';
import 'package:ziya_laundry_deliveryapp/Constants/Api_Constants.dart';

class NotificationService {
  final DioClient _client = DioClient();

  Future<Map<String, dynamic>> fetchNotificationsResponse() async {
    final resp = await _client.get(ApiConstants.notification);
    if (resp is Map<String, dynamic>) {
      return resp;
    }
    return {};
  }

  Future<List<Map<String, dynamic>>> fetchNotificationsFromApi() async {
    final response = await fetchNotificationsResponse();
    final notifications = response['notifications'];
    if (notifications is List) {
      return List<Map<String, dynamic>>.from(notifications);
    }
    if (response['data'] is List) {
      return List<Map<String, dynamic>>.from(response['data']);
    }
    return [];
  }

  Future<bool> markAsRead(List<String> notificationIds, {bool markAll = false}) async {
    final body = markAll
        ? {"markAll": true}
        : {"notificationIds": notificationIds};
    // Ensure this is PATCH to avoid the 404 "Cannot POST" error
    final resp = await _client.patch(ApiConstants.notificationRead, data: body);
    return resp != null && resp['success'] == true;
  }

  Future<bool> clearNotifications(List<String> notificationIds, {bool clearAll = false}) async {
    final body = clearAll
        ? {"clearAll": true}
        : {"notificationIds": notificationIds};
    final resp = await _client.post(ApiConstants.notificationClear, data: body);
    return resp != null && resp['success'] == true;
  }

  Future<bool> undoNotifications(List<String> notificationIds) async {
    final resp = await _client.post(ApiConstants.notificationUndo, data: {"notificationIds": notificationIds});
    return resp != null && resp['success'] == true;
  }
}