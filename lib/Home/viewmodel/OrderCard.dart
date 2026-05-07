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
import 'package:ziya_laundry_deliveryapp/Orders/widget/Bundle_Dialog.dart';
import 'package:ziya_laundry_deliveryapp/Orders/widget/add_item_dialog.dart';
import 'package:ziya_laundry_deliveryapp/Orders/widget/custom_widgets.dart';
import 'package:ziya_laundry_deliveryapp/Orders/widget/order_card_elements.dart';
import '../../Home/viewmodel/home_viewmodel.dart';

class OrderCard extends StatefulWidget {
  final String orderid;
  final String orderNumber;
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
    required this.orderNumber,
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
  State<OrderCard> createState() => _OrderCardState();
}

class _OrderCardState extends State<OrderCard> {
  final TextEditingController _mismatchController = TextEditingController();

  @override
  void dispose() {
    _mismatchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Optimized: Only rebuild if the specific order or online status changes
    final isOnline = context.select<HomeViewModel, bool>((vm) => vm.isOnline);
    
    // Safely look up the order. If the list is empty or order is missing, return null.
    final currentOrder = context.select<HomeViewModel, OrderModel?>(
      (vm) {
        final index = vm.orders.indexWhere((o) => o.orderId == widget.orderid);
        return index != -1 ? vm.orders[index] : null;
      }
    );

    // If the order data is missing (e.g. after a logout or failed refresh), 
    // don't try to render the card to avoid RangeErrors.
    if (currentOrder == null) return const SizedBox.shrink();
    
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
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            OrderIdRow(orderId: widget.orderNumber.startsWith("LDR") ? widget.orderNumber : "#${widget.orderNumber}"),
            if (!isPending) ...[SizedBox(height: 10.h), OrderStepper(stage: stage, orderType: currentOrder.orderType), SizedBox(height: 10.h)],
            SizedBox(height: 5.h),
            OrderInfoRow(icon: AppImages.iconProfile, label: AppText.LoginNameLabel, value: widget.name, trailing: widget.by.isNotEmpty ? OrderStatusBadge(text: widget.by) : null),
            SizedBox(height: 5.h),
            OrderInfoRow(icon: AppImages.iconLocation, label: AppText.PickupAddress),
            OrderIndentText(text: widget.address),
            SizedBox(height: 5.h),
            OrderInfoRow(
              icon: AppImages.iconPay,
              label: currentOrder.paymentMethod == "ONLINE"
                  ? "Online Payment"
                  : currentOrder.paymentMethod == "COD"
                      ? "Cash on Delivery"
                      : "Not Available",
              trailing: isPending 
                  ? OrderStatusBadge(text: "Total \$${currentOrder.totalAmount}")
                  : null,
            ),
            if (!isPending)
              Padding(
                  padding: EdgeInsets.only(left: 29.w),
                  child: OrderStatusBadge(
                    text: widget.isPaid
                        ? AppText.AmountPaid
                        : "Total Amount: \$${currentOrder.totalAmount}",
                  )),
            SizedBox(height: 10.h),
            if (isPending) ...[
              if (widget.isDetailsPage) ...[
                OrderInfoRow(icon: AppImages.iconItems, label: AppText.ItemsLabel),
                _buildVerificationList(context, currentOrder, true),
                if (currentOrder.orderType == OrderType.delivery) ...[
                  if (widget.by != "Per Piece" && currentOrder.bundles.isNotEmpty)
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
              ],
              SizedBox(height: 10.h),
              widget.isDetailsPage 
                ? OrderProgressButton(text: AppText.BtnAccept, stage: currentOrder.orderType == OrderType.delivery ? DeliveryStage.startDelivery : DeliveryStage.startPickup, onPressed: widget.onAccept ?? () {})
                : AcceptViewActionRow(isOnline: isOnline, onView: widget.onViewTap ?? () {}, onAccept: widget.onAccept),
            ] else ...[
              // Show item verification list
              _buildVerificationList(context, currentOrder, false),
              
              // Show bundles if they exist, or if it's an assigned pickup order requiring bundle input
              if (currentOrder.bundles.isNotEmpty || (currentOrder.status == OrderStatus.assigned && widget.by != "Per Piece") || currentOrder.status == OrderStatus.completed)
                ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: 150.h),
                  child: SingleChildScrollView(
                    child: BundleSection(
                      bundles: currentOrder.bundles,
                      onAddTap: currentOrder.isVerified ? () {} : () => _openBundleDialog(context),
                      onDelete: currentOrder.isVerified ? (i) {} : (i) => context.read<HomeViewModel>().removeOrderBundle(widget.orderid, i),
                      isReadOnly: currentOrder.status == OrderStatus.completed || 
                                  currentOrder.orderType == OrderType.delivery ||
                                  currentOrder.isVerified,
                    ),
                  ),
                ),

              // Show verification actions (Checked button & Mismatch report) for assigned pickup orders
              if (currentOrder.status == OrderStatus.assigned && currentOrder.orderType == OrderType.pickup)
                _buildVerificationActions(context, currentOrder),

              SizedBox(height: 15.h),
              // Image Gallery Section (only if images exist)
              if (currentOrder.pickedImages.isNotEmpty)
                ImageGallerySection(
                  pickedImages: currentOrder.pickedImages,
                  onSeeMore: () => _showImagePickerGrid(context, currentOrder.status == OrderStatus.completed || currentOrder.orderType == OrderType.delivery),
                ),

              // Add Image button for assigned pickup orders (always show if applicable)
              if (currentOrder.status == OrderStatus.assigned && currentOrder.orderType == OrderType.pickup)
                Padding(
                  padding: EdgeInsets.only(top: 10.h), // Add some top padding
                  child: SizedBox(
                    width: double.infinity, // Make it full width
                    height: 40.h,
                    child: OutlinedButton.icon(
                      onPressed: _handleAddImage,
                      icon: Icon(Icons.add_a_photo, size: 20.sp, color: AppColors.primaryBlue),
                      label: Text(
                        "Add Image",
                        style: GoogleFonts.poppins(fontSize: 14.sp, color: AppColors.primaryBlue, fontWeight: FontWeight.w600),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AppColors.primaryBlue, width: 1.r),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                      ),
                    ),
                  ),
                ),
              OrderProgressButton(stage: stage, onPressed: () => _handleProgressAction(context)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildVerificationList(BuildContext context, OrderModel order, bool isPending) {
    final isPickup = order.orderType == OrderType.pickup;
    // Disable buttons if already verified
    final isInteractive = !isPending && order.status == OrderStatus.assigned && isPickup && !order.isVerified;
    final displayItems = order.items.isEmpty ? widget.items : order.items;

    if (displayItems.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ConstrainedBox(
          constraints: BoxConstraints(maxHeight: 150.h), // Set a max height for the scrollable area
          child: SingleChildScrollView(
            child: Column(
              children: [
                ...displayItems.map((item) => Padding(
                  padding: EdgeInsets.symmetric(vertical: 4.h),
                  child: Row(
                    children: [
                      if (isInteractive || (!isPending && order.isVerified))
                        Checkbox(
                          value: item.isVerified,
                          activeColor: AppColors.primaryBlue,
                          onChanged: (isInteractive && !order.isVerified) ? (_) => context.read<HomeViewModel>().toggleItemVerification(widget.orderid, item.id) : null,
                        ),
                      Expanded(
                        child: Text(
                          "${item.name} x ${item.qty} ${item.unit}",
                          style: GoogleFonts.poppins(fontSize: 14.sp, decoration: item.isVerified ? TextDecoration.lineThrough : null),
                        ),
                      ),
                      if (isInteractive)
                        IconButton(
                          icon: Icon(Icons.delete_outline, color: AppColors.errorRed, size: 20.sp),
                          onPressed: (isInteractive && !order.isVerified) ? () => context.read<HomeViewModel>().deleteItemFromOrder(widget.orderid, item.id) : null,
                        ),
                    ],
                  ),
                )),
              ],
            ),
          ),
        ),
        Divider(color: AppColors.grey.withOpacity(0.5)),
      ],
    );
  }

  Widget _buildVerificationActions(BuildContext context, OrderModel order) {
    final bool isVerified = order.isVerified;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(top: 12.h, bottom: 8.h),
          child: Row(
            children: [
              if (widget.by == "Per Piece" && !isVerified) ...[ // Only show "Add" button if not verified
                SizedBox(
                  width: 136.w,
                  height: 32.h,
                  child: OutlinedButton( // This is the "Add" button
                    onPressed: () => _showAddItemDialog(context),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppColors.primaryBlue, width: 1.r),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                      padding: EdgeInsets.all(8.w),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add, size: 16.sp, color: AppColors.primaryBlue),
                        SizedBox(width: 8.w),
                        Text("Add", style: GoogleFonts.poppins(fontSize: 12.sp, color: AppColors.primaryBlue, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
              ],
              Expanded(
                child: SizedBox(
                  height: 32.h,
                  child: ElevatedButton(
                    onPressed: !isVerified ? () => context.read<HomeViewModel>().verifyOrder(widget.orderid) : null, // Disable if verified
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isVerified ? AppColors.green : AppColors.primaryBlue,
                      disabledBackgroundColor: isVerified ? AppColors.green : null,
                      disabledForegroundColor: isVerified ? Colors.white : null,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                      padding: EdgeInsets.all(8.w),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle_outline, size: 16.sp, color: Colors.white),
                        SizedBox(width: 8.w),
                        Text("Checked", style: GoogleFonts.poppins(fontSize: 12.sp, color: Colors.white, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        // Report Item Mismatch section, shown only if verified
        if (isVerified)
          Container(
            margin: EdgeInsets.only(bottom: 12.h),
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: AppColors.white,
              border: Border.all(color: AppColors.errorRed.withOpacity(0.3)),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Report Item Mismatch", style: GoogleFonts.poppins(fontSize: 13.sp, fontWeight: FontWeight.w600, color: AppColors.errorRed)),
                SizedBox(height: 10.h),
                TextField(
                  controller: _mismatchController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    hintText: "Type mismatch details here...",
                    hintStyle: GoogleFonts.poppins(fontSize: 12.sp, color: AppColors.grey),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r), borderSide: BorderSide(color: AppColors.grey.withOpacity(0.5))),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r), borderSide: const BorderSide(color: AppColors.primaryBlue)),
                    contentPadding: EdgeInsets.all(10.w),
                  ),
                  style: GoogleFonts.poppins(fontSize: 13.sp),
                ),
                SizedBox(height: 10.h),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _mismatchController.clear(),
                        style: OutlinedButton.styleFrom(side: BorderSide(color: AppColors.grey), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r))),
                        child: Text("Cancel", style: GoogleFonts.poppins(fontSize: 12.sp, color: AppColors.grey, fontWeight: FontWeight.w600)),
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          if (_mismatchController.text.trim().isNotEmpty) {
                            context.read<HomeViewModel>().reportItemMismatch(
                                  widget.orderid,
                                  _mismatchController.text.trim(),
                                );
                          }
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBlue, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r))),
                        child: Text("Enter", style: GoogleFonts.poppins(fontSize: 12.sp, color: Colors.white, fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ],
              ),
            ],
          ),
        ),
        Divider(color: AppColors.grey.withOpacity(0.5)),
      ],
    );
  }
  void _openBundleDialog(BuildContext context) async {
    final result = await showDialog(
      context: context, 
      builder: (context) => BundleDialog(orderId: widget.orderid));
    if (result != null) {
      context.read<HomeViewModel>().addOrderBundle(widget.orderid, result);
    }
  }

  void _showImagePickerGrid(BuildContext context, bool isReadOnly) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => GalleryScreen(
        orderId: widget.orderid,
        isReadOnly: isReadOnly,
      )),
    );
  }

  Future<void> _handleProgressAction(BuildContext context) async {
    final homeVM = context.read<HomeViewModel>();
    final currentOrder = homeVM.orders.firstWhere((o) => o.orderId == widget.orderid);
    final stage = currentOrder.deliveryStage;
    final ImagePicker picker = ImagePicker();

    if (stage == DeliveryStage.startPickup) {
      final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => const PickupLocationScreen())); // Simulate location confirmation
      if (!context.mounted) return;
      if (result == true) {
        final nextStage = currentOrder.by == "Per Piece" ? DeliveryStage.orderPicked : DeliveryStage.uploadImages;
        homeVM.updateOrderStage(widget.orderid, nextStage);
      }
    } else if (stage == DeliveryStage.uploadImages) {
      final images = await picker.pickMultiImage();
      if (!context.mounted) return;
      if (images.isNotEmpty) {
        homeVM.addOrderImages(currentOrder.orderId, images.map((i) => i.path).toList());
        homeVM.updateOrderStage(widget.orderid, DeliveryStage.orderPicked);
      }
    } else if (stage == DeliveryStage.orderPicked) {
      await _showStatusDialog(context, AppImages.orderPickedGif, AppText.OrderPickedTitle);
      if (!context.mounted) return;
      homeVM.updateOrderStatus(widget.orderid, OrderStatus.completed);
      homeVM.setSelectedFilter("completed");
    } else if (stage == DeliveryStage.startDelivery) {
      final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => const DeliveryLocationScreen()));
      if (!context.mounted) return;
      if (result == true) {
        homeVM.updateOrderStage(widget.orderid, DeliveryStage.reachedDelivery);
      }
    } else if (stage == DeliveryStage.reachedDelivery) {
      await _showStatusDialog(context, AppImages.successGif, AppText.OrderDeliveredTitle);
      if (!context.mounted) return;
      homeVM.updateOrderStatus(widget.orderid, OrderStatus.completed);
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

  void _handleAddImage() async {
    final ImagePicker picker = ImagePicker();
    final images = await picker.pickMultiImage();
    if (!mounted) return;
    if (images.isNotEmpty) {
      context.read<HomeViewModel>().addOrderImages(widget.orderid, images.map((i) => i.path).toList());
    }
  }

  // Method to show the AddItemDialog and handle the result
  void _showAddItemDialog(BuildContext context) async {
    final results = await showDialog<List<Map<String, dynamic>>>(
      context: context,
      builder: (context) => AddItemDialog(orderId: widget.orderid),
    );
    if (results != null && context.mounted) {
      for (var result in results) {
        await context.read<HomeViewModel>().addItemToOrder(
              widget.orderid,
              result['item'],
              price: (result['price'] as num?)?.toDouble() ?? 0.0,
              serviceName: result['serviceName'],
            );
      }
    }
  }
}
