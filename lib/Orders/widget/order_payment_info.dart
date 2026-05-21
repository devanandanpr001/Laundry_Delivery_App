import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ziya_laundry_deliveryapp/Constants/app_images.dart';
import 'package:ziya_laundry_deliveryapp/Constants/app_text.dart';
import 'package:ziya_laundry_deliveryapp/Home/data/model/home_models.dart';
import 'package:ziya_laundry_deliveryapp/Orders/widget/custom_widgets.dart';

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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 5.h),
        OrderInfoRow(
          icon: AppImages.iconPay,
          label: order.paymentMethod == "ONLINE"
              ? "Online Payment"
              : order.paymentMethod == "COD"
                  ? "Cash on Delivery"
                  : "Not Available",
          trailing: isPending
              ? OrderStatusBadge(text: "Total \$${order.totalAmount}")
              : null,
        ),
        if (!isPending)
          Padding(
            padding: EdgeInsets.only(left: 29.w),
            child: OrderStatusBadge(
              text: isPaid
                  ? AppText.AmountPaid
                  : "Total Amount: \$${order.totalAmount}",
            ),
          ),
      ],
    );
  }
}