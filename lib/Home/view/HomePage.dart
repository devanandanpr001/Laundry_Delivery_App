import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:ziya_laundry_deliveryapp/Constants/app_colors.dart';
import 'package:ziya_laundry_deliveryapp/Constants/app_text.dart';
import 'package:ziya_laundry_deliveryapp/Constants/app_images.dart';
import 'package:ziya_laundry_deliveryapp/Home/widgets/notification_bell.dart';
import 'package:ziya_laundry_deliveryapp/Home/widgets/online_toggle.dart';
import 'package:ziya_laundry_deliveryapp/Home/widgets/profile_avatar.dart';
import 'package:ziya_laundry_deliveryapp/Home/widgets/status_count_card.dart';
import 'package:ziya_laundry_deliveryapp/Home/widgets/welcome_section.dart';
import 'package:ziya_laundry_deliveryapp/Home/widgets/order_type_toggle.dart';
import 'package:ziya_laundry_deliveryapp/Orders/widget/OrderCard.dart' as home_order_card;
import '../../AuthSection/viewmodel/login_viewmodel.dart';
import '../../common_widgets/BottomNavigation/CustomSmartRefresher.dart';
import '../../core/dio_client.dart';
import '../viewmodel/home_viewmodel.dart';
import '../data/model/home_models.dart';

class Homepage extends StatefulWidget {
  final VoidCallback onGoToOrders;
  const Homepage({super.key, required this.onGoToOrders});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  OrderType _selectedOrderType = OrderType.pickup; // Default to pickup

  @override
  void initState() {
    super.initState();
    // Trigger initial data fetch
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeViewModel>().refreshOrders();
    });
    // Connect the DioClient session expired listener
    DioClient.onSessionExpired = () {
      if (mounted) {
        _showSessionExpiredDialog();
      }
    };
  }

  void _showSessionExpiredDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // Force user to acknowledge
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.r)),
        title: Text(
          "Session Expired",
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: AppColors.errorRed),
        ),
        content: Text(
          "Your session has expired. Please login again to continue.",
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () {
              // Navigate back to login and clear the entire history
              Navigator.of(context, rootNavigator: true).pushNamedAndRemoveUntil(
                '/login', // Ensure this route is defined in your MaterialApp
                (route) => false,
              );
            },
            child: Text("Login Again", style: TextStyle(color: AppColors.primaryBlue)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final homeVM = context.watch<HomeViewModel>();

    // Filter pending orders by the selected order type
    final newOrders = homeVM.pendingOrders
        .where((order) => order.orderType == _selectedOrderType)
        .toList();
    int completedOrdersCount = homeVM.completedCount;
    int assignedCount = homeVM.assignedCount;
    final authVM = Provider.of<LoginViewModel>(context);
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
                  ProfileAvatar( ),
                ],
              ),
              SizedBox(height: 20.h),
              Expanded(
                child: CustomSmartRefresher(
                  onRefresh: () => homeVM.refreshOrders(),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    children: [
                      WelcomeSection(name: authVM.loginName.isEmpty ? "Delivery Partner" : authVM.loginName),
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
                          homeVM.refreshOrders(); // Refresh orders to get the latest for the selected type
                        },
                      ),
                      // const TodaysEarningsCard(amount: "\$473"),
                      SizedBox(height: 20.h),
                      newOrders.isEmpty 
                      ? Padding(
                          padding: EdgeInsets.symmetric(vertical: 40.h),
                          child: Column(
                            children: [
                              Icon(Icons.assignment_late_outlined, size: 60.sp, color: AppColors.grey.withOpacity(0.5)),
                              SizedBox(height: 10.h),
                              Text(
                                "No ${_selectedOrderType == OrderType.pickup ? 'Pickup' : 'Delivery'} orders available",
                                style: GoogleFonts.poppins(color: AppColors.grey, fontSize: 14.sp),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                        physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: newOrders.length,
                        itemBuilder: (context, index) {
                          final order = newOrders[index];

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
                              showOnlyItems: false,
                              items: order.items,
                              deliveryStage: order.deliveryStage,
                              onViewTap: widget.onGoToOrders,
                              status: order.status,
                              selectedFilter: 'all',
                              onAccept: () async {
                                if (!homeVM.isOnline) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(AppText.UrOffline)),
                                  );
                                  return;
                                }

                                homeVM.updateOrderStatus(
                                  order.orderId,
                                  OrderStatus.assigned,
                                );
                                homeVM.setSelectedFilter("assigned");
                                showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (_) => Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Image(
                                          width: 200.w,
                                          height: 200.h,
                                          image: AssetImage(
                                            AppImages.successGif,
                                          ),
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
                                await Future.delayed(Duration(seconds: 2));
                                Navigator.of(
                                  context,
                                  rootNavigator: true,
                                ).pop();
                                widget.onGoToOrders();
                              },
                            ),
                          );
                        },
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
