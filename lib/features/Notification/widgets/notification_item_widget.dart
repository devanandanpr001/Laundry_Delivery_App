  import 'package:flutter/material.dart';
  import 'package:flutter_screenutil/flutter_screenutil.dart';
  import 'package:google_fonts/google_fonts.dart';
  import 'package:ziya_laundry_deliveryapp/core/Constants/app_colors.dart';
  import 'package:ziya_laundry_deliveryapp/core/Constants/app_images.dart';

  class NotificationItemWidget extends StatelessWidget {
    final String title;
    final String createdAt;
    final String message;
    final bool isSelected;
    final bool isRead;
    final bool isSelectionMode;
    final bool isExpanded;

    const NotificationItemWidget({
      super.key,
      required this.title,
      required this.createdAt,
      required this.message,
      required this.isSelected,
      required this.isRead,
      required this.isSelectionMode,
      this.isExpanded = false,
    });

    @override
    Widget build(BuildContext context) {
      return Stack(
        children: [
          Container(
            margin: EdgeInsets.symmetric(vertical: 8.h),
            width: double.infinity,
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
            SizedBox(
              height: 40.w,
              width: 40.w,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    height: 40.w,
                    width: 40.w,
                    decoration: BoxDecoration(
                      color: AppColors.notifBadgeBlue,
                      shape: BoxShape.circle,
                    ),
                  ),
                  Image.asset(AppImages.iconPackage, height: 15.h, width: 15.w),
                ],
              ),
            ),

            SizedBox(width: 14.w),

            /// Text Section
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Title + Time Row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          maxLines: isExpanded ? null : 1,
                          overflow: isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(fontSize: 16.sp, fontWeight: FontWeight.w500),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        createdAt,
                        style: GoogleFonts.poppins(
                          fontSize: 13.sp,
                          color: AppColors.notifTimeBlue,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6.h),
                  /// Notification message
                  Text(
                    message,
                    maxLines: isExpanded ? null : 2,
                    overflow: isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(fontSize: 14.sp, fontWeight: FontWeight.w400, color: AppColors.black54),
                  ),
                ],
              ),
            ),
          ],
        ),
          ),
          if (!isRead && !isSelectionMode)
            Positioned(
              top: 12.h,
              right: 4.w,
              child: Container(
                height: 10.h,
                width: 10.h,
                decoration: const BoxDecoration(
                  color: AppColors.red,
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      );
    }
  }