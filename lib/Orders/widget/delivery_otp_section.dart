import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:ziya_laundry_deliveryapp/core/Constants/app_colors.dart';
import 'package:ziya_laundry_deliveryapp/core/Constants/app_strings.dart';
import 'package:ziya_laundry_deliveryapp/common_widget/AppToast.dart';
import 'package:ziya_laundry_deliveryapp/Home/data/model/home_models.dart';
import 'package:ziya_laundry_deliveryapp/Orders/viewmodel/order_viewmodel.dart';

class DeliveryOtpSection extends StatefulWidget {
  final OrderModel order;
  final String orderId;
  final TextEditingController otpController;
  final bool otpVerified;
  final Function(bool) onOtpVerifiedChanged;

  const DeliveryOtpSection({
    super.key,
    required this.order,
    required this.orderId,
    required this.otpController,
    required this.otpVerified,
    required this.onOtpVerifiedChanged,
  });

  @override
  State<DeliveryOtpSection> createState() => _DeliveryOtpSectionState();
}

class _DeliveryOtpSectionState extends State<DeliveryOtpSection> {
  bool _otpSent = false;
  bool _isSendingOtp = false;

  @override
  Widget build(BuildContext context) {
    final orderVM = context.read<OrderViewModel>();
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 8.h),
          child: Row(
            children: [
              Icon(
                widget.otpVerified ? Icons.check_circle_outline : Icons.textsms_outlined,
                color: widget.otpVerified ? AppColors.green : AppColors.primaryBlue,
                size: 20.sp,
              ),
              SizedBox(width: 8.w),
              Text(
                widget.otpVerified ? "OTP Verified" : (_otpSent ? "Resend OTP" : "Send OTP"),
                style: GoogleFonts.poppins(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: widget.otpVerified ? AppColors.green : AppColors.primaryBlue,
                ),
              ),
              if (!widget.otpVerified) ...[
                const Spacer(),
                SizedBox(
                  width: 133.w,
                  height: 32.h,
                  child: ElevatedButton(
                    onPressed: _isSendingOtp ? null : () async {
                      setState(() => _isSendingOtp = true);
                      try {
                        final success = await orderVM.sendDeliveryOtp(widget.orderId);
                        if (success && mounted) {
                          setState(() => _otpSent = true);
                          if (!context.mounted) return;
                          AppToast.showSuccess(
                            title: "Success",
                            message: AppText.OtpSentSuccess,
                          );
                        }
                      } finally {
                        if (mounted) setState(() => _isSendingOtp = false);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF9E9F9F),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                      padding: EdgeInsets.all(8.w),
                    ),
                    child: _isSendingOtp
                        ? LoadingAnimationWidget.waveDots(color: Colors.white, size: 14.sp)
                        : Text(_otpSent ? "Resend" : "Send", style: GoogleFonts.poppins(fontSize: 12.sp, color: Colors.white, fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ],
          ),
        ),
        if (_otpSent && !widget.otpVerified)
          Padding(
            padding: EdgeInsets.only(top: 8.h, bottom: 8.h),
            child: SizedBox(
              width: 166.79.w,
              height: 32.h,
              child: TextField(
                controller: widget.otpController,
                keyboardType: TextInputType.number,
                maxLength: 4,
                decoration: InputDecoration(
                  isDense: true,
                  hintText: "Enter 4 digit OTP",
                  counterText: "",
                  hintStyle: GoogleFonts.poppins(fontSize: 12.sp, color: AppColors.grey),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r), borderSide: const BorderSide(color: Color(0xFF000000), width: 1.0)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r), borderSide: const BorderSide(color: Color(0xFF000000), width: 1.0)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r), borderSide: const BorderSide(color: Color(0xFF000000), width: 1.0)),
                  contentPadding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
                ),
                style: GoogleFonts.poppins(fontSize: 13.sp),
              ),
            ),
          ),
        Divider(color: AppColors.grey.withOpacity(0.5)),
      ],
    );
  }
}