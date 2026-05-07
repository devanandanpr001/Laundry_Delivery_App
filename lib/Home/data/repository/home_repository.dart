import 'package:ziya_laundry_deliveryapp/Home/data/service/home_service.dart';
import 'package:ziya_laundry_deliveryapp/Orders/data/model/order_model.dart';

class HomeRepository {
  final HomeService _service;

  HomeRepository(this._service);

  Future<List<OrderModel>> getAllOrders() => _service.fetchAllOrders();
  Future<Map<String, dynamic>> getDashboardCounts() => _service.getDashboardCountsFromApi();
  Future<Map<String, dynamic>?> getProfile() => _service.fetchProfile();
  Future<bool> getInitialOnlineStatus() async {
    final profile = await _service.fetchProfile();
    return profile?['isOnline'] ?? false;
  }
  Future<bool> acceptPickupOrder(String orderId) => _service.acceptPickupOrder(orderId);
  Future<bool> acceptDeliveryOrder(String orderId) => _service.acceptDeliveryOrder(orderId);
  Future<bool> confirmPickupOrder(String orderId) => _service.confirmPickupOrder(orderId);
  Future<void> updateStatus(String orderId, OrderStatus status) async {
    // This method needs to be implemented in HomeService if it's a real API call
  }
}