import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quick_popup_manager/quick_popup_manager.dart';

Future<bool> showPremiumConfirmationDialog(
  BuildContext context, {
  required String title,
  required String description,
  String confirmText = 'Yes',
  String cancelText = 'No',
  Color confirmColor = const Color(0xFF42B883),
  Color cancelColor = const Color(0xFFF04438),
}) {
  final completer = Completer<bool>();

  QuickPopupManager().showDialogPopup(
    barrierDismissible: false,
    animation: const AnimationConfig.scale(),
    style: PopupStyle(
      backgroundColor: Colors.transparent,
      elevation: 0,
      padding: EdgeInsets.zero,
      dialogAlignment: Alignment.center,
    ),
    confirmText: '',
    cancelText: '',
    onConfirm: null,
    onCancel: null,
    content: Center(
      child: Container(
        width: 640.w,
        // margin: EdgeInsets.symmetric(horizontal: 20.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 40.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1E293B),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 12.h),
          Text(
            description,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 13.sp,
              color: const Color(0xFF475569),
              height: 1.5,
            ),
          ),
          SizedBox(height: 32.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Cancel button (No)
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    QuickPopupManager().dismissAll();
                    completer.complete(false);
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    decoration: BoxDecoration(
                      color: cancelColor,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(8.r),
                        bottomLeft: Radius.circular(8.r),
                        bottomRight: Radius.circular(8.r),
                        topRight: Radius.circular(0), // Replicating screenshot artifact
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      cancelText,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14.sp,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              // Confirm button (Yes)
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    QuickPopupManager().dismissAll();
                    completer.complete(true);
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    decoration: BoxDecoration(
                      color: confirmColor,
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(8.r),
                        bottomRight: Radius.circular(8.r),
                        bottomLeft: Radius.circular(8.r),
                        topLeft: Radius.circular(0), // Replicating screenshot artifact
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      confirmText,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14.sp,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
        ),
      ),
    ),
  );

  return completer.future;
}

Future<bool> showPremiumLogoutDialog(BuildContext context) {
  return showPremiumConfirmationDialog(
    
    context,
    title: 'Log out?',
    description: 'Are you sure you want to log out from your account?',
    confirmText: 'Yes',
    cancelText: 'No',
    confirmColor: const Color(0xFF42B883),
    cancelColor: const Color(0xFFF04438),
  );
}

Future<void> showPremiumInfoDialog(
  BuildContext context, {
  required String title,
  required String description,
}) {
  final completer = Completer<void>();

  QuickPopupManager().showDialogPopup(
    barrierDismissible: true,
    animation: const AnimationConfig.scale(),
    style: PopupStyle(
      backgroundColor: Colors.transparent,
      elevation: 0,
      padding: EdgeInsets.zero,
      dialogAlignment: Alignment.center,
    ),
    confirmText: '',
    cancelText: '',
    onConfirm: null,
    onCancel: null,
    content: Center(
      child: Container(
        // width: 440.w,
        // margin: EdgeInsets.symmetric(horizontal: 20.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
        ),
        // child: Padding(
        //   padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 40.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1E293B),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 12.h),
          Text(
            description,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 13.sp,
              color: const Color(0xFF475569),
              height: 1.5,
            ),
          ),
          SizedBox(height: 32.h),
          GestureDetector(
            onTap: () {
              QuickPopupManager().dismissAll();
              completer.complete();
            },
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 12.h),
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFF42B883),
                borderRadius: BorderRadius.circular(8.r),
              ),
              alignment: Alignment.center,
              child: Text(
                "OK",
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14.sp,
                ),
              ),
            ),
          ),
        ],
      ),
        ),
      ),
    // ),
  );
  
  return completer.future;
}
