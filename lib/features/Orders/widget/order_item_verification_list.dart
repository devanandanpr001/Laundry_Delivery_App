import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:ziya_laundry_deliveryapp/Constants/app_colors.dart';
import 'package:ziya_laundry_deliveryapp/Constants/app_images.dart';
import 'package:ziya_laundry_deliveryapp/Constants/app_strings.dart';
import 'package:ziya_laundry_deliveryapp/features/Home/data/model/home_models.dart';
import 'package:ziya_laundry_deliveryapp/features/Orders/viewmodel/order_viewmodel.dart';
import 'package:quick_popup_manager/quick_popup_manager.dart';

class OrderItemVerificationList extends StatefulWidget {
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
  State<OrderItemVerificationList> createState() => _OrderItemVerificationListState();
}

class _OrderItemVerificationListState extends State<OrderItemVerificationList> {
  final Set<int> _selectedIndexes = {};

  @override
  void didUpdateWidget(covariant OrderItemVerificationList oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.displayItems.length != oldWidget.displayItems.length || widget.orderId != oldWidget.orderId) {
      _selectedIndexes.removeWhere((i) => i < 0 || i >= widget.displayItems.length);
    }

    if (_selectedIndexes.length == widget.displayItems.length && widget.displayItems.isNotEmpty) {
      _selectedIndexes.remove(widget.displayItems.length - 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPickup = widget.order.orderType == OrderType.pickup;

    // Use current view-model state to avoid stale widget.order values.
    // This makes the delete confirmation appear immediately after add/delete without waiting for refresh.
    final orderVM = context.watch<OrderViewModel>();
    final currentOrder = orderVM.orders.firstWhere(
      (o) => o.orderId == widget.orderId && o.orderType == widget.order.orderType,
      orElse: () => widget.order,
    );

    final isInteractive = !widget.isPending &&
        currentOrder.status == OrderStatus.assigned &&
        isPickup &&
        !currentOrder.isVerified &&
        widget.isArrived;

    if (widget.displayItems.isEmpty) return const SizedBox.shrink();

    final selectedCount = _selectedIndexes.length;

    return Theme(
      data: Theme.of(context).copyWith(
        dividerColor: Colors.transparent,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
      ),
      child: ExpansionTile(
        backgroundColor: const Color(0xffD9E3FF),
        collapsedBackgroundColor: const Color(0xffD9E3FF),
        tilePadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 0.h),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
        collapsedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
        
        leading: Image.asset(AppImages.iconItems, width: 20.r, height: 20.r, color: AppColors.primaryBlue),
        title: Text(
          AppText.ItemsLabel,
          style: GoogleFonts.poppins(fontSize: 14.sp, fontWeight: FontWeight.w600, color: AppColors.primaryBlue),
        ),
        children: [
          Container(
            color: Colors.white,
            padding: EdgeInsets.only(top: 8.h),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: 220.h),
              child: ListView.builder(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemCount: widget.displayItems.length,
                itemBuilder: (context, index) {
                  final item = widget.displayItems[index];
                  final isSelected = _selectedIndexes.contains(index);
                  final bool wouldLeaveEmpty = selectedCount == widget.displayItems.length - 1 && !isSelected;

                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: EdgeInsets.symmetric(vertical: 3.h, horizontal: 4.w),
                    padding: EdgeInsets.symmetric(vertical: 6.h, horizontal: 8.w),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xffD9E3FF) : Colors.transparent,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          height: 24.r,
                          width: 24.r,
                          child: Checkbox(
                            value: isSelected,
                            activeColor: AppColors.primaryBlue,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.r)),
                            onChanged: (isInteractive && !wouldLeaveEmpty)
                                ? (value) {
                                    setState(() {
                                      if (value == true) {
                                        _selectedIndexes.add(index);
                                      } else {
                                        _selectedIndexes.remove(index);
                                      }
                                    });
                                  }
                                : null,
                          ),
                        ),
                        SizedBox(width: 12.w),

                        Expanded(
                          child: Text(
                            item.name,
                            textAlign: TextAlign.start,
                            style: GoogleFonts.poppins(
                              fontSize: 13.sp,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                              decoration: item.isVerified ? TextDecoration.lineThrough : null,
                              color: item.isVerified 
                                  ? AppColors.textGrey 
                                  : (isSelected ? AppColors.primaryBlue : AppColors.textDark),
                            ),
                          ),
                        ),

                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 3.h),
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.white : AppColors.lightBlue, 
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          child: Text(
                            "x${item.qty}",
                            style: GoogleFonts.poppins(
                              fontSize: 12.sp, 
                              fontWeight: FontWeight.bold, 
                              color: AppColors.primaryBlue
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),

          if (selectedCount > 0 && selectedCount < widget.displayItems.length) ...[
            Container(
              color: Colors.white,
              padding: EdgeInsets.only(bottom: 6.h, top: 4.h, left: 4.w, right: 4.w),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(
                    color: AppColors.grey.withValues(alpha: 0.12),
                    width: 1.r,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 6.r,
                      offset: Offset(0, 2.h),
                    )
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 22.r,
                          height: 22.r,
                          alignment: Alignment.center,
                          decoration: const BoxDecoration(
                            color: AppColors.primaryBlue,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '$selectedCount',
                            style: GoogleFonts.poppins(fontSize: 11.sp, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          'items selected',
                          style: GoogleFonts.poppins(fontSize: 12.sp, fontWeight: FontWeight.w500, color: AppColors.textDark),
                        ),
                      ],
                    ),
                    
                    OutlinedButton.icon(
                      onPressed: isInteractive
                          ? () async {
                              // Ensure any existing popup stack is dismissed before opening confirmation.
                              // This is required because QuickPopupManager popups can remain on top.
                              // ignore: invalid_use_of_protected_member
                              QuickPopupManager().dismissAll();

                              final orderVM = context.read<OrderViewModel>();
                              final stateMounted = mounted;

                              final idsToDelete = _selectedIndexes
                                  .map((i) => widget.displayItems[i].id)
                                  .where((id) => id.isNotEmpty)
                                  .toList();

                              if (idsToDelete.isEmpty) return;

                              final bool confirmed = await widget.onConfirmDeletion(
                                context,
                                'Delete ${idsToDelete.length} selected items?',
                              );

                              if (!confirmed) return;

                              try {
                                for (final itemId in idsToDelete) {
                                  await orderVM.deleteItemFromOrderNoRefresh(widget.orderId, itemId);
                                }
                              } catch (e) {
                                // Error is handled gracefully by the viewmodel
                              }
                              if (stateMounted) {
                                setState(() => _selectedIndexes.clear());
                              }
                            }
                          : null,
                      icon: Icon(Icons.delete_outline, size: 14.r, color: AppColors.errorRed),
                      label: Text(
                        'Delete Selected',
                        maxLines: 1,
                        style: GoogleFonts.poppins(fontSize: 11.sp, fontWeight: FontWeight.w600),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.errorRed,
                        side: BorderSide(color: AppColors.errorRed, width: 1.r),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6.r)),
                        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                        minimumSize: Size(95.w, 32.h),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 6.h),
          ],
        ],
      ),
    );
  }
}