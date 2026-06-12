  import 'package:flutter/material.dart';
  import 'package:flutter_screenutil/flutter_screenutil.dart';
  import 'package:google_fonts/google_fonts.dart';
  import 'package:ziya_laundry_deliveryapp/Constants/app_colors.dart';
  import 'package:ziya_laundry_deliveryapp/Constants/app_images.dart';

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
      required this.isExpanded,
    });

    @override
    Widget build(BuildContext context) {
      return AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        margin: EdgeInsets.symmetric(vertical: 8.h),
        width: double.infinity,
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14.r),
          color: isSelected ? AppColors.notifSelectedRed : AppColors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              offset: const Offset(0, 4),
              blurRadius: 10,
            ),
          ],
        ),
        child: AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          alignment: Alignment.topCenter,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (isSelectionMode)
                    Padding(
                      padding: EdgeInsets.only(right: 12.w),
                      child: Container(
                        height: 22.h,
                        width: 22.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected ? AppColors.red : AppColors.primaryBlue,
                            width: 2,
                          ),
                          color: isSelected ? AppColors.red : AppColors.transparent,
                        ),
                        child: isSelected
                            ? const Icon(Icons.check, size: 14, color: AppColors.white)
                            : null,
                      ),
                    ),

                  /// Icon and Unread Indicator
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        height: 42.w,
                        width: 42.w,
                        decoration: const BoxDecoration(
                          color: Color(0xffE8F0FE),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Image.asset(AppImages.iconPackage, height: 20.h, width: 20.w),
                        ),
                      ),
                      if (!isRead && !isSelectionMode)
                        Positioned(
                          top: -2.h,
                          right: -2.w,
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
                  ),
                  SizedBox(width: 12.w),

                  /// Title and Date
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          createdAt,
                          style: GoogleFonts.poppins(
                            fontSize: 12.sp,
                            color: AppColors.primaryBlue,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: AppColors.grey,
                    size: 20.sp,
                  ),
                ],
              ),
              if (isExpanded) ...[
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(height: 1, color: AppColors.black12),
                ),
                Text(
                  message,
                  style: GoogleFonts.poppins(
                    fontSize: 13.sp,
                    color: Colors.black87,
                    height: 1.5,
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    }
  }