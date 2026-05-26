import 'package:flutter/material.dart';
import 'package:ziya_laundry_deliveryapp/Orders/data/repository/service_repository.dart';
import 'package:ziya_laundry_deliveryapp/Home/data/repository/home_repository.dart';
import 'package:ziya_laundry_deliveryapp/Profile/data/repository/profile_repository.dart';
import '../../Constants/Api_Constants.dart';
import '../../core/dio_client.dart';

class HomeViewModel extends ChangeNotifier {
  final HomeRepository _repository;
  final ProfileRepository _profileRepository;
  final ServiceRepository _serviceRepository;

  HomeViewModel(this._repository, this._profileRepository, this._serviceRepository) {
    _init();
  }

  bool _isOnline = false;
  bool _isLoading = false;
  bool _isSessionExpired = false;
  String _selectedFilter = "all";
  int _selectedIndex = 0; // For BottomNavigationBar index
  String? _scrollToOrderId; // For scrolling to a specific order
  int _assignedCount = 0;
  int _completedCount = 0;
  String _userName = "";
  String _profileImage = "";
  String _address = "";
  String? _errorMessage;

  bool get isOnline => _isOnline;
  bool get isLoading => _isLoading;
  bool get isSessionExpired => _isSessionExpired;
  String get selectedFilter => _selectedFilter;
  int get selectedIndex => _selectedIndex;
  String? get scrollToOrderId => _scrollToOrderId;
  String? get errorMessage => _errorMessage;
  int get assignedCount => _assignedCount;
  int get completedCount => _completedCount;
  String get userName => _userName;
  String get profileImage => _profileImage;
  String get address => _address;

  Future<void> _init() async {
    try {
      _isOnline = await _repository.getInitialOnlineStatus();
    } catch (e) {
      debugPrint("HomeViewModel: Failed to fetch initial online status: $e");
      _isOnline = false;
    }
    _isSessionExpired = false;
    DioClient.onSessionExpired = _handleSessionExpired;
    refreshOrders();
  }

  void _handleSessionExpired() {
    _isSessionExpired = true;
    _clearAllCachedData();
    notifyListeners();
  }

  /// Clears all cached data when session expires
  void _clearAllCachedData() {
    _userName = "";
    _profileImage = "";
    _address = "";
    _isOnline = false;
    _errorMessage = null;
  }

  /// Resets the session expired flag. Call this after showing the popup.
  void resetSessionExpired() {
    _isSessionExpired = false;
    notifyListeners();
  }

  Future<void> refreshOrders() async {
    if (_isLoading) return; // Performance: Prevent multiple simultaneous refreshes
    _isLoading = true;
    notifyListeners();
    try {
      final results = await Future.wait<dynamic>([
        _repository.getDashboardCounts().catchError((e) {
          debugPrint("HomeViewModel: Counts fetch failed: $e");
          return <String, dynamic>{};
        }),
        _profileRepository.getProfile().catchError((e) {
          debugPrint("HomeViewModel: Profile fetch failed: $e");
          return null;
        }),
      ]);

      final countData = (results[0] as Map<String, dynamic>?) ?? {};
      _assignedCount = countData['assignedCount'] ?? 0;
      _completedCount = countData['completedCount'] ?? 0;

      final profileData = results[1] as Map<String, dynamic>?;
      if (profileData != null) {
        _userName = profileData['name']?.toString() ?? "User";
        _address = profileData['address']?.toString() ?? "";
        String pImg = profileData['profileImage']?.toString() ?? "";
        if (pImg.isNotEmpty && !pImg.startsWith('http')) {
          _profileImage = '${ApiConstants.mediaBaseUrl}${pImg.startsWith('/') ? pImg.substring(1) : pImg}';
        } else {
          _profileImage = pImg;
        }
        _isOnline = profileData['isOnline'] ?? _isOnline;
      } else {
        if (_userName.isEmpty) _userName = "User";
        debugPrint("HomeViewModel: Profile data was null, using fallback name.");
      }
    } catch (e) {
      debugPrint("HomeViewModel Error: $e");
      _errorMessage = "Unable to fully sync dashboard. Please check connection.";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Clear error message after it's shown in the UI
  void clearErrorMessage() {
    _errorMessage = null;
    notifyListeners();
  }

  void setSelectedFilter(String filter) {
    _selectedFilter = filter;
    notifyListeners();
  }

  void setSelectedIndex(int index) {
    if (_selectedIndex != index) {
      _selectedIndex = index;
      notifyListeners();
    }
  }

  void setScrollToOrderId(String? orderId) {
    _scrollToOrderId = orderId;
    notifyListeners();
  }

  void clearScrollTarget() {
    _scrollToOrderId = null;
  }

  Future<void> toggleOnlineStatus() async {
    final newStatus = !_isOnline;
    // Optimistic UI update
    _isOnline = newStatus;
    notifyListeners();

    try {
      // Use PUT to match the backend route defined in users.route.js
      final response = await DioClient().put(
        ApiConstants.onlineStatus,
        data: {"isOnline": newStatus},
      );

      if (response == null || response['success'] != true) {
        throw Exception("Failed to update status");
      }
    } catch (e) {
      _isOnline = !newStatus; // Revert on failure
      notifyListeners();
      debugPrint("Error updating online status: $e");
    }
  }
}