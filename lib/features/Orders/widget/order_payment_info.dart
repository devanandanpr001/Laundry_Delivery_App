import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ziya_laundry_deliveryapp/Constants/app_colors.dart';
import 'package:ziya_laundry_deliveryapp/Constants/app_images.dart';
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

    return Container(
      margin: EdgeInsets.only(top: 4.h, bottom: 8.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(6.r),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Image.asset(AppImages.iconPay, height: 16.h, width: 16.w, color: AppColors.primaryBlue),
                  ),
                  SizedBox(width: 10.w),
                  Text(
                    order.paymentMethod == "ONLINE" ? "Online Payment" : "Cash on Delivery",
                    style: GoogleFonts.poppins(fontSize: 13.sp, fontWeight: FontWeight.w600, color: const Color(0xFF2D3142)),
                  ),
                ],
              ),
              Text(
                "₹ ${totalAmount.toStringAsFixed(2)}",
                style: GoogleFonts.poppins(fontSize: 15.sp, fontWeight: FontWeight.w700, color: AppColors.primaryBlue),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 10.h),
            child: Divider(color: Colors.grey.withOpacity(0.2), height: 1),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.check_circle_rounded, color: AppColors.green, size: 16.sp),
                  SizedBox(width: 6.w),
                  Text("Advance Paid", style: GoogleFonts.poppins(fontSize: 12.sp, fontWeight: FontWeight.w500, color: Colors.grey[700])),
                ],
              ),
              Text("₹ ${paidAmount.toStringAsFixed(2)}", style: GoogleFonts.poppins(fontSize: 13.sp, fontWeight: FontWeight.w600, color: AppColors.green)),
            ],
          ),
          SizedBox(height: 8.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    payableAmount > 0 ? Icons.error_rounded : Icons.check_circle_rounded,
                    color: payableAmount > 0 ? AppColors.errorRed : AppColors.green,
                    size: 16.sp,
                  ),
                  SizedBox(width: 6.w),
                  Text("Balance Due", style: GoogleFonts.poppins(fontSize: 12.sp, fontWeight: FontWeight.w500, color: Colors.grey[700])),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: (payableAmount > 0 ? AppColors.errorRed : AppColors.green).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: Text(
                  "₹ ${payableAmount.toStringAsFixed(2)}",
                  style: GoogleFonts.poppins(fontSize: 13.sp, fontWeight: FontWeight.w700, color: payableAmount > 0 ? AppColors.errorRed : AppColors.green),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}