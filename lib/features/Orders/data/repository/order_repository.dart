// import 'package:ziya_laundry_deliveryapp/features/Orders/data/service/order_service.dart';
// import 'package:ziya_laundry_deliveryapp/features/Orders/data/model/order_model.dart';

// class OrderRepository {
//   final OrderService _service;

//   OrderRepository(this._service);

//   Future<List<OrderModel>> getAllOrders() => _service.fetchAllOrders();
//   Future<List<OrderModel>> getPickupAssignedOrders() => _service.fetchPickupAssignedOrders();
//   Future<List<OrderModel>> getDeliveryAssignedOrders() => _service.fetchDeliveryAssignedOrders();

//   Future<bool> acceptPickupOrder(String orderId) => _service.acceptPickupOrder(orderId);
//   Future<bool> acceptDeliveryOrder(String orderId) => _service.acceptDeliveryOrder(orderId);
//   Future<bool> confirmPickupOrder(String orderId) => _service.confirmPickupOrder(orderId);
//   Future<bool> verifyOrder(String orderId) => _service.verifyOrderApi(orderId);
//   Future<bool> reportItemMismatch(String orderId, String details) => _service.reportMismatchApi(orderId, details);
//   Future<Map<String, dynamic>?> addItemToOrder(String orderId, Map<String, dynamic> payload) => _service.addItemApi(orderId, payload);
//   Future<void> deleteItemFromOrder(String orderId, String itemId) => _service.deleteItemApi(orderId, itemId);
//   Future<Map<String, String>?> uploadOrderImage(String orderId, String imagePath) => _service.uploadOrderImageApi(orderId, imagePath);
//   Future<bool> deleteOrderImage(String orderId, String imageId) => _service.deleteOrderImageApi(orderId, imageId);
//   Future<void> addOrderBundle(String orderId, Map<String, dynamic> payload) => _service.addItemApi(orderId, payload); // Reusing addItemApi for bundles
//   Future<Map<String, dynamic>> sendDeliveryOtp(String orderId) => _service.sendDeliveryOtpApi(orderId);
//   Future<Map<String, dynamic>> verifyDeliveryOtp(String orderId, String otp) => _service.verifyDeliveryOtpApi(orderId, otp);
// }
import 'package:ziya_laundry_deliveryapp/features/Orders/data/service/order_service.dart';
import 'package:ziya_laundry_deliveryapp/features/Orders/data/model/order_model.dart';

class OrderRepository {
  final OrderService _service;

  OrderRepository(this._service);

  Future<List<OrderModel>> getAllOrders() => _service.fetchAllOrders();
  Future<List<OrderModel>> getPickupAssignedOrders() => _service.fetchPickupAssignedOrders();
  Future<List<OrderModel>> getDeliveryAssignedOrders() => _service.fetchDeliveryAssignedOrders();
  Future<List<OrderModel>> getPickupOrders() => _service.fetchOrdersFromApi(OrderType.pickup);
  Future<List<OrderModel>> getDeliveryOrders() => _service.fetchOrdersFromApi(OrderType.delivery);
  Future<List<OrderModel>> getPickupCompletedOrders() => _service.fetchPickupCompletedOrders();
  Future<List<OrderModel>> getDeliveryCompletedOrders() => _service.fetchDeliveryCompletedOrders();

  Future<bool> acceptPickupOrder(String orderId) => _service.acceptPickupOrder(orderId);
  Future<bool> acceptDeliveryOrder(String orderId) => _service.acceptDeliveryOrder(orderId);
  Future<bool> confirmPickupOrder(String orderId) => _service.confirmPickupOrder(orderId);
  Future<bool> verifyOrder(String orderId) => _service.verifyOrderApi(orderId);
  Future<bool> reportItemMismatch(String orderId, String details) => _service.reportMismatchApi(orderId, details);
  Future<Map<String, dynamic>?> addItemToOrder(String orderId, Map<String, dynamic> payload) => _service.addItemApi(orderId, payload);
  Future<void> deleteItemFromOrder(String orderId, String itemId) => _service.deleteItemApi(orderId, itemId);
  Future<Map<String, String>?> uploadOrderImage(String orderId, String imagePath) => _service.uploadOrderImageApi(orderId, imagePath);
  Future<bool> deleteOrderImage(String orderId, String imageId) => _service.deleteOrderImageApi(orderId, imageId);
  Future<void> addOrderBundle(String orderId, Map<String, dynamic> payload) => _service.addItemApi(orderId, payload); // Reusing addItemApi for bundles
  Future<Map<String, dynamic>> sendDeliveryOtp(String orderId) => _service.sendDeliveryOtpApi(orderId);
  Future<Map<String, dynamic>> verifyDeliveryOtp(String orderId, String otp) => _service.verifyDeliveryOtpApi(orderId, otp);
}