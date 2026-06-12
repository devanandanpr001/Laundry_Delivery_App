import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ziya_laundry_deliveryapp/Constants/app_colors.dart';
import 'package:ziya_laundry_deliveryapp/features/Home/data/model/home_models.dart'; // For OrderStatus

class MismatchReasonDisplay extends StatelessWidget {
  final String? mismatchReason;
  final OrderStatus orderStatus;

  const MismatchReasonDisplay({
    super.key,
    required this.mismatchReason,
    required this.orderStatus,
  });

  @override
  Widget build(BuildContext context) {
    // Show only if there's a mismatch reason recorded (at any order status)
    if (mismatchReason == null || mismatchReason!.isEmpty) {
      return const SizedBox.shrink();
    }

    final bool isCompleted = orderStatus == OrderStatus.completed;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: AppColors.errorRed.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(
            color: AppColors.errorRed.withValues(alpha: 0.35),
            width: 1.2.r,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.errorRed.withValues(alpha: 0.08),
              blurRadius: 4.r,
              offset: Offset(0, 2.h),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(6.w),
                  decoration: BoxDecoration(
                    color: AppColors.errorRed.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Icon(
                    Icons.error_outline_rounded,
                    color: AppColors.errorRed,
                    size: 16.sp,
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Item Mismatch Reported",
                        style: GoogleFonts.poppins(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        isCompleted ? "Reported during pickup verification" : "Order status: ${orderStatus.toString().split('.').last}",
                        style: GoogleFonts.poppins(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textGrey,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: AppColors.errorRed.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.warning, color: AppColors.errorRed, size: 12.sp),
                      SizedBox(width: 4.w),
                      Text(
                        "Issue",
                        style: GoogleFonts.poppins(
                          fontSize: 10.sp,
                          color: AppColors.errorRed,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 10.h),
            // Mismatch Details Section
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(
                  color: AppColors.errorRed.withValues(alpha: 0.2),
                  width: 0.8.r,
                ),
              ),
              child: Text(
                mismatchReason ?? "No details provided",
                style: GoogleFonts.poppins(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textDark,
                  height: 1.4,
                ),
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(height: 8.h),
            // Status Information
            Row(
              children: [
                Icon(Icons.check_circle, color: AppColors.errorRed, size: 14.sp),
                SizedBox(width: 6.w),
                Expanded(
                  child: Text(
                    isCompleted
                        ? "This mismatch was recorded and order completed"
                        : "Mismatch has been documented for review",
                    style: GoogleFonts.poppins(
                      fontSize: 11.sp,
                      color: AppColors.textGrey,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
