// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:google_fonts/google_fonts.dart';

// class TodaysEarningsCard extends StatelessWidget {
//   final String amount;

//   const TodaysEarningsCard({super.key, required this.amount});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: double.infinity,
//       height: 109.w,
//       decoration: BoxDecoration(
//         color: const Color(0xFFF5B771),
//         borderRadius: BorderRadius.circular(16.w),
//       ),
//       child: Padding(
//         padding: EdgeInsets.symmetric(horizontal: 20.w),
//         child: Row(
//           children: [
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Text(
//                     "Today’s Earnings",
//                     maxLines: 1,
//                     overflow: TextOverflow.ellipsis,
//                     style: GoogleFonts.poppins(
//                       fontSize: 14.sp,
//                       fontWeight: FontWeight.w400,
//                       color: Colors.white,
//                     ),
//                   ),
//                   Text(
//                     amount,
//                     maxLines: 1,
//                     overflow: TextOverflow.ellipsis,
//                     style: GoogleFonts.poppins(
//                       fontSize: 40.sp,
//                       fontWeight: FontWeight.w500,
//                       color: Colors.white,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             SizedBox(width: 10.w),
//             Image.asset('assets/icons/ph_coin-light.png', height: 75.w, width: 75.w),
//           ],
//         ),
//       ),
//     );
//   }
// }