
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:quick_popup_manager/quick_popup_manager.dart';
import 'package:ziya_laundry_deliveryapp/Constants/app_colors.dart';

class AppLoader {
  static String? _currentLoaderId;

  /// Clean, modern & professional loader for Laundry Delivery App
  static void show({
    String message = "Processing your order...",
    VoidCallback? onCancel,
  }) {
    if (_currentLoaderId != null) return;

    _currentLoaderId = DateTime.now().millisecondsSinceEpoch.toString();

    QuickPopupManager().showDialogPopup(
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.5),
      animation: const AnimationConfig.fade(),
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
        child: Material(
          color: Colors.transparent,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 40.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Elegant Laundry-themed Loader
                LoadingAnimationWidget.threeArchedCircle(
                  color: AppColors.primaryBlue,
                  size: 62.sp,
                ),
                SizedBox(height: 28.h),

                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 15.5.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: 12,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),

                if (onCancel != null) ...[
                  SizedBox(height: 32.h),
                  TextButton(
                    onPressed: () {
                      hide();
                      onCancel();
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white70,
                      padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 10.h),
                    ),
                    child: Text(
                      "Cancel",
                      style: GoogleFonts.poppins(
                        fontSize: 14.5.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.redAccent.shade100,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Hides the loading overlay
  static void hide() {
    if (_currentLoaderId != null) {
      QuickPopupManager().dismissAll();
      _currentLoaderId = null;
    }
  }

  /// Result Dialog (Success / Error)
  static void showResult({
    required String title,
    required String message,
    bool isError = false,
    VoidCallback? onOk,
  }) {
    hide();
    QuickPopupManager().showDialogPopup(
      barrierDismissible: false,
      animation: const AnimationConfig.scale(),
      style: PopupStyle(
        backgroundColor: Colors.transparent,
        elevation: 0,
        padding: EdgeInsets.zero,
      ),
      confirmText: '',
      cancelText: '',
      onConfirm: null,
      onCancel: null,
      content: Center(
        child: Container(
          width: 330.w,
          margin: EdgeInsets.symmetric(horizontal: 24.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.18),
                blurRadius: 30,
                spreadRadius: 8,
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.all(32.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isError ? Icons.error_outline_rounded : Icons.check_circle_outline_rounded,
                  color: isError ? Colors.redAccent : const Color(0xFF42B883),
                  size: 58.sp,
                ),
                SizedBox(height: 22.h),
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 19.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1E293B),
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 12.h),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 14.sp,
                    color: Colors.grey[700],
                    height: 1.45,
                  ),
                ),
                SizedBox(height: 32.h),
                GestureDetector(
                  onTap: () {
                    QuickPopupManager().dismissAll();
                    if (onOk != null) onOk();
                  },
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    decoration: BoxDecoration(
                      color: isError ? Colors.redAccent : const Color(0xFF42B883),
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      "OK",
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
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

  // ==================== Navigation Methods ====================

  static Future<T?> navigateWithTask<T>(
    BuildContext context, {
    required Future<void> Function() task,
    required Widget page,
    String message = "Preparing your order...",
    VoidCallback? onCancel,
    RouteSettings? settings,
  }) async {
    show(message: message, onCancel: onCancel);
    try {
      await task();
      hide();
    } catch (e) {
      hide();
      showResult(
        title: "Connection Issue",
        message: e.toString().replaceFirst("Exception: ", ""),
        isError: true,
      );
      return null;
    }

    if (!context.mounted) return null;

    return Navigator.push<T>(
      context,
      PageRouteBuilder(
        settings: settings,
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 320),
      ),
    );
  }

  static Future<T?> navigateReplacementWithTask<T, TO>(
    BuildContext context, {
    required Future<void> Function() task,
    required Widget page,
    String message = "Updating...",
    RouteSettings? settings,
  }) async {
    show(message: message);
    try {
      await task();
      hide();
    } catch (e) {
      hide();
      showResult(title: "Task Failed", message: e.toString(), isError: true);
      return null;
    }

    if (!context.mounted) return null;

    return Navigator.pushReplacement<T, TO>(
      context,
      PageRouteBuilder(
        settings: settings,
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  static Future<T?> navigateAndRemoveUntilWithTask<T>(
    BuildContext context, {
    required Future<void> Function() task,
    required Widget page,
    String message = "Processing...",
    RouteSettings? settings,
  }) async {
    show(message: message);
    try {
      await task();
      hide();
    } catch (e) {
      hide();
      showResult(title: "Task Failed", message: e.toString(), isError: true);
      return null;
    }

    if (!context.mounted) return null;

    return Navigator.pushAndRemoveUntil<T>(
      context,
      PageRouteBuilder(
        settings: settings,
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
      (route) => false,
    );
  }

  // Backward Compatibility
  static Future<T?> navigateWithLoader<T>(
    BuildContext context,
    Widget page, {
    RouteSettings? settings,
    String message = "Loading...",
  }) async {
    return navigateWithTask<T>(
      context,
      task: () => Future.delayed(const Duration(milliseconds: 650)),
      page: page,
      message: message,
      settings: settings,
    );
  }
}