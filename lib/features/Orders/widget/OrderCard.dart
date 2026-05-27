
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:ziya_laundry_deliveryapp/core/Constants/app_colors.dart';
import 'package:ziya_laundry_deliveryapp/features/Orders/data/model/order_model.dart';
import 'package:collection/collection.dart'; // Import for firstWhereOrNull
import 'package:ziya_laundry_deliveryapp/core/Constants/app_images.dart';
import 'package:ziya_laundry_deliveryapp/core/Constants/app_strings.dart';
import 'package:ziya_laundry_deliveryapp/features/Orders/viewmodel/DeliveryStage.dart';
import 'package:ziya_laundry_deliveryapp/common_widget/AppToast.dart';
import 'package:ziya_laundry_deliveryapp/common_widget/premium_dialog.dart';
import 'package:ziya_laundry_deliveryapp/features/Orders/view/DeliveryLocation_Screen.dart';
import 'package:ziya_laundry_deliveryapp/features/Orders/view/PickUp_location.dart';
import 'package:ziya_laundry_deliveryapp/features/Orders/view/Gallery_Screen.dart';
import 'package:ziya_laundry_deliveryapp/features/Orders/view/camera_capture_screen.dart';
import 'package:ziya_laundry_deliveryapp/features/Orders/widget/Bundle_Dialog.dart';
import 'package:ziya_laundry_deliveryapp/features/Orders/widget/add_item_dialog.dart';
import 'package:ziya_laundry_deliveryapp/features/Orders/viewmodel/order_viewmodel.dart';
import 'package:ziya_laundry_deliveryapp/features/Orders/widget/order_card_elements.dart'; // Keep this for UI elements
import 'package:ziya_laundry_deliveryapp/features/Home/viewmodel/home_viewmodel.dart';
import 'package:ziya_laundry_deliveryapp/features/Orders/widget/order_item_verification_list.dart';
import 'package:ziya_laundry_deliveryapp/features/Orders/widget/mismatch_reason_display.dart';
import 'package:ziya_laundry_deliveryapp/features/Orders/widget/add_image_button.dart';
import 'package:ziya_laundry_deliveryapp/features/Orders/widget/delivery_otp_section.dart';
import 'package:ziya_laundry_deliveryapp/features/Orders/widget/pickup_verification_actions.dart';
import 'package:ziya_laundry_deliveryapp/features/Orders/widget/order_header_section.dart';
import 'package:ziya_laundry_deliveryapp/features/Orders/widget/order_customer_details.dart';
import 'package:ziya_laundry_deliveryapp/features/Orders/widget/order_payment_info.dart';
// Removed some unused imports to clean analyzer warnings

class OrderCard extends StatefulWidget {
  final String orderid;
  final String orderNumber;
  final String name;
  final String by;
  final String address;
  final OrderType orderType;
  final bool isPaid;
  final bool isDetailsPage;
  final Function()? onAccept;
  final List<OrderItem> items;
  final VoidCallback? onViewTap;

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
    this.onAccept,
    required this.items,
    this.onViewTap,
  });

  @override
  State<OrderCard> createState() => _OrderCardState();

  /// Shows a confirmation dialog before deleting an item or bundle.
  static Future<bool> _confirmDeletion(BuildContext context, String itemName) async {
    return await showPremiumConfirmationDialog(
      context,
      title: 'Confirm Deletion',
      description: "Are you sure you want to remove '$itemName'?",
      confirmText: 'Delete',
      cancelText: 'Cancel',
      confirmColor: AppColors.errorRed,
    );
  }
}

class _OrderCardState extends State<OrderCard> {
  final TextEditingController _otpController = TextEditingController(); // Still needed for _handleProgressAction
  
  bool _otpVerified = false; // State for OTP verification status
  bool _isOpeningAddItem = false; // Guard to prevent multiple dialogs
  bool _isVerifyingOtp = false; // Local state for verifying OTP

  // Baseline tracking to detect additions or deletions professionally
  int? _baselineItemCount;
  int? _baselineBundleCount;

  @override
  void initState() {
    super.initState();
    _otpController.addListener(() => setState(() {}));

    final orderVM = context.read<OrderViewModel>();
    final orderIndex = orderVM.orders.indexWhere((o) => o.orderId == widget.orderid && o.orderType == widget.orderType);
    if (orderIndex != -1) {
      _baselineItemCount = orderVM.orders[orderIndex].items.length;
      _baselineBundleCount = orderVM.orders[orderIndex].bundles.length;
    }
  }

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Optimized: Only rebuild if the specific order or online status changes
    final homeVM = context.watch<HomeViewModel>();
    final orderVM = context.watch<OrderViewModel>();
    final currentOrder = orderVM.orders.firstWhereOrNull((o) => o.orderId == widget.orderid); // Safely look up the order.
    
    // If the order data is missing (e.g. after a logout or failed refresh), 
    // don't try to render the card to avoid errors.
    if (currentOrder == null) return const SizedBox.shrink();

    final isOnline = homeVM.isOnline;
    
    final isPending = currentOrder.status == OrderStatus.pending;
    final stage = currentOrder.status == OrderStatus.completed 
        ? DeliveryStage.delivered 
        : currentOrder.deliveryStage;

    final bool isModified = _baselineItemCount != null && 
                           (currentOrder.items.length != _baselineItemCount || 
                            currentOrder.bundles.length != _baselineBundleCount);

    // Driver can only edit or verify items after clicking 'Start to Pick up' and arriving at the location.
    final bool isArrivedForPickup = currentOrder.orderType == OrderType.pickup && 
                                   currentOrder.status == OrderStatus.assigned &&
                                   currentOrder.deliveryStage != DeliveryStage.startPickup;

    // Professional Recovery: If images exist, the next logical step is always "Order Picked"
    // This handles app crashes or restarts after images were uploaded.
    DeliveryStage effectiveStage = stage;
    if (stage == DeliveryStage.uploadImages && currentOrder.pickedImages.isNotEmpty) {
      effectiveStage = DeliveryStage.orderPicked;
    }

    final bool isWeightPickupMissingImages = currentOrder.orderType == OrderType.pickup && 
                                             currentOrder.by == "By Weight" && 
                                             effectiveStage == DeliveryStage.orderPicked && 
                                             currentOrder.pickedImages.isEmpty;

    // NEW LOGIC FOR BY WEIGHT VERIFICATION
    // Automatically mark 'By Weight' pickup orders as verified once images are uploaded
    // and the driver has arrived, if not already verified.
    if (currentOrder.orderType == OrderType.pickup &&
        currentOrder.by == "By Weight" &&
        isArrivedForPickup &&
        !isWeightPickupMissingImages &&
        !currentOrder.isVerified) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          context.read<OrderViewModel>().verifyOrder(widget.orderid);
        }
      });
    }

    // Mismatch report required if items were changed
    final bool isMismatchReportRequired = isModified || currentOrder.isMismatch;

    // Enable only after mismatch report successfully submitted
    final bool isMismatchReportSubmitted =
        currentOrder.mismatchReason != null &&
        currentOrder.mismatchReason!.trim().isNotEmpty;

    // Pending when modified but report not submitted
    final bool isMismatchReportPending =
        isArrivedForPickup &&
        currentOrder.isVerified &&
        isMismatchReportRequired &&
        !isMismatchReportSubmitted;

    // Condition for "Order Picked" button:
    // It should be disabled if a mismatch report is required but not yet submitted.
    final bool disableOrderPickedDueToMismatch = isMismatchReportPending && effectiveStage == DeliveryStage.orderPicked;

    // Condition: Disable the final delivery button until OTP is verified OR disable pickup progress buttons until items are verified (Checked).
    // Also disable Order Picked button if mismatch report is required but not submitted yet.
    final bool isActionDisabled = 
        (currentOrder.orderType == OrderType.delivery && 
         effectiveStage == DeliveryStage.reachedDelivery && 
         !_otpVerified && (_otpController.text.length != 4 || _isVerifyingOtp)) ||
        (isArrivedForPickup && !currentOrder.isVerified) || // Disable if not verified
        disableOrderPickedDueToMismatch || // Disable if mismatch report is pending for Order Picked stage
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
            OrderHeaderSection(
              orderNumber: widget.orderNumber,
              isPending: isPending,
              stage: stage,
              orderType: currentOrder.orderType,
            ),
            OrderCustomerDetails(
              name: widget.name,
              by: widget.by,
              address: widget.address,
            ),
            OrderPaymentInfo(
              order: currentOrder,
              isPending: isPending,
              isPaid: widget.isPaid,
            ),
            // Show mismatch details if:
            // 1. Order is completed, OR
            // 2. Order is assigned and has a mismatch reason recorded, OR
            // 3. Order has mismatch reason at any stage
            if (currentOrder.mismatchReason != null && currentOrder.mismatchReason!.trim().isNotEmpty)
              MismatchReasonDisplay(
                mismatchReason: currentOrder.mismatchReason,
                orderStatus: currentOrder.status,
              ),
            SizedBox(height: 10.h),
            if (isPending) ...[
              if (widget.isDetailsPage) ...[
                if (widget.by == "Per Piece")
                  OrderItemVerificationList(
                    order: currentOrder,
                    orderId: widget.orderid,
                    isPending: true,
                    isArrived: false,
                    displayItems: currentOrder.items.isEmpty ? widget.items : currentOrder.items,
                    onConfirmDeletion: OrderCard._confirmDeletion,),
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
              if (widget.by == "Per Piece")
                OrderItemVerificationList(
                  order: currentOrder,
                  orderId: widget.orderid,
                  isPending: false,
                  isArrived: isArrivedForPickup,
                  displayItems: currentOrder.items.isEmpty ? widget.items : currentOrder.items,
                  onConfirmDeletion: OrderCard._confirmDeletion,),
              
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
                      final orderVM = context.read<OrderViewModel>();
                      if (await OrderCard._confirmDeletion(context, bundleName)) {
                        try {
                          await orderVM.removeOrderBundle(widget.orderid, i);
                          if (!mounted) return;
                          AppToast.showSuccess(title: "Success", message: "Bundle removed");
                        } catch (e) {
                          if (!mounted) return;
                          AppToast.showError(title: "Error", message: "Failed to remove bundle");
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
              if (isArrivedForPickup) ...[
                PickupVerificationActions(
                  order: currentOrder,
                  orderId: widget.orderid,
                  by: widget.by,
                  isModified: isModified,
                  onShowAddItemDialog: () => _showAddItemDialog(context),
                ),
              ],

              // Show OTP section for assigned delivery orders only after arrival
              if (currentOrder.orderType == OrderType.delivery &&
                  stage == DeliveryStage.reachedDelivery)
                DeliveryOtpSection(order: currentOrder, orderId: widget.orderid, otpController: _otpController, otpVerified: _otpVerified, onOtpVerifiedChanged: (value) => setState(() => _otpVerified = value)),

              SizedBox(height: 15.h),
              // Image Gallery Section (only if images exist)
              if (currentOrder.pickedImages.isNotEmpty)
                ImageGallerySection(
                  pickedImages: currentOrder.pickedImages,
                  onSeeMore: () => _showImagePickerGrid(context, currentOrder.status == OrderStatus.completed || currentOrder.orderType == OrderType.delivery || !isArrivedForPickup),
                ),

              // Add Image button for assigned pickup orders (always show if applicable)
              if (isArrivedForPickup)
                AddImageButton(
                  onAddImage: _handleAddImage,
                ),
              if (currentOrder.status != OrderStatus.completed)
                Column(
                  children: [
                    if (isMismatchReportPending && currentOrder.deliveryStage == DeliveryStage.orderPicked)
                      Padding( // This message is shown when the button is disabled due to pending mismatch report
                        padding: EdgeInsets.only(bottom: 8.h),
                        child: Container(
                          padding: EdgeInsets.all(10.w),
                          decoration: BoxDecoration(
                            color: AppColors.errorRed.withValues(alpha: 0.1),
                            border: Border.all(color: AppColors.errorRed.withValues(alpha: 0.3), width: 1.r),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.info_outline, color: AppColors.errorRed, size: 16.sp),
                              SizedBox(width: 8.w),
                              Expanded(
                                child: Text(
                                  "Please submit the item mismatch report before proceeding",
                                  style: GoogleFonts.poppins(fontSize: 11.sp, color: AppColors.errorRed, fontWeight: FontWeight.w500),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    IgnorePointer(
                      ignoring: isActionDisabled,
                      child: Opacity(
                        opacity: isActionDisabled ? 0.5 : 1.0,
                        child: OrderProgressButton(
                          stage: effectiveStage, 
                          onPressed: isActionDisabled ? () {
                            if (isMismatchReportPending && currentOrder.deliveryStage == DeliveryStage.orderPicked) {
                              AppToast.showInfo(
                                title: "Mismatch Report Required",
                                message: "Please report any item discrepancies before moving forward",
                              );
                            }
                          } : () => _handleProgressAction(context),
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ],
        ),
      ),
    );
  }

  void _openBundleDialog(BuildContext context) async {
    final orderVM = context.read<OrderViewModel>();
    final result = await showDialog(
      context: context, 
      builder: (context) => BundleDialog(orderId: widget.orderid));
    if (result != null) { // Use orderVM
      orderVM.addOrderBundle(widget.orderid, result);
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
    final homeVM = context.read<HomeViewModel>(); // For setSelectedFilter
    final orderVM = context.read<OrderViewModel>();
    final currentOrder = orderVM.orders.firstWhere((o) => o.orderId == widget.orderid);
    
    // Use effective logic to determine what action to take
    DeliveryStage stage = currentOrder.deliveryStage;
    if (stage == DeliveryStage.uploadImages && currentOrder.pickedImages.isNotEmpty) {
      stage = DeliveryStage.orderPicked;
    }

    if (stage == DeliveryStage.startPickup) {
      final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => const PickupLocationScreen())); // Simulate location confirmation
      if (!context.mounted) return;
      if (result == true) {
        final nextStage = currentOrder.by == "Per Piece" ? DeliveryStage.orderPicked : DeliveryStage.uploadImages;
        orderVM.updateOrderStage(widget.orderid, nextStage);
      }
    } else if (stage == DeliveryStage.uploadImages) {
      final didUpload = await Navigator.push<bool>(
        context,
        MaterialPageRoute(builder: (_) => CameraCaptureScreen(orderId: widget.orderid)),
      );
      if (!context.mounted) return;
      if (didUpload == true) {
        // Update stage immediately for snappy UI
        orderVM.updateOrderStage(widget.orderid, DeliveryStage.orderPicked);
        // Trigger refresh in background
        orderVM.fetchAllOrders(); 
        AppToast.showSuccess(title: "Success", message: "Images uploaded successfully");
      }
    } else if (stage == DeliveryStage.orderPicked) {
      // Connect to confirm-pickup API endpoint
      final success = await orderVM.confirmPickup(widget.orderid);
      if (success && mounted) {
        await _showStatusDialog(context, AppImages.orderPickedGif, AppText.OrderPickedTitle);
        homeVM.setSelectedFilter("completed");
        homeVM.refreshOrders(); // Sync counts after state change
      }
    } else if (stage == DeliveryStage.startDelivery) {
      final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => const DeliveryLocationScreen()));
      if (!context.mounted) return;
      if (result == true) {
        orderVM.updateOrderStage(widget.orderid, DeliveryStage.reachedDelivery);
        AppToast.showSuccess(title: "Arrived", message: "You have reached the delivery location");
      }
    } else if (stage == DeliveryStage.reachedDelivery) {
      // If OTP is not yet verified, attempt to verify it using the input from _otpController
      if (!_otpVerified) {
        if (_otpController.text.length != 4) {
          AppToast.showError(
            // context: context,
            title: "Validation Error",
            message: "Enter 4 digit OTP",
          );
          return;
        }
        setState(() => _isVerifyingOtp = true); // Set local loading state for the main button
        final success = await orderVM.verifyDeliveryOtp(currentOrder.orderId, _otpController.text); // Use orderVM
        if (mounted) {
          setState(() => _isVerifyingOtp = false);
          if (!success) {
            AppToast.showError(
              title: "Verification Failed",
              message: AppText.InvalidOtp,
              // context: context,
            );
            return; // Stop if OTP verification fails
          }
          setState(() => _otpVerified = true); // Mark as verified if successful
        }
      }

      if (!mounted) return;
      if (!context.mounted) return;
      // The backend 'verifyDeliveryOtp' already updates status to DELIVERED and marks it complete.
      await _showStatusDialog(context, AppImages.successGif, AppText.OrderDeliveredTitle); // Show success dialog after verification

      if (mounted) {
        homeVM.setSelectedFilter("completed");
        homeVM.refreshOrders(); // Sync counts after state change
      }
    }
  }

  Future<void> _showStatusDialog(BuildContext context, String asset, String text) async {
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Image.asset(asset, height: 120.h),
        SizedBox(height: 10.h),
        Text(text, style: GoogleFonts.poppins(fontSize: 24.sp, fontWeight: FontWeight.w500, color: AppColors.green, decoration: TextDecoration.none)),
      ])),
    );
    await Future.delayed(const Duration(seconds: 3));
    if (context.mounted) Navigator.pop(context);
  }

  Future<void> _handleAddImage() async {
    final didUpload = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => CameraCaptureScreen(orderId: widget.orderid)),
    );
    if (didUpload == true && mounted) {
      context.read<OrderViewModel>().fetchAllOrders(); // Refresh in background
      AppToast.showSuccess(
        title: "Success",
        message: "Images uploaded successfully",
      );
    }
  }

  // Method to show the AddItemDialog and handle the result
  void _showAddItemDialog(BuildContext context) async {
    if (_isOpeningAddItem) return;
    setState(() => _isOpeningAddItem = true);
    await showDialog(
      context: context,
      builder: (context) => AddItemDialog(orderId: widget.orderid),
    );
    if (mounted) setState(() => _isOpeningAddItem = false);
  }
}
