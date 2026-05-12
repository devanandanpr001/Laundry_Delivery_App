
import '../model/order_model.dart';
import '../service/order_service.dart';

class OrderRepository {
  final OrderService _service;

  OrderRepository(this._service);

  Future<List<OrderModel>> getOrders() async {
    final data = await _service.fetchOrdersFromApi();
    return data.map((json) {
      // Use appOrderType injected by the service to avoid collision with backend laundry type
      final OrderType type = parseOrderType(json['appOrderType']);
      final bool forceCompleted = json['forceCompleted'] == true;
      return OrderModel.fromJson(json, type, forceCompleted: forceCompleted);
    }).toList();
  }

  Future<void> updateStatus(String orderId, OrderStatus status) async {
    await _service.updateOrderStatusOnApi(orderId, status);
  }
}