
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:ziya_laundry_deliveryapp/common_widget/AppToast.dart';
import 'package:ziya_laundry_deliveryapp/features/AuthSection/View/NewPassword.dart';
import 'package:ziya_laundry_deliveryapp/features/AuthSection/View/verification_screen.dart';
import 'package:ziya_laundry_deliveryapp/features/AuthSection/viewmodel/forgot_password_viewmodel.dart';
import 'package:ziya_laundry_deliveryapp/features/AuthSection/widgets/custom_button.dart';
import 'package:ziya_laundry_deliveryapp/Constants/app_colors.dart';
import 'package:ziya_laundry_deliveryapp/Constants/app_strings.dart';

class ForgotPassword extends StatelessWidget {
  const ForgotPassword({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: AppColors.bg,
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 35.w),
              child: Consumer<ForgotPasswordViewModel>(
                builder: (context, provider, child) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: 20.h),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: Icon(Icons.arrow_back, size: 22.sp),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),

                      SizedBox(height: 20.h),
                      Text(
                        AppText.Frgt,
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w500,
                          fontFamily: GoogleFonts.roboto().fontFamily,
                          color: AppColors.black,
                        ),
                      ),

                      SizedBox(height: 60.h),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          AppText.FrgtPhoneLabel,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            fontFamily: GoogleFonts.roboto().fontFamily,
                            color: AppColors.black,
                          ),
                        ),
                      ),

                      SizedBox(height: 10.h),
                      TextField(
                        controller: provider.mobileController,
                        keyboardType: TextInputType.phone,
                        style: TextStyle(fontSize: 14.sp),
                        decoration: InputDecoration(
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 12.h,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.r),
                            borderSide: const BorderSide(color: AppColors.borderGreen),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.r),
                            borderSide: const BorderSide(color: AppColors.borderGreen),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.r),
                            borderSide: const BorderSide(color: AppColors.borderGreen),
                          ),
                        ),
                      ),
                      SizedBox(height: 25.h),
                     /// Back to Sign in
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child:  Text(
                          AppText.FrgtBackSignIn,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: AppColors.linkBlue,
                            fontFamily: GoogleFonts.roboto().fontFamily,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),

                      SizedBox(height: 30.h),

                      CustomButton(
                        text: AppText.FrgtGetOtp,
                        height: 40.h,
                        borderRadius: 10.r,
                        backgroundColor: AppColors.primaryBlue,
                        fontFamily: GoogleFonts.roboto().fontFamily,
                        onPressed: provider.isLoading
                            ? () {}
                            : () async {
                                final success = await provider.sendOtp();
                                if (success && context.mounted) {
                                  final verified = await Navigator.push<bool>(
                                    context,
                                    MaterialPageRoute(
                                      settings: const RouteSettings(name: '/verification'),
                                      builder: (context) => VerificationScreen(
                                        title: AppText.VrfTitle,
                                        subtitle: AppText.VrfSubtitle,
                                        onCompleted: (pin) async => await provider.verifyOtp(pin),
                                        onResend: () => provider.resendOtp(),
                                      ),
                                    ),
                                  );

                                  if (verified == true && context.mounted) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        settings: const RouteSettings(name: '/new-password'),
                                        builder: (context) => NewPasswordScreen(
                                          phone: provider.mobileController.text,
                                        ),
                                      ),
                                    );
                                  }
                                } else if (context.mounted) {
                                  AppToast.showError(
                                 
                                    title: "Error",
                                    message: AppText.FrgtValidPhone,
                                  );
                                }
                              },
                      )
                    ],
                  );
                },
              ),
            ),
          ),
        ),
    );
  }
}