import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ziya_laundry_deliveryapp/core/Constants/app_colors.dart';
import 'package:ziya_laundry_deliveryapp/core/Constants/app_images.dart';
import 'package:ziya_laundry_deliveryapp/features/Home/data/model/home_models.dart';

class OrderPaymentInfo extends StatelessWidget {
  final OrderModel order;
  final bool isPending;
  final bool isPaid;

  const OrderPaymentInfo({
    super.key,
    required this.order,
    required this.isPending,
    required this.isPaid,
  });

  @override
  Widget build(BuildContext context) {
    final double totalAmount = double.tryParse(order.totalAmount) ?? 0.0;
    final double paidAmount = double.tryParse(order.paidAmount) ?? 0.0;
    final double payableAmount = double.tryParse(order.payableAmount) ?? 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 5.h),
        Container(
          margin: EdgeInsets.symmetric(vertical: 4.h),
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: AppColors.lightBackground,
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(color: AppColors.grey.withOpacity(0.2)),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Image.asset(AppImages.iconPay, height: 20.h, width: 20.w, color: AppColors.primaryBlue),
                      SizedBox(width: 10.w),
                      Text(
                        order.paymentMethod == "ONLINE" ? "Online Payment" : "Cash on Delivery",
                        style: GoogleFonts.poppins(fontSize: 13.sp, fontWeight: FontWeight.w500, color: AppColors.textDark),
                      ),
                    ],
                  ),
                  Text(
                    "₹ ${totalAmount.toStringAsFixed(2)}",
                    style: GoogleFonts.poppins(fontSize: 14.sp, fontWeight: FontWeight.w700, color: AppColors.primaryBlue),
                  ),
                ],
              ),
              Divider(height: 16.h, thickness: 0.5),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.check_circle_outline, color: AppColors.green, size: 14.sp),
                      SizedBox(width: 8.w),
                      Text("Advance Amt", style: GoogleFonts.poppins(fontSize: 12.sp, fontWeight: FontWeight.w600, color: AppColors.green)),
                    ],
                  ),
                  Text("₹ ${paidAmount.toStringAsFixed(2)}", style: GoogleFonts.poppins(fontSize: 12.sp, fontWeight: FontWeight.w600, color: AppColors.green)),
                ],
              ),
              SizedBox(height: 6.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        payableAmount > 0 ? Icons.error_outline : Icons.check_circle,
                        color: payableAmount > 0 ? AppColors.errorRed : AppColors.green,
                        size: 14.sp,
                      ),
                      SizedBox(width: 8.w),
                      Text("Balance Amt", style: GoogleFonts.poppins(fontSize: 12.sp, fontWeight: FontWeight.w600, color: payableAmount > 0 ? AppColors.errorRed : AppColors.green)),
                    ],
                  ),
                  Text(
                    "₹ ${payableAmount.toStringAsFixed(2)}",
                    style: GoogleFonts.poppins(fontSize: 13.sp, fontWeight: FontWeight.w700, color: payableAmount > 0 ? AppColors.errorRed : AppColors.green),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}