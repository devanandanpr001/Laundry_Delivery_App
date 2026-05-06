import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ziya_laundry_deliveryapp/Constants/app_colors.dart';
import 'package:provider/provider.dart';
import 'package:ziya_laundry_deliveryapp/Home/viewmodel/home_viewmodel.dart';
import 'package:ziya_laundry_deliveryapp/Home/data/model/home_models.dart'; // Assuming OrderItem is defined here

class AddItemDialog extends StatefulWidget {
  const AddItemDialog({super.key, required String orderId});

  @override
  State<AddItemDialog> createState() => _AddItemDialogState();
}

class _AddItemDialogState extends State<AddItemDialog> {
  final Set<String> _selectedServiceIds = {};
  String? _selectedItem;
  int _quantity = 1;
  final TextEditingController _amountController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  double _safeDouble(dynamic value) {
    if (value == null) return 0.0;
    return double.tryParse(value.toString()) ?? 0.0;
  }

  void _updateAmount() {
    if (_selectedServiceIds.isEmpty || _selectedItem == null) {
      _amountController.text = "";
      return;
    }

    final viewModel = context.read<HomeViewModel>();
    final availableServices = viewModel.availableServices;
    final serviceItemsMap = viewModel.serviceItemsMap;

    double totalUnitPrice = 0;
    for (String serviceId in _selectedServiceIds) {
      // Safely find the service
      final Map<String, dynamic> service = availableServices.firstWhere(
            (s) => s['id']?.toString() == serviceId,
            orElse: () => <String, dynamic>{},
          );

      if (service.isEmpty) continue;

      final itemsForThisService = serviceItemsMap[serviceId] ?? [];
      final itemData = itemsForThisService.firstWhere(
        (i) => i is Map && i['costume'] == _selectedItem,
        orElse: () => null,
      );

      double price = _safeDouble(service['pricePerKg']);
      if (itemData != null && itemData is Map && itemData['services'] != null && itemData['services'] is List) {
        final List servicesList = itemData['services'] as List;
        final servicePricing = servicesList.firstWhere(
          (s) => s != null && s is Map && s['serviceId']?.toString() == serviceId,
          orElse: () => null,
        );
        if (servicePricing != null && servicePricing is Map) {
          price = _safeDouble(servicePricing['price']);
        }
      }
      totalUnitPrice += price;
    }
    double totalAmount = totalUnitPrice * _quantity;
    _amountController.text = totalAmount > 0 ? totalAmount.toStringAsFixed(0) : "";
  }

  @override
  Widget build(BuildContext context) {
    final availableServices = context.watch<HomeViewModel>().availableServices;
    final serviceItemsMap = context.watch<HomeViewModel>().serviceItemsMap;

    // Check if any selected service is currently waiting for items from backend
    final bool isFetchingItems = _selectedServiceIds.any((id) => !serviceItemsMap.containsKey(id));

    final List<String> dynamicItems = _selectedServiceIds
        .expand((id) => serviceItemsMap[id] ?? [])
        .where((e) => e != null && e is Map && e.containsKey('costume'))
        .map((e) => (e as Map)['costume'].toString())
        .toSet()
        .toList();

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Add New Item",
              style: GoogleFonts.poppins(fontSize: 18.sp, fontWeight: FontWeight.w600, color: AppColors.primaryBlue),
            ),
            SizedBox(height: 16.h),
            Text(
              "Select Services (Max 3)",
              style: GoogleFonts.poppins(fontSize: 14.sp, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 8.h),
            Container(
              constraints: BoxConstraints(maxHeight: 180.h),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.grey.withOpacity(0.3)),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: availableServices.length,
                itemBuilder: (context, index) {
                  final service = availableServices[index];
                  final serviceId = service['id'].toString();
                  final isSelected = _selectedServiceIds.contains(serviceId);
                  
                  return CheckboxListTile(
                    title: Text(service['name'], style: GoogleFonts.poppins(fontSize: 13.sp)),
                    value: isSelected,
                    activeColor: AppColors.primaryBlue,
                    dense: true,
                    onChanged: (bool? value) {
                      setState(() {
                        if (value == true) {
                          if (_selectedServiceIds.length < 3) {
                            _selectedServiceIds.add(serviceId);
                            context.read<HomeViewModel>().fetchItemsForMultipleServices(_selectedServiceIds.toList());
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("You can only select up to 3 services")),
                            );
                          }
                        } else {
                          _selectedServiceIds.remove(serviceId);
                        }
                        _selectedItem = null; // Reset selection when services change
                      });
                      _updateAmount();
                    },
                  );
                },
              ),
            ),
            SizedBox(height: 12.h),
            _buildDropdown(
              label: isFetchingItems ? "Loading Items..." : "Select Item",
              value: _selectedItem,
              items: isFetchingItems ? [] : dynamicItems,
              enabled: !isFetchingItems && _selectedServiceIds.isNotEmpty,
              hint: isFetchingItems ? "Fetching from server..." : null,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedItem = newValue;
                });
                _updateAmount();
              },
            ),
            SizedBox(height: 12.h),
            Text(
              "Quantity",
              style: GoogleFonts.poppins(fontSize: 14.sp, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 8.h),
            Row(
              children: [
                _buildQuantityButton(Icons.remove, () {
                  if (_quantity > 1) {
                    setState(() {
                      _quantity--;
                    });
                    _updateAmount();
                  }
                }),
                SizedBox(width: 16.w),
                Text(
                  _quantity.toString(),
                  style: GoogleFonts.poppins(fontSize: 16.sp, fontWeight: FontWeight.w600),
                ),
                SizedBox(width: 16.w),
                _buildQuantityButton(Icons.add, () {
                  setState(() {
                    _quantity++;
                  });
                  _updateAmount();
                }),
              ],
            ),
            if (_selectedServiceIds.isNotEmpty && _selectedItem != null) ...[
              SizedBox(height: 12.h),
              Text(
                "Amount",
                style: GoogleFonts.poppins(fontSize: 14.sp, fontWeight: FontWeight.w500),
              ),
              SizedBox(height: 8.h),
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                readOnly: true,
                decoration: InputDecoration(
                  hintText: "Enter amount",
                  hintStyle: GoogleFonts.poppins(fontSize: 12.sp, color: AppColors.grey),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r), borderSide: BorderSide(color: AppColors.grey.withOpacity(0.5))),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r), borderSide: const BorderSide(color: AppColors.primaryBlue)),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                ),
                style: GoogleFonts.poppins(fontSize: 13.sp),
              ),
            ],
            SizedBox(height: 20.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    "Cancel",
                    style: GoogleFonts.poppins(fontSize: 14.sp, color: AppColors.grey),
                  ),
                ),
                SizedBox(width: 10.w),
                ElevatedButton(
                  onPressed: _onAddItem,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                    padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                  ),
                  child: Text(
                    "Add Item",
                    style: GoogleFonts.poppins(fontSize: 14.sp, color: AppColors.white, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
required List<String> items,
    required ValueChanged<String?> onChanged,
    String? hint,
    bool enabled = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(fontSize: 14.sp, fontWeight: FontWeight.w500),
        ),
        SizedBox(height: 8.h),
        DropdownButtonFormField<String>(
          value: value,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r), borderSide: BorderSide(color: AppColors.grey.withOpacity(0.5))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r), borderSide: const BorderSide(color: AppColors.primaryBlue)),
            contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
          ),
          hint: Text(
            hint ?? "Select $label",
            style: GoogleFonts.poppins(fontSize: 12.sp, color: AppColors.grey),
          ),
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item, style: GoogleFonts.poppins(fontSize: 13.sp)),
            );
          }).toList(),
          onChanged: enabled ? onChanged : null,
          style: GoogleFonts.poppins(fontSize: 13.sp, color: Colors.black),
          isExpanded: true,
        ),
      ],
    );
  }

  Widget _buildQuantityButton(IconData icon, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 32.w,
        height: 32.w,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.primaryBlue),
        ),
        child: Icon(icon, color: AppColors.primaryBlue, size: 20.sp),
      ),
    );
  }

  void _onAddItem() {
    if (_selectedServiceIds.isEmpty || _selectedItem == null || _amountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select services, an item, and enter an amount.")),
      );
      return;
    }

    final double? enteredAmount = double.tryParse(_amountController.text);
    if (enteredAmount == null || enteredAmount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a valid amount.")),
      );
      return;
    }

    final availableServices = context.read<HomeViewModel>().availableServices;
    final serviceItemsMap = context.read<HomeViewModel>().serviceItemsMap;
    final List<Map<String, dynamic>> results = [];

    for (String serviceId in _selectedServiceIds) {
      final service = availableServices.firstWhere(
        (s) => s['id']?.toString() == serviceId,
        orElse: () => {},
      );
      if (service.isEmpty) continue;

      final itemsForThisService = serviceItemsMap[serviceId] ?? [];

      // Attempt to find specific pricing for this costume in this service
      final itemData = itemsForThisService.firstWhere(
        (i) => i is Map && i['costume'] == _selectedItem,
        orElse: () => null,
      );

      double price = _safeDouble(service['pricePerKg']);
      if (itemData != null && itemData is Map && itemData['services'] is List) {
        final servicePricing = (itemData['services'] as List).firstWhere(
          (s) => s is Map && s['serviceId']?.toString() == serviceId,
          orElse: () => null,
        );
        if (servicePricing != null && servicePricing is Map) {
          price = _safeDouble(servicePricing['price']);
        }
      }

      results.add({
        "item": OrderItem(
          id: DateTime.now().millisecondsSinceEpoch.toString() + serviceId,
          name: "${service['name'] ?? 'General'} - $_selectedItem",
          qty: _quantity.toString(),
          unit: "piece",
          isVerified: false,
        ),
        "price": enteredAmount / (_quantity * _selectedServiceIds.length),
      });
    }

    Navigator.pop(context, results);
  }
}