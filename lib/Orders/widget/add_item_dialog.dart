import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ziya_laundry_deliveryapp/Constants/app_colors.dart';
import 'package:provider/provider.dart';
import 'package:ziya_laundry_deliveryapp/Orders/viewmodel/order_viewmodel.dart';
import 'package:ziya_laundry_deliveryapp/Orders/viewmodel/service_viewmodel.dart';
import 'package:ziya_laundry_deliveryapp/common_widgets/AppToast.dart';
import 'package:ziya_laundry_deliveryapp/Home/data/model/home_models.dart'; // Assuming OrderItem is defined here
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:ziya_laundry_deliveryapp/Orders/widget/add_item_widgets.dart';

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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchAvailableServices();
    });
  }

  Future<void> _fetchAvailableServices() async {
    final serviceVM = context.read<ServiceViewModel>();
    await serviceVM.fetchAvailableServices(orderId: widget.orderId);
    _syncAmountController();
  }

  void _syncAmountController() {
    if (!mounted) return;
    final serviceVM = context.read<ServiceViewModel>();
    final amount = _calculateDerivedAmount(serviceVM.availableServices, serviceVM.serviceItemsMap);
    final String expectedText = amount > 0 ? amount.toStringAsFixed(0) : "";
    if (_amountController.text != expectedText) {
      _amountController.text = expectedText;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  // Logic: Calculate Derived Amount based on selected services and selected item
  double _calculateDerivedAmount(List<Map<String, dynamic>> services, Map<String, List<dynamic>> itemsMap) {
    if (_selectedServiceIds.isEmpty || _selectedItem == null) return 0;

    double totalUnitPrice = 0;
    for (String serviceId in _selectedServiceIds) {
      final service = services.firstWhere(
        (s) => s['id']?.toString() == serviceId,
        orElse: () => {},
      );

      if (service.isEmpty) continue;

      final itemsForThisService = itemsMap[serviceId] ?? [];
      final itemData = itemsForThisService.firstWhere(
        (i) => i is Map && _getItemName(i) == _selectedItem,
        orElse: () => null,
      );

      double price = _getPriceForService(service, itemData, serviceId);
      totalUnitPrice += price;
    }

    return totalUnitPrice * _quantity;
  }

  String? _getItemName(dynamic item) {
    if (item is! Map<String, dynamic>) return null;
    return item['costume']?.toString() ??
        item['name']?.toString() ??
        item['title']?.toString() ??
        item['itemName']?.toString() ??
        item['label']?.toString();
  }

  List<dynamic> _getItemServices(dynamic item) {
    if (item is! Map<String, dynamic>) return [];
    return item['services'] as List? ??
        item['service'] as List? ??
        item['serviceTypes'] as List? ??
        [];
  }

  double _getPriceForService(Map<String, dynamic> service, dynamic itemData, String serviceId) {
    double basePrice = _toDouble(service['pricePerKg']);

    if (itemData is Map<String, dynamic>) {
      final itemServices = _getItemServices(itemData);
      final pricingEntry = itemServices.firstWhere(
        (s) => s is Map && (s['serviceId']?.toString() == serviceId || s['id']?.toString() == serviceId),
        orElse: () => null,
      );
      if (pricingEntry is Map) {
        basePrice = _toDouble(pricingEntry['price'] ?? pricingEntry['unitPrice'] ?? pricingEntry['pricePerKg']);
      }
      basePrice = basePrice > 0 ? basePrice : _toDouble(itemData['price'] ?? itemData['unitPrice'] ?? itemData['pricePerKg']);
    }

    return basePrice;
  }

  double _toDouble(dynamic v) => double.tryParse(v?.toString() ?? '0') ?? 0.0;

  @override
  Widget build(BuildContext context) {
    // Optimized: Only rebuild when specifically needed data changes
    final availableServices = context.select<ServiceViewModel, List<Map<String, dynamic>>>((vm) => vm.availableServices);
    final serviceItemsMap = context.select<ServiceViewModel, Map<String, List<dynamic>>>((vm) => vm.serviceItemsMap);
    final serviceLoading = context.select<ServiceViewModel, bool>((vm) => vm.isLoading);
    final serviceError = context.select<ServiceViewModel, String?>((vm) => vm.errorMessage);

    final bool isFetchingItems = _selectedServiceIds.any((id) => !serviceItemsMap.containsKey(id));
    final List<String> dynamicItems = _selectedServiceIds
        .expand((id) => serviceItemsMap[id] ?? [])
        .where((e) => e != null && e is Map && _getItemName(e) != null)
        .map((e) => _getItemName(e as Map<String, dynamic>)!)
        .toSet()
        .toList();

    return Dialog(
      backgroundColor: Colors.transparent, // Make dialog background transparent
      insetPadding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Material(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12.r),
        elevation: 10, // Added elevation for depth
        shadowColor: AppColors.shadowColor.withValues(alpha: 0.2), // Subtle shadow
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
                const AddItemLabel(text: "Services"),
                AddItemDropdownTrigger(
                  text: serviceLoading
                      ? "Loading services..."
                      : availableServices.isEmpty
                          ? "No services available"
                          : (_selectedServiceIds.isEmpty ? "Select" : "${_selectedServiceIds.length} Selected"),
                  width: double.infinity, // Ensure it fills available width
                  onTap: serviceLoading || availableServices.isEmpty
                      ? null
                      : () => setState(() {
                            _isServicesDropdownOpen = !_isServicesDropdownOpen;
                            _isItemsDropdownOpen = false; // Auto-close items dropdown
                          }),
                  isOpen: _isServicesDropdownOpen,
                ),
                if (_isServicesDropdownOpen)
                  AddItemDropdownContent(
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
                                title: Text(service['name'] ?? 'Unknown Service', style: GoogleFonts.poppins(fontSize: 13.sp, color: Colors.black)),
                                value: isSelected,
                                activeColor: AppColors.primaryBlue,
                                dense: true,
                                onChanged: (bool? value) {
                                  if (!mounted) return;
                                  final svm = context.read<ServiceViewModel>();
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
                                      if (_selectedServiceIds.isEmpty) _selectedItem = null;
                                    }
                                  });
                                  _syncAmountController();

                                  // Trigger API outside of setState block for better performance
                                  if (value == true && _selectedServiceIds.contains(serviceId)) {
                                  svm.fetchItemsForMultipleServices(_selectedServiceIds.toList());
                                  }
                                },
                              );
                            },
                          ),
                  ),
                SelectedServicesDisplay(
                  selectedServiceIds: _selectedServiceIds,
                  availableServices: availableServices,
                ),
                if (serviceError != null && serviceError.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.only(top: 8.h),
                    child: Text(
                      serviceError,
                      style: GoogleFonts.poppins(fontSize: 12.sp, color: Colors.redAccent),
                    ),
                  ),
                SizedBox(height: 12.h),
                const AddItemLabel(text: "Items"),
                AddItemDropdownTrigger(
                  text: _selectedServiceIds.isEmpty
                      ? "Select services first"
                      : (isFetchingItems ? "Loading items..." : (_selectedItem ?? "Select")),
                  width: double.infinity,
                  onTap: _selectedServiceIds.isEmpty || serviceLoading
                      ? null
                      : () => setState(() {
                            _isItemsDropdownOpen = !_isItemsDropdownOpen;
                            _isServicesDropdownOpen = false;
                          }),
                  isOpen: _isItemsDropdownOpen,
                ),
                if (_isItemsDropdownOpen)
                  AddItemDropdownContent(child: _buildItemsList(isFetchingItems, dynamicItems)),
                SizedBox(height: 12.h),
                const AddItemLabel(text: "Quantity"),
                QuantityCounter(
                  quantity: _quantity,
                  onIncrement: () {
                    setState(() => _quantity++);
                    _syncAmountController();
                  },
                  onDecrement: () {
                    if (_quantity > 1) {
                      setState(() => _quantity--);
                      _syncAmountController();
                    }
                  },
                ),
                SizedBox(height: 12.h),
                const AddItemLabel(text: "Amount"),
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
                AddItemSubmitButton(
                  isLoading: _isLoading,
                  onPressed: _onAddItem,
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

  void _onAddItem() async {
    if (_isLoading) return;
    if (_selectedServiceIds.isEmpty || _selectedItem == null || _amountController.text.isEmpty) {
      AppToast.showError(
        title: "Input Error",
        message: "Please select services, an item, and enter an amount.");
      return;
    }

    final serviceVM = context.read<ServiceViewModel>();
    final orderVM = context.read<OrderViewModel>();
    final availableServices = serviceVM.availableServices;
    final serviceItemsMap = serviceVM.serviceItemsMap;

    final double totalAmount = _calculateDerivedAmount(availableServices, serviceItemsMap);
    if (totalAmount <= 0) {
      AppToast.showError(
        title: "Invalid Amount",
        message: "Unable to calculate amount for selected services and item.",
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final List<String> serviceNames = _selectedServiceIds.map((id) {
        final service = availableServices.firstWhere((s) => s['id']?.toString() == id, orElse: () => {});
        return service['name']?.toString() ?? 'General';
      }).toList();

      final String combinedName = "${serviceNames.join(", ")} - $_selectedItem";
      
      if (_quantity <= 0) {
        AppToast.showError(
          title: "Input Error",
          message: "Quantity must be at least 1",
        );
        return;
      }
      final double unitPrice = totalAmount / _quantity;

      await orderVM.addItemToOrder(
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