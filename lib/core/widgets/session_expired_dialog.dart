import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ziya_laundry_deliveryapp/core/Constants/app_colors.dart';
import 'package:ziya_laundry_deliveryapp/core/widgets/session_expired_widgets.dart';

class SessionExpiredDialog extends StatefulWidget {
  final VoidCallback onLoginAgain;
  final Duration? expirationTime;

  const SessionExpiredDialog({
    super.key,
    required this.onLoginAgain,
    this.expirationTime,
  });

  @override
  State<SessionExpiredDialog> createState() => _SessionExpiredDialogState();
}

class _SessionExpiredDialogState extends State<SessionExpiredDialog> {
  late Duration _remainingTime;
  late Stream<int> _timerStream;

  @override
  void initState() {
    super.initState();
    _remainingTime = widget.expirationTime ?? const Duration(seconds: 5);
    _timerStream = Stream<int>.periodic(
      const Duration(seconds: 1),
      (count) => count,
    ).takeWhile((_) {
      _remainingTime = _remainingTime - const Duration(seconds: 1);
      if (_remainingTime.inSeconds <= 0) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            Navigator.pop(context);
            widget.onLoginAgain();
          }
        });
        return false;
      }
      return true;
    });
  }

  String _formatDuration(Duration duration) {
    int seconds = duration.inSeconds;
    if (seconds < 60) {
      return '${seconds}s';
    }
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
        backgroundColor: Colors.white,
        title: Row(
          children: [
            Icon(
              Icons.lock_outline,
              color: AppColors.primaryBlue,
              size: 28.sp,
            ),
            SizedBox(width: 12.w),
            Text(
              "Session Expired",
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 18.sp,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Your session has expired. Please login again to continue.",
              style: GoogleFonts.poppins(
                fontSize: 14.sp,
                color: Colors.black54,
              ),
              textAlign: TextAlign.center,
            ),
            if (widget.expirationTime != null) ...[
              SizedBox(height: 16.h),
              SessionCountdownDisplay(
                timerStream: _timerStream,
                remainingTime: _remainingTime,
                formatDuration: _formatDuration,
              ),
            ],
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                widget.onLoginAgain();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                padding: EdgeInsets.symmetric(vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
              child: Text(
                "Login Again",
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
    );
  }
}
