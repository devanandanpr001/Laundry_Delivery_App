import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ziya_laundry_deliveryapp/Constants/app_colors.dart';
import 'package:ziya_laundry_deliveryapp/Home/data/model/home_models.dart'; // For OrderStatus

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
    // Only show if the order is completed or if there's a mismatch reason recorded
    if (orderStatus != OrderStatus.completed && (mismatchReason == null || mismatchReason!.isEmpty)) {
      return const SizedBox.shrink();
    }

    final bool hasMismatch = mismatchReason != null && mismatchReason!.isNotEmpty;

    return Padding(
      padding: EdgeInsets.only(top: 8.h),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(10.w),
        decoration: BoxDecoration(
          color: hasMismatch
              ? AppColors.errorRed.withValues(alpha: 0.05)
              : AppColors.grey.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(
            color: hasMismatch
                ? AppColors.errorRed.withValues(alpha: 0.3)
                : AppColors.grey.withValues(alpha: 0.3),
          ),
        ),
        child: Text(
          "Mismatch Reason: ${hasMismatch ? mismatchReason : "Not Recorded"}",
          style: GoogleFonts.poppins(
            fontSize: 13.sp,
            fontWeight: FontWeight.w500,
            color: hasMismatch ? AppColors.errorRed : AppColors.grey,
          ),
        ),
      ),
    );
  }
}