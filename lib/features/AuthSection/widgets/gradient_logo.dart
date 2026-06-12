import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ziya_laundry_deliveryapp/Constants/app_colors.dart';
import 'package:ziya_laundry_deliveryapp/Constants/app_strings.dart';
import 'package:ziya_laundry_deliveryapp/Constants/app_images.dart';

class GradientLogo extends StatelessWidget {
  const GradientLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Image.asset(
          AppImages.appLogo,
          height: 30.h,color: AppColors.primaryBlue,
        ),
        SizedBox(width: 8.w),
        Text(
          AppText.AppName,
          style: GoogleFonts.poppins(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.primaryBlue
          ),
        ),
      ],
    );
  }
}
