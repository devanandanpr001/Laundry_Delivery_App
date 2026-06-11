import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:ziya_laundry_deliveryapp/core/Constants/app_colors.dart';

class NoInternetWidget extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const NoInternetWidget({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset(
              'assets/gifs/no_internet.json',
              width: 200.w,
              height: 200.h,
              fit: BoxFit.contain,
            ),
 
            SizedBox(height: 24.h),

            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.red,
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
            ),

            SizedBox(height: 24.h),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.primaryBlue,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 12.h),
              ),
              onPressed: onRetry,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Retry', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600)),
                  SizedBox(width: 8.w),
                  Icon(Icons.refresh, size: 18.sp),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}