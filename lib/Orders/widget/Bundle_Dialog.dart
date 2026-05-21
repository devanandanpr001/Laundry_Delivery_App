import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:ziya_laundry_deliveryapp/Constants/app_colors.dart';
import 'package:ziya_laundry_deliveryapp/Constants/app_images.dart';
import 'package:ziya_laundry_deliveryapp/Constants/app_text.dart';
import 'package:ziya_laundry_deliveryapp/Orders/widget/service_repository.dart';
import 'package:ziya_laundry_deliveryapp/Orders/widget/service_service.dart';
import 'package:ziya_laundry_deliveryapp/Orders/widget/service_viewmodel.dart';

import '../data/model/Bundle_Model.dart';

class BundleDialog extends StatefulWidget {
  final String orderId;
  const BundleDialog({super.key, required this.orderId});

  @override
  State<BundleDialog> createState() => _BundleDialogState();
}

class _BundleDialogState extends State<BundleDialog> {
  // Import ServiceViewModel
  final ServiceViewModel _serviceViewModel = ServiceViewModel(ServiceRepository(ServiceService()));
  final TextEditingController _weightController = TextEditingController();
  double _unitPrice = 0.0;
  double _totalAmount = 0.0;
  List<String> selectedServices = [];
  bool showDropdown = false;

  @override
  void initState() {
    super.initState();
    // Efficiently trigger fetching services from the VM if not already loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final serviceViewModel = Provider.of<ServiceViewModel>(context, listen: false);
      if (serviceViewModel.services.isEmpty) {
        serviceViewModel.fetchAvailableServices(orderId: widget.orderId);
      }
    });
    _weightController.addListener(_updateTotal);
  }

  void _updateTotal() {
    final serviceViewModel = Provider.of<ServiceViewModel>(context, listen: false);
    final weightStr = _weightController.text.trim().replaceAll(',', '.');
    final weight = double.tryParse(weightStr) ?? 0.0;
    
    double priceSum = 0.0; // Initialize priceSum

    for (var serviceName in selectedServices) { // Iterate through selected services
      final serviceData = serviceViewModel.availableServices.firstWhere(
        (s) => s['name'] == serviceName,
        orElse: () => <String, dynamic>{},
      );
      
      if (serviceData.isNotEmpty) {
        // Robust parsing of service rates from backend
        final dynamic rawRate = serviceData['price'] ?? 
                                serviceData['unitPrice'] ?? 
                                serviceData['rate'] ?? 
                                serviceData['pricePerKg'] ?? 0.0;
                                
        double rate = 0.0;
        if (rawRate is num) {
          rate = rawRate.toDouble();
        } else if (rawRate != null) {
          rate = double.tryParse(rawRate.toString().replaceAll(',', '.')) ?? 0.0;
        }
        priceSum += rate;
      }
    }

    if (mounted) {
      setState(() {
        _unitPrice = priceSum;
        _totalAmount = weight * priceSum;
      });
    }
  }

  @override
  void dispose() {
    _weightController.removeListener(_updateTotal);
    _weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Watch the ServiceViewModel for service updates
    final serviceViewModel = context.watch<ServiceViewModel>();
    final services = serviceViewModel.services;

    return Dialog(
      backgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [

              /// HEADER
              Row(
                children: [
                  CircleAvatar(
                    radius: 12,
                    backgroundColor: AppColors.cyanBlue,
                    child:  Text("1",style: GoogleFonts.poppins(
                      color: AppColors.white
                    ),),
                  ),
                  const SizedBox(width: 10),
                   Text(
                    AppText.BundleLabel,
                    style: GoogleFonts.poppins(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w400,
                    ),
                  )
                ],
              ),

              const SizedBox(height: 20),

              /// RADIO BUTTONS
              Row(
                children: [

                 Container(
                   height: 12.h,width: 12.w,
                   decoration: BoxDecoration(
                     shape: BoxShape.circle,
                     color: AppColors.primaryBlue
                   ),
                 ),
                   SizedBox(width: 5.w,),

                   Text(AppText.PerWeightLabel,style: GoogleFonts.poppins(
                     fontSize: 14.sp,
                     fontWeight: FontWeight.w600
                   ),),

                  const SizedBox(width: 8),


                ],
              ),

              const SizedBox(height: 20),

              /// SERVICES DROPDOWN
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Row(
                     children: [
                       Image.asset(AppImages.washingMachine,height: 24.h,width: 24.w,),
                       SizedBox(width: 10.w,),
                       Text(AppText.ServicesLabel,style: GoogleFonts.poppins(
                         color: AppColors.primaryBlue,
                         fontWeight: FontWeight.w400,
                         fontSize: 14.sp
                       ),),
                     ],
                   ),
                  const SizedBox(height: 5),

                  Column(
                    children: [

                      /// DROPDOWN BUTTON
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            if (services.isNotEmpty) showDropdown = !showDropdown;
                          });
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.hintGrey),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              if (serviceViewModel.isLoading)
                                SizedBox(
                                  width: 16.w, height: 16.h,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryBlue),
                                )
                              else
                              Expanded(
                                child: Text(
                                  selectedServices.isEmpty
                                      ? AppText.SelectServicesHint
                                      : "${selectedServices.length} ${AppText.SelectedSuffix}",
                                  style: GoogleFonts.poppins(
                                    fontSize: 14.sp, fontWeight: FontWeight.w600
                                  ),
                                ),
                              ),
                              Icon(showDropdown 
                                  ? Icons.keyboard_arrow_up
                                  : Icons.keyboard_arrow_down),
                            ],
                          ),
                        ),
                      ),

                      /// DROPDOWN LIST
                      if (showDropdown)
                        Container(
                          margin: EdgeInsets.only(top: 5),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.divider),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          constraints: BoxConstraints(maxHeight: 180.h),
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: services.length,
                            padding: EdgeInsets.zero,
                            itemBuilder: (context, index) {
                              final service = services[index];
                              return CheckboxListTile(
                                controlAffinity: ListTileControlAffinity.leading,
                                title: Text(service, style: GoogleFonts.poppins(fontSize: 13.sp)),
                                value: selectedServices.contains(service),
                                activeColor: AppColors.primaryBlue,
                                onChanged: (value) {
                                  setState(() {
                                    if (value == true) {
                                      selectedServices.add(service);
                                    } else {
                                      selectedServices.remove(service);
                                    }
                                  });
                                  _updateTotal();
                                },
                              );
                            },
                          ),
                        ),
                      if (selectedServices.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: selectedServices.map((service) {
                              return Text("• $service",style: GoogleFonts.poppins(
                                color: AppColors.primaryBlue,
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w400
                              ),);
                            }).toList(),
                          ),
                        ),
                    ],
                  )
                ],
              ),

              const SizedBox(height: 20),

              /// WEIGHT FIELD
              Row(
                children: [
                  Text(
                    AppText.WeightLabel,
                    style: GoogleFonts.poppins(fontSize: 14.sp, fontWeight: FontWeight.w400),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _weightController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      style: GoogleFonts.poppins(fontSize: 14.sp),
                      decoration: InputDecoration(
                        hintText: AppText.PerKgHint,
                        hintStyle: GoogleFonts.poppins(fontSize: 13.sp, color: AppColors.hintGrey),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
                      ),
                    ),
                  )
                ],
              ),

              const SizedBox(height: 20),

              /// TOTAL
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: AppColors.bg,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Column(
                  children: [
                    _buildAmountRow("Rate per KG", "₹ ${_unitPrice.toStringAsFixed(2)}", isTotal: false),
                    SizedBox(height: 8.h),
                    _buildAmountRow(AppText.TotalAmountLabel, "₹ ${_totalAmount.toStringAsFixed(2)}", isTotal: true),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              /// ADD BUTTON
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: (selectedServices.isEmpty || _totalAmount <= 0 || _unitPrice <= 0) ? null : () {
                    final bundle = BundleModel(
                      id: '1',
                      price: _unitPrice,
                      services: List.from(selectedServices),
                      name: 'Bundle ${selectedServices.length}',
                      weight: _weightController.text,
                    );
                    Navigator.pop(context, bundle);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: selectedServices.isEmpty ? AppColors.grey : AppColors.primaryBlue
                  ),
                  icon:  Icon(Icons.add,color: AppColors.white,),
                  label: const Text(AppText.AddBtn,style: TextStyle(color: AppColors.white),),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAmountRow(String label, String value, {required bool isTotal}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14.sp,
            fontWeight: isTotal ? FontWeight.w600 : FontWeight.w400,
            color: isTotal ? Colors.black : Colors.grey,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: isTotal ? 16.sp : 14.sp,
            fontWeight: isTotal ? FontWeight.w700 : FontWeight.w500,
            color: isTotal ? AppColors.primaryBlue : Colors.black,
          ),
        ),
      ],
    );
  }
}