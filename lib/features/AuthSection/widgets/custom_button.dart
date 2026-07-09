import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:ziya_laundry_deliveryapp/Constants/app_colors.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? textColor;
  final FontWeight? fontWeight;
  final double? height;
  final double? borderRadius;
  final double? elevation;
  final String? fontFamily;
  final bool loading;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.backgroundColor,
    this.textColor,
    this.fontWeight,
    this.height,
    this.borderRadius,
    this.elevation,
    this.fontFamily,
    this.loading = false,
  });

  @override
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
        onPressed: loading ? null : onPressed,
        child: loading
            ? LoadingAnimationWidget.waveDots(
                color: AppColors.white,
                size: 24.h,
              )
            : Text(
                text,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: fontWeight ?? FontWeight.w600,
                  color: textColor ?? AppColors.white,
                  fontFamily: fontFamily,
                ),
              ),
      ),
    );
  }
}