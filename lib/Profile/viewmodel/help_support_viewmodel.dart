// import 'package:flutter/material.dart';
// import 'package:ziya_laundry_deliveryapp/Profile/data/models/help_support_model.dart';
// import 'package:ziya_laundry_deliveryapp/Profile/data/repository/help_support_repository.dart';

// class HelpSupportViewModel extends ChangeNotifier {
//   final HelpSupportRepository _repository;
//   List<HelpSupportItem> _items = [];
//   bool _isLoading = false;

//   HelpSupportViewModel(this._repository) {
//     loadSupportItems();
//   }

//   List<HelpSupportItem> get items => _items;
//   bool get isLoading => _isLoading;

//   Future<void> loadSupportItems() async {
//     _isLoading = true;
//     notifyListeners();
//     try {
//       _items = await _repository.getSupportCategories();
//     } catch (e) {
//       // Handle error
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }
// }