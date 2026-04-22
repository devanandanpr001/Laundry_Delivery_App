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
import '../../AuthSection/viewmodel/login_viewmodel.dart';
import '../../Orders/widget/OrderCard.dart' as order_card_widget;
import '../viewmodel/home_viewmodel.dart';
import '../data/model/home_models.dart';

class Homepage extends StatefulWidget {
  final VoidCallback onGoToOrders;
  const Homepage({super.key, required this.onGoToOrders});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  @override
  Widget build(BuildContext context) {
    final homeVM = context.watch<HomeViewModel>();

    final newOrders = homeVM.pendingOrders;
    int completedOrdersCount = homeVM.completedCount;
    int assignedCount = homeVM.assignedCount;
    bool hasAssignedOrder = homeVM.orders.any(
      (o) => o.status == OrderStatus.assigned,
    );
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
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      WelcomeSection(name: authVM.loginName),
                      SizedBox(height: 20.h),

                      /// Assigned & Completed Status Cards
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
                        onToggle: (index) {
                          // Handle filtering logic here (0: Pick Up, 1: Delivery)
                        },
                      ),
                      // const TodaysEarningsCard(amount: "\$473"),
                      SizedBox(height: 20.h),
                      ListView.builder(
                        physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: newOrders.length,
                        itemBuilder: (context, index) {
                          final order = newOrders[index];

                          return Padding(
                            padding: EdgeInsets.only(bottom: 12.h),
                            child: order_card_widget.OrderCard(
                              orderid: order.orderId,
                              name: order.name,
                              by: order.by,
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
                                if (hasAssignedOrder) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(AppText.FinishOrderMsg),
                                    ),
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
            ],
          ),
        ),
      ),
    );
  }
}
