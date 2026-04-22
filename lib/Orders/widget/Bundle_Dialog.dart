import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ziya_laundry_deliveryapp/Constants/app_colors.dart';
import 'package:ziya_laundry_deliveryapp/Constants/app_images.dart';
import 'package:ziya_laundry_deliveryapp/Constants/app_text.dart';

import '../data/model/Bundle_Model.dart';

class BundleDialog extends StatefulWidget {
  const BundleDialog({super.key});

  @override
  State<BundleDialog> createState() => _BundleDialogState();
}

class _BundleDialogState extends State<BundleDialog> {
  List<String> services = AppText.DefaultServices;

  List<String> selectedServices = [];
  bool showDropdown = false;

  String selectedType = AppText.PerWeightLabel;
  String? selectedService;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
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
                            showDropdown = !showDropdown;
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
                              Expanded(
                                child: Text(style: GoogleFonts.poppins(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600
                                ),
                                  selectedServices.isEmpty
                                      ? AppText.SelectServicesHint
                                      : AppText.SelectServicesHint
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
                          child: SizedBox(
                            height: 180.h,
                            child: Stack(
                              children: [
                             ListView(
                                shrinkWrap: true,
                              children: services.map((service) {
                                return CheckboxListTile(
                                  controlAffinity: ListTileControlAffinity.leading,
                                  title: Text(service),
                                  value: selectedServices.contains(service),
                                  onChanged: (value) {
                                    setState(() {
                                      if (value!) {
                                        selectedServices.add(service);
                                      } else {
                                        selectedServices.remove(service);
                                      }
                                    });
                                  },
                                );
                              }).toList(),
                                                      ),
                            ],
                        ),),),
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
                  const Text(AppText.WeightLabel),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: AppText.PerKgHint,
                        border: OutlineInputBorder(),
                      ),
                    ),
                  )
                ],
              ),

              const SizedBox(height: 20),

              /// TOTAL
              Align(
                alignment: Alignment.centerLeft,
                child: const Text(AppText.TotalAmountLabel),
              ),

              const SizedBox(height: 20),

              /// ADD BUTTON
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: selectedServices.isEmpty ? null :() {
                    final bundle = BundleModel(
                      id: 1,
                      price: 473,
                      services: selectedServices,
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
}