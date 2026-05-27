import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:ziya_laundry_deliveryapp/core/validators/Validators.dart';
import 'package:ziya_laundry_deliveryapp/core/Constants/app_colors.dart';
import 'package:ziya_laundry_deliveryapp/core/Constants/app_strings.dart';
import 'package:ziya_laundry_deliveryapp/common_widget/AppToast.dart';
import 'package:ziya_laundry_deliveryapp/features/AuthSection/View/LogIn_screen.dart';
import 'package:ziya_laundry_deliveryapp/features/AuthSection/viewmodel/forgot_password_viewmodel.dart';
import 'package:ziya_laundry_deliveryapp/features/AuthSection/widgets/custom_button.dart';

class NewPasswordScreen extends StatefulWidget {
  final String phone;
  const NewPasswordScreen({super.key, required this.phone});

  @override
  State<NewPasswordScreen> createState() => _NewPasswordScreenState();
}

class _NewPasswordScreenState extends State<NewPasswordScreen> {
  bool _isNewPasswordObscured = true;
  bool _isConfirmPasswordObscured = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: AppColors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: AppColors.black,
            size: 20.sp,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer<ForgotPasswordViewModel>(
        builder: (context, provider, child) => SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 35.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 40.h),
                Text(
                  AppText.NewPasswordTitle,
                  style: TextStyle(
                    color: AppColors.textDark,
                    fontSize: 18.sp,
                    fontFamily: GoogleFonts.roboto().fontFamily,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 60.h),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppText.NewPasswordEnter,
                      style: TextStyle(
                        color: AppColors.black,
                        fontSize: 14.sp,
                        fontFamily: GoogleFonts.roboto().fontFamily,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    TextFormField(
                      controller: provider.newPasswordController,
                      obscureText: _isNewPasswordObscured,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontFamily: GoogleFonts.roboto().fontFamily,
                      ),
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 15.w,
                          vertical: 12.h,
                        ),
                        hintText: AppText.NewPasswordHint,
                        hintStyle: TextStyle(
                          color: AppColors.hintGrey,
                          fontSize: 14.sp,
                          fontFamily: GoogleFonts.roboto().fontFamily,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.r),
                          borderSide: BorderSide(color: AppColors.borderGreen),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.r),
                          borderSide: BorderSide(color: AppColors.borderGreen),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.r),
                          borderSide: BorderSide(
                            color: AppColors.borderGreen,
                            width: 1.5,
                          ),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.r),
                          borderSide: BorderSide(color: AppColors.red),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.r),
                          borderSide: BorderSide(
                            color: AppColors.red,
                            width: 2,
                          ),
                        ),
                        suffixIcon: GestureDetector(
                          onTapDown: (_) =>
                              setState(() => _isNewPasswordObscured = false),
                          onTapUp: (_) =>
                              setState(() => _isNewPasswordObscured = true),
                          onTapCancel: () =>
                              setState(() => _isNewPasswordObscured = true),
                          child: Icon(
                            _isNewPasswordObscured
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: AppColors.grey,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 25.h),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppText.NewPasswordConfirm,
                      style: TextStyle(
                        color: AppColors.black,
                        fontSize: 14.sp,
                        fontFamily: GoogleFonts.roboto().fontFamily,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    TextFormField(
                      controller: provider.confirmPasswordController,
                      obscureText: _isConfirmPasswordObscured,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontFamily: GoogleFonts.roboto().fontFamily,
                      ),
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 15.w,
                          vertical: 12.h,
                        ),
                        hintText: AppText.PasswordHint,
                        hintStyle: TextStyle(
                          color: AppColors.hintGrey,
                          fontSize: 14.sp,
                          fontFamily: GoogleFonts.roboto().fontFamily,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.r),
                          borderSide: BorderSide(color: AppColors.borderGreen),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.r),
                          borderSide: BorderSide(color: AppColors.borderGreen),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.r),
                          borderSide: BorderSide(
                            color: AppColors.borderGreen,
                            width: 1.5,
                          ),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.r),
                          borderSide: BorderSide(color: AppColors.red),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.r),
                          borderSide: BorderSide(
                            color: AppColors.red,
                            width: 2,
                          ),
                        ),
                        suffixIcon: GestureDetector(
                          onTapDown: (_) => setState(
                            () => _isConfirmPasswordObscured = false,
                          ),
                          onTapUp: (_) =>
                              setState(() => _isConfirmPasswordObscured = true),
                          onTapCancel: () =>
                              setState(() => _isConfirmPasswordObscured = true),
                          child: Icon(
                            _isConfirmPasswordObscured
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: AppColors.grey,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 52.h),
                _buildSubmitButton(
                  isLoading: provider.isLoading,
                  onPressed: () async {
                    // 1. Validate Empty
                    final passErr = Validators.validatePassword(
                      provider.newPasswordController.text,
                    );
                    final confErr = Validators.validateConfirmPassword(
                      provider.newPasswordController.text,
                      provider.confirmPasswordController.text,
                    );

                    if (passErr != null || confErr != null) {
                      AppToast.showError(
                        message: passErr ?? confErr!,
                        title: 'Error',
                      );
                      return;
                    }

                    if (await provider.submitReset(widget.phone)) {
                      if (!context.mounted) return;
                      AppToast.showSuccess(
                        message: AppText.NewPasswordSuccess,
                        title: 'Success',
                      );

                      Future.delayed(const Duration(seconds: 2), () {
                        if (context.mounted) {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              settings: const RouteSettings(name: '/login'),
                              builder: (context) => const LoginScreen(),
                            ),
                            (route) => false,
                          );
                        }
                      });
                    } else if (context.mounted) {
                      AppToast.showError(
                        message:
                            provider.errorMessage ?? "Failed to reset password",
                        title: 'Error',
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitButton({
    required VoidCallback onPressed,
    bool isLoading = false,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 4.r,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
        ],
      ),
      child: CustomButton(
        text: AppText.SubmitButton,
        onPressed: isLoading ? () {} : onPressed,
        height: 48.h,
        elevation: 0,
        borderRadius: 10.r,
        fontFamily: GoogleFonts.roboto().fontFamily,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
