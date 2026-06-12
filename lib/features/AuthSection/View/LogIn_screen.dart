
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:ziya_laundry_deliveryapp/Constants/app_colors.dart';
import 'package:ziya_laundry_deliveryapp/common_widget/AppToast.dart';
import 'package:ziya_laundry_deliveryapp/Constants/app_strings.dart';
import 'package:ziya_laundry_deliveryapp/Constants/app_images.dart';
import 'package:ziya_laundry_deliveryapp/BottomNavigation/bottom_navigation_page.dart';
import 'package:ziya_laundry_deliveryapp/core/widgets/app_network_image.dart';
import 'package:ziya_laundry_deliveryapp/features/AuthSection/View/forgot_password_screen.dart';
import 'package:ziya_laundry_deliveryapp/features/AuthSection/View/verification_screen.dart';
import '../widgets/custom_button.dart';
import '../viewmodel/login_viewmodel.dart';
import '../widgets/Reusable_inputfield.dart';
import '../widgets/TopRightCurveClipper.dart';
import '../widgets/gradient_logo.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}
class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Stack(
                children: [
                  SizedBox(height: 1.sh, width: double.infinity),
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    height: 0.55.sh,
                    child: AppNetworkImage(
                      imageUrl: AppImages.loginBg,
                      width: double.infinity,
                      height: 0.55.sh,
                      fit: BoxFit.cover,
                      placeholder: Container(color: AppColors.loginGradientStart),
                      errorWidget: Container(color: AppColors.loginGradientEnd),
                    ),
                  ),

                  
                  Column(
                    children: [
                      SizedBox(height: 0.33.sh),
                      Stack(
                        alignment: Alignment.topCenter,
                        children: [
                          Positioned(
                            top: 0,
                            left: 0,
                            right: 0,
                            child: ClipPath(
                                clipper: TopRightCurveClipper(curveHeight: 150),
                                child: Container(
                                  height: 0.50.sh,
                                  width: double.infinity,
                                  decoration: const BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [AppColors.loginGradientStart, AppColors.loginGradientEnd],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,)
                                  ),
                                )
                            ),
                          ),

                          /// 🔹 WHITE CARD
                          Padding(
                            padding: EdgeInsets.only(top: 0.05.sh),
                            child: ClipPath(
                              clipper: TopRightCurveClipper(),
                              child: Container(
                                width: double.infinity,
                                padding: EdgeInsets.symmetric(
                                  horizontal: 24.w,
                                  vertical: 28.h,
                                ),
                                color: AppColors.white,
                                child: Consumer<LoginViewModel>(
                                  builder: (_, vm, __) {
                                    return Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(AppText.WlcmBack,
                                          style: GoogleFonts.poppins(
                                            fontSize: 20.sp,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        SizedBox(height: 20.h),
                                        InputField(
                                          label: AppText.LoginNameLabel,
                                          hint: AppText.LoginNameHint,
                                          controller: vm.nameController,
                                          // onChanged: vm.updateLoginName, // Controller handles updates
                                          errorText: vm.loginNameError,
                                        ),
                                        InputField(
                                          label: AppText.LoginMobileLabel,
                                          hint: AppText.LoginMobileHint,
                                          controller: vm.mobileController,
                                          // onChanged: vm.updateLoginMobile, // Controller handles updates
                                          errorText: vm.loginMobileError,
                                        ),

                                        InputField(
                                          label: AppText.LoginPasswordLabel,
                                          hint: AppText.PasswordHint,
                                          obscure: true,
                                          controller: vm.passwordController,
                                          // onChanged: vm.updateLoginPassword, // Controller handles updates
                                          errorText: vm.loginPasswordError,
                                        ),
                                        SizedBox(height: 10.h),
                                        Row(
                                          children: [
                                            Transform.scale(
                                              scale: 1.25,
                                              child: Checkbox(
                                                value: vm.isRememberMe,
                                                onChanged: (v) => vm.toggleRememberMe(v ?? false),
                                              ),
                                            ),
                                            Text(
                                              AppText.RememberMe,
                                              style: GoogleFonts.poppins(fontSize: 12.sp),
                                            ),
                                            const Spacer(),
                                            GestureDetector(
                                              onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                settings: const RouteSettings(name: '/forgot-password'),
                                                builder: (context) => const ForgotPassword(),
                                              ),
                                            );
                                              },
                                              child: Text(AppText.Frgt,
                                                style: GoogleFonts.poppins(
                                                  fontSize: 12.sp,
                                                  color: AppColors.linkBlue,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),

                                        SizedBox(height: 20.h),

                                        CustomButton(
                                          text: AppText.Buttn,
                                          height: 48.h,
                                          borderRadius: 12.r,
                                          backgroundColor: AppColors.primaryBlue,
                                          onPressed: vm.isLoading ? () {} : () async {
                                            if (await vm.submitLogin()) {
                                              if (!context.mounted) return;
                                              final verified = await Navigator.push<bool>(
                                                context,
                                                MaterialPageRoute(
                                                  settings: const RouteSettings(name: '/verification'),
                                                  builder: (context) => VerificationScreen(
                                                    title: AppText.VrfTitle,
                                                    subtitle: AppText.VrfSubtitle,
                                                    onCompleted: (pin) async => await vm.verifyOtp(pin),
                                                    onResend: () => vm.resendOtp(),
                                                  ),
                                                ),
                                              );

                                              if (verified == true && context.mounted) {
                                                AppToast.showSuccess(
                                                  title: "Success",
                                                  message: AppText.LoginSuccess, 
                                                );
                                                Navigator.pushAndRemoveUntil(
                                                  context,
                                                  MaterialPageRoute(
                                                      settings: const RouteSettings(name: '/home'),
                                                      builder: (context) => const BottomNavigationPage()),
                                                  (route) => false,
                                                );
                                              }
                                            } else {
                                              if (!context.mounted) return;
                                              AppToast.showError(
                                                title: "Login Failed",
                                                message: vm.errorMessage ?? "Please check your credentials",
                                              );
                                            }
                                          },
                                        ),
                                        SizedBox(height: 12.h),
                                 
                                      ],
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),

                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
                            child: GradientLogo(),
                          ),
                        ],
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
  }
}
