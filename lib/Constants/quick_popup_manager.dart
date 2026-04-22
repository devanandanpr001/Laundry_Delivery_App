import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class QuickPopupManager {
  /// Shows a Bottom Notification Bar (Success or Error)
  static void showNotification(BuildContext context, String message, {bool isError = false}) {
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