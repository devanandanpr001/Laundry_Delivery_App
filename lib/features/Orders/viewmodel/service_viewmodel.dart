import 'package:flutter/material.dart';
import 'package:ziya_laundry_deliveryapp/features/Orders/data/repository/service_repository.dart';

class ServiceViewModel extends ChangeNotifier {
  final ServiceRepository _repository;

  ServiceViewModel(this._repository);

  List<Map<String, dynamic>> _availableServices = [];
  final Map<String, List<dynamic>> _serviceItemsMap = {};
  final Set<String> _fetchingServiceIds = {};
  bool _isLoading = false;
  String? _errorMessage;

  List<Map<String, dynamic>> get availableServices => _availableServices;
  Map<String, List<dynamic>> get serviceItemsMap => _serviceItemsMap;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<String> get services => _availableServices
      .map((s) => s['name']?.toString() ?? "")
      .where((name) => name.isNotEmpty)
      .toList();

  void clearAllCachedData() {
    _availableServices.clear();
    _serviceItemsMap.clear();
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> fetchAvailableServices({String? orderId}) async {
    if (_isLoading) return;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _availableServices = await _repository.fetchAvailableServices(orderId: orderId);
    } catch (e) {
      debugPrint("ServiceViewModel fetchAvailableServices Error: $e");
      _errorMessage = "Failed to fetch services: $e";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchItemsForService(String serviceId) async {
    if (_serviceItemsMap.containsKey(serviceId)) return;
    _errorMessage = null;
    notifyListeners();
    try {
      final items = await _repository.fetchItemsForService(serviceId);
      _serviceItemsMap[serviceId] = items;
      notifyListeners();
    } catch (e) {
      debugPrint("ServiceViewModel fetchItemsForService Error: $e");
      _errorMessage = "Failed to fetch items for service: $e";
      notifyListeners();
    }
  }

  Future<void> fetchItemsForMultipleServices(List<String> serviceIds) async {
    final idsToFetch = serviceIds.where((id) => !_serviceItemsMap.containsKey(id) && !_fetchingServiceIds.contains(id)).toList();
    if (idsToFetch.isEmpty) return;

    _fetchingServiceIds.addAll(idsToFetch);
    _errorMessage = null;
    notifyListeners();
    try {
      final items = await _repository.fetchItemsForMultipleServices(idsToFetch);

      for (var id in idsToFetch) {
        _serviceItemsMap[id] = [];
      }

      for (var item in items) {
        final List itemServices = (item['services'] as List?) ?? [];
        for (var s in itemServices) {
          final String? sId = (s is Map) ? (s['serviceId']?.toString() ?? s['id']?.toString()) : s?.toString();
          if (sId != null) {
            for (var targetId in idsToFetch) {
              if (targetId.trim().toLowerCase() == sId.trim().toLowerCase()) {
                _serviceItemsMap[targetId]?.add(item);
              }
            }
          }
        }
      }
    } catch (e) {
      debugPrint("ServiceViewModel fetchItemsForMultipleServices Error: $e");
      _errorMessage = "Failed to fetch multiple service items: $e";
    } finally {
      _fetchingServiceIds.removeAll(idsToFetch);
      notifyListeners();
    }
  }
}