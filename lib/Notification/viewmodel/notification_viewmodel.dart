import 'package:flutter/material.dart';
import 'package:ziya_laundry_deliveryapp/Notification/data/repository/notification_repository.dart';
import '../data/model/notification_model.dart';

class NotificationViewModel extends ChangeNotifier {
  final NotificationRepository _repository;
  NotificationViewModel(this._repository) {
    fetchNotifications();
  }

  List<NotificationModel> _notifications = [];
  bool _isLoading = false;

  List<NotificationModel> get notificationList => _notifications;
  bool get isLoading => _isLoading;

  Future<void> fetchNotifications() async {
    _isLoading = true;
    notifyListeners();
    try {
      _notifications = await _repository.getNotifications();
    } catch (e) {
      debugPrint("NotificationViewModel Error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void toggleSelection(int index) {
    _notifications[index] = _notifications[index].copyWith(
      isSelected: !_notifications[index].isSelected,
    );
    notifyListeners();
  }

  void removeAt(int index) {
    _notifications.removeAt(index);
    notifyListeners();
  }

  void selectAll(bool selected) {
    _notifications = _notifications
        .map((item) => item.copyWith(isSelected: selected))
        .toList();
    notifyListeners();
  }

  void deleteSelected() {
    _notifications.removeWhere((item) => item.isSelected);
    notifyListeners();
  }
}