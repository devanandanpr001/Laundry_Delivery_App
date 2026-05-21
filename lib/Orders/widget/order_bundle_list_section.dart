import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:ziya_laundry_deliveryapp/Home/data/model/home_models.dart';
import 'package:ziya_laundry_deliveryapp/Orders/viewmodel/order_viewmodel.dart';
import 'package:ziya_laundry_deliveryapp/Orders/widget/order_card_elements.dart';
import 'package:ziya_laundry_deliveryapp/common_widgets/AppToast.dart';

class OrderBundleListSection extends StatelessWidget {
  final OrderModel order;
  final bool isArrivedForPickup;
  final VoidCallback onOpenBundleDialog;
  final Future<bool> Function(BuildContext, String) onConfirmDeletion;

  const OrderBundleListSection({
    super.key,
    required this.order,
    required this.isArrivedForPickup,
    required this.onOpenBundleDialog,
    required this.onConfirmDeletion,
  });

  @override
  Widget build(BuildContext context) {
    // Show bundles if they exist, or if it's an assigned pickup order requiring bundle input
    final bool shouldShow = order.bundles.isNotEmpty ||
        (order.by != "Per Piece" &&
            (order.status == OrderStatus.assigned ||
                order.status == OrderStatus.completed));

    if (!shouldShow) return const SizedBox.shrink();

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: 150.h),
      child: SingleChildScrollView(
        child: BundleSection(
          bundles: order.bundles,
          onAddTap: (order.isVerified || !isArrivedForPickup)
              ? () {}
              : onOpenBundleDialog,
          onDelete: (order.isVerified || !isArrivedForPickup)
              ? (i) {}
              : (i) async {
                  final bundleName = order.bundles[i].name;
                  final orderVM = context.read<OrderViewModel>();
                  if (await onConfirmDeletion(context, bundleName)) {
                    try {
                      await orderVM.removeOrderBundle(order.orderId, i);
                      AppToast.showSuccess(
                          title: "Success", message: "Bundle removed");
                    } catch (e) {
                      AppToast.showError(
                          title: "Error", message: "Failed to remove bundle");
                    }
                  }
                },
          isReadOnly: order.status == OrderStatus.completed ||
              order.orderType == OrderType.delivery ||
              order.isVerified,
        ),
      ),
    );
  }
}