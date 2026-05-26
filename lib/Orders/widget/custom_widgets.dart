import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ziya_laundry_deliveryapp/Constants/app_colors.dart';
import 'package:ziya_laundry_deliveryapp/Constants/app_images.dart';
import 'package:ziya_laundry_deliveryapp/Constants/app_text.dart';
import '../../Home/data/model/home_models.dart';

/// Reusable Order ID display
class OrderIdRow extends StatelessWidget {
  final String orderId;
  const OrderIdRow({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(AppText.OrderId, style: GoogleFonts.poppins(fontSize: 18.sp, fontWeight: FontWeight.w500, color: AppColors.textLightGrey)),
        Text(orderId, style: GoogleFonts.poppins(fontSize: 14.sp, fontWeight: FontWeight.w400)),
      ],
    );
  }
}

/// Reusable Row with an Icon, Label, and Optional Value/Trailing Widget
class OrderInfoRow extends StatelessWidget {
  final String icon;
  final String label;
  final String? value;
  final Widget? trailing;
  const OrderInfoRow({super.key, required this.icon, required this.label, this.value, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Image.asset(icon, height: 24.h, width: 24.w),
        SizedBox(width: 10.w),
        Expanded(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(label,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(fontSize: 14.sp, fontWeight: FontWeight.w400, color: AppColors.primaryBlue)),
              ),
              if (value != null) ...[
                SizedBox(width: 5.w),
                Flexible(
                  child: Text(value!,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(fontSize: 14.sp, fontWeight: FontWeight.w400)),
                ),
              ],
            ],
          ),
        ),
        if (trailing != null) ...[
          SizedBox(width: 10.w),
          trailing!,
        ],
      ],
    );
  }
}

/// Reusable Status Capsule (e.g., "amount paid", "Per Piece")
class OrderStatusBadge extends StatelessWidget {
  final String text;
  final double? width;
  const OrderStatusBadge({super.key, required this.text, this.width});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(minHeight: 30.h, minWidth: width ?? 87.w),
      width: width,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
      decoration: BoxDecoration(
          color: AppColors.badgeBlue, borderRadius: BorderRadius.circular(15.w)),
      child: Center(
          child: Text(text,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                  fontSize: 14.sp, fontWeight: FontWeight.w500))),
    );
  }
}

/// Simple Indented Text used for addresses
class OrderIndentText extends StatelessWidget {
  final String text;
  const OrderIndentText({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 32.w),
      child: Text(text, style: GoogleFonts.poppins(fontSize: 14.sp, fontWeight: FontWeight.w400)),
    );
  }
}

class OrderAddressCard extends StatelessWidget {
  final String address;
  const OrderAddressCard({super.key, required this.address});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(left: 28.w, top: 8.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.lightBackground,
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Text(
        address.trim().isEmpty ? 'No address provided' : address.trim(),
        style: GoogleFonts.poppins(fontSize: 14.sp, fontWeight: FontWeight.w400, color: AppColors.textDark, height: 1.4),
      ),
    );
  }
}

/// Helper for dash lines in steppers
class DashLine extends StatelessWidget {
  const DashLine({super.key});
  @override
  Widget build(BuildContext context) => Container(width: 3.w, height: 1.5.h, color: AppColors.primaryBlue);
}

/// Header for Assigned Orders
class OrderAssignedHeader extends StatelessWidget {
  final DeliveryStage stage;
  final OrderType orderType;
  const OrderAssignedHeader({super.key, required this.stage, required this.orderType});

  @override
  Widget build(BuildContext context) {
    String statusText = orderType == OrderType.pickup 
        ? AppText.PickupAssignedToYou 
        : AppText.OutForDelivery;
    Color statusColor = AppColors.green;

    if (stage == DeliveryStage.delivered) {
      statusText = orderType == OrderType.pickup 
          ? AppText.OrderPickedTitle 
          : AppText.OrderDeliveredTitle;
      statusColor = AppColors.grey;
    } else if (orderType == OrderType.delivery && stage.index >= DeliveryStage.orderPicked.index) {
      statusText = AppText.OutForDelivery;
      statusColor = AppColors.primaryBlue;
    }

    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(statusText, style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14.sp, color: statusColor)),
    ]);
  }
}
/// Standard Item List display
class OrderItemsList extends StatelessWidget {
  final List<OrderItem> items;
  const OrderItemsList({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        OrderInfoRow(icon: AppImages.iconItems, label: AppText.ItemsLabel),
        SizedBox(height: 10.h),
        Wrap(
          spacing: 10.w,
          runSpacing: 10.h,
          children: items.map((item) {
            return Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
              constraints: BoxConstraints(maxWidth: 200.w),
              decoration: BoxDecoration(
                color: AppColors.lightBlue,
                borderRadius: BorderRadius.circular(14.r),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Expanded(
                    child: Text(
                      item.name,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(fontSize: 14.sp, fontWeight: FontWeight.w500),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Text(
                      item.qty.toString(),
                      style: GoogleFonts.poppins(fontSize: 12.sp, fontWeight: FontWeight.w600, color: AppColors.white),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
        SizedBox(height: 10.h),
      ],
    );
  }
}
/// Progress Stepper for Delivery Stages

class OrderStepper extends StatelessWidget {
  final DeliveryStage stage;
  final OrderType orderType;
  const OrderStepper({super.key, required this.stage, required this.orderType});

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween, 
    children: orderType == OrderType.pickup 
      ? [
          _step(AppText.StepPickupAssigned, true),
          const _DashLineContainer(),
          _step(AppText.StepPickedUp, stage == DeliveryStage.delivered),
        ]
      : [
          _step(AppText.OutForDelivery, true),
          const _DashLineContainer(),
          _step(AppText.Delivered, stage.index >= DeliveryStage.delivered.index),
        ]
  );

  Widget _step(String text, bool active) => Column(children: [
    Container(height: 14.w, width: 14.w, decoration: BoxDecoration(shape: BoxShape.circle, color: active ? AppColors.primaryBlue : AppColors.white, border: Border.all(color: AppColors.primaryBlue))),
    const SizedBox(height: 6),
    Text(text, textAlign: TextAlign.center, style: const TextStyle(fontSize: 10)),
  ]);
}

class _DashLineContainer extends StatelessWidget {
  const _DashLineContainer();
  @override
  Widget build(BuildContext context) => Expanded(child: LayoutBuilder(builder: (context, constraints) {
    final dashCount = (constraints.maxWidth / 6).floor();
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: List.generate(dashCount, (_) => const DashLine()));
  }));
}