import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ziya_laundry_deliveryapp/features/Home/data/model/home_models.dart';
import 'package:ziya_laundry_deliveryapp/features/Orders/widget/custom_widgets.dart';

class OrderHeaderSection extends StatelessWidget {
  final String orderNumber;
  final bool isPending;
  final DeliveryStage stage;
  final OrderType orderType;

  const OrderHeaderSection({
    super.key,
    required this.orderNumber,
    required this.isPending,
    required this.stage,
    required this.orderType,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        OrderIdRow(orderId: orderNumber.startsWith("LDR") ? orderNumber : "#$orderNumber"),
        if (!isPending) ...[
          SizedBox(height: 10.h),
          OrderStepper(stage: stage, orderType: orderType),
          SizedBox(height: 10.h),
        ],
      ],
    );
  }
}