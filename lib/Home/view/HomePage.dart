import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:ziya_laundry_deliveryapp/core/Constants/app_colors.dart';
import 'package:ziya_laundry_deliveryapp/core/Constants/app_strings.dart';
import 'package:ziya_laundry_deliveryapp/core/Constants/app_images.dart';
import 'package:ziya_laundry_deliveryapp/Home/widgets/notification_bell.dart';
import 'package:ziya_laundry_deliveryapp/Home/widgets/online_toggle.dart';
import 'package:ziya_laundry_deliveryapp/Home/widgets/profile_avatar.dart';
import 'package:ziya_laundry_deliveryapp/Home/widgets/status_count_card.dart';
import 'package:ziya_laundry_deliveryapp/Home/widgets/welcome_section.dart';
import 'package:ziya_laundry_deliveryapp/Home/widgets/order_type_toggle.dart';
import 'package:ziya_laundry_deliveryapp/Orders/viewmodel/order_viewmodel.dart';
import 'package:ziya_laundry_deliveryapp/Orders/widget/OrderCard.dart' as home_order_card;
import 'package:ziya_laundry_deliveryapp/common_widget/AppToast.dart';
import 'package:ziya_laundry_deliveryapp/common_widget/app_shimmer.dart';
import 'package:ziya_laundry_deliveryapp/core/connectivity_viewmodel.dart';
import '../../common_widget/CustomSmartRefresher.dart';
import '../viewmodel/home_viewmodel.dart';
import '../../Orders/data/model/order_model.dart';

class Homepage extends StatefulWidget {
  final VoidCallback onGoToOrders;
  const Homepage({super.key, required this.onGoToOrders});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  OrderType _selectedOrderType = OrderType.pickup; // Default to pickup
  bool _isAcceptingOrder = false; // Guard for accept button

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final homeVM = context.read<HomeViewModel>();
      final orderVM = context.read<OrderViewModel>();
      Future.wait([homeVM.refreshOrders(), orderVM.fetchAllOrders()]);
    });
  }

  @override
  Widget build(BuildContext context) {
    final homeVM = context.watch<HomeViewModel>();
    final orderVM = context.watch<OrderViewModel>();

    // Display all active (unassigned) orders for the selected type.
    // This ensures statuses like 'OUT_FOR_DELIVERY' are visible in the dashboard.
    final newOrders = orderVM.orders
        .where((order) => 
            order.orderType == _selectedOrderType && 
            order.status == OrderStatus.pending)
        .toList();
    int completedOrdersCount = homeVM.completedCount;
    int assignedCount = homeVM.assignedCount;
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(left: 20.w, right: 20.w, top: 20.h),
          child: Column(
            children: [
              Row(
                children: [
                  OnlineToggle(),
                  Spacer(),
                  NotificationBell(),
                  SizedBox(width: 15.w),
                  ProfileAvatar(imageUrl: homeVM.profileImage),
                ],
              ), 
              SizedBox(height: 20.h),
              Expanded(
                child: CustomSmartRefresher(
                  onRefresh: () async {
                    final connectivity = context.read<ConnectivityViewModel>();
                    if (!await connectivity.refreshConnection()) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(AppText.UrOffline)),
                        );
                      }
                      return;
                    }
                    await Future.wait([homeVM.refreshOrders(), orderVM.fetchAllOrders()]);
                  },
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    children: [
                      WelcomeSection(name: homeVM.userName.isEmpty ? "Delivery Partner" : homeVM.userName),
                      SizedBox(height: 20.h),
                      Row(
                        children: [
                          Expanded(
                            child: StatusCountCard(
                              color: AppColors.pinkPurple,
                              title: AppText.Assigned,
                              count: assignedCount,
                              image: AppImages.iconAssigned,
                              onTap: () {
                                homeVM.setSelectedFilter('assigned');
                                widget.onGoToOrders();
                              },
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: StatusCountCard(
                              color: AppColors.skyBlue,
                              title: AppText.Compltd,
                              count: completedOrdersCount,
                              image: AppImages.iconCompleted,
                              onTap: () {
                                homeVM.setSelectedFilter('completed');
                                widget.onGoToOrders();
                              },
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20.h),

                      OrderTypeToggle(
                        onToggle: (index) { // 0: Pick Up, 1: Delivery
                          setState(() => _selectedOrderType = index == 0 ? OrderType.pickup : OrderType.delivery);
                          Future.wait([homeVM.refreshOrders(), orderVM.fetchAllOrders()]);
                        },
                      ),
                      // const TodaysEarningsCard(amount: "\$473"),
                      // Show shimmer while loading
                      if (homeVM.isLoading || orderVM.isLoading)
                        Column(
                          children: List.generate(4, (index) => AppShimmer.orderCard()),
                        )
                      else if (newOrders.isEmpty) 
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 40.h),
                          child: Column(
                            children: [
                              Icon(Icons.assignment_late_outlined, size: 60.sp, color: AppColors.grey.withValues(alpha: 0.5)),
                              SizedBox(height: 10.h),
                              Text(
                                "No ${_selectedOrderType == OrderType.pickup ? 'Pickup' : 'Delivery'} orders available",
                                style: GoogleFonts.poppins(color: AppColors.grey, fontSize: 14.sp),
                              ),
                            ],
                          ),
                        )
                      else
                        Column(
                          children: newOrders.map((order) {
                            return Padding(
                              padding: EdgeInsets.only(bottom: 12.h),
                              child: home_order_card.OrderCard(
                                key: ValueKey("${order.orderId}_${order.orderType}"),
                                orderid: order.orderId,
                                orderNumber: order.orderNumber,
                                name: order.name,
                                by: order.by,
                                orderType: order.orderType,
                                address: order.address,
                                isPaid: order.isPaid,
                                isDetailsPage: false,
                                items: order.items,
                                onViewTap: () {
                                  // Set navigation index and scroll target
                                  homeVM.setSelectedIndex(1);
                                  homeVM.setScrollToOrderId(order.orderId);
                                  widget.onGoToOrders();
                                },
                                onAccept: () async {
                                  if (_isAcceptingOrder) return;
                                  final connectivity = context.read<ConnectivityViewModel>();
                                  if (!await connectivity.refreshConnection() && mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(AppText.UrOffline)),
                                    );
                                    return;
                                  }

                                  setState(() => _isAcceptingOrder = true);
                                  
                                  final orderVM = context.read<OrderViewModel>();
                                  final success = await orderVM.acceptOrder(
                                    order.orderId,
                                    order.orderType,
                                  );
                                  
                                  if (success && mounted) {
                                    homeVM.setSelectedFilter("assigned");
                                    showDialog(
                                      context: context,
                                      barrierDismissible: false,
                                      builder: (_) => Center(
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Image(
                                              width: 200.w,
                                              height: 200.h,
                                              image: AssetImage(AppImages.successGif),
                                            ),
                                            Text(
                                              AppText.OrdrAssigned,
                                              style: GoogleFonts.poppins(
                                                fontSize: 24.sp,
                                                fontWeight: FontWeight.w500,
                                                color: AppColors.green,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                    await Future.delayed(const Duration(seconds: 2));
                                    if (!mounted) return;
                                    Navigator.of(context, rootNavigator: true).pop();
                                    setState(() => _isAcceptingOrder = false);
                                    widget.onGoToOrders();
                                  } else if (mounted) {
                                    setState(() => _isAcceptingOrder = false);
                                  }
                                },
                              ),
                            );
                          }).toList(),
                        ),
                    ],
                  ),
                ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
