import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:ziya_laundry_deliveryapp/Constants/app_colors.dart';
import 'package:ziya_laundry_deliveryapp/Constants/app_images.dart';
import 'package:ziya_laundry_deliveryapp/Constants/app_text.dart';
import 'package:ziya_laundry_deliveryapp/Home/data/model/home_models.dart';
import 'package:ziya_laundry_deliveryapp/Orders/view/DeliveryLocation_Screen.dart';
import 'package:ziya_laundry_deliveryapp/Orders/view/PickUp_location.dart';
import 'package:ziya_laundry_deliveryapp/Orders/view/Gallery_Screen.dart';
import '../../Home/viewmodel/home_viewmodel.dart';
import 'custom_widgets.dart';
import 'order_card_elements.dart';
import 'Bundle_Dialog.dart';

class OrderCard extends StatelessWidget {
  final String orderid;
  final String name;
  final String by;
  final String address;
  final bool isPaid;
  final bool isDetailsPage;
  final bool showOnlyItems;
  final Function()? onAccept;
  final List<OrderItem> items;
  final VoidCallback? onViewTap;
  final String? selectedFilter;
  // Re-added optional params to fix compilation errors in other files
  final OrderStatus? status;
  final DeliveryStage? deliveryStage;

  const OrderCard({
    super.key,
    required this.orderid,
    required this.name,
    required this.by,
    required this.address,
    required this.isPaid,
    this.isDetailsPage = false,
    this.showOnlyItems = false,
    this.onAccept,
    required this.items,
    this.onViewTap,
    this.selectedFilter,
    this.status,
    this.deliveryStage,
  });

  @override
  Widget build(BuildContext context) {
    // Optimized: Only rebuild if the specific order or online status changes
    final isOnline = context.select<HomeViewModel, bool>((vm) => vm.isOnline);
    
    final currentOrder = context.select<HomeViewModel, OrderModel>(
      (vm) => vm.orders.firstWhere(
        (o) => o.orderId == orderid, 
        // Fallback to avoid crashes if an order is removed while the widget is still in the tree
        orElse: () => vm.orders.isNotEmpty ? vm.orders.first : vm.orders[0] 
      )
    );
    
    final isPending = currentOrder.status == OrderStatus.pending;
    final stage = currentOrder.status == OrderStatus.completed 
        ? DeliveryStage.delivered 
        : currentOrder.deliveryStage;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(10.w), border: Border.all(color: AppColors.grey)),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: isPending ? 10.h : 12.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            if (!isPending) ...[OrderAssignedHeader(stage: stage, orderType: currentOrder.orderType), SizedBox(height: 5.h)],
            OrderIdRow(orderId: orderid),
            if (!isPending) ...[SizedBox(height: 10.h), OrderStepper(stage: stage, orderType: currentOrder.orderType), SizedBox(height: 10.h)],
            SizedBox(height: 5.h),
            OrderInfoRow(icon: AppImages.iconProfile, label: AppText.LoginNameLabel, value: name, trailing: by.isNotEmpty ? OrderStatusBadge(text: by) : null),
            SizedBox(height: 5.h),
            OrderInfoRow(icon: AppImages.iconLocation, label: AppText.PickupAddress),
            OrderIndentText(text: address),
            SizedBox(height: 5.h),
            OrderInfoRow(icon: AppImages.iconPay, label: AppText.CashOnDelivery),
            Padding(padding: EdgeInsets.only(left: 29.w), child: OrderStatusBadge(text: isPaid ? AppText.AmountPaid : AppText.NotYetPaid, width: 103.w)),
            SizedBox(height: 10.h),
            if (isPending) ...[
              if (items.isNotEmpty) OrderItemsList(items: items),
              if (currentOrder.orderType == OrderType.delivery) ...[
                if (by != "Per Piece" && currentOrder.bundles.isNotEmpty)
                  BundleSection(
                    bundles: currentOrder.bundles,
                    onAddTap: () {}, // Read-only for pending delivery
                    onDelete: (_) {},
                    isReadOnly: true,
                  ),
                if (currentOrder.pickedImages.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.only(top: 10.h),
                    child: ImageGallerySection(
                      pickedImages: currentOrder.pickedImages,
                      onSeeMore: () => _showImagePickerGrid(context, true),
                    ),
                  ),
              ],
              SizedBox(height: 10.h),
              isDetailsPage 
                ? OrderProgressButton(text: AppText.BtnAccept, stage: currentOrder.orderType == OrderType.delivery ? DeliveryStage.startDelivery : DeliveryStage.startPickup, onPressed: onAccept ?? () {}) 
                : AcceptViewActionRow(isOnline: isOnline, onView: onViewTap ?? () {}, onAccept: onAccept),
            ] else ...[
              if (by == "Per Piece" && items.isNotEmpty) OrderItemsList(items: items),
              if (stage != DeliveryStage.startPickup && by != "Per Piece" || currentOrder.orderType == OrderType.delivery)
                BundleSection(
                  bundles: currentOrder.bundles,
                  onAddTap: currentOrder.orderType == OrderType.delivery ? () {} : () => _openBundleDialog(context),
                  onDelete: currentOrder.orderType == OrderType.delivery ? (_) {} : (i) => context.read<HomeViewModel>().removeOrderBundle(orderid, i),
                  isReadOnly: currentOrder.status == OrderStatus.completed || currentOrder.orderType == OrderType.delivery,
                ),
              SizedBox(height: 15.h),
              if (currentOrder.pickedImages.isNotEmpty) ImageGallerySection(pickedImages: currentOrder.pickedImages, onSeeMore: () => _showImagePickerGrid(context, currentOrder.status == OrderStatus.completed || currentOrder.orderType == OrderType.delivery)),
              OrderProgressButton(stage: stage, onPressed: () => _handleProgressAction(context)),
            ],
          ],
        ),
      ),
    );
  }

  void _openBundleDialog(BuildContext context) async {
    final result = await showDialog(context: context, builder: (context) => const BundleDialog());
    if (result != null) {
      context.read<HomeViewModel>().addOrderBundle(orderid, result);
    }
  }

  void _showImagePickerGrid(BuildContext context, bool isReadOnly) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => GalleryScreen(
        orderId: orderid,
        isReadOnly: isReadOnly,
      )),
    );
  }

  Future<void> _handleProgressAction(BuildContext context) async {
    final homeVM = context.read<HomeViewModel>();
    final currentOrder = homeVM.orders.firstWhere((o) => o.orderId == orderid);
    final stage = currentOrder.deliveryStage;
    final ImagePicker picker = ImagePicker();

    if (stage == DeliveryStage.startPickup) {
      final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => const PickupLocationScreen()));
      if (!context.mounted) return;
      if (result == true) {
        final nextStage = currentOrder.by == "Per Piece" ? DeliveryStage.orderPicked : DeliveryStage.uploadImages;
        homeVM.updateOrderStage(orderid, nextStage);
      }
    } else if (stage == DeliveryStage.uploadImages) {
      final images = await picker.pickMultiImage();
      if (!context.mounted) return;
      if (images.isNotEmpty) {
        homeVM.addOrderImages(currentOrder.orderId, images.map((i) => i.path).toList());
        homeVM.updateOrderStage(orderid, DeliveryStage.orderPicked);
      }
    } else if (stage == DeliveryStage.orderPicked) {
      await _showStatusDialog(context, AppImages.orderPickedGif, AppText.OrderPickedTitle);
      if (!context.mounted) return;
      homeVM.updateOrderStatus(orderid, OrderStatus.completed);
      homeVM.setSelectedFilter("completed");
    } else if (stage == DeliveryStage.startDelivery) {
      final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => const DeliveryLocationScreen()));
      if (!context.mounted) return;
      if (result == true) {
        homeVM.updateOrderStage(orderid, DeliveryStage.reachedDelivery);
      }
    } else if (stage == DeliveryStage.reachedDelivery) {
      await _showStatusDialog(context, AppImages.successGif, AppText.OrderDeliveredTitle);
      if (!context.mounted) return;
      homeVM.updateOrderStatus(orderid, OrderStatus.completed);
      homeVM.setSelectedFilter("completed");
    }
  }

  Future<void> _showStatusDialog(BuildContext context, String asset, String text) async {
    showDialog(context: context, barrierDismissible: false, builder: (_) => Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Image.asset(asset, height: 120.h),
      SizedBox(height: 10.h),
      Text(text, style: GoogleFonts.poppins(fontSize: 24.sp, fontWeight: FontWeight.w500, color: AppColors.green, decoration: TextDecoration.none)),
    ])));
    await Future.delayed(const Duration(seconds: 3));
    if (context.mounted) Navigator.pop(context);
  }
}
