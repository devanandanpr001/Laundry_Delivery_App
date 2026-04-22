
import '../model/order_model.dart';
import '../service/order_service.dart';

class OrderRepository {
  final OrderService _service;

  OrderRepository(this._service);

  Future<List<OrderModel>> getOrders() async {
    final data = await _service.fetchOrdersFromApi();
    return data.map((json) => OrderModel.fromJson(json)).toList();
  }

  Future<void> updateStatus(String orderId, OrderStatus status) async {
    await _service.updateOrderStatusOnApi(orderId, status);
  }
}