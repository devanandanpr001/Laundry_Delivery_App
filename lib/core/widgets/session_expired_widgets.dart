import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ziya_laundry_deliveryapp/core/Constants/app_colors.dart';

/// A widget to display the countdown for session expiration.
class SessionCountdownDisplay extends StatelessWidget {
  final Stream<int> timerStream;
  final Duration remainingTime;
  final String Function(Duration) formatDuration;

  const SessionCountdownDisplay({
    super.key,
    required this.timerStream,
    required this.remainingTime,
    required this.formatDuration,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<int>(
      stream: timerStream,
      builder: (context, snapshot) {
        return Container(
          padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 16.w),
          decoration: BoxDecoration(
            color: AppColors.primaryBlue.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(
              color: AppColors.primaryBlue.withValues(alpha: 0.3), // Changed to primaryBlue with alpha
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.schedule, color: AppColors.primaryBlue, size: 18.sp),
              SizedBox(width: 8.w),
              Text("Redirecting in: ${formatDuration(remainingTime)}",
                  style: GoogleFonts.poppins(fontSize: 13.sp, fontWeight: FontWeight.w600, color: AppColors.primaryBlue)),
            ],
          ),
        );
      },
    );
  }
}