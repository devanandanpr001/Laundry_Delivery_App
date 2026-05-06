import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:ziya_laundry_deliveryapp/Constants/app_colors.dart';
import 'package:ziya_laundry_deliveryapp/Constants/app_text.dart';
import 'package:ziya_laundry_deliveryapp/Constants/app_images.dart';
import 'package:ziya_laundry_deliveryapp/Orders/widget/OrderCard.dart';
import '../../Home/viewmodel/home_viewmodel.dart';
import '../../Home/data/model/home_models.dart';

class OrderlistScreen extends StatefulWidget {
  final String initialFilter;
  final VoidCallback onBackToHome;
  const OrderlistScreen({super.key,
    this.initialFilter="all",
    required this.onBackToHome});

  @override
  State<OrderlistScreen> createState() => _OrderlistScreenState();
}

class _OrderlistScreenState extends State<OrderlistScreen> {
  OrderType _selectedType = OrderType.pickup;

  @override
  Widget build(BuildContext context) {
    // Using context.watch to rebuild when relevant VM data changes
    final homeVM = context.watch<HomeViewModel>();
    final selectedFilter = homeVM.selectedFilter;
    final isOnline = homeVM.isOnline;

    // Get page info dynamically
    final (title, subtitle) = _resolvePageInfo(homeVM, selectedFilter);

    // Compute filtered list efficiently
    final filteredOrders = homeVM.orders.where((order) {
      final typeMatch = order.orderType == _selectedType;
      if (!typeMatch) return false;

      if (selectedFilter == "all") return order.status == OrderStatus.pending;
      if (selectedFilter == "assigned") return order.status == OrderStatus.assigned;
      if (selectedFilter == "completed") return order.status == OrderStatus.completed;

      return order.status.name == selectedFilter;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            // Fixed Header Section
            Padding(
              padding: EdgeInsets.all(20.w),
              child: Row(
                children: [
                  IconButton(
                    onPressed: widget.onBackToHome,
                    icon: Icon(Icons.arrow_back_ios, size: 24.sp),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w500, fontSize: 18.sp),
                      ),
                      SizedBox(height: 5.h),
                      Text(
                        subtitle,
                        style: GoogleFonts.poppins(fontSize: 14.sp, fontWeight: FontWeight.w400),
                      ),
                    ],
                  )
                ],
              ),
            ),

            // Type Toggle (Pickup / Delivery)
            Container(
              margin: EdgeInsets.symmetric(horizontal: 20.w),
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: AppColors.borderColorBlue),
              ),
              child: Row(
                children: [
                  _buildTypeToggle(OrderType.pickup, AppText.PickUpOrders),
                  _buildTypeToggle(OrderType.delivery, AppText.DeliveryOrders),
                ],
              ),
            ),

            SizedBox(height: 15.h),

            // Filter Tabs
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildFilterButton(homeVM, "all", AppText.All, 60.w),
                _buildFilterButton(homeVM, "assigned", AppText.Asignd, 90.w),
                _buildFilterButton(homeVM, "completed", AppText.Cmpltd, 110.w),
              ],
            ),

            SizedBox(height: 10.h),

            // Efficient List Rendering
            Expanded(
              child: filteredOrders.isEmpty
                  ? _buildEmptyState(selectedFilter)
                  : ListView.builder(
                      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                      itemCount: filteredOrders.length,
                      itemBuilder: (context, index) {
                        final order = filteredOrders[index];
                        return Padding(
                          padding: EdgeInsets.only(bottom: 15.h),
                          child: OrderCard(
                            onAccept: () => _handleAcceptOrder(context, homeVM, order, isOnline),
                            orderid: order.orderId,
                            orderNumber: order.orderNumber,
                            name: order.name,
                            by: order.by,
                            address: order.address,
                            isPaid: order.isPaid,
                            isDetailsPage: true,
                            showOnlyItems: false,
                            items: order.items,
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeToggle(OrderType type, String label) {
    final isActive = _selectedType == type;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedType = type),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 10.h),
          decoration: BoxDecoration(
            color: isActive ? AppColors.primaryBlue : Colors.transparent,
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.poppins(
                color: isActive ? Colors.white : AppColors.primaryBlue,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterButton(HomeViewModel vm, String filterKey, String label, double width) {
    final isSelected = vm.selectedFilter == filterKey;
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        side: BorderSide(color: AppColors.primaryBlue),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
        backgroundColor: isSelected ? AppColors.primaryBlue : AppColors.white,
        minimumSize: Size(width, 38.h),
      ),
      onPressed: () => vm.setSelectedFilter(filterKey),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 14.sp,
          fontWeight: FontWeight.w500,
          color: isSelected ? AppColors.white : AppColors.primaryBlue,
        ),
      ),
    );
  }

  Widget _buildEmptyState(String filter) {
    String message = AppText.NoOrdersAvailable;
    if (filter == "assigned") message = AppText.NoAssgnd;
    if (filter == "completed") message = AppText.NoCmpltd;

    return Center(
      child: Text(
        message,
        style: GoogleFonts.poppins(
          fontSize: 18.sp,
          fontWeight: FontWeight.w600,
          color: AppColors.grey,
        ),
      ),
    );
  }

  (String title, String subtitle) _resolvePageInfo(HomeViewModel vm, String filter) {
    switch (filter) {
      case "assigned":
        return (AppText.ActiveOrders, "${vm.assignedCount} ${AppText.ActiveTasks}");
      case "completed":
        return (AppText.CompletedOrders, "${vm.completedCount} ${AppText.Delivered}");
      default:
        final count = vm.pendingOrders.length;
        final suffix = count == 1 ? AppText.OrderSingle : AppText.OrderPlural;
        return (AppText.NewOrders, "$count $suffix ${AppText.ReviewedConfirmed}");
    }
  }

  Future<void> _handleAcceptOrder(BuildContext context, HomeViewModel vm, OrderModel order, bool isOnline) async {
    if (!isOnline) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppText.UrOffline)));
      return;
    }

    vm.updateOrderStatus(order.orderId, OrderStatus.assigned);
    vm.setSelectedFilter("assigned");

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(AppImages.successGif, height: 180.h, width: 180.w),
            Text(
              AppText.OrdrAssigned,
              style: GoogleFonts.poppins(fontSize: 22.sp, fontWeight: FontWeight.w600, color: AppColors.green),
            )
          ],
        ),
      ),
    );

    await Future.delayed(const Duration(seconds: 2));
    if (mounted) Navigator.of(context, rootNavigator: true).pop();
  }
 }
//                 ),
//                 SizedBox(height: 20.h,),
//                 Expanded(
//                   child: SingleChildScrollView(
//                     child: Column(
//                       children: [
//                       // Type Toggle (Pickup / Delivery)
//                       Container(
//                         margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
//                         padding: EdgeInsets.all(4.w),
//                         decoration: BoxDecoration(
//                           color: AppColors.white,
//                           borderRadius: BorderRadius.circular(12.r),
//                           border: Border.all(color: AppColors.borderColorBlue),
//                         ),
//                         child: Row(
//                           children: [
//                             Expanded(
//                               child: GestureDetector(
//                                 onTap: () => setState(() => _selectedType = OrderType.pickup),
//                                 child: Container(
//                                   padding: EdgeInsets.symmetric(vertical: 8.h),
//                                   decoration: BoxDecoration(
//                                     color: _selectedType == OrderType.pickup ? AppColors.primaryBlue : Colors.transparent,
//                                     borderRadius: BorderRadius.circular(8.r),
//                                   ),
//                                   child: Center(
//                                     child: Text(AppText.PickUpOrders, style: GoogleFonts.poppins(color: _selectedType == OrderType.pickup ? Colors.white : AppColors.primaryBlue, fontWeight: FontWeight.w600)),
//                                   ),
//                                 ),
//                               ),
//                             ),
//                             Expanded(
//                               child: GestureDetector(
//                                 onTap: () => setState(() => _selectedType = OrderType.delivery),
//                                 child: Container(
//                                   padding: EdgeInsets.symmetric(vertical: 8.h),
//                                   decoration: BoxDecoration(
//                                     color: _selectedType == OrderType.delivery ? AppColors.primaryBlue : Colors.transparent,
//                                     borderRadius: BorderRadius.circular(8.r),
//                                   ),
//                                   child: Center(
//                                     child: Text(AppText.DeliveryOrders, style: GoogleFonts.poppins(color: _selectedType == OrderType.delivery ? Colors.white : AppColors.primaryBlue, fontWeight: FontWeight.w600)),
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                       SizedBox(height: 10.h),
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                           children: [
//                             ////all
//                             ElevatedButton(
//                               style: ElevatedButton.styleFrom(side: BorderSide(color: AppColors.primaryBlue),
//                                 shape: RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.circular(10.r)),
//                                 backgroundColor: selectedFilter == 'all'
//                                     ? AppColors.primaryBlue
//                                     : AppColors.white,
//                                 minimumSize: Size(51.w, 35.h),
//                               ),
//                               onPressed: () => homeVM.setSelectedFilter("all"),

//                               child: Text(AppText.All,style: GoogleFonts.poppins(
//                                 fontSize: 14.sp,fontWeight: FontWeight.w500,
//                                 color: selectedFilter == 'all'
//                                     ? AppColors.white
//                                     : AppColors.primaryBlue,
//                               ),),
//                             ),
//                             ////assigned
//                             ElevatedButton(
//                               style: ElevatedButton.styleFrom(side: BorderSide(color: AppColors.primaryBlue),
//                                 shape: RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.circular(10.r)),
//                                 backgroundColor: selectedFilter == 'assigned'
//                                     ? AppColors.primaryBlue
//                                     : AppColors.white,
//                                 minimumSize: Size(70.w, 35.h),
//                               ),
//                               onPressed: () => homeVM.setSelectedFilter("assigned"),

//                               child: Text(AppText.Asignd,style: GoogleFonts.poppins(
//                                 fontSize: 14.sp,fontWeight: FontWeight.w500,
//                                 color: selectedFilter == 'assigned'
//                                     ? AppColors.white
//                                     : AppColors.primaryBlue,
//                               ),),
//                             ),
//                             ////completed
//                             ElevatedButton(
//                               style: ElevatedButton.styleFrom(side: BorderSide(color: AppColors.primaryBlue),
//                                 shape: RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.circular(10.r)),
//                                 backgroundColor: selectedFilter == 'completed'
//                                     ? AppColors.primaryBlue
//                                     : AppColors.white,
//                                 minimumSize: Size(90.w, 35.h),
//                               ),
//                               onPressed: () => homeVM.setSelectedFilter("completed"),

//                               child: Text(AppText.Cmpltd,style: GoogleFonts.poppins(
//                                 fontSize: 14.sp,fontWeight: FontWeight.w500,
//                                 color: selectedFilter == 'completed'
//                                     ? AppColors.white
//                                     : AppColors.primaryBlue,
//                               ),),
//                             ),
//                           ],
//                         ),
//                         SizedBox(height: 20.h),

//                         filteredOrders.isEmpty
//                             ? Padding(
//                           padding: EdgeInsets.only(top: 120.h),
//                           child: Center(
//                             child: Text(
//                               selectedFilter == "assigned"
//                                   ? AppText.NoAssgnd
//                                   : selectedFilter == "completed"
//                                   ? AppText.NoCmpltd
//                                   : AppText.NoOrdersAvailable,
//                               style: GoogleFonts.poppins(
//                                 fontSize: 20.sp,
//                                 fontWeight: FontWeight.w600,
//                                 color: AppColors.grey,
//                               ),
//                             ),
//                           ),
//                         )
//                             : ListView.builder(
//                           physics: NeverScrollableScrollPhysics(),
//                           shrinkWrap: true,
//                           itemCount: filteredOrders.length,   // your order list
//                           itemBuilder: (context, index) {
//                             final order = filteredOrders[index];

//                             return Padding(
//                               padding: EdgeInsets.only(bottom: 15.h),
//                               child: OrderCard(
//                                 onAccept: () async {
//                                   if (!isOnline) {
//                                     ScaffoldMessenger.of(context).showSnackBar(
//                                       SnackBar(content: Text(AppText.UrOffline)),
//                                     );
//                                     return;
//                                   }
                                  
//                                   context.read<HomeViewModel>().updateOrderStatus(
//                                     order.orderId,
//                                     OrderStatus.assigned,
//                                   );

//                                   homeVM.setSelectedFilter("assigned");
//                                   showDialog(
//                                       context: context,
//                                       barrierDismissible: false,
//                                       builder: (_)=>Center(
//                                           child: Column(
//                                             mainAxisAlignment: MainAxisAlignment.center,
//                                             children: [
//                                               Image(
//                                                 height: 200.h,
//                                                 width: 200.w,
//                                                 image: AssetImage(AppImages.successGif),
//                                               ),
//                                               Text(AppText.OrdrAssigned,style: GoogleFonts.poppins(
//                                                   fontSize: 24.sp, fontWeight: FontWeight.w500,color: AppColors.green
//                                               ),)
//                                             ],
//                                           )
//                                       )
//                                   );
//                                   await Future.delayed(const Duration(seconds: 2));
//                                   Navigator.of(context, rootNavigator: true).pop();
//                                 },
//                                 orderid: order.orderId,
//                                 orderNumber: order.orderNumber,
//                                 name: order.name,
//                                 by: order.by,
//                                 address: order.address,
//                                 isPaid: order.isPaid,
//                                 isDetailsPage: true,
//                                 showOnlyItems: false,
//                                 items: order.items,
//                                 // Provider handles status and stage automatically via orderid
//                               ),
//                             );
//                           },
//                         ),

//                       ],
//                     ),
//                   ),
//                 )


//               ],
//             ),
//           )),
//     );
//   }
// }
