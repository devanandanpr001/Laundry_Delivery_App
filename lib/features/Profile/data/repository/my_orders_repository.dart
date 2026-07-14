import 'package:ziya_laundry_deliveryapp/features/Orders/data/model/order_model.dart';
import 'package:ziya_laundry_deliveryapp/features/Profile/data/service/my_orders_service.dart';

class MyOrdersRepository {
  final MyOrdersService _service;

  MyOrdersRepository(this._service);

  Future<List<OrderModel>> getMyCompletedOrders() => _service.fetchMyCompletedOrders();
}