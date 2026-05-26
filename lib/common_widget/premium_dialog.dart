import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ziya_laundry_deliveryapp/core/Constants/app_colors.dart';

Future<bool> showPremiumConfirmationDialog(
  BuildContext context, {
  required String title,
  required String description,
  String confirmText = 'Delete',
  String cancelText = 'Cancel',
  Color confirmColor = Colors.red,
}) {
  return showGeneralDialog<bool>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Confirm',
    barrierColor: Colors.black.withOpacity(0.35),
    transitionDuration: const Duration(milliseconds: 320),
    pageBuilder: (context, anim1, anim2) {
      return const SizedBox.shrink();
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      final curved = Curves.easeOut.transform(animation.value);
      return Opacity(
        opacity: animation.value,
        child: Transform.scale(
          scale: 0.95 + (curved * 0.05),
          child: Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16.r),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.86,
                  padding: EdgeInsets.all(20.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.r),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 20, offset: const Offset(0, 8)),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(title, style: GoogleFonts.poppins(fontSize: 18.sp, fontWeight: FontWeight.w600, color: AppColors.textDark)),
                      SizedBox(height: 10.h),
                      Text(description, textAlign: TextAlign.center, style: GoogleFonts.poppins(fontSize: 14.sp, color: AppColors.textGrey)),
                      SizedBox(height: 18.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: AppColors.divider),
                                padding: EdgeInsets.symmetric(vertical: 12.h),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                              ),
                              child: Text(cancelText, style: GoogleFonts.poppins(color: AppColors.darkGrey, fontWeight: FontWeight.w600)),
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: confirmColor,
                                padding: EdgeInsets.symmetric(vertical: 12.h),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                              ),
                              child: Text(confirmText, style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w700)),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    },
  ).then((value) => value ?? false);
}

Future<bool> showPremiumLogoutDialog(BuildContext context) async {
  return showPremiumConfirmationDialog(
    context,
    title: 'Log out',
    description: 'Are you sure you want to log out from this account?',
    confirmText: 'Yes',
    cancelText: 'No',
    confirmColor: AppColors.errorRed,
  );
}
