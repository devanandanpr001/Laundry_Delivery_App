import 'package:ziya_laundry_deliveryapp/Home/data/service/home_service.dart';
import 'package:ziya_laundry_deliveryapp/Orders/data/model/order_model.dart';

class HomeRepository {
  final HomeService _homeService = HomeService();

  Future<bool> getInitialOnlineStatus() async {
    // Simulate fetching initial online status
    await Future.delayed(const Duration(milliseconds: 100));
    return true; // Default to online
  }

  // This method will now fetch all orders (pickup and delivery)
  Future<List<OrderModel>> getAllOrders() async {
    return await _homeService.fetchAllOrders();
  }

  Future<Map<String, dynamic>> getDashboardCounts() async {
    return await _homeService.getDashboardCountsFromApi();
  }

  Future<bool> acceptPickupOrder(String orderId) async {
    return await _homeService.acceptPickupOrder(orderId);
  }

  Future<bool> acceptDeliveryOrder(String orderId) async {
    return await _homeService.acceptDeliveryOrder(orderId);
  }

  Future<bool> updateStatus(String orderId, OrderStatus status) async {
    // Assuming updateStatus is primarily for marking as completed/delivered
    return await _homeService.markOrderDeliveredApi(orderId);
  }

  Future<List<OrderModel>> getCompletedOrders() async {
    return await _homeService.fetchCompletedOrders();
  }

  Future<Map<String, dynamic>?> getProfile() async {
    return await _homeService.fetchProfile();
  }

  Future<bool> updateOnlineStatus(bool isOnline) async {
    return await _homeService.updateOnlineStatusApi(isOnline);
  }
}