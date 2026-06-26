// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:provider/provider.dart';
// import 'package:ziya_laundry_deliveryapp/Constants/app_colors.dart';
// import 'package:ziya_laundry_deliveryapp/Constants/app_images.dart';
// import 'package:ziya_laundry_deliveryapp/Constants/app_strings.dart';
// import 'package:ziya_laundry_deliveryapp/common_widget/AppToast.dart';
// import 'package:ziya_laundry_deliveryapp/features/Home/data/model/home_models.dart';
// import 'package:ziya_laundry_deliveryapp/features/Orders/viewmodel/order_viewmodel.dart';

// class OrderItemVerificationList extends StatefulWidget {
//   final OrderModel order;
//   final String orderId;
//   final bool isPending;
//   final bool isArrived;
//   final List<OrderItem> displayItems;
//   final Future<bool> Function(BuildContext, String) onConfirmDeletion;

//   const OrderItemVerificationList({
//     super.key,
//     required this.order,
//     required this.orderId,
//     required this.isPending,
//     required this.isArrived,
//     required this.displayItems,
//     required this.onConfirmDeletion,
//   });

//   @override
//   State<OrderItemVerificationList> createState() => _OrderItemVerificationListState();
// }

// class _OrderItemVerificationListState extends State<OrderItemVerificationList> {
//   final Set<int> _selectedIndexes = {};

//   @override
//   void didUpdateWidget(covariant OrderItemVerificationList oldWidget) {
//     super.didUpdateWidget(oldWidget);
//     // If list changes, clear invalid selections to avoid index out-of-range.
//     if (widget.displayItems.length != oldWidget.displayItems.length || widget.orderId != oldWidget.orderId) {
//       _selectedIndexes.removeWhere((i) => i < 0 || i >= widget.displayItems.length);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final isPickup = widget.order.orderType == OrderType.pickup;
//     // Keep existing interactivity rules
//     final isInteractive = !widget.isPending &&
//         widget.order.status == OrderStatus.assigned &&
//         isPickup &&
//         !widget.order.isVerified &&
//         widget.isArrived;

//     if (widget.displayItems.isEmpty) return const SizedBox.shrink();

//     final selectedCount = _selectedIndexes.length;

//     return Theme(
//       data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
//       child: Stack(
//         children: [
//           ExpansionTile(
//             tilePadding: EdgeInsets.zero,
//             leading: Image.asset(AppImages.iconItems, width: 20.sp, height: 20.sp, color: AppColors.primaryBlue),
//             title: Text(
//               AppText.ItemsLabel,
//               style: GoogleFonts.poppins(fontSize: 14.sp, fontWeight: FontWeight.w600, color: AppColors.primaryBlue),
//             ),
//             children: [
//               // Counter row
//               if (selectedCount > 0)
//                 Padding(
//                   padding: EdgeInsets.only(left: 8.w, right: 8.w, bottom: 8.h),
//                   child: Align(
//                     alignment: Alignment.centerLeft,
//                     child: Text(
//                       '$selectedCount ${selectedCount == 1 ? "item" : "items"} selected',
//                       style: GoogleFonts.poppins(fontSize: 13.sp, fontWeight: FontWeight.w600, color: AppColors.primaryBlue),
//                     ),
//                   ),
//                 ),

//               ConstrainedBox(
//                 constraints: BoxConstraints(maxHeight: 200.h),
//                 child: ListView.builder(
//                   shrinkWrap: true,
//                   padding: EdgeInsets.zero,
//                   itemCount: widget.displayItems.length,
//                   itemBuilder: (context, index) {
//                     final item = widget.displayItems[index];
//                     final isSelected = _selectedIndexes.contains(index);

//                     return Padding(
//                       padding: EdgeInsets.symmetric(vertical: 4.h),
//                       child: Row(
//                         children: [
//                           SizedBox(
//                             height: 24.h,
//                             width: 24.w,
//                             child: Checkbox(
//                               value: isSelected,
//                               activeColor: AppColors.primaryBlue,
//                               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.r)),
//                               onChanged: (isInteractive)
//                                   ? (value) {
//                                       setState(() {
//                                         if (value == true) {
//                                           _selectedIndexes.add(index);
//                                         } else {
//                                           _selectedIndexes.remove(index);
//                                         }
//                                       });
//                                     }
//                                   : null,
//                             ),
//                           ),
//                           SizedBox(width: 10.w),

//                           // Center-ish item name
//                           Expanded(
//                             child: Text(
//                               item.name,
//                               textAlign: TextAlign.center,
//                               style: GoogleFonts.poppins(
//                                 fontSize: 13.sp,
//                                 fontWeight: FontWeight.w500,
//                                 decoration: item.isVerified ? TextDecoration.lineThrough : null,
//                                 color: item.isVerified ? AppColors.textGrey : AppColors.textDark,
//                               ),
//                             ),
//                           ),

//                           // Quantity badge
//                           Container(
//                             padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
//                             decoration: BoxDecoration(color: AppColors.lightBlue, borderRadius: BorderRadius.circular(6.r)),
//                             child: Text(
//                               "x${item.qty}",
//                               style: GoogleFonts.poppins(fontSize: 12.sp, fontWeight: FontWeight.bold, color: AppColors.primaryBlue),
//                             ),
//                           ),
//                         ],
//                       ),
//                     );
//                   },
//                 ),
//               ),

//               Divider(color: AppColors.grey.withValues(alpha: 0.5)),
//             ],
//           ),

//           // Bottom-right delete button inside section
//           if (selectedCount > 0)
//             Positioned(
//               right: 12.w,
//               bottom: 16.h,
//               child: ElevatedButton(
//                 onPressed: (isInteractive)
//                     ? () async {
//                         final orderVM = context.read<OrderViewModel>();

//                         final idsToDelete = _selectedIndexes
//                             .map((i) => widget.displayItems[i].id)
//                             .where((id) => id.isNotEmpty)
//                             .toList();

//                         if (idsToDelete.isEmpty) return;

//                         final bool confirmed = await widget.onConfirmDeletion(
//                           context,
//                           'Delete ${idsToDelete.length} selected items?',
//                         );

//                         if (!confirmed) return;

//                         try {
//                           // Delete sequentially to keep backend consistent; UI is small.
//                           for (final itemId in idsToDelete) {
//                             await orderVM.deleteItemFromOrder(widget.orderId, itemId);
//                           }
//                           if (!mounted) return;

//                           setState(() => _selectedIndexes.clear());
//                           AppToast.showItemDeleted(context, itemName: 'Selected items');
//                         } catch (e) {
//                           if (!mounted) return;
//                           AppToast.showError(title: "Error", message: "Failed to remove selected items");
//                         }
//                       }
//                     : null,
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: AppColors.errorRed,
//                   foregroundColor: AppColors.white,
//                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
//                   padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
//                   elevation: 6,
//                 ),
//                 child: Text(
//                   'Delete Selected',
//                   style: GoogleFonts.poppins(fontSize: 13.sp, fontWeight: FontWeight.w700),
//                 ),
//               ),
//             ),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:ziya_laundry_deliveryapp/Constants/app_colors.dart';
import 'package:ziya_laundry_deliveryapp/Constants/app_images.dart';
import 'package:ziya_laundry_deliveryapp/Constants/app_strings.dart';
import 'package:ziya_laundry_deliveryapp/common_widget/AppToast.dart';
import 'package:ziya_laundry_deliveryapp/features/Home/data/model/home_models.dart';
import 'package:ziya_laundry_deliveryapp/features/Orders/viewmodel/order_viewmodel.dart';

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
      // Remove invalid selections (out of range indices)
      _selectedIndexes.removeWhere((i) => i < 0 || i >= widget.displayItems.length);
    }

    // Safety: ensure at least 1 item remains (prevent selecting all for deletion)
    if (_selectedIndexes.length == widget.displayItems.length && widget.displayItems.isNotEmpty) {
      _selectedIndexes.remove(widget.displayItems.length - 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPickup = widget.order.orderType == OrderType.pickup;
    final isInteractive = !widget.isPending &&
        widget.order.status == OrderStatus.assigned &&
        isPickup &&
        !widget.order.isVerified &&
        widget.isArrived;

    if (widget.displayItems.isEmpty) return const SizedBox.shrink();

    final selectedCount = _selectedIndexes.length;

    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        leading: Image.asset(AppImages.iconItems, width: 20.r, height: 20.r, color: AppColors.primaryBlue),
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
              itemCount: widget.displayItems.length,
              itemBuilder: (context, index) {
                final item = widget.displayItems[index];
                final isSelected = _selectedIndexes.contains(index);
                final bool wouldLeaveEmpty = selectedCount == widget.displayItems.length - 1 && !isSelected;

                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 6.h),
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
                            fontWeight: FontWeight.w500,
                            decoration: item.isVerified ? TextDecoration.lineThrough : null,
                            color: item.isVerified ? AppColors.textGrey : AppColors.textDark,
                          ),
                        ),
                      ),

                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 3.h),
                        decoration: BoxDecoration(
                          color: AppColors.lightBlue, 
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Text(
                          "x${item.qty}",
                          style: GoogleFonts.poppins(fontSize: 12.sp, fontWeight: FontWeight.bold, color: AppColors.primaryBlue),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

// Micro Floating Bottom Action Card (Aligned to Right End)
          if (selectedCount > 0 && selectedCount < widget.displayItems.length) ...[
            SizedBox(height: 10.h),
            Card(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(
                    color: AppColors.grey.withValues(alpha: 0.12),
                    width: 1.r,
                  ),
                  // boxShadow: [
                  //   BoxShadow(
                  //     color: Colors.black.withValues(alpha: 0.02),
                  //     blurRadius: 6.r,
                  //     offset: Offset(0, 2.h),
                  //   )
                  // ]
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween, // Pushes everything neatly to the right
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    // Smaller Circular Count Badge
                    Container(
                      width: 20.r,
                      height: 20.r,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        color: AppColors.primaryBlue,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '$selectedCount',
                        style: GoogleFonts.poppins(fontSize: 10.sp, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      'items selected',
                      style: GoogleFonts.poppins(fontSize: 11.sp, fontWeight: FontWeight.w500, color: AppColors.textDark),
                    ),
                    SizedBox(width: 12.w), // Space between text block and compact button
          
                    // Small Red Outlined Delete Action Button
                    OutlinedButton.icon(
                      onPressed: isInteractive
                          ? () async {
                              final orderVM = context.read<OrderViewModel>();
          
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
                                if (!mounted) return;
          
                                setState(() => _selectedIndexes.clear());
                                AppToast.showItemDeleted(context, itemName: 'Selected items');
                              } catch (e) {
                                if (!mounted) return;
                                AppToast.showError(context: context,title: "Error", message: "Failed to remove selected items");
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
                        minimumSize: Size(95.w, 30.h),
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

