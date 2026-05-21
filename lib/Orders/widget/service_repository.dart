import 'package:ziya_laundry_deliveryapp/Orders/widget/service_service.dart';

class ServiceRepository {
  final ServiceService _service;

  ServiceRepository(this._service);

  Future<List<Map<String, dynamic>>> fetchAvailableServices({String? orderId}) =>
      _service.fetchAvailableServicesApi(orderId: orderId);

  Future<List<dynamic>> fetchItemsForService(String serviceId) =>
      _service.fetchItemsForServiceApi(serviceId);

  Future<List<Map<String, dynamic>>> fetchItemsForMultipleServices(List<String> serviceIds) =>
      _service.fetchItemsForMultipleServicesApi(serviceIds);
}