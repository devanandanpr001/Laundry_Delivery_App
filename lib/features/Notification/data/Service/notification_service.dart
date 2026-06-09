import 'package:flutter/material.dart';
import 'package:ziya_laundry_deliveryapp/core/network/dio_client.dart';
import 'package:ziya_laundry_deliveryapp/core/Constants/api_constants.dart';

class NotificationService {
  NotificationService._internal();

  static final NotificationService instance = NotificationService._internal();

  /// If the app was launched from a terminated notification, the payload
  /// can be stored here for the UI to handle once navigation is ready.
  Map<String, dynamic>? pendingNavigationData;

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
        : {"notificationIds": notificationIds}; // Changed to PATCH
    final resp = await _client.patch(ApiConstants.notificationClear, data: body);
    return resp != null && resp['success'] == true;
  }

  Future<bool> undoNotifications(List<String> notificationIds) async {
    final resp = await _client.patch(ApiConstants.notificationUndo, data: {"notificationIds": notificationIds});
    return resp != null && resp['success'] == true;
  }

  /// Handle any pending navigation payload. This method should be called
  /// after the app's navigator is ready. Keep implementation minimal so
  /// callers can invoke it safely without UI changes.
  void handlePendingNavigation(Map<String, dynamic> data, BuildContext context) {
    try {
      // Example: if payload contains a route name, navigate to it.
      final route = data['route'] as String?;
      if (route != null && route.isNotEmpty) {
        Navigator.pushNamed(context, route, arguments: data['args']);
        return;
      }

      // If no route provided, log the payload for debugging.
      debugPrint('handlePendingNavigation: no route found in payload: $data');
    } catch (e) {
      debugPrint('handlePendingNavigation error: $e');
    }
  }
}