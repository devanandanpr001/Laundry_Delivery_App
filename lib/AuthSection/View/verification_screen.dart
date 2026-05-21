
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ziya_laundry_deliveryapp/Constants/quick_popup_manager.dart';
import 'package:ziya_laundry_deliveryapp/Constants/app_colors.dart';
import 'package:ziya_laundry_deliveryapp/Constants/app_text.dart';
import 'package:ziya_laundry_deliveryapp/common_widgets/AppToast.dart';

class VerificationScreen extends StatefulWidget {
  final String title;
  final String subtitle;
  final Future<dynamic> Function(String pin) onCompleted;
  final VoidCallback onResend;

  const VerificationScreen({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onCompleted,
    required this.onResend,
  });

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  late final TextEditingController _pinController;
  final FocusNode _focusNode = FocusNode();
  Timer? _timer;
  int _start = 60;
  bool _isTimerActive = true;
  bool _isLoading = false;
  String? _error;

  void startTimer() {
    _start = 60;
    _isTimerActive = true;
    _timer?.cancel();
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (Timer timer) {
        if (!mounted) return timer.cancel();
        if (_start == 0) {
          setState(() {
            timer.cancel();
            _isTimerActive = false;
          });
        } else {
          setState(() => _start--);
        }
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _pinController = TextEditingController();
    startTimer();
  }

  @override
  void dispose() {
    _pinController.dispose();
    _focusNode.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.black, size: 24.sp),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 30.w),
          child: Column(
            children: [
              SizedBox(height: 40.h),
              Text(
                widget.title,
                style: TextStyle(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.bold,
                  fontFamily: GoogleFonts.poppins().fontFamily,
                  color: AppColors.textBlack,
                ),
              ),
              SizedBox(height: 12.h),
              Text(
                widget.subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.textGrey,
                  fontFamily: GoogleFonts.poppins().fontFamily,
                  height: 1.5,
                ),
              ),
              SizedBox(height: 50.h),
              Stack(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(4, (index) {
                      Color borderColor = AppColors.borderColorBlue;

                      // Show red border if there is an error
                      if (_error != null) {
                        borderColor = AppColors.red;
                      }

                      return Container(
                        width: 55.w,
                        height: 55.w,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.r),
                          border: Border.all(color: borderColor, width: 1.5.r),
                        ),
                        child: Text(
                          index < _pinController.text.length ? '*' : '',
                          style: TextStyle(
                            fontSize: 24.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryBlue,
                          ),
                        ),
                      );
                    }),
                  ),
                  Positioned.fill(
                    child: TextField(
                      controller: _pinController,
                      focusNode: _focusNode,
                      maxLength: 4,
                      keyboardType: TextInputType.number,
                      showCursor: false,
                      enableSuggestions: false,
                      autocorrect: false,
                      enabled: !_isLoading,
                      decoration: const InputDecoration(
                        counterText: "",
                        border: OutlineInputBorder(borderSide: BorderSide.none),
                        fillColor: AppColors.transparent,
                        filled: true,
                      ),
                      style: const TextStyle(color: AppColors.transparent),
                      onChanged: (value) {
                        // Update the UI to show '*' for entered digits
                        // and clear any previous error state.
                        setState(() {
                          _error = null;
                        });

                        if (value.length == 4) {
                          setState(() => _isLoading = true);
                          
                          // Ensure we treat the result as a boolean
                          widget.onCompleted(value).then((dynamic result) async {
                            if (!mounted) return;
                            
                            // Explicitly check for true to avoid Map vs Bool type issues
                            final bool isVerified = result == true;

                            if (isVerified) {
                              setState(() {
                                _isLoading = false;
                              });
                              _focusNode.unfocus();
                              // Signal success to the calling screen so it can navigate to ResetPasswordScreen
                              Navigator.pop(context, true);
                            } else {
                              // If verification fails, show red borders and then clear.
                              setState(() {
                                _isLoading = false;
                                _error = AppText.InvalidOtp;
                              });
                              // A delay to allow the user to see the red borders.
                              await Future.delayed(const Duration(seconds: 1));
                              if (mounted) {
                                _pinController.clear();
                                _focusNode.requestFocus();
                              }
                            }
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 40.h),
              if (_isLoading)
                LoadingAnimationWidget.waveDots(
                  color: Theme.of(context).primaryColor,
                  size: 50.h,
                )
              else if (_error != null)
                Text(
                  _error!,
                  style: TextStyle(color: AppColors.red, fontSize: 14.sp),
                  textAlign: TextAlign.center,
                )
              else
                SizedBox(height: 24.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_isTimerActive)
                    Text(
                      '${AppText.WaitText}${_start.toString().padLeft(2, '0')} ',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppColors.darkGrey,
                        fontFamily: GoogleFonts.poppins().fontFamily,
                      ),
                    ),
                  GestureDetector(
                    onTap: (_isLoading || _isTimerActive)
                        ? null
                        : () {
                            widget.onResend();
                            AppToast.showSuccess(
                              message: AppText.OtpSentSuccess, title: 'success',
                            );
                            startTimer();
                          },
                    child: Text(
                      AppText.ResendOtp,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: (_isLoading || _isTimerActive) ? AppColors.grey : AppColors.resendGreen,
                        fontFamily: GoogleFonts.poppins().fontFamily,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
