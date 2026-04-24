import 'package:ziya_laundry_deliveryapp/Home/data/service/home_service.dart';
import 'package:ziya_laundry_deliveryapp/Home/data/model/home_models.dart';
import 'package:ziya_laundry_deliveryapp/Orders/data/model/Bundle_Model.dart';
import 'package:ziya_laundry_deliveryapp/Orders/viewmodel/DeliveryStage.dart';
import 'package:ziya_laundry_deliveryapp/Constants/app_images.dart';

class HomeRepository {
  final HomeService _service;

  HomeRepository(this._service);

  Future<List<OrderModel>> getOrders() async {
    final List<Map<String, dynamic>> data = await _service.fetchOrdersFromApi();
    return data.map((json) => OrderModel.fromJson(json)).toList();
  }

  Future<Map<String, dynamic>> getDashboardCounts() async {
    return await _service.getDashboardCountsFromApi();
  }

  Future<bool> updateStatus(String id, OrderStatus status) async {
    return await _service.updateOrderStatusOnApi(id, status.name);
  }

  Future<bool> getInitialOnlineStatus() async => await _service.getOnlineStatusFromApi();
}