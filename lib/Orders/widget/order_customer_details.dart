import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ziya_laundry_deliveryapp/Constants/app_images.dart';
import 'package:ziya_laundry_deliveryapp/Constants/app_text.dart';
import 'package:ziya_laundry_deliveryapp/Orders/widget/custom_widgets.dart';

class OrderCustomerDetails extends StatelessWidget {
  final String name;
  final String by;
  final String address;

  const OrderCustomerDetails({
    super.key,
    required this.name,
    required this.by,
    required this.address,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 5.h),
        OrderInfoRow(
          icon: AppImages.iconProfile,
          label: AppText.LoginNameLabel,
          value: name,
          trailing: by.isNotEmpty ? OrderStatusBadge(text: by) : null,
        ),
        SizedBox(height: 10.h),
        OrderInfoRow(icon: AppImages.iconLocation, label: AppText.PickupAddress),
        OrderAddressCard(address: address),
      ],
    );
  }
}