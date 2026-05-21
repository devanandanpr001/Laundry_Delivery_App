import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:ziya_laundry_deliveryapp/Constants/app_colors.dart';
import 'package:ziya_laundry_deliveryapp/Constants/app_text.dart';
import 'package:ziya_laundry_deliveryapp/Constants/app_images.dart';
import 'package:ziya_laundry_deliveryapp/Orders/viewmodel/order_viewmodel.dart';
import 'package:ziya_laundry_deliveryapp/core/connectivity_viewmodel.dart';
import 'package:ziya_laundry_deliveryapp/common_widgets/BottomNavigation/CustomSmartRefresher.dart';
import 'package:ziya_laundry_deliveryapp/common_widgets/app_shimmer.dart';

import '../../Orders/data/model/order_model.dart';

  class MyOrdersScreen extends StatefulWidget {
    const MyOrdersScreen({super.key});

    @override
    State<MyOrdersScreen> createState() => _MyOrdersScreenState();
  }

  class _MyOrdersScreenState extends State<MyOrdersScreen> {
    @override
    void initState() {
      super.initState();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<OrderViewModel>().fetchAllOrders();
      });
    }

    String _formatOrderDate(DateTime? date) {
      if (date == null) return "N/A";
      


      final localDate = date.toLocal();
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final yesterday = today.subtract(const Duration(days: 1));
      final dateToCheck = DateTime(localDate.year, localDate.month, localDate.day);

      if (dateToCheck == today) {
        return "Today";
      } else if (dateToCheck == yesterday) {
        return "Yesterday";
      } else {
        const months = [
          'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
          'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
        ];
        return "${localDate.day} ${months[localDate.month - 1]} ${localDate.year}";
      }
    }

    @override
    Widget build(BuildContext context) {
      final orderVM = context.watch<OrderViewModel>();
      
      // Filter to only display orders with a completed/delivered status
      final orders = orderVM.orders.where((o) => o.status == OrderStatus.completed).toList();
      
      return Scaffold(
        backgroundColor: AppColors.bg,
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// HEADER
                Row(
                  children: [
                    IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: Icon(Icons.arrow_back_ios, size: 20.sp)),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppText.TitleMy,
                            style: GoogleFonts.poppins(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            "${orders.length} ${orders.length == 1 ? AppText.OrderSingle : AppText.OrderPlural}",
                            style: GoogleFonts.poppins(
                                fontSize: 14.sp, fontWeight: FontWeight.w400, color: AppColors.black87),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 20.h),
                
                Expanded(
                  child: CustomSmartRefresher(
                    onRefresh: () async {
                      final connectivity = context.read<ConnectivityViewModel>();
                      if (!await connectivity.refreshConnection()) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(AppText.UrOffline)),
                        );
                        return;
                      }
                      await orderVM.fetchAllOrders();
                    },
                    child: orderVM.isLoading
                        ? ListView.builder(
                            physics: const AlwaysScrollableScrollPhysics(),
                            itemCount: 6,
                            itemBuilder: (context, index) => AppShimmer.orderCard(),
                          )
                        : orders.isEmpty
                            ? ListView(
                                physics: const AlwaysScrollableScrollPhysics(),
                                children: [
                                  SizedBox(height: 180.h),
                                  Center(
                                    child: Text(
                                      AppText.NoOrdersAvailable,
                                      style: GoogleFonts.poppins(
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.grey,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ],
                              )
                            : ListView.builder(
                                itemCount: orders.length,
                                itemBuilder: (context, index) {
                                  final order = orders[index];

                                  return MyOrderCard(
                                    orderId: order.orderNumber, // Use the formatted orderNumber for display
                                    status: order.status == OrderStatus.completed
                                        ? "delivered"
                                        : "out",
                                    time: _formatOrderDate(order.updatedAt),
                                    address: order.address,
                                  );
                                },
                              ),
                  ),
                )
                ],
              ),
          ),
        ),
      );
    }

    Widget sectionTitle(String title) {
      return Padding(
        padding: EdgeInsets.only(left: 13.w),
        child: Row(
          children: [
            Text(
              title,
              style:  GoogleFonts.poppins(
                  color: AppColors.grey,fontSize: 14.sp,fontWeight: FontWeight.w400),
            ),
            const Expanded(
              child: Divider(thickness: 1), // Standard dividers usually don't need scaling, but 1.h can be used for precision
            )
          ],
        ),
      );
    }
  }


  class MyOrderCard extends StatelessWidget {
    final String status;
    final String time;
    final String orderId;
    final String address;

    const MyOrderCard({
      super.key,
      required this.status,
      required this.time,
      required this.orderId,
      required this.address,
    });

    @override
    Widget build(BuildContext context) {
      // bool isDelivered = status == "delivered"; // TODO: Use if needed for status check

      return Container(
        constraints: BoxConstraints(minHeight: 110.w),
        margin: EdgeInsets.only(bottom: 15.h),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(offset: Offset(0, 4.h),
              blurRadius: 6.r,
              color: AppColors.black12,
            )
          ],
        ),
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.only(left: 15.w, top: 15.h, bottom: 15.h, right: 60.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// ORDER ID
                  Row(
                    children: [
                      Text(
                        AppText.OrderId,
                        style: GoogleFonts.poppins(fontSize: 16.sp, fontWeight: FontWeight.w400),
                      ),
                      Expanded(
                        child: Text(
                          orderId,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w400),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 6.h),

                  /// STATUS
                  Row(
                    children: [
                      Image.asset(
                        AppImages.iconCheck,
                        color: AppColors.green, height: 20.h, width: 20.w,
                      ),
                      SizedBox(width: 6.w),
                      Expanded(
                        child: Text(
                          AppText.OrderDeliveredTitle,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w400,
                            color: AppColors.green,
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 6.h),

                  /// LOCATION
                  Row(
                    children:  [
                      Image.asset(AppImages.iconLocation,height: 20.h,width: 20.w,color: AppColors.primaryBlue,),
                      SizedBox(width: 4.w),
                      Expanded(
                        child: Text(
                          address,
                          style: GoogleFonts.poppins(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w400,
                            height: 1.4,
                            color: const Color(0xFF1D1B20)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            /// TIME BADGE
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                padding: EdgeInsets.symmetric(
                    horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: AppColors.timeBadgeBlue,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  time,
                  style: TextStyle(fontSize: 12.sp),
                ),
              ),
            ),
          ],
        ),
      );
    }
  }