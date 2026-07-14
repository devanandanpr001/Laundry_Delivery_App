 
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:ziya_laundry_deliveryapp/Constants/app_colors.dart';
import 'package:collection/collection.dart';
import 'package:ziya_laundry_deliveryapp/features/Orders/data/model/order_model.dart';
import 'package:ziya_laundry_deliveryapp/Constants/app_strings.dart';
import 'package:ziya_laundry_deliveryapp/features/Orders/viewmodel/order_viewmodel.dart';
import 'package:ziya_laundry_deliveryapp/features/Orders/viewmodel/DeliveryStage.dart';
import 'package:ziya_laundry_deliveryapp/common_widget/AppToast.dart';
import 'package:ziya_laundry_deliveryapp/common_widget/AppLoader.dart';
import 'package:ziya_laundry_deliveryapp/common_widget/premium_dialog.dart';
import 'package:ziya_laundry_deliveryapp/features/Orders/view/DeliveryLocation_Screen.dart';
import 'package:ziya_laundry_deliveryapp/features/Orders/view/PickUp_location.dart';
import 'package:ziya_laundry_deliveryapp/features/Orders/view/Gallery_Screen.dart';
import 'package:ziya_laundry_deliveryapp/features/Orders/view/camera_capture_screen.dart';
import 'package:ziya_laundry_deliveryapp/features/Orders/widget/Bundle_Dialog.dart';
import 'package:ziya_laundry_deliveryapp/features/Orders/widget/add_item_dialog.dart';
import 'package:ziya_laundry_deliveryapp/features/Orders/widget/order_card_elements.dart';
import 'package:ziya_laundry_deliveryapp/features/Home/viewmodel/home_viewmodel.dart';
import 'package:ziya_laundry_deliveryapp/features/Orders/widget/order_item_verification_list.dart';
import 'package:ziya_laundry_deliveryapp/features/Orders/widget/mismatch_reason_display.dart';
import 'package:ziya_laundry_deliveryapp/features/Orders/widget/add_image_button.dart';
import 'package:ziya_laundry_deliveryapp/features/Orders/widget/delivery_otp_section.dart';
import 'package:ziya_laundry_deliveryapp/features/Orders/widget/pickup_verification_actions.dart';
import 'package:ziya_laundry_deliveryapp/features/Orders/widget/order_header_section.dart';
import 'package:ziya_laundry_deliveryapp/features/Orders/widget/order_customer_details.dart';
import 'package:ziya_laundry_deliveryapp/features/Orders/widget/order_payment_info.dart';
import 'package:ziya_laundry_deliveryapp/features/Orders/widget/success_splash_screen.dart';

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
  final bool isOnline;
  final HomeViewModel homeVM;
  final bool fullBorder;

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
    required this.isOnline,
    required this.homeVM,
    this.fullBorder = false,
  });

  @override
  State<OrderCard> createState() => _OrderCardState();

  static Future<bool> _confirmDeletion(BuildContext context, String itemName) async {
    return await showPremiumConfirmationDialog(
      context,
      title: 'Delete Item?',
      description: "Are you sure you want to delete this item?",
      confirmText: 'Yes',
      cancelText: 'No',
    );
  }
}

class _OrderCardState extends State<OrderCard> {
  final TextEditingController _otpController = TextEditingController(); // Still needed for _handleProgressAction
  
  bool _otpVerified = false; // State for OTP verification status
  bool _isOpeningAddItem = false; // Guard to prevent multiple dialogs
  bool _isVerifyingOtp = false; // Local state for verifying OTP
  bool _isActionLoading = false; // For main progress button

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
    final orderVM = context.watch<OrderViewModel>();
    final currentOrder = orderVM.orders.firstWhereOrNull((o) => o.orderId == widget.orderid);
    
    if (currentOrder == null) return const SizedBox.shrink();

    final isOnline = widget.isOnline;
    
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

    
    // if (currentOrder.orderType == OrderType.pickup &&
    //     currentOrder.by == "By Weight" &&
    //     isArrivedForPickup &&
    //     !isWeightPickupMissingImages &&
    //     !currentOrder.isVerified) {
    //   WidgetsBinding.instance.addPostFrameCallback((_) {
    //     if (mounted) {
    //       context.read<OrderViewModel>().verifyOrder(widget.orderid);
    //     }
    //   });
    // }

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
         (!_otpVerified && (_otpController.text.length != 4 || _isVerifyingOtp))) ||
        _isActionLoading || // Disable when any action is loading
        (isArrivedForPickup && !currentOrder.isVerified) || // Disable if not verified
        disableOrderPickedDueToMismatch || // Disable if mismatch report is pending for Order Picked stage
        isWeightPickupMissingImages;

    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: AppColors.white, 
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: widget.fullBorder
            ? null
            : [
                BoxShadow(
                  color: Color(0x40000000),
                  blurRadius: 0,
                  spreadRadius: 1,
                  offset: Offset(0, 0),
                ),
              ],
        border: widget.fullBorder
            ? Border.all(color: Color(0x40000000), width: 1)
            : Border.all(color: AppColors.grey.withValues(alpha: 0.15), width: 1),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: isPending ? 14.h : 16.h),
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
                ? OrderProgressButton(
                    text: AppText.BtnAccept, 
                    stage: currentOrder.orderType == OrderType.delivery ? DeliveryStage.startDelivery : DeliveryStage.startPickup, 
                    onPressed: () {
                      if (!isOnline) {
                        AppToast.showOnlineAction(
                          context,
                          isOnline: isOnline,
                          homeVM: widget.homeVM,
                        );
                      } else {
                        widget.onAccept?.call();
                      }
                    })
                : AcceptViewActionRow(
                    isOnline: isOnline, 
                    onView: widget.onViewTap ?? () {}, 
                    onAccept: () {
                      if (!isOnline) {
                        AppToast.showOnlineAction(
                          context,
                          isOnline: isOnline,
                          homeVM: widget.homeVM,
                        );
                      } else {
                        widget.onAccept?.call();
                      }
                    }),
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
                          SuccessSplashScreen.show(context, message: "Bundle removed");
                        } catch (e) {
                          if (!mounted) return;
                          AppToast.showError(
                            context: context,
                            title: "Error", message: "Failed to remove bundle");
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
              
              if (currentOrder.orderType == OrderType.delivery &&
                  stage == DeliveryStage.reachedDelivery) ...[
                  SizedBox(height: 10.h),
                  DeliveryOtpSection(order: currentOrder, orderId: widget.orderid, otpController: _otpController, otpVerified: _otpVerified, onOtpVerifiedChanged: (value) => setState(() => _otpVerified = value)),
                ],
                

              SizedBox(height: 15.h),
              if (currentOrder.pickedImages.isNotEmpty)
                ImageGallerySection(
                  pickedImages: currentOrder.pickedImages,
                  onSeeMore: () => _showImagePickerGrid(context, currentOrder.status == OrderStatus.completed || currentOrder.orderType == OrderType.delivery || !isArrivedForPickup),
                ),

              if (isArrivedForPickup && currentOrder.by == "By Weight")
                AddImageButton(
                  onAddImage: _handleAddImage,
                ),
              if (currentOrder.status != OrderStatus.completed)
                Column(
                  children: [
                    if (isMismatchReportPending && currentOrder.deliveryStage == DeliveryStage.orderPicked)
                      Padding(
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
                          isLoading: _isActionLoading,
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
    AppLoader.navigateWithLoader(
      context,
      GalleryScreen(
        orderId: widget.orderid,
        isReadOnly: isReadOnly,
      ),
    );
  }

  Future<void> _handleProgressAction(BuildContext context) async {
    final homeVM = context.read<HomeViewModel>(); // For setSelectedFilter
    final orderVM = context.read<OrderViewModel>();
    final currentOrder = orderVM.orders.firstWhere((o) => o.orderId == widget.orderid);
    
    setState(() => _isActionLoading = true);
    try {

    // Use effective logic to determine what action to take
    DeliveryStage stage = currentOrder.deliveryStage;
    if (stage == DeliveryStage.uploadImages && currentOrder.pickedImages.isNotEmpty) {
      stage = DeliveryStage.orderPicked;
    }
    if (stage == DeliveryStage.startPickup) {
      final result = await AppLoader.navigateWithLoader(context, const PickupLocationScreen()); // Simulate location confirmation
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
        AppToast.showImageUploadSuccess(context);
      }
    } else if (stage == DeliveryStage.orderPicked) {
      // Connect to confirm-pickup API endpoint
      final success = await orderVM.confirmPickup(widget.orderid);
      if (success && mounted) {
        SuccessSplashScreen.show(context, message: AppText.OrderPickedTitle);
        homeVM.setSelectedFilter("completed");
        homeVM.refreshOrders(); // Sync counts after state change
      }
    } else if (stage == DeliveryStage.startDelivery) {
      final result = await AppLoader.navigateWithLoader(context, const DeliveryLocationScreen());
      if (!context.mounted) return;
      if (result == true) {
        orderVM.updateOrderStage(widget.orderid, DeliveryStage.reachedDelivery);
        SuccessSplashScreen.show(context, message: "You have reached the delivery location");
      }
    } else if (stage == DeliveryStage.reachedDelivery) {
      if (!_otpVerified) {
        if (_otpController.text.length != 4) {
          AppToast.showError(
            title: "Validation Error",
            message: "Enter 4 digit OTP",
            context: context,
          );
          return;
        }
        setState(() => _isVerifyingOtp = true); 
        final success = await orderVM.verifyDeliveryOtp(context, currentOrder.orderId, _otpController.text);

        if (mounted) {

         setState(() => _isVerifyingOtp = false);
          if (!success) {
            AppToast.showError(
              title: "Verification Failed",
              message: AppText.InvalidOtp,
              context: context,
            );
            return; 
          }
          setState(() => _otpVerified = true);
        }
      }

      if (!mounted) return;
      if (!context.mounted) return;
      SuccessSplashScreen.show(context, message: AppText.OrderDeliveredTitle);
      
      if (mounted) {
        homeVM.setSelectedFilter("completed");
        homeVM.refreshOrders();
      }
    }
    } finally {
      if(mounted) {
        setState(() => _isActionLoading = false);
      }
    }
  }

  Future<void> _handleAddImage() async {
    final didUpload = await AppLoader.navigateWithLoader<bool>(
      context,
      CameraCaptureScreen(orderId: widget.orderid),
    );
    if (didUpload == true && mounted) {
      context.read<OrderViewModel>().fetchAllOrders(); 
      AppToast.showImageUploadSuccess(context);
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
