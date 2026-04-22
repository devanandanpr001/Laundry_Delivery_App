import 'package:flutter/material.dart';
import 'package:ziya_laundry_deliveryapp/Home/data/repository/home_repository.dart';
import '../../Orders/data/model/order_model.dart';
import '../../Orders/viewmodel/DeliveryStage.dart';
import '../../Orders/data/model/Bundle_Model.dart';

class HomeViewModel extends ChangeNotifier {
  final HomeRepository _repository;

  HomeViewModel(this._repository) {
    _init();
  }

  List<OrderModel> _orders = [];
  bool _isOnline = false;
  bool _isLoading = false;
  String _selectedFilter = "all";

  // Getters
  List<OrderModel> get orders => _orders;
  bool get isOnline => _isOnline;
  bool get isLoading => _isLoading;
  String get selectedFilter => _selectedFilter;

  // Logic Getters for UI
  List<OrderModel> get pendingOrders => _orders.where((o) => o.status == OrderStatus.pending).toList();
  int get completedCount => _orders.where((o) => o.status == OrderStatus.completed).length;
  int get assignedCount => _orders.where((o) => o.status == OrderStatus.assigned).length;

  Future<void> _init() async {
    _isOnline = await _repository.getInitialOnlineStatus();
    refreshOrders();
  }

  Future<void> refreshOrders() async {
    _isLoading = true;
    notifyListeners();
    try {
      _orders = await _repository.getOrders();
    } catch (e) {
      debugPrint("HomeViewModel Error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateOrderStatus(String orderId, OrderStatus status) async {
    final index = _orders.indexWhere((o) => o.orderId == orderId);
    if (index != -1) {
      final currentOrder = _orders[index];
      
      // Logic: Differentiate start stage based on OrderType when accepting
      DeliveryStage targetStage = currentOrder.deliveryStage;
      if (status == OrderStatus.assigned && currentOrder.status == OrderStatus.pending) {
        targetStage = currentOrder.orderType == OrderType.delivery 
            ? DeliveryStage.startDelivery 
            : DeliveryStage.startPickup;
      } else if (status == OrderStatus.completed) {
        targetStage = DeliveryStage.delivered;
      }

      _orders[index] = _orders[index].copyWith(
        status: status,
        deliveryStage: targetStage,
      );
      notifyListeners();
    }
    
    try {
      await _repository.updateStatus(orderId, status);
    } catch (e) {
      debugPrint("Backend sync failed: $e");
    }
  }

  Future<void> updateOrderStage(String orderId, DeliveryStage stage) async {
    final index = _orders.indexWhere((o) => o.orderId == orderId);
    if (index != -1) {
      _orders[index] = _orders[index].copyWith(deliveryStage: stage);
      notifyListeners();
    }

    // Placeholder for backend call
    // _isLoading = true; notifyListeners();
    // await _repository.updateStage(orderId, stage);
    // _isLoading = false; notifyListeners();
  }

  void addOrderImages(String orderId, List<String> images) {
    final index = _orders.indexWhere((o) => o.orderId == orderId);
    if (index != -1) {
      final currentImages = List<String>.from(_orders[index].pickedImages);
      currentImages.addAll(images);
      _orders[index] = _orders[index].copyWith(pickedImages: currentImages);
      notifyListeners();
    }
  }

  void removeOrderImage(String orderId, int imageIndex) {
    final index = _orders.indexWhere((o) => o.orderId == orderId);
    if (index != -1) {
      final currentImages = List<String>.from(_orders[index].pickedImages);
      currentImages.removeAt(imageIndex);
      _orders[index] = _orders[index].copyWith(pickedImages: currentImages);
      notifyListeners();
    }
  }

  void addOrderBundle(String orderId, dynamic bundle) {
    final index = _orders.indexWhere((o) => o.orderId == orderId);
    if (index != -1) {
      final currentBundles = List<BundleModel>.from(_orders[index].bundles);
      currentBundles.add(bundle);
      _orders[index] = _orders[index].copyWith(bundles: currentBundles);
      notifyListeners();
    }
  }

  void removeOrderBundle(String orderId, int bundleIndex) {
    final index = _orders.indexWhere((o) => o.orderId == orderId);
    if (index != -1) {
      final currentBundles = List<BundleModel>.from(_orders[index].bundles);
      currentBundles.removeAt(bundleIndex);
      _orders[index] = _orders[index].copyWith(bundles: currentBundles);
      notifyListeners();
    }
  }

  void setSelectedFilter(String filter) {
    _selectedFilter = filter;
    notifyListeners();
  }

  void toggleOnlineStatus() {
    _isOnline = !_isOnline;
    notifyListeners();
  }
}