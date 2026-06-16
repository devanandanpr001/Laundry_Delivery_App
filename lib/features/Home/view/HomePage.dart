import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:ziya_laundry_deliveryapp/features/Home/widgets/online_toggle.dart';
import 'package:ziya_laundry_deliveryapp/features/Home/widgets/order_type_toggle.dart';
import 'package:ziya_laundry_deliveryapp/Constants/app_colors.dart';
import 'package:ziya_laundry_deliveryapp/Constants/app_strings.dart';
import 'package:ziya_laundry_deliveryapp/Constants/app_images.dart';
import 'package:ziya_laundry_deliveryapp/features/Home/widgets/notification_bell.dart';
import 'package:ziya_laundry_deliveryapp/features/Home/widgets/profile_avatar.dart';
import 'package:ziya_laundry_deliveryapp/features/Home/widgets/status_count_card.dart';
import 'package:ziya_laundry_deliveryapp/features/Home/widgets/welcome_section.dart';
import 'package:ziya_laundry_deliveryapp/features/Orders/viewmodel/order_viewmodel.dart';
import 'package:ziya_laundry_deliveryapp/features/Orders/widget/OrderCard.dart' as home_order_card;
import 'package:ziya_laundry_deliveryapp/features/Notification/viewmodel/notification_viewmodel.dart';
import 'package:ziya_laundry_deliveryapp/features/Profile/viewmodel/profile_viewmodel.dart';
import 'package:ziya_laundry_deliveryapp/common_widget/app_shimmer.dart';
import 'package:ziya_laundry_deliveryapp/core/widgets/no_internet_widget.dart';
import 'package:ziya_laundry_deliveryapp/features/Orders/widget/order_empty_state.dart';
import 'package:ziya_laundry_deliveryapp/core/connectivity_viewmodel.dart';
import '../../../../common_widget/CustomSmartRefresher.dart';
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
  String? _fetchError; // New flag to track network errors during data fetch

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initialLoad();
    });
  }

  Future<void> _initialLoad() async {
    if (mounted) setState(() => _fetchError = null);
    final homeVM = context.read<HomeViewModel>();
    final orderVM = context.read<OrderViewModel>();
    final profileVM = context.read<ProfileViewModel>();
    final notificationVM = context.read<NotificationViewModel>();

    try {
      // Fetch profile data first, as notification init depends on it
      await profileVM.fetchProfileData();

      String userId = '';
      String role = 'DELIVERY_PARTNER';

      if (mounted && profileVM.userProfile != null) {
        userId = (profileVM.userProfile?['id'] ?? profileVM.userProfile?['_id'] ?? '').toString();
        role = profileVM.userProfile?['role']?.toString() ?? 'DELIVERY_PARTNER';
      }

      // Now initiate all other fetches in parallel
      final List<Future<void>> futures = [
        homeVM.refreshOrders(),
        orderVM.fetchAllOrders(),
      ];

      if (userId.isNotEmpty) {
        // Initialize socket and fetch notifications
        futures.add(notificationVM.init(userId, role));
      }
      await Future.wait(futures);
    } catch (e) {
      if (mounted) {
        setState(() => _fetchError = _parseError(e));
      }
      debugPrint("Homepage: Error during _initialLoad: $e");
    }
  }

  Future<void> _onRefresh() async {
    final connectivity = context.read<ConnectivityViewModel>();
    if (!await connectivity.refreshConnection()) {
      if (mounted) setState(() => _fetchError = "No internet connection");
      return;
    }

    final homeVM = context.read<HomeViewModel>();
    final orderVM = context.read<OrderViewModel>();
    final profileVM = context.read<ProfileViewModel>();
    final notificationVM = context.read<NotificationViewModel>();
    
    try {
      if (mounted) setState(() => _fetchError = null);
      
      // Refresh all screen data in parallel
      await profileVM.fetchProfileData();
      String userId = '';
      String role = 'DELIVERY_PARTNER';

      if (mounted && profileVM.userProfile != null) {
        userId = (profileVM.userProfile?['id'] ?? profileVM.userProfile?['_id'] ?? '').toString();
        role = profileVM.userProfile?['role']?.toString() ?? 'DELIVERY_PARTNER';
      }

      final List<Future<void>> futures = [
        homeVM.refreshOrders(),
        orderVM.fetchAllOrders(),
      ];
      if (userId.isNotEmpty) futures.add(notificationVM.init(userId, role));
      await Future.wait(futures);
    } catch (e) {
      if (mounted) {
        setState(() => _fetchError = _parseError(e));      }
      debugPrint("Homepage: Error during _onRefresh: $e");
    }
  }

  String _parseError(dynamic e) {
    String msg = e.toString().replaceFirst(RegExp(r'^Exception:\s*'), '').trim();
    final lower = msg.toLowerCase();
    if (lower.contains("socket") || lower.contains("network") || lower.contains("connection")) {
      return "No internet connection";
    }
    return msg.isEmpty ? "An unexpected error occurred" : msg;
  }

  @override
  Widget build(BuildContext context) {
    final homeVM = context.watch<HomeViewModel>();
    final connectivityVM = context.watch<ConnectivityViewModel>();
    final orderVM = context.watch<OrderViewModel>();

    final newOrders = orderVM.orders
        .where((order) => 
            order.orderType == _selectedOrderType && 
            order.status == OrderStatus.pending)
        .toList();
    int completedOrdersCount = homeVM.completedCount;
    int assignedCount = homeVM.assignedCount;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 800),
        child: _fetchError != null && !homeVM.isLoading && !orderVM.isLoading && !connectivityVM.isOnline
            ? NoInternetWidget(
                key: const ValueKey('no_internet_screen'),
                message: _fetchError ?? AppText.UrOffline,
                onRetry: () async {
                  final connected = await connectivityVM.refreshConnection();
                  if (connected) {
                    await _onRefresh();
                  }
                },
              )
            : SafeArea(
                key: const ValueKey('home_content'),
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
                        onRefresh: _onRefresh,
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
                                onToggle: (index) {
                                  // 0: Pick Up, 1: Delivery
                                  setState(() => _selectedOrderType = index == 0 ? OrderType.pickup : OrderType.delivery);
                                  Future.wait([homeVM.refreshOrders(), orderVM.fetchAllOrders()]);
                                },
                              ),
                              SizedBox(height: 20.h,),
                              if (homeVM.isLoading || orderVM.isLoading)
                                Column(
                                  children: List.generate(4, (index) => AppShimmer.orderCard()),
                                )
                              else if (newOrders.isEmpty)
                                SizedBox(
                                  height: 0.6.sh,
                                  child: const OrderEmptyState(
                                    message: AppText.NoOrdersAvailable,
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
                                          final success = await orderVM.acceptOrder(order.orderId, order.orderType);
                                          if (success && mounted) {
                                            homeVM.setSelectedFilter("assigned");
                                            showDialog(
                                              context: context,
                                              barrierDismissible: false,
                                              builder: (_) => Center(
                                                child: Column(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    Image(width: 200.w, height: 200.h, image: AssetImage(AppImages.successGif)),
                                                    Text(AppText.OrdrAssigned, style: GoogleFonts.poppins(fontSize: 24.sp, fontWeight: FontWeight.w500, color: AppColors.green)),
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
      ),
    );
  }
}
