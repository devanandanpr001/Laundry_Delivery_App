import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:ziya_laundry_deliveryapp/Constants/app_colors.dart';
import 'package:ziya_laundry_deliveryapp/Constants/app_text.dart';
import '../viewmodel/home_viewmodel.dart';

class OnlineToggle extends StatelessWidget {
  const OnlineToggle({super.key});
  @override
  Widget build(BuildContext context) {
    final isOnline = context.watch<HomeViewModel>().isOnline;
    return GestureDetector(
      onTap: () => context.read<HomeViewModel>().toggleOnlineStatus(),
      child: AnimatedContainer(
        height: 38.w, width: 115.w,
        duration: const Duration(milliseconds: 300),
        padding: EdgeInsets.symmetric(horizontal: 10.w),
        decoration: BoxDecoration(
          color: isOnline ? AppColors.onlineBlue : AppColors.offlineRed,
          borderRadius: BorderRadius.circular(25.w),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Align(
              alignment: isOnline ? Alignment.centerLeft : Alignment.centerRight,
              child: SizedBox(width: 80.w, child: FittedBox(fit: BoxFit.scaleDown, child: Text(isOnline ? AppText.Online : AppText.Offline, style: GoogleFonts.poppins(color: AppColors.white, fontSize: 16.sp, fontWeight: FontWeight.w500)))),
            ),
            AnimatedAlign(  duration: const Duration(milliseconds: 300), curve: Curves.easeOut, alignment: isOnline ? Alignment.centerRight : Alignment.centerLeft, child: Container(height: 26.w, width: 26.w, decoration: const BoxDecoration(color: AppColors.white, shape: BoxShape.circle))),
          ],
        ),
      ),
    );
  }
}