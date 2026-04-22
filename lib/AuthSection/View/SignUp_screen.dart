

// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:provider/provider.dart';
// import 'package:ziya_laundry_deliveryapp/AuthSection/View/LogIn_screen.dart';
// import 'package:ziya_laundry_deliveryapp/Constants/quick_popup_manager.dart';
// import 'package:ziya_laundry_deliveryapp/Constants/app_colors.dart';
// import 'package:ziya_laundry_deliveryapp/Constants/app_text.dart';
// import 'package:ziya_laundry_deliveryapp/Constants/app_images.dart';
// import '../widgets/custom_button.dart';
// import '../viewmodel/signup_viewmodel.dart';
// import '../widgets/Reusable_inputfield.dart';
// import '../widgets/TopRightCurveClipper.dart';
// import '../widgets/gradient_logo.dart';

// class SignupScreen extends StatelessWidget {
//   const SignupScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       resizeToAvoidBottomInset: true,
//       backgroundColor: AppColors.bg,
//       body: SafeArea(
//         child: SingleChildScrollView(
//           physics: const ClampingScrollPhysics(),
//           child: Stack(
//             children: [
//               SizedBox(height: 1.sh, width: double.infinity),
//               /// 🔹 BACKGROUND IMAGE
//               Positioned(
//                 top: 0,
//                 left: 0,
//                 right: 0,
//                 height: 0.55.sh,
//                 child: Image.network(
//                   AppImages.signupBg,
//                   fit: BoxFit.cover,
//                 ),
//               ),

//               Column(
//                 children: [
//                   SizedBox(height: 0.33.sh),
//                   Stack(
//                     alignment: Alignment.topCenter,
//                     children: [
//                       Positioned(
//                         top: 0,
//                         left: 0,
//                         right: 0,
//                         child: ClipPath(
//                             clipper: TopRightCurveClipper(curveHeight: 150),
//                             child: Container(
//                               height: 0.50.sh,
//                               width: double.infinity,
//                               decoration: const BoxDecoration(
//                                   gradient: LinearGradient(
//                                     colors: [
//                                       AppColors.loginGradientStart,
//                                       AppColors.loginGradientEnd,
//                                     ],
//                                     begin: Alignment.topLeft,
//                                     end: Alignment.bottomRight,
//                                   )
//                               ),
//                             )
//                         ),
//                       ),

//                       /// 🔹 WHITE CARD
//                       Padding(
//                         padding: EdgeInsets.only(top: 0.05.sh),
//                         child: ClipPath(
//                           clipper: TopRightCurveClipper(),
//                           child: Container(
//                             width: double.infinity,
//                             padding: EdgeInsets.symmetric(
//                               horizontal: 24.w,
//                               vertical: 15.h,
//                             ),
//                             color: AppColors.white,
//                             child: Consumer<SignupViewModel>(
//                               builder: (context, vm, child) {
//                                 return Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   mainAxisSize: MainAxisSize.min,
//                                   children: [
//                                     Text(AppText.Wlcm,
//                                       style: GoogleFonts.poppins(
//                                         fontSize: 20.sp,
//                                         fontWeight: FontWeight.w600,
//                                       ),
//                                     ),
//                                     SizedBox(height: 10.h),
//                                     Text(
//                                       AppText.SignupMsg,
//                                       style: GoogleFonts.poppins(
//                                         fontSize: 14.sp,
//                                         fontWeight: FontWeight.w400,
//                                       ),
//                                     ),
//                                     SizedBox(height: 12.h),

//                                     // Form Fields
//                                     InputField(label: AppText.SignupNameLabel, hint: AppText.SignupNameHint, onChanged: vm.updateSignupName, errorText: vm.signupNameError),
//                                     InputField(label: AppText.LoginMobileLabel, hint: AppText.LoginMobileHint, onChanged: vm.updateSignupMobile, errorText: vm.signupMobileError),
//                                     InputField(label: AppText.LoginPasswordLabel, hint: AppText.PasswordHint, obscure: true, onChanged: vm.updateSignupPassword, errorText: vm.signupPasswordError),
//                                     InputField(label: AppText.NewPasswordConfirm, hint: AppText.PasswordHint, obscure: true, onChanged: vm.updateConfirmPassword, errorText: vm.confirmPasswordError),

//                                     // SizedBox(height: 10.h),
//                                     // Terms & Conditions
//                                     Row(
//                                       children: [
//                                         Checkbox(
//                                           value: vm.isAgreed,
//                                           activeColor: AppColors.primaryBlue,
//                                           onChanged: (v) => vm.toggleAgreement(v ?? false),
//                                         ),
//                                         SizedBox(width: 8.w),
//                                         Expanded(
//                                           child: Text(
//                                             AppText.TermsAndConditions,
//                                             style: GoogleFonts.poppins(
//                                               fontSize: 11.sp,
//                                               color: AppColors.grey,
//                                             ),
//                                             overflow: TextOverflow.ellipsis,
//                                           ),
//                                         ),
//                                       ],
//                                     ),

//                                     // SizedBox(height: 0.h),

//                                     CustomButton(
//                                       text: AppText.Button,
//                                       height: 48.h,
//                                       backgroundColor: AppColors.primaryBlue,
//                                       borderRadius: 12.r,
//                                      onPressed: () async {
//                                         if (await vm.submitSignup()) {
//                                           if (!context.mounted) return;
//                                           QuickPopupManager.showNotification(
//                                             context,
//                                             AppText.SignupSuccess,
//                                           );
//                                           Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
//                                         } else {
//                                           if (!context.mounted) return;
//                                           QuickPopupManager.showNotification(context, AppText.SignupError, isError: true);
//                                         }
//                                       },
//                                     ),

//                                     SizedBox(height: 12.h),
//                                     Row(
//                                       mainAxisAlignment: MainAxisAlignment.center,
//                                       children: [
//                                         Text(
//                                           AppText.HaveAccnt,
//                                           style: GoogleFonts.poppins(
//                                             fontSize: 13.sp,
//                                           ),
//                                         ),
//                                         GestureDetector(
//                                           onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginScreen())),
//                                           child: Text(
//                                             AppText.LoginLink,
//                                             style: GoogleFonts.poppins(
//                                               fontSize: 13.sp,
//                                               color: AppColors.primaryBlue,
//                                               fontWeight: FontWeight.bold,
//                                             ),
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   ],
//                                 );
//                               },
//                             ),
//                           ),
//                         ),
//                       ),

//                       Padding(
//                         padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
//                         child: GradientLogo(),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }