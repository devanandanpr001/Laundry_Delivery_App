import 'package:flutter/material.dart';
import 'package:ziya_laundry_deliveryapp/Home/data/model/home_models.dart';
import 'package:ziya_laundry_deliveryapp/Orders/widget/order_card_elements.dart';

class OrderGallerySectionWrapper extends StatelessWidget {
  final OrderModel order;
  final bool isArrivedForPickup;
  final Function(bool isReadOnly) onShowImagePicker;

  const OrderGallerySectionWrapper({
    super.key,
    required this.order,
    required this.isArrivedForPickup,
    required this.onShowImagePicker,
  });

  @override
  Widget build(BuildContext context) {
    // Image Gallery Section (only if images exist)
    if (order.pickedImages.isEmpty || order.by == "Per Piece") {
      return const SizedBox.shrink();
    }

    return ImageGallerySection(
      pickedImages: order.pickedImages,
      onSeeMore: () {
        final bool isReadOnly = order.status == OrderStatus.completed ||
            order.orderType == OrderType.delivery ||
            !isArrivedForPickup;
        onShowImagePicker(isReadOnly);
      },
    );
  }
}