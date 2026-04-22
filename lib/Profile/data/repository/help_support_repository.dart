import 'package:ziya_laundry_deliveryapp/Profile/data/models/help_support_model.dart';
import 'package:ziya_laundry_deliveryapp/Profile/data/service/help_support_service.dart';

class HelpSupportRepository {
  final HelpSupportService _service;

  HelpSupportRepository(this._service);

  Future<List<HelpSupportItem>> getSupportCategories() async {
    final data = await _service.fetchSupportCategories();
    return data.map((item) => HelpSupportItem(
      icon: item['icon'],
      title: item['title'],
      description: item['description'],
      contact: item['contact'],
    )).toList();
  }
}