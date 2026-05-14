import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ziya_laundry_deliveryapp/Constants/app_colors.dart';
import 'package:provider/provider.dart';
import 'package:ziya_laundry_deliveryapp/Home/viewmodel/home_viewmodel.dart';
import 'package:ziya_laundry_deliveryapp/common_widgets/AppToast.dart';
import 'package:ziya_laundry_deliveryapp/Home/data/model/home_models.dart'; // Assuming OrderItem is defined here
import 'package:loading_animation_widget/loading_animation_widget.dart';

class AddItemDialog extends StatefulWidget {
  final String orderId;
  const AddItemDialog({super.key, required this.orderId});

  @override
  State<AddItemDialog> createState() => _AddItemDialogState();
}

class _AddItemDialogState extends State<AddItemDialog> {
  final Set<String> _selectedServiceIds = {};
  String? _selectedItem;
  int _quantity = 1;
  final TextEditingController _amountController = TextEditingController();
  bool _isServicesDropdownOpen = false;
  bool _isItemsDropdownOpen = false;
  bool _isLoading = false;
  HomeViewModel? _homeViewModel; 

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Professional: Capture the ViewModel reference in didChangeDependencies to ensure 
    // context access is safe and the reference is available for dispose().
    final vm = Provider.of<HomeViewModel>(context, listen: false);
    if (_homeViewModel != vm) {
      _homeViewModel?.removeListener(_syncAmountController);
      _homeViewModel = vm;
      _homeViewModel?.addListener(_syncAmountController);
    }
  }

  void _syncAmountController() {
    // Strict safety check: Never use 'context' inside a listener callback to avoid deactivation errors.
    if (!mounted || _homeViewModel == null) return;
    
    final amount = _calculateDerivedAmount(_homeViewModel!.availableServices ?? [], _homeViewModel!.serviceItemsMap ?? {});
    final String expectedText = amount > 0 ? amount.toStringAsFixed(0) : "";
    
    if (_amountController.text != expectedText) {
      _amountController.text = expectedText;
      setState(() {}); // Reflect updated amount in UI
    }
  }

  @override
  void dispose() {
    _homeViewModel?.removeListener(_syncAmountController);
    _amountController.dispose();
    super.dispose();
  }

  // Logic: Calculate Derived Amount based on selected services and items
  double _calculateDerivedAmount(List<Map<String, dynamic>> services, Map<String, List<dynamic>> itemsMap) {
    if (_selectedServiceIds.isEmpty || _selectedItem == null) return 0;

    double totalUnitPrice = 0;
    for (String serviceId in _selectedServiceIds) {
      final service = services.firstWhere(
        (s) => s['id']?.toString() == serviceId,
        orElse: () => {},
      );

      if (service.isNotEmpty) {
        final itemsForThisService = itemsMap[serviceId] ?? [];
        final itemData = itemsForThisService.firstWhere(
          (i) => i is Map && i['costume'] == _selectedItem,
          orElse: () => null,
        );

        double price = _toDouble(service['pricePerKg']);
        if (itemData != null && itemData is Map && itemData['services'] is List) {
          final List servicesList = itemData['services'] as List;
          final servicePricing = servicesList.firstWhere(
            (s) => s is Map && s['serviceId']?.toString() == serviceId,
            orElse: () => null,
          );
          if (servicePricing != null) {
            price = _toDouble(servicePricing['price']);
          }
        }
        totalUnitPrice += price;
      }
    }
    return totalUnitPrice * _quantity;
  }

  double _toDouble(dynamic v) => double.tryParse(v?.toString() ?? '0') ?? 0.0;

  @override
  Widget build(BuildContext context) {
    // Optimized: Only rebuild when specifically needed data changes
    final availableServices = context.select<HomeViewModel, List<Map<String, dynamic>>>((vm) => vm.availableServices ?? []);
    final serviceItemsMap = context.select<HomeViewModel, Map<String, List<dynamic>>>((vm) => vm.serviceItemsMap ?? {});

    final bool isFetchingItems = _selectedServiceIds.any((id) => !serviceItemsMap.containsKey(id));
    final List<String> dynamicItems = _selectedServiceIds
        .expand((id) => serviceItemsMap[id] ?? [])
        .where((e) => e != null && e is Map && e.containsKey('costume'))
        .map((e) => (e as Map)['costume'].toString())
        .toSet()
        .toList();

    return Dialog(
      backgroundColor: Colors.transparent, // Make dialog background transparent
      insetPadding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Material(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12.r),
        elevation: 10, // Added elevation for depth
        shadowColor: AppColors.shadowColor.withOpacity(0.2), // Subtle shadow
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.86,
          ),
          child: SingleChildScrollView(
            padding: EdgeInsets.all(24.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Add Items",
                  style: GoogleFonts.poppins(fontSize: 18.sp, fontWeight: FontWeight.bold, color: Colors.black),
                ),
                SizedBox(height: 16.h),
                _buildLabel("Services"),
                _buildDropdownTrigger(
                  text: availableServices.isEmpty ? "No services available" : ( _selectedServiceIds.isEmpty ? "Select" : "${_selectedServiceIds.length} Selected"),
                  width: double.infinity, // Ensure it fills available width
                  onTap: () => setState(() {
                    _isServicesDropdownOpen = !_isServicesDropdownOpen;
                    _isItemsDropdownOpen = false; // Auto-close items dropdown
                  }),
                  isOpen: _isServicesDropdownOpen,
                ),
                if (_isServicesDropdownOpen)
                  _buildDropdownContent(
                    child: availableServices.isEmpty
                        ? Padding(
                            padding: EdgeInsets.all(12.w),
                            child: Text(
                              "No services available",
                              style: GoogleFonts.poppins(fontSize: 13.sp, color: Colors.black54),
                            ),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const BouncingScrollPhysics(),
                            padding: EdgeInsets.zero,
                            itemCount: availableServices.length,
                            itemBuilder: (context, index) {
                              final Map<String, dynamic> service = availableServices[index];
                              final serviceId = service['id'].toString();
                              final isSelected = _selectedServiceIds.contains(serviceId);
                              return CheckboxListTile(
                                title: Text(service['name'], style: GoogleFonts.poppins(fontSize: 13.sp, color: Colors.black)),
                                value: isSelected,
                                activeColor: AppColors.primaryBlue,
                                dense: true,
                                onChanged: (bool? value) {
                                  if (!mounted) return;
                                  final vm = context.read<HomeViewModel>();
                                  setState(() {
                                    if (value == true) {
                                      if (_selectedServiceIds.length < 3) {
                                        _selectedServiceIds.add(serviceId);
                                      } else {
                                        AppToast.showWarning(
                                          title: "Warning",
                                          message: "You can only select up to 3 services",
                                        );
                                      }
                                    } else {
                                      _selectedServiceIds.remove(serviceId);
                                    }
                                    _selectedItem = null;
                                  });
                                  _syncAmountController();
                                  // Trigger API outside of setState block
                                  if (value == true && _selectedServiceIds.contains(serviceId)) {
                                    vm.fetchItemsForMultipleServices(_selectedServiceIds.toList());
                                  }
                                },
                              );
                            },
                          ),
                  ),
                if (_selectedServiceIds.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.only(top: 8.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: _selectedServiceIds.map((id) {
                        final service = availableServices.firstWhere((s) => s['id']?.toString() == id, orElse: () => {});
                        return Text("• ${service['name'] ?? ''}", style: GoogleFonts.poppins(fontSize: 13.sp, color: AppColors.linkBlue));
                      }).toList(),
                    ),
                  ),
                SizedBox(height: 12.h),
                _buildLabel("Items"),
                _buildDropdownTrigger(
                  text: _selectedServiceIds.isEmpty
                      ? "Select service first"
                      : (isFetchingItems ? "Loading Items..." : (_selectedItem ?? "Select")),
                  width: double.infinity,
                  onTap: _selectedServiceIds.isEmpty
                      ? null
                      : () => setState(() {
                            _isItemsDropdownOpen = !_isItemsDropdownOpen;
                            _isServicesDropdownOpen = false;
                          }),
                  isOpen: _isItemsDropdownOpen,
                ),
                if (_isItemsDropdownOpen)
                  _buildDropdownContent(child: _buildItemsList(isFetchingItems, dynamicItems)),
                SizedBox(height: 12.h),
                _buildLabel("Quantity"),
                Row(
                  children: [
                    _buildQuantityAction("-", () {
                      if (_quantity > 1) {
                        if (!mounted) return;
                        setState(() {
                          _quantity--;
                        });
                        _syncAmountController(); // Manually trigger sync on local state change
                      }
                    }),
                    SizedBox(width: 12.w),
                    Container(
                      width: 48.w, height: 36.w,
                      decoration: BoxDecoration(color: const Color(0xFF0064D7), borderRadius: BorderRadius.circular(4.r)),
                      child: Center(child: Text(_quantity.toString(), style: GoogleFonts.poppins(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Colors.white))),
                    ),
                    SizedBox(width: 12.w),
                    _buildQuantityAction("+", () {
                      if (!mounted) return;
                      setState(() {
                        _quantity++;
                      });
                      _syncAmountController(); // Manually trigger sync on local state change
                    }),
                  ],
                ),
                SizedBox(height: 12.h),
                _buildLabel("Amount"),
                SizedBox(
                  width: 134.w,
                  height: 32.h,
                  child: TextFormField(
                    controller: _amountController,
                    readOnly: true,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r), borderSide: BorderSide(color: Colors.black, width: 1.w)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r), borderSide: BorderSide(color: Colors.black, width: 1.w)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r), borderSide: BorderSide(color: Colors.black, width: 1.w)),
                      contentPadding: EdgeInsets.all(8.w),
                    ),
                    style: GoogleFonts.poppins(fontSize: 14.sp, color: Colors.black),
                  ),
                ),
                SizedBox(height: 24.h),
                SizedBox(
                  width: double.infinity,
                  height: 32.h,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _onAddItem,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      padding: EdgeInsets.symmetric(horizontal: 8.w),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                      elevation: 0,
                      minimumSize: Size(283.w, 32.h),
                      disabledBackgroundColor: AppColors.primaryBlue.withOpacity(0.6),
                    ),
                    child: _isLoading
                        ? LoadingAnimationWidget.waveDots(
                            color: Colors.white,
                            size: 20.sp,
                          )
                        : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add, color: Colors.white, size: 20.sp),
                        SizedBox(width: 8.w),
                        Text("Add Items",
                            style: GoogleFonts.poppins(fontSize: 14.sp, color: Colors.white, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildItemsList(bool isFetching, List<String> items) {
    if (isFetching && items.isEmpty) {
      return Center(child: LoadingAnimationWidget.waveDots(color: AppColors.primaryBlue, size: 30.sp));
    }
    if (items.isEmpty) {
      return Padding(
        padding: EdgeInsets.all(12.w),
        child: Text(
          isFetching ? "Loading items..." : "No items available",
          style: GoogleFonts.poppins(fontSize: 13.sp, color: Colors.black54),
        ),
      );
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.zero,
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return ListTile(
          title: Text(item, style: GoogleFonts.poppins(fontSize: 13.sp, color: Colors.black)),
          onTap: () {
            if (!mounted) return;
            setState(() {
              _selectedItem = item;
              _isItemsDropdownOpen = false;
            });
            _syncAmountController();
          },
        );
      },
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Text(text, style: GoogleFonts.poppins(fontSize: 14.sp, fontWeight: FontWeight.w600, color: Colors.black)),
    );
  }

  Widget _buildDropdownTrigger({required String text, required VoidCallback? onTap, required bool isOpen, double? width}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width ?? 134.w, // Use provided width or default
        height: 32.h,
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Colors.black, width: 1.w), borderRadius: BorderRadius.circular(8.r)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(child: Text(text, style: GoogleFonts.poppins(fontSize: 14.sp, color: Colors.black54), overflow: TextOverflow.ellipsis)),
            Icon(isOpen ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, color: Colors.black, size: 16.sp),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownContent({required Widget child}) {
    return Container(
      margin: EdgeInsets.only(top: 4.h),
      constraints: BoxConstraints(maxHeight: 200.h),
      decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Colors.black), borderRadius: BorderRadius.circular(8.r)),
      child: child,
    );
  }

  Widget _buildQuantityAction(String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 50.w,
        height: 25.h,
        decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(5.r)),
        child: Center(child: Text(label, style: GoogleFonts.poppins(fontSize: 18.sp, color: Colors.black))),
      ),
    );
  }

  void _onAddItem() async {
    if (_isLoading) return;
    if (_selectedServiceIds.isEmpty || _selectedItem == null || (_amountController.text.isEmpty && _selectedServiceIds.isNotEmpty)) {
      AppToast.showError(title: "Input Error", message: "Please select services, an item, and enter an amount.");
      return;
    }

    final double? enteredAmount = double.tryParse(_amountController.text);
    if (enteredAmount == null || enteredAmount <= 0) {
      AppToast.showError(
        title: "Invalid Amount",
        message: "Please enter a valid amount.",
      );
      return;
    }

    setState(() => _isLoading = true);

    final homeVM = context.read<HomeViewModel>();
    final availableServices = homeVM.availableServices ?? [];

    try {
      final List<String> serviceNames = _selectedServiceIds.map((id) {
        final service = availableServices.firstWhere((s) => s['id']?.toString() == id, orElse: () => {});
        return service['name']?.toString() ?? 'General';
      }).toList();

      final String combinedName = "${serviceNames.join(", ")} - $_selectedItem";
      final double unitPrice = enteredAmount / _quantity;

      await homeVM.addItemToOrder(
        widget.orderId,
        OrderItem(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: combinedName,
          qty: _quantity.toString(),
          unit: "piece",
          isVerified: false,
        ),
        price: unitPrice,
        serviceNames: serviceNames,
      );

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        AppToast.showError(
          title: "Error",
          message: "Failed to add items: $e",
        );
      }
    }
  }
}