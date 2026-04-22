import 'package:flutter/material.dart';
import '../data/model/order_model.dart';
import '../data/repository/order_repository.dart';

class OrderViewModel extends ChangeNotifier {
  final OrderRepository _repository;

  OrderViewModel(this._repository) {
    fetchOrders();
  }

  List<OrderModel> _orders = [];
  bool _isLoading = false;

  List<OrderModel> get orders => _orders;
  bool get isLoading => _isLoading;

  Future<void> fetchOrders() async {
    _isLoading = true;
    notifyListeners();

    try {
      _orders = await _repository.getOrders();
    } catch (e) {
      debugPrint("OrderViewModel Error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateOrderStatus(String orderId, OrderStatus newStatus) async {
    final index = _orders.indexWhere((o) => o.orderId == orderId);

    if (index != -1) {
      try {
        await _repository.updateStatus(orderId, newStatus);
        _orders[index] = _orders[index].copyWith(status: newStatus);
        notifyListeners();
      } catch (e) {
        debugPrint("OrderViewModel Update Error: $e");
      }
    }
  }
}