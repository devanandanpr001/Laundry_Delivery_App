import 'package:flutter/material.dart';
import 'package:ziya_laundry_deliveryapp/Profile/data/models/help_support_model.dart';
import 'package:ziya_laundry_deliveryapp/Profile/data/repository/help_support_repository.dart';

class HelpSupportController extends ChangeNotifier {
  final HelpSupportRepository repository;
  List<HelpSupportItem> supportItems = [];
  bool _isLoading = false;

  HelpSupportController(this.repository);

  List<HelpSupportItem> get items => supportItems;
  bool get isLoading => _isLoading;

  Future<void> fetchSupportData() async {
    _isLoading = true;
    notifyListeners();
    try {
      supportItems = await repository.getFaqItems();
    } catch (e) {
      debugPrint("Error fetching FAQ data: $e");
      // Optionally, set an error message here
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}