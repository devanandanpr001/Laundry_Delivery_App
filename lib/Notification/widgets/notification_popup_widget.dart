// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:google_fonts/google_fonts.dart';

// // Assuming these are your paths, replace them if they differ
// import 'package:ziya_laundry_deliveryapp/Constants/app_colors.dart';
// import 'package:ziya_laundry_deliveryapp/Constants/app_images.dart';

// class NotificationPopupWidget extends StatelessWidget {
//   final String title;
//   final String message;
//   final String date; // e.g., "May 16, 2026"
//   final String time; // e.g., "06:05 AM"

//   const NotificationPopupWidget({
//     super.key,
//     required this.title,
//     required this.message,
//     required this.date,
//     required this.time,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Dialog(
//       backgroundColor: Colors.transparent,
//       insetPadding: EdgeInsets.symmetric(horizontal: 24.w),
//       child: Stack(
//         alignment: Alignment.bottomCenter,
//         children: [
//           /// Main Card Content
//           Container(
//             margin: EdgeInsets.only(bottom: 40.h),
//             padding: EdgeInsets.only(left: 20.w, right: 20.w, top: 30.h, bottom: 20.h),
//             decoration: BoxDecoration(
//               color: AppColors.white,
//               borderRadius: BorderRadius.circular(28.r),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.12),
//                   blurRadius: 30,
//                   offset: const Offset(0, 10),
//                 ),
//               ],
//             ),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 /// Top Illustration with Bell Badge
//                 Stack(
//                   alignment: Alignment.topRight,
//                   children: [
//                     Container(
//                       height: 145.h,
//                       width: 145.w,
//                       decoration: BoxDecoration(
//                         shape: BoxShape.circle,
//                         color: AppColors.primaryBlue.withOpacity(0.06),
//                       ),
//                       child: Center(
//                         child: Image.asset(
//                           AppImages.iconPackage,
//                           height: 75.h,
//                         ),
//                       ),
//                     ),
//                     Positioned(
//                       top: 15.h,
//                       right: 2.w,
//                       child: Container(
//                         padding: EdgeInsets.all(8.w),
//                         decoration: BoxDecoration(
//                           shape: BoxShape.circle,
//                           color: const Color(0xFFFFB822), // Warm golden orange
//                           boxShadow: [
//                             BoxShadow(
//                               color: const Color(0xFFFFB822).withOpacity(0.3),
//                               blurRadius: 10,
//                               offset: const Offset(0, 4),
//                             )
//                           ],
//                         ),
//                         child: Icon(
//                           Icons.notifications,
//                           color: Colors.white,
//                           size: 20.sp,
//                         ),
//                       ),
//                     )
//                   ],
//                 ),

//                 SizedBox(height: 24.h),

//                 /// Title
//                 Text(
//                   title,
//                   textAlign: TextAlign.center,
//                   style: GoogleFonts.poppins(
//                     fontSize: 22.sp,
//                     fontWeight: FontWeight.w700,
//                     color: const Color(0xFF1E293B), // Navy/Charcoal
//                   ),
//                 ),

//                 SizedBox(height: 12.h),

//                 /// Minimal Custom Indicator Line
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Expanded(child: Divider(color: Colors.grey.shade200, thickness: 1)),
//                     Container(
//                       width: 6.w,
//                       height: 6.h,
//                       decoration: const BoxDecoration(
//                         color: Colors.blue,
//                         shape: BoxShape.circle,
//                       ),
//                     ),
//                     Expanded(child: Divider(color: Colors.grey.shade200, thickness: 1)),
//                   ],
//                 ),

//                 SizedBox(height: 16.h),

//                 /// Date and Time Row Splitter
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Icon(Icons.calendar_today_outlined, size: 18.sp, color: Colors.blue),
//                     SizedBox(width: 6.w),
//                     Text(
//                       date,
//                       style: GoogleFonts.poppins(
//                         fontSize: 14.sp,
//                         color: Colors.grey.shade600,
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                     Container(
//                       height: 14.h,
//                       width: 1.w,
//                       color: Colors.grey.shade300,
//                       margin: EdgeInsets.symmetric(horizontal: 12.w),
//                     ),
//                     Icon(Icons.access_time, size: 18.sp, color: Colors.blue),
//                     SizedBox(width: 6.w),
//                     Text(
//                       time,
//                       style: GoogleFonts.poppins(
//                         fontSize: 14.sp,
//                         color: Colors.grey.shade600,
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                   ],
//                 ),

//                 SizedBox(height: 16.h),

//                 /// Dynamic Message / Body Content
//                 Text(
//                   message,
//                   textAlign: TextAlign.center,
//                   style: GoogleFonts.poppins(
//                     fontSize: 16.sp,
//                     color: Colors.grey.shade600,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),

//                 SizedBox(height: 24.h),

//                 /// Bottom Status Action Banner
//                 Container(
//                   width: double.infinity,
//                   padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
//                   decoration: BoxDecoration(
//                     color: const Color(0xFFEDF2FE), // Light blue banner background
//                     borderRadius: BorderRadius.circular(16.r),
//                   ),
//                   child: Row(
//                     children: [
//                       CircleAvatar(
//                         radius: 20.r,
//                         backgroundColor: Colors.white,
//                         child: const Icon(
//                           Icons.local_shipping_outlined,
//                           color: Colors.blue,
//                         ),
//                       ),
//                       SizedBox(width: 14.w),
//                       Expanded(
//                         child: Text(
//                           "You have a new notification regarding delivery.",
//                           style: GoogleFonts.poppins(
//                             fontSize: 13.sp,
//                             color: const Color(0xFF475569),
//                             fontWeight: FontWeight.w500,
//                           ),
//                         ),
//                       ),
//                       const Icon(
//                         Icons.arrow_forward_ios,
//                         size: 14,
//                         color: Colors.blue,
//                       )
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           /// Close Bottom Button
//           Positioned(
//             bottom: 0,
//             child: GestureDetector(
//               onTap: () => Navigator.pop(context),
//               child: Container(
//                 height: 56.h,
//                 width: 56.w,
//                 decoration: BoxDecoration(
//                   shape: BoxShape.circle,
//                   color: AppColors.white,
//                   border: Border.all(
//                     color: const Color(0xFFE2E8F0), // Matching border ring
//                     width: 4,
//                   ),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black.withOpacity(0.1),
//                       blurRadius: 10,
//                       offset: const Offset(0, 4),
//                     )
//                   ],
//                 ),
//                 child: const Icon(
//                   Icons.close,
//                   color: Colors.blue,
//                   size: 24,
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// } 
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

// Ensure these point to your actual setup paths
// AppColors not required in this simplified popup
import 'package:ziya_laundry_deliveryapp/Constants/app_images.dart';

class NotificationPopupWidget extends StatelessWidget {
  final String title;       // e.g., "Notification for delivery test"
  final String message;     // e.g., "jhsdja"
  final String date;        // e.g., "May 16, 2026"
  final String time;        // e.g., "06:05 AM"

  const NotificationPopupWidget({
    super.key,
    required this.title,
    required this.message,
    required this.date,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Container(
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          color: Colors.white, // Or AppColors.white
          borderRadius: BorderRadius.circular(24.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 12.h),

            /// 1. Top Package Illustration with Blue Bell Badge
            Stack(
              alignment: Alignment.topRight,
              children: [
                Container(
                  height: 100.h,
                  width: 100.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFEBF2FE), // Light tint blue background
                  ),
                  child: Center(
                    child: Image.asset(
                      AppImages.iconPackage,
                      height: 50.h,
                      width: 50.w,
                      color: const Color(0xFF1D4ED8), // Deep blue icon lines
                    ),
                  ),
                ),
                Positioned(
                  top: 2.h,
                  right: 2.w,
                  child: Container(
                    padding: EdgeInsets.all(6.w),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF2563EB), // Vibrant blue badge
                    ),
                    child: Icon(
                      Icons.notifications,
                      color: Colors.white,
                      size: 14.sp,
                    ),
                  ),
                )
              ],
            ),

            SizedBox(height: 20.h),

            /// 2. Bold Title Text
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 20.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF0F172A), // Dark slate/black text
              ),
            ),

            SizedBox(height: 6.h),

            /// 3. Subtitle Message Text
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 15.sp,
                color: const Color(0xFF475569), // Slate gray text
                fontWeight: FontWeight.w400,
              ),
            ),

            SizedBox(height: 16.h),
            Divider(color: const Color(0xFFE2E8F0), thickness: 1.h),
            SizedBox(height: 16.h),

            /// 4. Date and Time Info Row
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.calendar_today_rounded, size: 18.sp, color: const Color(0xFF2563EB)),
                SizedBox(width: 8.w),
                Text(
                  date,
                  style: GoogleFonts.poppins(
                    fontSize: 14.sp,
                    color: const Color(0xFF1E293B),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Container(
                  height: 16.h,
                  width: 1.w,
                  color: const Color(0xFFCBD5E1),
                  margin: EdgeInsets.symmetric(horizontal: 16.w),
                ),
                Icon(Icons.access_time_rounded, size: 18.sp, color: const Color(0xFF2563EB)),
                SizedBox(width: 8.w),
                Text(
                  time,
                  style: GoogleFonts.poppins(
                    fontSize: 14.sp,
                    color: const Color(0xFF1E293B),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),

            SizedBox(height: 24.h),

            /// 5. Inner Delivery Status Custom Card
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF), // Soft light blue fill
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.all(10.w),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFFDBEAFE), // Darker circle background accent
                    ),
                    child: Image.asset(
                      AppImages.iconPackage,
                      height: 24.h,
                      width: 24.w,
                      color: const Color(0xFF1D4ED8),
                    ),
                  ),
                  SizedBox(width: 14.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Delivery Notification",
                          style: GoogleFonts.poppins(
                            fontSize: 14.sp,
                            color: const Color(0xFF0F172A),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          "Your delivery update is available.",
                          style: GoogleFonts.poppins(
                            fontSize: 13.sp,
                            color: const Color(0xFF475569),
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 24.h),

            /// 6. Main Action "Close" Button
            SizedBox(
              width: double.infinity,
              height: 48.h,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB), // Sharp primary blue
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: Text(
                  "Close",
                  style: GoogleFonts.poppins(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            SizedBox(height: 4.h),
          ],
        ),
      ),
    );
  }
}