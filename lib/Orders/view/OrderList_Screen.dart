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
  
  /// Professional helper to get page details based on current filter
  (String title, int count, String subtitle) _getPageInfo(HomeViewModel vm, String filter) {
    switch (filter) {
      case "assigned":
        return (AppText.ActiveOrders, vm.assignedCount, "${vm.assignedCount} ${AppText.ActiveTasks}");
      case "completed":
        return (AppText.CompletedOrders, vm.completedCount, "${vm.completedCount} ${AppText.Delivered}");
      default:
        return (AppText.NewOrders, vm.pendingOrders.length, "${vm.pendingOrders.length} ${vm.pendingOrders.length == 1 ? AppText.OrderSingle : AppText.OrderPlural}${AppText.ReviewedConfirmed}");
    }
  }

  @override
  Widget build(BuildContext context) {
    // Optimized: Select only what is needed for the layout logic
    final selectedFilter = context.select<HomeViewModel, String>((vm) => vm.selectedFilter);
    final orders = context.select<HomeViewModel, List<OrderModel>>((vm) => vm.orders);
    final isOnline = context.select<HomeViewModel, bool>((vm) => vm.isOnline);
    
    final homeVM = context.read<HomeViewModel>(); // Use read for non-rebuilding references
    final pageInfo = _getPageInfo(homeVM, selectedFilter);
    
    bool hasAssignedOrder = orders.any((o) => o.status == OrderStatus.assigned);

    // Optimized filtering logic
    List<OrderModel> filteredOrders = orders.where((order) => order.orderType == _selectedType).where((order) {
      if (selectedFilter == "all") {
        return order.status == OrderStatus.pending;
      }
      
      // Check if we are in assigned tab and order is assigned
      if (selectedFilter == "assigned" && order.status == OrderStatus.assigned) {
        return true;
      }
      
      if (selectedFilter == "completed" && order.status == OrderStatus.completed) {
        return true;
      }
      
      return order.status.name == selectedFilter;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(20.w),
            child: Column(
              children: [
                Row(
                  children: [
                    IconButton(onPressed: widget.onBackToHome,
                        icon: Icon(Icons.arrow_back_ios, size: 24.sp)),
                    //Track order id
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(pageInfo.$1, style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w500, fontSize: 18.sp
                        ),),
                        SizedBox(height: 5.h),
                        Text(pageInfo.$3, style: GoogleFonts.poppins(
                          fontSize: 14.sp, fontWeight: FontWeight.w400,
                        ),
                        ),
                      ],
                    )
                  ],
                ),
                SizedBox(height: 20.h,),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                      // Type Toggle (Pickup / Delivery)
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                        padding: EdgeInsets.all(4.w),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(color: AppColors.borderColorBlue),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() => _selectedType = OrderType.pickup),
                                child: Container(
                                  padding: EdgeInsets.symmetric(vertical: 8.h),
                                  decoration: BoxDecoration(
                                    color: _selectedType == OrderType.pickup ? AppColors.primaryBlue : Colors.transparent,
                                    borderRadius: BorderRadius.circular(8.r),
                                  ),
                                  child: Center(
                                    child: Text(AppText.PickUpOrders, style: GoogleFonts.poppins(color: _selectedType == OrderType.pickup ? Colors.white : AppColors.primaryBlue, fontWeight: FontWeight.w600)),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() => _selectedType = OrderType.delivery),
                                child: Container(
                                  padding: EdgeInsets.symmetric(vertical: 8.h),
                                  decoration: BoxDecoration(
                                    color: _selectedType == OrderType.delivery ? AppColors.primaryBlue : Colors.transparent,
                                    borderRadius: BorderRadius.circular(8.r),
                                  ),
                                  child: Center(
                                    child: Text(AppText.DeliveryOrders, style: GoogleFonts.poppins(color: _selectedType == OrderType.delivery ? Colors.white : AppColors.primaryBlue, fontWeight: FontWeight.w600)),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 10.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ////all
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(side: BorderSide(color: AppColors.primaryBlue),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.circular(10.r)),
                                backgroundColor: selectedFilter == 'all'
                                    ? AppColors.primaryBlue
                                    : AppColors.white,
                                minimumSize: Size(51.w, 35.h),
                              ),
                              onPressed: () => homeVM.setSelectedFilter("all"),

                              child: Text(AppText.All,style: GoogleFonts.poppins(
                                fontSize: 14.sp,fontWeight: FontWeight.w500,
                                color: selectedFilter == 'all'
                                    ? AppColors.white
                                    : AppColors.primaryBlue,
                              ),),
                            ),
                            ////assigned
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(side: BorderSide(color: AppColors.primaryBlue),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.circular(10.r)),
                                backgroundColor: selectedFilter == 'assigned'
                                    ? AppColors.primaryBlue
                                    : AppColors.white,
                                minimumSize: Size(70.w, 35.h),
                              ),
                              onPressed: () => homeVM.setSelectedFilter("assigned"),

                              child: Text(AppText.Asignd,style: GoogleFonts.poppins(
                                fontSize: 14.sp,fontWeight: FontWeight.w500,
                                color: selectedFilter == 'assigned'
                                    ? AppColors.white
                                    : AppColors.primaryBlue,
                              ),),
                            ),
                            ////completed
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(side: BorderSide(color: AppColors.primaryBlue),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.circular(10.r)),
                                backgroundColor: selectedFilter == 'completed'
                                    ? AppColors.primaryBlue
                                    : AppColors.white,
                                minimumSize: Size(90.w, 35.h),
                              ),
                              onPressed: () => homeVM.setSelectedFilter("completed"),

                              child: Text(AppText.Cmpltd,style: GoogleFonts.poppins(
                                fontSize: 14.sp,fontWeight: FontWeight.w500,
                                color: selectedFilter == 'completed'
                                    ? AppColors.white
                                    : AppColors.primaryBlue,
                              ),),
                            ),
                          ],
                        ),
                        SizedBox(height: 20.h),

                        filteredOrders.isEmpty
                            ? Padding(
                          padding: EdgeInsets.only(top: 120.h),
                          child: Center(
                            child: Text(
                              selectedFilter == "assigned"
                                  ? AppText.NoAssgnd
                                  : selectedFilter == "completed"
                                  ? AppText.NoCmpltd
                                  : AppText.NoOrdersAvailable,
                              style: GoogleFonts.poppins(
                                fontSize: 20.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.grey,
                              ),
                            ),
                          ),
                        )
                            : ListView.builder(
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: filteredOrders.length,   // your order list
                          itemBuilder: (context, index) {
                            final order = filteredOrders[index];

                            return Padding(
                              padding: EdgeInsets.only(bottom: 15.h),
                              child: OrderCard(
                                onAccept: () async {
                                  if (!isOnline) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(AppText.UrOffline)),
                                    );
                                    return;
                                  }
                                  if (hasAssignedOrder) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                       SnackBar(
                                        content: Text(AppText.FinishOrderMsg),
                                      ),
                                    );
                                    return;
                                  }
                                  
                                  context.read<HomeViewModel>().updateOrderStatus(
                                    order.orderId,
                                    OrderStatus.assigned,
                                  );

                                  homeVM.setSelectedFilter("assigned");
                                  showDialog(
                                      context: context,
                                      barrierDismissible: false,
                                      builder: (_)=>Center(
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Image(
                                                height: 200.h,
                                                width: 200.w,
                                                image: AssetImage(AppImages.successGif),
                                              ),
                                              Text(AppText.OrdrAssigned,style: GoogleFonts.poppins(
                                                  fontSize: 24.sp, fontWeight: FontWeight.w500,color: AppColors.green
                                              ),)
                                            ],
                                          )
                                      )
                                  );
                                  await Future.delayed(const Duration(seconds: 2));
                                  Navigator.of(context, rootNavigator: true).pop();
                                },
                                orderid: order.orderId,
                                name: order.name,
                                by: order.by,
                                address: order.address,
                                isPaid: order.isPaid,
                                isDetailsPage: true,
                                showOnlyItems: false,
                                items: order.items,
                                // Provider handles status and stage automatically via orderid
                              ),
                            );
                          },
                        ),

                      ],
                    ),
                  ),
                )


              ],
            ),
          )),
    );
  }
}
