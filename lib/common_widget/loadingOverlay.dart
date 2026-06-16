
// // import 'package:flutter/material.dart';
// // import 'package:flutter_screenutil/flutter_screenutil.dart';
// // import 'package:lottie/lottie.dart';
// // import 'package:ziya_laundry_deliveryapp/Constants/app_colors.dart';
// // import 'package:ziya_laundry_deliveryapp/Constants/app_images.dart';

// // class LoadingOverlay extends StatelessWidget {
// //   const LoadingOverlay({super.key});

// //   @override
// //   Widget build(BuildContext context) {
// //     return Container(
// //       child: Center(
// //         child: Container(
// //           width: 100.w,
// //           height: 100.h,
// //           decoration: BoxDecoration(
// //             color: AppColors.transparent,
// //             borderRadius: BorderRadius.circular(10.r),
// //           ),
// //           child: Lottie.asset(
// //             AppImages.loading,
// //             width: 50.w,
// //             height: 50.h,
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// // }
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:lottie/lottie.dart';
// import 'package:ziya_laundry_deliveryapp/Constants/app_colors.dart';
// import 'package:ziya_laundry_deliveryapp/Constants/app_images.dart';

// class LoadingOverlay extends StatelessWidget {
//   const LoadingOverlay({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       child: Center(
//         child: Container(
//           width: 100.w,
//           height: 100.h,
//           decoration: BoxDecoration(
//             color: AppColors.transparent,
//             borderRadius: BorderRadius.circular(10.r),
//           ),
//           child: Lottie.asset(
//             AppImages.loading,
//             width: 50.w,
//             height: 50.h,
//             errorBuilder: (context, error, stackTrace) {
//               return Center(
//                 child: CircularProgressIndicator(
//                   color: AppColors.primaryBlue,
//                   strokeWidth: 3.r,
//                 ),
//               );
//             },
//           ),
//         ),
//       ),
//     );
//   }
// }