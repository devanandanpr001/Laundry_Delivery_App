// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:provider/provider.dart';
// import 'package:ziya_laundry_deliveryapp/Constants/app_colors.dart';
// import 'package:ziya_laundry_deliveryapp/Constants/app_strings.dart';
// import 'package:ziya_laundry_deliveryapp/common_widget/AppToast.dart';
// import 'package:ziya_laundry_deliveryapp/features/AuthSection/View/LogIn_screen.dart';
// import 'package:ziya_laundry_deliveryapp/features/AuthSection/viewmodel/SignUp_viewmodel.dart';
// import 'package:ziya_laundry_deliveryapp/features/AuthSection/widgets/app_checkbox.dart';
// import 'package:ziya_laundry_deliveryapp/features/AuthSection/widgets/custom_button.dart';
// import 'package:ziya_laundry_deliveryapp/features/AuthSection/widgets/Reusable_inputfield.dart';

// class SignUpScreen extends StatefulWidget {
//   const SignUpScreen({super.key});

//   @override
//   State<SignUpScreen> createState() => _SignUpScreenState();
// }

// class _SignUpScreenState extends State<SignUpScreen> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       resizeToAvoidBottomInset: true,
//       backgroundColor: AppColors.white,
//       body: SafeArea(
//         child: SingleChildScrollView(
//           physics: const ClampingScrollPhysics(),
//           child: Padding(
//             padding: EdgeInsets.symmetric(horizontal: 24.w),
//             child: Consumer<SignupViewModel>(
//               builder: (_, vm, __) {
//                 return Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     SizedBox(height: 60.h),
//                     Text(
//                       AppText.Wlcm,
//                       style: GoogleFonts.poppins(
//                         fontSize: 24.sp,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                     SizedBox(height: 8.h),
//                     Text(
//                       AppText.SignupMsg,
//                       style: GoogleFonts.poppins(
//                         fontSize: 14.sp,
//                         color: AppColors.grey,
//                         fontWeight: FontWeight.w400,
//                       ),
//                     ),
//                     SizedBox(height: 30.h),
//                     InputField(
//                       label: AppText.SignupNameLabel,
//                       hint: AppText.SignupNameHint,
//                       controller: TextEditingController(text: vm.signupName),
//                       onChanged: (v) => vm.updateSignupName(v),
//                       errorText: vm.signupNameError,
//                     ),
//                     SizedBox(height: 16.h),
//                     InputField(
//                       label: 'Mobile Number',
//                       hint: 'Enter mobile number',
//                       controller: TextEditingController(text: vm.signupMobile),
//                       onChanged: (v) => vm.updateSignupMobile(v),
//                       errorText: vm.signupMobileError,
//                     ),
//                     SizedBox(height: 16.h),
//                     InputField(
//                       label: 'Password',
//                       hint: AppText.PasswordHint,
//                       obscure: true,
//                       controller: TextEditingController(text: vm.signupPassword),
//                       onChanged: (v) => vm.updateSignupPassword(v),
//                       errorText: vm.signupPasswordError,
//                     ),
//                     SizedBox(height: 16.h),
//                     InputField(
//                       label: 'Confirm Password',
//                       hint: AppText.PasswordHint,
//                       obscure: true,
//                       controller: TextEditingController(text: vm.signupConfirmPassword),
//                       onChanged: (v) => vm.updateConfirmPassword(v),
//                       errorText: vm.confirmPasswordError,
//                     ),
//                     SizedBox(height: 20.h),
//                     Row(
//                       children: [
//                         AppCheckbox(
//                           value: vm.isAgreed,
//                           onChanged: (v) => vm.toggleAgreement(v ?? false),
//                         ),
//                         SizedBox(width: 8.w),
//                         Expanded(
//                           child: Text(
//                             AppText.TermsAndConditions,
//                             style: GoogleFonts.poppins(
//                               fontSize: 12.sp,
//                               color: AppColors.black,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                     if (vm.agreementError != null) ...[
//                       SizedBox(height: 4.h),
//                       Padding(
//                         padding: EdgeInsets.only(left: 6.w),
//                         child: Text(
//                           vm.agreementError!,
//                           style: TextStyle(
//                             fontSize: 11.5.sp,
//                             color: AppColors.errorRed,
//                             fontWeight: FontWeight.w500,
//                           ),
//                         ),
//                       ),
//                     ],
//                     SizedBox(height: 30.h),
//                     CustomButton(
//                       text: AppText.Button,
//                       loading: vm.isLoading,
//                       onPressed: vm.isLoading
//                           ? () {}
//                           : () async {
//                               if (await vm.submitSignup()) {
//                                 if (!context.mounted) return;
//                                 AppToast.showSignupSuccess(context);
//                                 Navigator.push(
//                                   context,
//                                   MaterialPageRoute(
//                                     settings: const RouteSettings(name: '/login'),
//                                     builder: (context) => const LoginScreen(),
//                                   ),
//                                 );
//                               } else if (context.mounted) {
//                                 AppToast.showSignupFailed(context, error: vm.errorMessage);
//                               }
//                             },
//                     ),
//                     SizedBox(height: 20.h),
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Text(
//                           AppText.HaveAccnt,
//                           style: GoogleFonts.poppins(
//                             fontSize: 12.sp,
//                             color: AppColors.grey,
//                           ),
//                         ),
//                         GestureDetector(
//                           onTap: () {
//                             Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                 settings: const RouteSettings(name: '/login'),
//                                 builder: (context) => const LoginScreen(),
//                               ),
//                             );
//                           },
//                           child: Text(
//                             AppText.LoginLink,
//                             style: GoogleFonts.poppins(
//                               fontSize: 12.sp,
//                               color: AppColors.linkBlue,
//                               fontWeight: FontWeight.w500,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                     SizedBox(height: 40.h),
//                   ],
//                 );
//               },
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }