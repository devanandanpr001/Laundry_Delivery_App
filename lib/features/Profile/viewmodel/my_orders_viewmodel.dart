import 'package:flutter/material.dart';
import 'package:ziya_laundry_deliveryapp/features/Orders/data/model/order_model.dart';
import 'package:ziya_laundry_deliveryapp/features/Profile/data/repository/my_orders_repository.dart';

class MyOrdersViewModel extends ChangeNotifier {
  final MyOrdersRepository _repository;
  MyOrdersViewModel(this._repository);

  List<OrderModel> _orders = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<OrderModel> get orders => _orders;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchMyOrders() async {
    if (_isLoading) return;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final fetchedOrders = await _repository.getMyCompletedOrders();

      // Ensure each Order ID is unique in the list.
      // If a driver handles both Pickup and Delivery for the same order, we merge them.
      final Map<String, OrderModel> uniqueOrdersMap = {};
      for (var o in fetchedOrders) {
        if (!uniqueOrdersMap.containsKey(o.orderId) || o.roleType == "PICKUP_AND_DELIVERY") {
          uniqueOrdersMap[o.orderId] = o;
        }
      }

      _orders = uniqueOrdersMap.values.toList();
      // Sort by updated time descending to show newest activity at the top
      _orders.sort((a, b) => (b.updatedAt ?? DateTime(0)).compareTo(a.updatedAt ?? DateTime(0)));

    } catch (e) {
      _errorMessage = "Failed to load orders: $e";
      debugPrint("MyOrdersViewModel Error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}