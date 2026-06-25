
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:ziya_laundry_deliveryapp/Constants/app_colors.dart';
import 'package:ziya_laundry_deliveryapp/common_widget/AppToast.dart';
import 'package:ziya_laundry_deliveryapp/features/Home/data/model/home_models.dart';
import 'package:ziya_laundry_deliveryapp/features/Orders/viewmodel/order_viewmodel.dart';

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
  int _cooldownSeconds = 0;
  Timer? _timer;

  bool get _isCooldownActive => _cooldownSeconds > 0;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startCooldown() {
    _timer?.cancel();

    setState(() {
      _cooldownSeconds = 15;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (_cooldownSeconds <= 1) {
        timer.cancel();
        setState(() {
          _cooldownSeconds = 0;
        });
      } else {
        setState(() {
          _cooldownSeconds--;
        });
      }
    });
  }

  Future<void> _sendOtp(OrderViewModel orderVM) async {
    if (_isSendingOtp || _isCooldownActive || widget.otpVerified) return;

    setState(() {
      _isSendingOtp = true;
    });

    try {
      final success = await orderVM.sendDeliveryOtp(widget.orderId);

      if (success && mounted) {
        setState(() {
          _otpSent = true;
        });

        _startCooldown();

        AppToast.showOrderDelivered(context, orderId: widget.order.orderId);
      }
    } catch (e) {
      debugPrint("OTP send error: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isSendingOtp = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final orderVM = context.read<OrderViewModel>();

    final Color buttonColor = widget.otpVerified
        ? Colors.green
        : _isCooldownActive
            ? AppColors.grey
            : AppColors.primaryBlue;

    final String buttonText = widget.otpVerified
        ? "Verified"
        : _isCooldownActive
            ? "Wait ${_cooldownSeconds}s"
            : _otpSent
                ? "Resend OTP"
                : "Send OTP";

    final IconData buttonIcon = widget.otpVerified
        ? Icons.check
        : _otpSent
            ? Icons.refresh
            : Icons.send_outlined;

    return Row(
      children: [
        /// SEND OTP BUTTON
        Expanded(
          flex: 2,
          child: SizedBox(
            height: 38.h,
            child: ElevatedButton.icon(
              onPressed: (_isSendingOtp || _isCooldownActive || widget.otpVerified)
                  ? null
                  : () => _sendOtp(orderVM),
              style: ElevatedButton.styleFrom(
                backgroundColor: buttonColor,
                disabledBackgroundColor: buttonColor,
                disabledForegroundColor: Colors.white,
                elevation: 0,
                padding: EdgeInsets.symmetric(horizontal: 8.w),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
              icon: _isSendingOtp
                  ? LoadingAnimationWidget.waveDots(
                      color: Colors.white,
                      size: 14.sp,
                    )
                  : Icon(
                      buttonIcon,
                      size: 16.sp,
                      color: Colors.white,
                    ),
              label: Text(
                buttonText,
                style: GoogleFonts.poppins(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),

        SizedBox(width: 8.w),

        /// OTP INPUT
        Expanded(
          flex: 3,
          child: SizedBox(
            height: 38.h,
            child: TextField(
              controller: widget.otpController,
              keyboardType: TextInputType.number,
              maxLength: 4,
              textAlign: TextAlign.center,
              enabled: !widget.otpVerified,
              style: GoogleFonts.poppins(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                letterSpacing: 8,
              ),
              decoration: InputDecoration(
                counterText: "",
                hintText: "1 2 3 4",
                hintStyle: GoogleFonts.poppins(
                  fontSize: 14.sp,
                  color: Colors.black54,
                  letterSpacing: 8,
                ),
                filled: true,
                fillColor:
                    widget.otpVerified ? Colors.grey.shade100 : Colors.white,
                contentPadding: EdgeInsets.zero,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                  borderSide: const BorderSide(
                    color: Colors.black45,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                  borderSide: const BorderSide(
                    color: Colors.black45,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                  borderSide: BorderSide(
                    color: AppColors.primaryBlue,
                    width: 1.2,
                  ),
                ),
                disabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                  borderSide: BorderSide(
                    color: Colors.green.shade300,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}