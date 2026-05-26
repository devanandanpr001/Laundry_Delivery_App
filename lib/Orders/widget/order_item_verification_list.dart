import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:ziya_laundry_deliveryapp/core/Constants/app_colors.dart';
import 'package:ziya_laundry_deliveryapp/core/Constants/app_images.dart';
import 'package:ziya_laundry_deliveryapp/core/Constants/app_strings.dart';
import 'package:ziya_laundry_deliveryapp/common_widget/AppToast.dart';
import 'package:ziya_laundry_deliveryapp/Home/data/model/home_models.dart';
import 'package:ziya_laundry_deliveryapp/Orders/viewmodel/order_viewmodel.dart';

class OrderItemVerificationList extends StatelessWidget {
  final OrderModel order;
  final String orderId;
  final bool isPending;
  final bool isArrived;
  final List<OrderItem> displayItems;
  final Future<bool> Function(BuildContext, String) onConfirmDeletion;

  const OrderItemVerificationList({
    super.key,
    required this.order,
    required this.orderId,
    required this.isPending,
    required this.isArrived,
    required this.displayItems,
    required this.onConfirmDeletion,
  });

  @override
  Widget build(BuildContext context) {
    final isPickup = order.orderType == OrderType.pickup;
    // Disable buttons if already verified OR if driver hasn't arrived for pickup yet
    final isInteractive = !isPending && order.status == OrderStatus.assigned && isPickup && !order.isVerified && isArrived;

    if (displayItems.isEmpty) return const SizedBox.shrink();

    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        leading: Image.asset(AppImages.iconItems, width: 20.sp, height: 20.sp, color: AppColors.primaryBlue),
        title: Text(
          AppText.ItemsLabel,
          style: GoogleFonts.poppins(fontSize: 14.sp, fontWeight: FontWeight.w600, color: AppColors.primaryBlue),
        ),
        children: [
          ConstrainedBox(
            constraints: BoxConstraints(maxHeight: 200.h),
            child: ListView.builder(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              itemCount: displayItems.length,
              itemBuilder: (context, index) {
                final item = displayItems[index];
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 4.h),
                  child: Row(
                    children: [
                      if (isInteractive || (!isPending && order.isVerified))
                        SizedBox(
                          height: 24.h, width: 24.w,
                          child: Checkbox(
                            value: item.isVerified,
                            activeColor: AppColors.primaryBlue,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.r)),
                            onChanged: (isInteractive) ? (_) => context.read<OrderViewModel>().toggleItemVerification(orderId, item.id) : null,
                          ),
                        ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          "${item.name}",
                          style: GoogleFonts.poppins(
                            fontSize: 13.sp, 
                            fontWeight: FontWeight.w500,
                            decoration: item.isVerified ? TextDecoration.lineThrough : null,
                            color: item.isVerified ? AppColors.textGrey : AppColors.textDark,
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                        decoration: BoxDecoration(color: AppColors.lightBlue, borderRadius: BorderRadius.circular(6.r)),
                        child: Text(
                          "x${item.qty}",
                          style: GoogleFonts.poppins(fontSize: 12.sp, fontWeight: FontWeight.bold, color: AppColors.primaryBlue),
                        ),
                      ),
                      if (isInteractive)
                        IconButton(
                          icon: Icon(
                            Icons.delete_outline,
                            color: displayItems.length <= 1 ? AppColors.grey : AppColors.errorRed,
                            size: 18.sp,
                          ),
                          onPressed: displayItems.length <= 1
                              ? null
                              : () async {
                                  final orderVM = context.read<OrderViewModel>();
                                  if (await onConfirmDeletion(context, item.name)) {
                                    try {
                                      await orderVM.deleteItemFromOrder(orderId, item.id);
                                      if (!context.mounted) return;
                                      AppToast.showSuccess(title: "Success", message: "Item removed");
                                    } catch (e) {
                                      if (!context.mounted) return;
                                      AppToast.showError(title: "Error", message: "Failed to remove item");
                                    }
                                  }
                                },
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
          Divider(color: AppColors.grey.withValues(alpha: 0.5)),
        ],
      ),
    );
  }
}