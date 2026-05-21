import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ziya_laundry_deliveryapp/Constants/app_colors.dart';

class NoInternetConnectionScreen extends StatelessWidget {
  final Future<void> Function() onRetry;

  const NoInternetConnectionScreen({super.key, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.bg,
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 30.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Center(
                  child: Image.asset(
                    'assets/No_internet.png',
                    width: 300.w,
                    fit: BoxFit.contain,
                    gaplessPlayback: true,
                  ),
                ),
                SizedBox(height: 28.h),
                Text(
                  'No internet connection',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.black87,
                  ),
                ),
                SizedBox(height: 14.h),
                Text(
                  "It looks like you're offline. Check your connection and tap the button below to refresh.",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w400,
                    color: AppColors.black54,
                    height: 1.5,
                  ),
                ),
                SizedBox(height: 32.h),
                SizedBox(
                  width: 180.w,
                  height: 48.h,
                  child: ElevatedButton.icon(
                    onPressed: onRetry,
                    icon: Icon(Icons.refresh, size: 20.sp),
                    label: Text(
                      'Refresh',
                      style: GoogleFonts.poppins(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: AppColors.white,
                      backgroundColor: AppColors.primaryBlue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14.r),
                      ),
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
}
