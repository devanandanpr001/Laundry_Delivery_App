import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ziya_laundry_deliveryapp/Constants/app_colors.dart';

enum QuickPopupType {
  success,
  error,
  warning,
  info,
}

class QuickPopupManager {
  static OverlayEntry? _overlayEntry;
  static Timer? _timer;

  static void showToast({
    required BuildContext context,
    required String title,
    required String message,
    required QuickPopupType type,
    Duration duration = const Duration(seconds: 3),
  }) {
    _removeCurrent();

    final overlay = Overlay.of(context);

    Color bgColor;
    Color accentColor;
    IconData icon;

    switch (type) {
      case QuickPopupType.success:
        bgColor = const Color(0xFFEAF8EC);
        accentColor = const Color(0xFF2E7D32);
        icon = Icons.check_circle;
        break;

      case QuickPopupType.error:
        bgColor = const Color(0xFFFCEBEC);
        accentColor = const Color(0xFFC62828);
        icon = Icons.error;
        break;

      case QuickPopupType.warning:
        bgColor = const Color(0xFFFFF8E1);
        accentColor = const Color(0xFFF57C00);
        icon = Icons.warning;
        break;

      case QuickPopupType.info:
        bgColor = const Color(0xFFE3F2FD);
        accentColor = const Color(0xFF1565C0);
        icon = Icons.info;
        break;
    }

    _overlayEntry = OverlayEntry(
      builder: (_) => _AnimatedPopup(
        title: title,
        message: message,
        bgColor: bgColor,
        accentColor: accentColor,
        icon: icon,
      ),
    );

    overlay.insert(_overlayEntry!);

    _timer = Timer(duration, () {
      _removeCurrent();
    });
  }

  static void showNotification(
    BuildContext context,
    String message, {
    bool isError = false,
  }) {
    showToast(
      context: context,
      title: isError ? "Error" : "Success",
      message: message,
      type: isError ? QuickPopupType.error : QuickPopupType.success,
    );
  }

  static void showSuccess(
    BuildContext context, {
    required String message,
    String title = "Success",
  }) {
    showToast(
      context: context,
      title: title,
      message: message,
      type: QuickPopupType.success,
    );
  }

  static void showError(
    BuildContext context, {
    required String message,
    String title = "Error",
  }) {
    showToast(
      context: context,
      title: title,
      message: message,
      type: QuickPopupType.error,
    );
  }

  static void _removeCurrent() {
    _timer?.cancel();
    _overlayEntry?.remove();
    _overlayEntry = null;
  }
}

class _AnimatedPopup extends StatefulWidget {
  final String title;
  final String message;
  final Color bgColor;
  final Color accentColor;
  final IconData icon;

  const _AnimatedPopup({
    required this.title,
    required this.message,
    required this.bgColor,
    required this.accentColor,
    required this.icon,
  });

  @override
  State<_AnimatedPopup> createState() => _AnimatedPopupState();
}

class _AnimatedPopupState extends State<_AnimatedPopup>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );

    _slide = Tween<Offset>(
      begin: const Offset(0, -1.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutBack,
      ),
    );

    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 10.h,
      left: 45.w,
      right: 45.w,
      child: Material(
        color: Colors.transparent,
        child: SlideTransition(
          position: _slide,
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: 12.w,
              vertical: 10.h,
            ),
            decoration: BoxDecoration(
              color: widget.bgColor,
              borderRadius: BorderRadius.circular(10.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.12),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(
                  widget.icon,
                  color: widget.accentColor,
                  size: 20.sp,
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: GoogleFonts.poppins(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        widget.message,
                        style: GoogleFonts.poppins(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w400,
                          color: Colors.black87,
                        ),
                      ),
                    ],
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

/// Internal widget for animated notifications
class _AnimatedNotification extends StatefulWidget {
  final String message;
  final String? title;
  final QuickPopupType type;
  final VoidCallback onDismiss;
  final bool isBottom;

  const _AnimatedNotification({
    required this.message,
    this.title,
    required this.type,
    required this.onDismiss,
    required this.isBottom,
  });

  @override
  State<_AnimatedNotification> createState() => _AnimatedNotificationState();
}

class _AnimatedNotificationState extends State<_AnimatedNotification> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: const Duration(milliseconds: 400), vsync: this);
    _offsetAnimation = Tween<Offset>(
      begin: widget.isBottom ? const Offset(0.0, 2.0) : const Offset(0.0, -2.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _controller.forward();
    _timer = Timer(const Duration(milliseconds: 3000), () {
      if (mounted) _controller.reverse().then((_) => widget.onDismiss());
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
    final color = widget.type == QuickPopupType.error ? AppColors.red : 
                  widget.type == QuickPopupType.success ? AppColors.green :
                  widget.type == QuickPopupType.warning ? Colors.orange : AppColors.primaryBlue;
    
    final icon = widget.type == QuickPopupType.error ? Icons.error_outline : 
                 widget.type == QuickPopupType.success ? Icons.check_circle_outline :
                 widget.type == QuickPopupType.warning ? Icons.warning_amber_rounded : Icons.info_outline;

    return Positioned(
      top: widget.isBottom ? null : MediaQuery.of(context).padding.top + 10.h,
      bottom: widget.isBottom ? 50.h : null,
      left: 45.w,
      right: 45.w,
      child: Material(
        color: Colors.transparent,
        child: SlideTransition(
          position: _offsetAnimation,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8.r), // Standard radius
              boxShadow: [BoxShadow(color: color.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 4))],
              border: Border.all(color: color.withOpacity(0.1)),
            ),
            child: Row(
              children: [
                Icon(icon, color: color, size: 20.sp),
                SizedBox(width: 10.w),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (widget.title != null)
                        Text(widget.title!, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13.sp, color: Colors.black87)),
                      Text(widget.message, style: GoogleFonts.poppins(fontSize: 11.sp, color: Colors.black54)),
                    ],
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
