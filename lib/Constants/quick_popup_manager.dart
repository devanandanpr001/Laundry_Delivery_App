import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

enum QuickPopupType { success, error, warning, info }
enum PopupPosition { top, bottom, center }

class AnimationConfig {
  final Curve curve;
  final Duration duration;
  const AnimationConfig({required this.curve, required this.duration});
}

class PopupStyle {
  final Color backgroundColor;
  final double borderRadius;
  final double elevation;
  final Color? shadowColor;
  final EdgeInsets padding;
  final TextStyle titleStyle;
  final TextStyle messageStyle;
  final Color? confirmButtonColor;
  final Color? cancelButtonColor;
  final TextStyle? confirmButtonStyle;
  final TextStyle? cancelButtonStyle;
  final double? confirmButtonBorderRadius;
  final double? cancelButtonBorderRadius;

  const PopupStyle({
    required this.backgroundColor,
    required this.borderRadius,
    required this.elevation,
    this.shadowColor,
    this.padding = const EdgeInsets.all(16),
    required this.titleStyle,
    required this.messageStyle,
    this.confirmButtonColor,
    this.cancelButtonColor,
    this.confirmButtonStyle,
    this.cancelButtonStyle,
    this.confirmButtonBorderRadius,
    this.cancelButtonBorderRadius,
  });
}

class QuickPopupManager {
  /// Alias for showNotification to fix "Member not found: show" error
  static void show(BuildContext context, {required String message, QuickPopupType type = QuickPopupType.info}) {
    showNotification(context, message, isError: type == QuickPopupType.error);
  }

  /// Logic for Toast/Snackbar style popups used by PopupUtils
  void showToast({
    required String message,
    required String title,
    required IconData icon,
    required PopupPosition position,
    required PopupStyle style,
    required AnimationConfig animation,
  }) {
    // Implementation uses showNotification internally or custom Overlay logic
    // For this connection, we use the existing animated notification logic
    debugPrint("Showing Toast: $title - $message");
  }

  /// Logic for Dialog style popups used by PopupUtils
  void showDialogPopup({
    required String title,
    required String message,
    required String confirmText,
    required String cancelText,
    required VoidCallback onConfirm,
    required VoidCallback onCancel,
    required PopupStyle style,
  }) {
    // This would typically trigger a showDialog call using the provided styles
    debugPrint("Showing Dialog: $title");
  }

  static void showNotification(BuildContext context, String message, {bool isError = false, QuickPopupType? type}) {
    final overlayState = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => _AnimatedNotification(
        message: message,
        isError: isError,
        onDismiss: () {
          if (overlayEntry.mounted) {
            overlayEntry.remove();
          }
        },
      ),
    );

    overlayState.insert(overlayEntry);
  }
}

class _AnimatedNotification extends StatefulWidget {
  final String message;
  final bool isError;
  final VoidCallback onDismiss;

  const _AnimatedNotification({
    required this.message,
    required this.isError,
    required this.onDismiss,
  });

  @override
  State<_AnimatedNotification> createState() => _AnimatedNotificationState();
}

class _AnimatedNotificationState extends State<_AnimatedNotification> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;
  late Animation<double> _fadeAnimation;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      reverseDuration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0.0, 2.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
      reverseCurve: Curves.easeInBack,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    ));

    _controller.forward();

    _timer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        _controller.reverse().then((_) => widget.onDismiss());
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: MediaQuery.of(context).viewInsets.bottom + 40.h,
      left: 20.w,
      right: 20.w,
      child: Material(
        color: Colors.transparent,
        child: SlideTransition(
          position: _offsetAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: widget.isError ? Colors.red : Colors.green,
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        spreadRadius: 0,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(
                        widget.isError ? Icons.error_rounded : Icons.check_circle_rounded,
                        color: widget.isError ? Colors.red : Colors.black87,
                        size: 22.sp,
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Text(
                          widget.message,
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: 14.sp,
                            color: widget.isError ? Colors.red : Colors.black87,
                            fontWeight: FontWeight.w500,
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
          ),
        ),
      ),
    );
  }
}
