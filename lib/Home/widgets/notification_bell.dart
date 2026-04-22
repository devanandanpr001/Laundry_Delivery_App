import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ziya_laundry_deliveryapp/Constants/app_colors.dart';
import '../../Notification/view/notification_screen.dart';
import '../../Notification/viewmodel/notification_viewmodel.dart';
import 'package:provider/provider.dart';

class NotificationBell extends StatelessWidget {
  const NotificationBell({super.key});
  @override
  Widget build(BuildContext context) {
    final notifications = context.watch<NotificationViewModel>().notificationList;
    return Stack(clipBehavior: Clip.none, children: [
      GestureDetector(onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationScreen())), child: Icon(Icons.notifications_none_outlined, color: AppColors.primaryBlue, size: 24.sp)),
      if (notifications.isNotEmpty)
        Positioned(right: -2.w, top: -4.h, child: Container(padding: EdgeInsets.all(4.w), decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.red), child: Text('${notifications.length}', style: GoogleFonts.poppins(fontSize: 8.sp, fontWeight: FontWeight.w500, color: AppColors.white)))),
    ]);
  }
}