import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:ziya_laundry_deliveryapp/Constants/app_colors.dart';
import 'package:ziya_laundry_deliveryapp/Constants/app_images.dart';
import 'package:ziya_laundry_deliveryapp/Constants/app_text.dart';
import 'package:ziya_laundry_deliveryapp/common_widgets/AppToast.dart';
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
                  padding: EdgeInsets.symmetric(vertical: 2.h),
                  child: Row(
                    children: [
                      if (isInteractive || (!isPending && order.isVerified))
                        Checkbox(
                          value: item.isVerified,
                          activeColor: AppColors.primaryBlue,
                          onChanged: (isInteractive) ? (_) => context.read<OrderViewModel>().toggleItemVerification(orderId, item.id) : null,
                        ),
                      Expanded(
                        child: Text(
                          "${item.name} x ${item.qty} ${item.unit}",
                          style: GoogleFonts.poppins(fontSize: 13.sp, decoration: item.isVerified ? TextDecoration.lineThrough : null),
                        ),
                      ),
                      if (isInteractive)
                        IconButton(
                          icon: Icon(Icons.delete_outline, color: AppColors.errorRed, size: 18.sp),
                          onPressed: () async {
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