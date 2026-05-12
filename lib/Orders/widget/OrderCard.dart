
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:ziya_laundry_deliveryapp/Constants/app_colors.dart';
import 'package:ziya_laundry_deliveryapp/Constants/app_images.dart';
import 'package:ziya_laundry_deliveryapp/Constants/app_text.dart';
import 'package:ziya_laundry_deliveryapp/Constants/quick_popup_manager.dart';
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
  final OrderType orderType;
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
    required this.orderType,
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

  /// Shows a confirmation dialog before deleting an item or bundle.
  static Future<bool> _confirmDeletion(BuildContext context, String itemName) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
        title: Text(
          "Confirm Deletion",
          style: GoogleFonts.poppins(fontSize: 18.sp, fontWeight: FontWeight.bold),
        ),
        content: Text(
          "Are you sure you want to remove '$itemName'?",
          style: GoogleFonts.poppins(fontSize: 14.sp),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text("Cancel", style: GoogleFonts.poppins(color: AppColors.grey, fontWeight: FontWeight.w600)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text("Delete", style: GoogleFonts.poppins(color: AppColors.errorRed, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}

class _OrderCardState extends State<OrderCard> {
  final TextEditingController _mismatchController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  bool _otpSent = false;
  bool _isVerifyingOtp = false;
  bool _otpVerified = false;
  bool _isSendingReport = false;
  bool _reportSentSuccess = false;
  bool _reportSentFailed = false;
  bool _isUserEditing = false;
  String _lastSentReportText = "";

  // Baseline tracking to detect additions or deletions professionally
  int? _baselineItemCount;
  int? _baselineBundleCount;

  @override
  void initState() {
    super.initState();
    _otpController.addListener(() => setState(() {}));

    // Professional: Capture the initial state of the order to detect manual modifications later.
    final vm = context.read<HomeViewModel>();
    final orderIndex = vm.orders.indexWhere((o) => o.orderId == widget.orderid && o.orderType == widget.orderType);
    if (orderIndex != -1) {
      _baselineItemCount = vm.orders[orderIndex].items.length;
      _baselineBundleCount = vm.orders[orderIndex].bundles.length;

      // Professional: Sync the report state with existing data from backend
      if (vm.orders[orderIndex].mismatchReason != null && vm.orders[orderIndex].mismatchReason!.isNotEmpty) {
        _mismatchController.text = vm.orders[orderIndex].mismatchReason!;
        _lastSentReportText = vm.orders[orderIndex].mismatchReason!;
        _reportSentSuccess = true;
      }
    }
    
    // Professional: Listen to changes to handle real-time UI updates (buttons, tick, etc.)
    _mismatchController.addListener(_onMismatchTextChanged);
  }

  void _onMismatchTextChanged() {
    if (mounted) setState(() {});
    if (mounted) {
      // Detect if user is actively changing text compared to what was last sent
      setState(() => _isUserEditing = _mismatchController.text.trim() != _lastSentReportText);
    }
  }

  @override
  void dispose() {
    _mismatchController.removeListener(_onMismatchTextChanged);
    _mismatchController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Optimized: Only rebuild if the specific order or online status changes
    final isOnline = context.select<HomeViewModel, bool>((vm) => vm.isOnline);
    
    // Safely look up the order. If the list is empty or order is missing, return null.
    final currentOrder = context.select<HomeViewModel, OrderModel?>(
      (vm) {
        final index = vm.orders.indexWhere((o) => o.orderId == widget.orderid && o.orderType == widget.orderType);
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

    // Logic: Calculate if items or bundles have been added or removed since arrival
    final bool isModified = _baselineItemCount != null && 
                           (currentOrder.items.length != _baselineItemCount || 
                            currentOrder.bundles.length != _baselineBundleCount);

    // Logic: Actions are only allowed if it's a Pickup order AND the driver has moved past the 'startPickup' stage.
    final bool isArrivedForPickup = currentOrder.orderType == OrderType.pickup && 
                                   stage != DeliveryStage.startPickup && 
                                   currentOrder.status == OrderStatus.assigned;

    // Professional Recovery: If images exist, the next logical step is always "Order Picked"
    // This handles app crashes or restarts after images were uploaded.
    DeliveryStage effectiveStage = stage;
    if (stage == DeliveryStage.uploadImages && currentOrder.pickedImages.isNotEmpty) {
      effectiveStage = DeliveryStage.orderPicked;
    }

    // Logic: For "By Weight" orders, the "Order Picked" action is strictly gated.
    // It will be disabled if no images have been uploaded yet.
    final bool isWeightPickupMissingImages = currentOrder.orderType == OrderType.pickup && 
                                             currentOrder.by == "By Weight" && 
                                             effectiveStage == DeliveryStage.orderPicked && 
                                             currentOrder.pickedImages.isEmpty;

    // Condition: Disable the final delivery button until OTP is verified 
    // OR disable pickup progress buttons until items are verified (Checked).
    final bool isActionDisabled = 
        (currentOrder.orderType == OrderType.delivery && 
         effectiveStage == DeliveryStage.reachedDelivery && 
         !_otpVerified && 
         (!_otpSent || _otpController.text.length != 4)) ||
        (isArrivedForPickup && !currentOrder.isVerified) ||
        isWeightPickupMissingImages;

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
            if (currentOrder.status == OrderStatus.completed || (currentOrder.mismatchReason != null && currentOrder.mismatchReason!.isNotEmpty))
              Padding(
                padding: EdgeInsets.only(top: 8.h),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(10.w),
                  decoration: BoxDecoration(
                    color: (currentOrder.mismatchReason?.isNotEmpty ?? false) 
                        ? AppColors.errorRed.withOpacity(0.05) 
                        : AppColors.grey.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(color: (currentOrder.mismatchReason?.isNotEmpty ?? false) 
                        ? AppColors.errorRed.withOpacity(0.3) 
                        : AppColors.grey.withOpacity(0.3)),
                  ),
                  child: Text(
                    "Mismatch Reason: ${currentOrder.mismatchReason?.isNotEmpty == true ? currentOrder.mismatchReason : "Not Recorded"}",
                    style: GoogleFonts.poppins(
                        fontSize: 13.sp, 
                        fontWeight: FontWeight.w500, 
                        color: (currentOrder.mismatchReason?.isNotEmpty ?? false) ? AppColors.errorRed : AppColors.grey),
                  ),
                ),
              ),
            SizedBox(height: 10.h),
            if (isPending) ...[
              if (widget.isDetailsPage) ...[
                if (widget.by == "Per Piece")
                  _buildVerificationList(context, currentOrder, true, false),
                if (currentOrder.orderType == OrderType.delivery) ...[
                  if (widget.by != "Per Piece" && currentOrder.bundles.isNotEmpty)
                    BundleSection(
                      bundles: currentOrder.bundles,
                      onAddTap: () {}, // Read-only for pending delivery
                      onDelete: (_) {},
                      isReadOnly: true,
                    ),
                  if (currentOrder.pickedImages.isNotEmpty && currentOrder.by != "Per Piece")
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
              if (widget.by == "Per Piece")
                _buildVerificationList(context, currentOrder, false, isArrivedForPickup),
              
              // Show bundles if they exist, or if it's an assigned pickup order requiring bundle input
              if (currentOrder.bundles.isNotEmpty || (widget.by != "Per Piece" && (currentOrder.status == OrderStatus.assigned || currentOrder.status == OrderStatus.completed)))
                ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: 150.h),
                  child: SingleChildScrollView(
                    child: BundleSection(
                      bundles: currentOrder.bundles,
                      onAddTap: (currentOrder.isVerified || !isArrivedForPickup) ? () {} : () => _openBundleDialog(context),
                      onDelete: (currentOrder.isVerified || !isArrivedForPickup) ? (i) {} : (i) async {
                      final bundleName = currentOrder.bundles[i].name;
                      if (await OrderCard._confirmDeletion(context, bundleName)) {
                        try {
                          await context.read<HomeViewModel>().removeOrderBundle(widget.orderid, i);
                          QuickPopupManager.show(context, message: "Bundle removed", type: QuickPopupType.success);
                        } catch (e) {
                          QuickPopupManager.show(context, message: "Failed to remove bundle", type: QuickPopupType.error);
                        }
                      }
                    },
                      isReadOnly: currentOrder.status == OrderStatus.completed || 
                                  currentOrder.orderType == OrderType.delivery ||
                                  currentOrder.isVerified,
                    ),
                  ),
                ),

              // Show verification actions (Checked button & Mismatch report) for assigned pickup orders
              if (isArrivedForPickup)
                _buildVerificationActions(context, currentOrder, isModified),

              // Show OTP section for assigned delivery orders only after arrival
              if (currentOrder.status == OrderStatus.assigned && 
                  currentOrder.orderType == OrderType.delivery && 
                  stage == DeliveryStage.reachedDelivery)
                _buildDeliveryOTPSection(context, currentOrder),

              SizedBox(height: 15.h),
              // Image Gallery Section (only if images exist)
              if (currentOrder.pickedImages.isNotEmpty && currentOrder.by != "Per Piece")
                ImageGallerySection(
                  pickedImages: currentOrder.pickedImages,
                  onSeeMore: () => _showImagePickerGrid(context, currentOrder.status == OrderStatus.completed || currentOrder.orderType == OrderType.delivery || !isArrivedForPickup),
                ),

              // Add Image button for assigned pickup orders (always show if applicable)
              if (isArrivedForPickup && currentOrder.by != "Per Piece")
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
              if (currentOrder.status != OrderStatus.completed)
                IgnorePointer(
                  ignoring: isActionDisabled,
                  child: Opacity(
                    opacity: isActionDisabled ? 0.5 : 1.0,
                    child: OrderProgressButton(
                      stage: effectiveStage, 
                      onPressed: isActionDisabled ? () {} : () => _handleProgressAction(context),
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildVerificationList(BuildContext context, OrderModel order, bool isPending, bool isArrived) {
    final isPickup = order.orderType == OrderType.pickup;
    // Disable buttons if already verified OR if driver hasn't arrived for pickup yet
    final isInteractive = !isPending && order.status == OrderStatus.assigned && isPickup && !order.isVerified && isArrived;
    final displayItems = order.items.isEmpty ? widget.items : order.items;

    if (displayItems.isEmpty) return const SizedBox.shrink();

    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero, // Figma usually has no padding here
        leading: Image.asset(AppImages.iconItems, width: 20.sp, height: 20.sp, color: AppColors.primaryBlue),
        title: Text(
          AppText.ItemsLabel, // As per Figma and request, just the label
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
                          onChanged: (isInteractive) ? (_) => context.read<HomeViewModel>().toggleItemVerification(widget.orderid, item.id) : null,
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
                            if (await OrderCard._confirmDeletion(context, item.name)) {
                              try {
                                await context.read<HomeViewModel>().deleteItemFromOrder(widget.orderid, item.id);
                                QuickPopupManager.show(context, message: "Item removed", type: QuickPopupType.success);
                              } catch (e) {
                                QuickPopupManager.show(context, message: "Failed to remove item", type: QuickPopupType.error);
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
          Divider(color: AppColors.grey.withOpacity(0.5)),
        ],
      ),
    );
  }

  Widget _buildDeliveryOTPSection(BuildContext context, OrderModel order) {
    final homeVM = context.read<HomeViewModel>();
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 8.h),
          child: Row(
            children: [
              Icon(
                _otpVerified ? Icons.check_circle_outline : Icons.textsms_outlined,
                color: _otpVerified ? AppColors.green : AppColors.primaryBlue,
                size: 20.sp,
              ),
              SizedBox(width: 8.w),
              Text(
                _otpVerified ? "OTP Verified" : (_otpSent ? "Resend OTP" : "Send OTP"),
                style: GoogleFonts.poppins(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: _otpVerified ? AppColors.green : AppColors.primaryBlue,
                ),
              ),
              if (!_otpVerified) ...[
                const Spacer(),
                SizedBox(
                  width: 133.w,
                  height: 32.h,
                  child: ElevatedButton(
                    onPressed: () async {
                      final success = await homeVM.sendDeliveryOtp(order.orderId);
                      if (success && context.mounted) {
                        setState(() => _otpSent = true);
                        QuickPopupManager.show(context, message: AppText.OtpSentSuccess, type: QuickPopupType.success);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF9E9F9F),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                      padding: EdgeInsets.all(8.w),
                    ),
                    child: Text(_otpSent ? "Resend" : "Send", style: GoogleFonts.poppins(fontSize: 12.sp, color: Colors.white, fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ],
          ),
        ),
        if (_otpSent && !_otpVerified) // Show OTP input field only if OTP has been sent and not yet verified
          Padding(
            padding: EdgeInsets.only(top: 8.h, bottom: 8.h),
            child: Row(
              children: [
                SizedBox(
                  width: 166.79.w,
                  height: 32.h,
                  child: TextField(
                    controller: _otpController,
                    keyboardType: TextInputType.number,
                    maxLength: 4,
                    decoration: InputDecoration(
                      isDense: true,
                      hintText: "Enter 4 digit OTP",
                      counterText: "",
                      hintStyle: GoogleFonts.poppins(fontSize: 12.sp, color: AppColors.grey),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                          borderSide: const BorderSide(color: Color(0xFF000000), width: 1.0)),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                          borderSide: const BorderSide(color: Color(0xFF000000), width: 1.0)),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                          borderSide: const BorderSide(color: Color(0xFF000000), width: 1.0)),
                      contentPadding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
                    ),
                    style: GoogleFonts.poppins(fontSize: 13.sp),
                  ),
                ),
              ],
            ),
          ),
        Divider(color: AppColors.grey.withOpacity(0.5)),
      ],
    );
  }

  Widget _buildVerificationActions(BuildContext context, OrderModel order, bool isModified) {
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
        // Logic: Show the section if order is verified AND (items were changed OR a report already exists)
        // This ensures the section persists after app restart/re-open.
        if (isVerified && 
           (isModified || 
           (order.mismatchReason != null && 
            order.mismatchReason!.isNotEmpty)))
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
                Row(
                  children: [
                    Text("Report Item Mismatch", style: GoogleFonts.poppins(fontSize: 13.sp, fontWeight: FontWeight.w600, color: AppColors.errorRed)),
                    const Spacer(),
                    // Show tick if the current text matches what was sent successfully
                    if (_reportSentSuccess && _mismatchController.text.trim() == _lastSentReportText && _lastSentReportText.isNotEmpty)
                      Icon(Icons.check_circle, color: AppColors.green, size: 18.sp),
                    // Show error icon if the last attempt failed
                    if (_reportSentFailed)
                      Icon(Icons.error, color: AppColors.errorRed, size: 18.sp),
                  ],
                ),
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
                
                // Professional Logic: Only show buttons if the current text differs from the last successfully sent report.
                if (_mismatchController.text.trim() != _lastSentReportText)
                // Show buttons if text has changed from what was sent, or if never sent successfully.
                if (_isUserEditing || !_reportSentSuccess)
                  Padding(
                    padding: EdgeInsets.only(top: 10.h),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              _mismatchController.clear();
                              setState(() {
                                _reportSentFailed = false;
                                // If no report was ever sent, we reset the success state.
                                if (_lastSentReportText.isEmpty) _reportSentSuccess = false;
                                _isUserEditing = _lastSentReportText.isNotEmpty;
                              });
                            },
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: AppColors.grey), 
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r))
                            ),
                            child: Text("Clear", style: GoogleFonts.poppins(fontSize: 12.sp, color: AppColors.grey, fontWeight: FontWeight.w600)),
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: (_isSendingReport || _mismatchController.text.trim().isEmpty) 
                                ? null 
                                : _handleMismatchReportSubmission,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryBlue,
                              disabledBackgroundColor: AppColors.grey,
                              elevation: 0, 
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r))
                            ),
                            child: _isSendingReport 
                              ? SizedBox(height: 15.h, width: 15.h, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                              : Text(
                                  _lastSentReportText.isEmpty ? "Enter" : "Resend", 
                                  style: GoogleFonts.poppins(fontSize: 12.sp, color: Colors.white, fontWeight: FontWeight.w600)
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        Divider(color: AppColors.grey.withOpacity(0.5)),
      ],
    );
  }

  Future<void> _handleMismatchReportSubmission() async {
    final reportText = _mismatchController.text.trim();
    setState(() {
      _isSendingReport = true;
      _reportSentFailed = false;
    });
    
    final success = await context.read<HomeViewModel>().reportItemMismatch(widget.orderid, reportText);
    
    if (mounted) {
      setState(() {
        _isSendingReport = false;
        if (success) {
          _reportSentSuccess = true;
          _lastSentReportText = reportText;
          _isUserEditing = false;
          QuickPopupManager.show(context, message: "Report successfully sent", type: QuickPopupType.success);
        } else {
          _reportSentFailed = true;
        }
      });
    }
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
    
    // Use effective logic to determine what action to take
    DeliveryStage stage = currentOrder.deliveryStage;
    if (stage == DeliveryStage.uploadImages && currentOrder.pickedImages.isNotEmpty) {
      stage = DeliveryStage.orderPicked;
    }

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
        QuickPopupManager.show(
          context, 
          message: "Images uploaded successfully", 
          type: QuickPopupType.success
        );

        homeVM.updateOrderStage(widget.orderid, DeliveryStage.orderPicked);
      }
    } else if (stage == DeliveryStage.orderPicked) {
      // Connect to confirm-pickup API endpoint
      final success = await homeVM.confirmPickup(widget.orderid);
      if (success && context.mounted) {
        await _showStatusDialog(context, AppImages.orderPickedGif, AppText.OrderPickedTitle);
        homeVM.setSelectedFilter("completed");
      }
    } else if (stage == DeliveryStage.startDelivery) {
      final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => const DeliveryLocationScreen()));
      if (!context.mounted) return;
      if (result == true) {
        homeVM.updateOrderStage(widget.orderid, DeliveryStage.reachedDelivery);
      }
    } else if (stage == DeliveryStage.reachedDelivery) {
      // If OTP is not yet verified, attempt to verify it using the input from _otpController
      if (!_otpVerified) {
        if (_otpController.text.length != 4) {
          QuickPopupManager.show(context, message: "Enter 4 digit OTP", type: QuickPopupType.error);
          return;
        }
        setState(() => _isVerifyingOtp = true);
        final success = await homeVM.verifyDeliveryOtp(currentOrder.orderId, _otpController.text);
        if (context.mounted) {
          setState(() => _isVerifyingOtp = false);
          if (!success) {
            QuickPopupManager.show(context, message: AppText.InvalidOtp, type: QuickPopupType.error);
            return; // Stop if OTP verification fails
          }
          setState(() => _otpVerified = true); // Mark as verified if successful
        }
      }
      
      // The backend 'verifyDeliveryOtp' already updates status to DELIVERED and marks it complete.
      await _showStatusDialog(context, AppImages.successGif, AppText.OrderDeliveredTitle); // Show success dialog after verification
      if (!context.mounted) return;
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
    if (images.isNotEmpty && context.mounted) {
      await context.read<HomeViewModel>().addOrderImages(widget.orderid, images.map((i) => i.path).toList());
      QuickPopupManager.show(
        context, 
        message: "Images uploaded successfully", 
        type: QuickPopupType.success
      );
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
