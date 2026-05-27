import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:ziya_laundry_deliveryapp/core/Constants/app_colors.dart';
import 'package:ziya_laundry_deliveryapp/core/Constants/app_strings.dart';
import 'package:ziya_laundry_deliveryapp/core/Constants/app_images.dart';
import 'package:ziya_laundry_deliveryapp/features/Orders/viewmodel/order_viewmodel.dart';
import 'package:ziya_laundry_deliveryapp/core/connectivity_viewmodel.dart';
import 'package:ziya_laundry_deliveryapp/common_widget/CustomSmartRefresher.dart';
import 'package:ziya_laundry_deliveryapp/common_widget/app_shimmer.dart';

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

    String _formatOrderDate(OrderModel order) {
      DateTime? date = order.updatedAt;
      
      // Fallback to createdAt if updatedAt is null
      if (date == null && order.createdAt != null) {
        date = DateTime.tryParse(order.createdAt!);
      }

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
        return DateFormat('dd MMM yyyy').format(localDate);
      }
    }

    @override
    Widget build(BuildContext context) {
      final orderVM = context.watch<OrderViewModel>();

      // Filter completed orders and ensure each Order ID is unique in the list.
      // If a driver handles both Pickup and Delivery for the same order, we merge them into one card.
      final Map<String, OrderModel> uniqueOrdersMap = {};
      for (var o in orderVM.orders) {
        if (o.status == OrderStatus.completed) {
          // If we find a duplicate orderId, prioritize the one with 'PICKUP_AND_DELIVERY' roleType.
          if (!uniqueOrdersMap.containsKey(o.orderId) || o.roleType == "PICKUP_AND_DELIVERY") {
            uniqueOrdersMap[o.orderId] = o;
          }
        }
      }

      final orders = uniqueOrdersMap.values.toList();
      // Sort by updated time descending to show newest activity at the top
      orders.sort((a, b) => (b.updatedAt ?? DateTime(0)).compareTo(a.updatedAt ?? DateTime(0)));

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
                                    time: _formatOrderDate(order),
                                    roleType: order.roleType ?? "DELIVERY",
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
    final String roleType;
    final String address;

    const MyOrderCard({
      super.key,
      required this.status,
      required this.time,
      required this.roleType,
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: 10.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: AppColors.timeBadgeBlue,
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(12.r),
                        bottomLeft: Radius.circular(8.r),
                      ),
                    ),
                    child: Text(
                      time,
                      style: GoogleFonts.poppins(fontSize: 11.sp, fontWeight: FontWeight.w500),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Padding(
                    padding: EdgeInsets.only(right: 8.w),
                    child: _buildRoleBadge(roleType),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    Widget _buildRoleBadge(String role) {
      Color bgColor;
      String label;
      switch (role) {
        case "PICKUP":
          bgColor = AppColors.primaryBlue;
          label = "Pickup Only";
          break;
        case "PICKUP_AND_DELIVERY":
          bgColor = AppColors.pinkPurple;
          label = "Full Cycle";
          break;
        default:
          bgColor = AppColors.green;
          label = "Delivery Only";
      }
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
        decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(4.r)),
        child: Text(
          label,
          style: GoogleFonts.poppins(color: Colors.white, fontSize: 10.sp, fontWeight: FontWeight.w600),
        ),
      );
    }
  }