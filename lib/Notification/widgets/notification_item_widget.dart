import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ziya_laundry_deliveryapp/Constants/app_colors.dart';
import 'package:ziya_laundry_deliveryapp/Constants/app_images.dart';

class NotificationItemWidget extends StatelessWidget {
  final String title;
  final String time;
  final String orderId;
  final bool isSelected;
  final bool isSelectionMode;

  const NotificationItemWidget({
    super.key,
    required this.title,
    required this.time,
    required this.orderId,
    required this.isSelected,
    required this.isSelectionMode,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        color: isSelected ? AppColors.notifSelectedRed : AppColors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.black12,
            offset: Offset(0, 3),
            blurRadius: 6,
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isSelectionMode)
            Padding(
              padding: EdgeInsets.only(right: 10.w, top: 10.h),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: 24.h,
                width: 24.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? AppColors.red : AppColors.primaryBlue,
                    width: 2,
                  ),
                  color: isSelected ? AppColors.red : AppColors.transparent,
                ),
                child: isSelected
                    ? const Center(
                        child: Icon(Icons.check, size: 16, color: AppColors.white),
                      )
                    : null,
              ),
            ),

          /// Icon Circle
          Container(
              height: 40.w,
              width: 40.w,
              decoration: BoxDecoration(
                color: AppColors.notifBadgeBlue, // light blue circle
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Image.asset(AppImages.iconPackage, height: 15.h, width: 15.w),
              )),

          SizedBox(width: 14.w),

          /// Text Section
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Title + Time Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(title,
                          style: GoogleFonts.poppins(fontSize: 16.sp, fontWeight: FontWeight.w500)),
                    ),
                    Text(time,
                        style: GoogleFonts.poppins(
                            fontSize: 13.sp, color: AppColors.notifTimeBlue, fontWeight: FontWeight.w500)),
                  ],
                ),
                SizedBox(height: 6.h),
                /// Order ID
                Text(orderId,
                    style: GoogleFonts.poppins(fontSize: 14.sp, fontWeight: FontWeight.w400, color: AppColors.black54)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}