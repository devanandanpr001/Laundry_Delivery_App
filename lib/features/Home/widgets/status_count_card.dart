import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ziya_laundry_deliveryapp/Constants/app_colors.dart';

class StatusCountCard extends StatelessWidget {
  final Color color;
  final String title;
  final int count;
  final String image;
  final VoidCallback onTap;

  const StatusCountCard({
    super.key,
    required this.color,
    required this.title,
    required this.count,
    required this.image,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        constraints: BoxConstraints(minHeight: 100.h),
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(8.w)),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: GoogleFonts.poppins(fontSize: 14.sp, fontWeight: FontWeight.w500, color: AppColors.white)),
            SizedBox(height: 10.h),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text(count.toString().padLeft(2, '0'), style: GoogleFonts.poppins(fontSize: 32.sp, fontWeight: FontWeight.w500, color: AppColors.white)),
              const Spacer(),
              if (image.isNotEmpty)
                Flexible(
                  child: Image.asset(
                    image,
                    height: 50.h,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                  ),
                ),
            ])
          ]),
        ),
      ),
    );
  }
}