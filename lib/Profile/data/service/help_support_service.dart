import 'package:ziya_laundry_deliveryapp/Constants/Api_Constants.dart';
import 'package:ziya_laundry_deliveryapp/core/dio_client.dart';

class HelpSupportService {
  final DioClient _dioClient;

  HelpSupportService(this._dioClient);

  Future<List<Map<String, dynamic>>> fetchFaqData() async {
    try {
      final response = await _dioClient.get(
        ApiConstants.cmsPage.replaceAll(':type', 'FAQ'),
      );

      if (response != null && response['success'] == true && response['data'] != null) {
        final cmsData = response['data'];
        if (cmsData is Map<String, dynamic> && cmsData.containsKey('faq') && cmsData['faq'] is List) {
          return List<Map<String, dynamic>>.from(cmsData['faq']);
        }
        return [];
      } else {
        throw Exception('Failed to load FAQ data: ${response?['message'] ?? 'Unknown error'}');
      }
    } catch (e) {
      throw Exception('Error fetching FAQ: $e');
    }
  }
}