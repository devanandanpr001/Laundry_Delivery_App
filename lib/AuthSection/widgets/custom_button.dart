import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ziya_laundry_deliveryapp/Constants/app_colors.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed; // Made nullable to allow disabling the button
  final Color? backgroundColor;
  final Color? textColor; // Added textColor parameter
  final FontWeight? fontWeight;
  final double? height;
  final double? borderRadius;
  final double? elevation;
  final String? fontFamily;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed, // No longer required, can be null to disable
    this.backgroundColor,
    this.textColor, // Added to constructor
    this.fontWeight,
    this.height,
    this.borderRadius,
    this.elevation,
    this.fontFamily,
  });

  
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? AppColors.primaryBlue,
          minimumSize: Size(double.infinity, height ?? 48.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius ?? 12.r),
          ),
          elevation: elevation,
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: fontWeight ?? FontWeight.w600,
            color: textColor ?? AppColors.white, // Use textColor if provided, else default to white
            fontFamily: fontFamily,
          ),
        ),
      ),
    );
  }
}