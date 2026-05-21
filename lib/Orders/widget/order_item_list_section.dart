import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ziya_laundry_deliveryapp/Home/data/model/home_models.dart';
import 'package:ziya_laundry_deliveryapp/Orders/widget/order_item_verification_list.dart';
import 'package:ziya_laundry_deliveryapp/Orders/widget/order_card_elements.dart';

class OrderItemListSection extends StatelessWidget {
  final OrderModel order;
  final String orderId;
  final List<OrderItem> items;
  final Function(bool isReadOnly) onShowImagePicker;
  final Future<bool> Function(BuildContext, String) onConfirmDeletion;

  const OrderItemListSection({
    super.key,
    required this.order,
    required this.orderId,
    required this.items,
    required this.onShowImagePicker,
    required this.onConfirmDeletion,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (order.by == "Per Piece")
          OrderItemVerificationList(
            order: order,
            orderId: orderId,
            isPending: true,
            isArrived: false,
            displayItems: order.items.isEmpty ? items : order.items,
            onConfirmDeletion: onConfirmDeletion,
          ),
        if (order.orderType == OrderType.delivery) ...[
          if (order.by != "Per Piece" && order.bundles.isNotEmpty)
            BundleSection(
              bundles: order.bundles,
              onAddTap: () {}, // Read-only for pending delivery
              onDelete: (_) {},
              isReadOnly: true,
            ),
          if (order.pickedImages.isNotEmpty && order.by != "Per Piece")
            Padding(
              padding: EdgeInsets.only(top: 10.h),
              child: ImageGallerySection(
                pickedImages: order.pickedImages,
                onSeeMore: () => onShowImagePicker(true),
              ),
            ),
        ],
      ],
    );
  }
}