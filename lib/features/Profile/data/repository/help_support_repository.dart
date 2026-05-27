import 'package:ziya_laundry_deliveryapp/features/Profile/data/models/help_support_model.dart';
import 'package:ziya_laundry_deliveryapp/features/Profile/data/service/help_support_service.dart';

class HelpSupportRepository {
  final HelpSupportService _service;

  HelpSupportRepository(this._service); // Constructor injection

  Future<List<HelpSupportItem>> getFaqItems() async {
    final data = await _service.fetchFaqData();
    return data.map((item) => HelpSupportItem.fromJson(item)).toList();
  }
}