// import 'package:flutter/material.dart';
// import 'package:ziya_laundry_deliveryapp/features/Notification/data/repository/notification_repository.dart';
// import 'package:ziya_laundry_deliveryapp/core/services/SocketService.dart';
// import '../data/model/notification_model.dart';

// class NotificationViewModel extends ChangeNotifier {
//   final NotificationRepository _repository;
//   NotificationViewModel(this._repository) {
//     fetchNotifications();
//   }

//   List<NotificationModel> _notifications = [];
//   bool _isLoading = false;
//   int _unreadCount = 0;
//   bool _socketInitialized = false;

//   List<NotificationModel> get notificationList => _notifications;
//   bool get isLoading => _isLoading;
//   int get unreadCount => _unreadCount;
//   bool get hasUnread => _unreadCount > 0;

//   Future<void> fetchNotifications() async {
//     _isLoading = true;
//     notifyListeners();
//     try {
//       _notifications = await _repository.getNotifications();
//       _unreadCount = _notifications.where((item) => !item.isRead).length;
//     } catch (e) {
//       debugPrint("NotificationViewModel Error: $e");
//       _notifications = [];
//       _unreadCount = 0;
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }

//   void toggleSelection(int index) {
//     _notifications[index] = _notifications[index].copyWith(
//       isSelected: !_notifications[index].isSelected,
//     );
//     notifyListeners();
//   }

//   void removeAt(int index) {
//     _notifications.removeAt(index);
//     notifyListeners();
//   }

//   /// Clear a notification at [index] by calling repository and removing on success.
//   Future<bool> clearNotificationAt(int index) async {
//     if (index < 0 || index >= _notifications.length) return false;
//     final id = _notifications[index].id;
//     final wasUnread = !_notifications[index].isRead;
//     _isLoading = true;
//     notifyListeners();
//     try {
//       final success = await _repository.clearNotification(id);
//       if (success) {
//         _notifications.removeAt(index);
//         if (wasUnread && _unreadCount > 0) {
//           _unreadCount -= 1;
//         }
//         notifyListeners();
//         return true;
//       }
//       return false;
//     } catch (e) {
//       debugPrint('clearNotificationAt error: $e');
//       return false;
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }

//   Future<bool> markAsReadAt(int index) async {
//     if (index < 0 || index >= _notifications.length) return false;
//     final id = _notifications[index].id;
//     try {
//       final success = await _repository.markAsRead(id);
//       if (success && !_notifications[index].isRead) {
//         _notifications[index] = _notifications[index].copyWith(isRead: true);
//         if (_unreadCount > 0) {
//           _unreadCount -= 1;
//         }
//         notifyListeners();
//       }
//       return success;
//     } catch (e) {
//       debugPrint('markAsReadAt error: $e');
//       return false;
//     }
//   }

//   Future<bool> undoClearAt(int index, {String? notificationIdOverride}) async {
//     final id = notificationIdOverride ?? (index >= 0 && index < _notifications.length ? _notifications[index].id : null);
//     if (id == null) return false;
//     try {
//       final success = await _repository.undoClear(id);
//       if (success) {
//         await fetchNotifications();
//       }
//       return success;
//     } catch (e) {
//       debugPrint('undoClearAt error: $e');
//       return false;
//     }
//   }

//   Future<bool> undoMultipleClear(List<String> notificationIds) async {
//     if (notificationIds.isEmpty) return false;
//     try {
//       final success = await _repository.undoClearMultiple(notificationIds);
//       if (success) {
//         await fetchNotifications();
//       }
//       return success;
//     } catch (e) {
//       debugPrint('undoMultipleClear error: $e');
//       return false;
//     }
//   }

//   void selectAll(bool selected) {
//     _notifications = _notifications
//         .map((item) => item.copyWith(isSelected: selected))
//         .toList();
//     notifyListeners();
//   }

//   Future<List<String>> deleteSelected() async {
//     final selectedIds = _notifications
//         .where((e) => e.isSelected)
//         .map((e) => e.id)
//         .toList();

//     if (selectedIds.isEmpty) return [];

//     _isLoading = true;
//     notifyListeners();

//     try {
//       final success = await _repository
//           .clearNotifications(selectedIds);

//       if (success) {
//         _notifications.removeWhere(
//           (e) => e.isSelected,
//         );

//         _unreadCount =
//             _notifications.where((e) => !e.isRead).length;
//         return selectedIds;
//       }
//       return [];
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }

//   /// Initialize notification view model for a specific user.
//   /// Keeps signature compatible with existing callers: `init(userId, role)`.
//   Future<void> init(String userId, String role) async {
//     await SocketService().connect(userId: userId, role: role);
//     initSocket();
//     await fetchNotifications();
//   }

//   /// Initialize Socket listeners for real-time notifications.
//   void initSocket() {
//     if (_socketInitialized) return;

//     _socketInitialized = true;
//     SocketService().listenNotificationChange((data) {
//       debugPrint(
//         '🔔 Live Notification Received => $data',
//       );
//       // Re-fetch all notifications to ensure UI is always in sync with backend
//       // This avoids client-side parsing issues and duplicate checks.
//       fetchNotifications();
//     });

//     SocketService().listenJoinSuccess((data) {
//       debugPrint(
//         '✅ Joined Room => $data',
//       );
//     });
//   }

//   @override
//   void dispose() {
//     // Clean up socket listeners when the ViewModel is disposed
//     SocketService().off('notification-change');
//     SocketService().off('joined-successfully');
//     super.dispose();
//   }
// }
import 'package:flutter/material.dart';
import 'package:ziya_laundry_deliveryapp/features/Notification/data/repository/notification_repository.dart';
import 'package:ziya_laundry_deliveryapp/core/services/SocketService.dart';
import '../data/model/notification_model.dart';

class NotificationViewModel extends ChangeNotifier {
  final NotificationRepository _repository;
  NotificationViewModel(this._repository) {
    fetchNotifications();
  }

  List<NotificationModel> _notifications = [];
  bool _isLoading = false;
  int _unreadCount = 0;
  bool _socketInitialized = false;

  List<NotificationModel> get notificationList => _notifications;
  bool get isLoading => _isLoading;
  int get unreadCount => _unreadCount;
  bool get hasUnread => _unreadCount > 0;

  Future<void> fetchNotifications() async {
    _isLoading = true;
    notifyListeners();
    try {
      _notifications = await _repository.getNotifications();
      _unreadCount = _notifications.where((item) => !item.isRead).length;
    } catch (e) {
      debugPrint("NotificationViewModel Error: $e");
      _notifications = [];
      _unreadCount = 0;
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

  /// Clear a notification at [index] by calling repository and removing on success.
  Future<bool> clearNotificationAt(int index) async {
    if (index < 0 || index >= _notifications.length) return false;
    final id = _notifications[index].id;
    final wasUnread = !_notifications[index].isRead;
    _isLoading = true;
    notifyListeners();
    try {
      final success = await _repository.clearNotification(id);
      if (success) {
        _notifications.removeAt(index);
        if (wasUnread && _unreadCount > 0) {
          _unreadCount -= 1;
        }
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('clearNotificationAt error: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> markAsReadAt(int index) async {
    if (index < 0 || index >= _notifications.length) return false;
    final id = _notifications[index].id;
    try {
      final success = await _repository.markAsRead(id);
      if (success && !_notifications[index].isRead) {
        _notifications[index] = _notifications[index].copyWith(isRead: true);
        if (_unreadCount > 0) {
          _unreadCount -= 1;
        }
        notifyListeners();
      }
      return success;
    } catch (e) {
      debugPrint('markAsReadAt error: $e');
      return false;
    }
  }

  Future<bool> undoClearAt(int index, {String? notificationIdOverride}) async {
    final id = notificationIdOverride ?? (index >= 0 && index < _notifications.length ? _notifications[index].id : null);
    if (id == null) return false;
    try {
      final success = await _repository.undoClear(id);
      if (success) {
        await fetchNotifications();
      }
      return success;
    } catch (e) {
      debugPrint('undoClearAt error: $e');
      return false;
    }
  }

  Future<bool> undoMultipleClear(List<String> notificationIds) async {
    if (notificationIds.isEmpty) return false;
    try {
      final success = await _repository.undoClearMultiple(notificationIds);
      if (success) {
        await fetchNotifications();
      }
      return success;
    } catch (e) {
      debugPrint('undoMultipleClear error: $e');
      return false;
    }
  }

  void selectAll(bool selected) {
    _notifications = _notifications
        .map((item) => item.copyWith(isSelected: selected))
        .toList();
    notifyListeners();
  }

  Future<List<String>> deleteSelected() async {
    final selectedIds = _notifications
        .where((e) => e.isSelected)
        .map((e) => e.id)
        .toList();

    if (selectedIds.isEmpty) return [];

    _isLoading = true;
    notifyListeners();

    try {
      final success = await _repository
          .clearNotifications(selectedIds);

      if (success) {
        _notifications.removeWhere(
          (e) => e.isSelected,
        );

        _unreadCount =
            _notifications.where((e) => !e.isRead).length;
        return selectedIds;
      }
      return [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Initialize notification view model for a specific user.
  /// Keeps signature compatible with existing callers: `init(userId, role)`.
  Future<void> init(String userId, String role) async {
    await SocketService().connect(userId: userId, role: role);
    initSocket();
    await fetchNotifications();
  }

  /// Initialize Socket listeners for real-time notifications.
  void initSocket() {
    if (_socketInitialized) return;

    _socketInitialized = true;
    SocketService().listenNotificationChange((data) {
      debugPrint(
        '🔔 Live Notification Received => $data',
      );
      // Re-fetch all notifications to ensure UI is always in sync with backend
      // This avoids client-side parsing issues and duplicate checks.
      fetchNotifications();
    });

    SocketService().listenJoinSuccess((data) {
      debugPrint(
        '✅ Joined Room => $data',
      );
    });
  }

  @override
  void dispose() {
    // Clean up socket listeners when the ViewModel is disposed
    SocketService().off('notification-change');
    SocketService().off('joined-successfully');
    super.dispose();
  }
}