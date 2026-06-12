import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:ziya_laundry_deliveryapp/Constants/app_colors.dart';
import 'package:ziya_laundry_deliveryapp/Constants/app_strings.dart';
import 'package:ziya_laundry_deliveryapp/Constants/app_images.dart';
import 'package:ziya_laundry_deliveryapp/features/Orders/widget/OrderCard.dart' as home_order_card;
import 'package:ziya_laundry_deliveryapp/common_widget/CustomSmartRefresher.dart';
import 'package:ziya_laundry_deliveryapp/common_widget/app_shimmer.dart';
import 'package:ziya_laundry_deliveryapp/features/Orders/viewmodel/order_viewmodel.dart';
import 'package:ziya_laundry_deliveryapp/core/connectivity_viewmodel.dart';
import 'package:ziya_laundry_deliveryapp/core/widgets/no_internet_widget.dart';
import 'package:ziya_laundry_deliveryapp/features/Orders/data/model/order_model.dart';
import '../../Home/viewmodel/home_viewmodel.dart';

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
  String? _fetchError;

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

    try {
      await Future.wait([
        homeVM.refreshOrders(),
        orderVM.fetchAllOrders(),
      ]);
    } catch (e) {
      if (mounted) setState(() => _fetchError = _parseError(e));
      debugPrint("OrderlistScreen: Error during _initialLoad: $e");
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

    try {
      if (mounted) setState(() => _fetchError = null);
      await Future.wait([
        homeVM.refreshOrders(),
        orderVM.fetchAllOrders(),
      ]);
    } catch (e) {
      if (mounted) setState(() => _fetchError = _parseError(e));
      debugPrint("OrderlistScreen: Error during _onRefresh: $e");
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
    final orderVM = context.watch<OrderViewModel>();
    final connectivityVM = context.watch<ConnectivityViewModel>();
    final selectedFilter = homeVM.selectedFilter;
    final isOnline = homeVM.isOnline;

    // Get page info dynamically
    final (title, subtitle) = _resolvePageInfo(homeVM, orderVM, selectedFilter);

    // Compute filtered list efficiently
    final filteredOrders = orderVM.orders.where((order) {
      final typeMatch = order.orderType == _selectedType;
      if (!typeMatch) return false;

      if (selectedFilter == "all") return order.status == OrderStatus.pending;
      if (selectedFilter == "assigned") return order.status == OrderStatus.assigned;
      if (selectedFilter == "completed") return order.status == OrderStatus.completed;
      return false;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: _fetchError != null && !homeVM.isLoading && !orderVM.isLoading && !connectivityVM.isOnline
          ? NoInternetWidget(
              message: _fetchError ?? AppText.UrOffline,
              onRetry: () async {
                final connected = await connectivityVM.refreshConnection();
                if (connected) {
                  await _onRefresh();
                }
              },
            )
          : SafeArea(
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
              child: CustomSmartRefresher(
                onRefresh: _onRefresh,
                child: (orderVM.isLoading || homeVM.isLoading)
                    ? ListView.builder(
                        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                        itemCount: 6,
                        itemBuilder: (context, index) => AppShimmer.orderCard(),
                      )
                    : filteredOrders.isEmpty
                    ? ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                        children: [
                          _buildEmptyState(selectedFilter),
                        ],
                      )
                    : ListView.builder(
                        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                        itemCount: filteredOrders.length,
                        itemBuilder: (context, index) {
                        final order = filteredOrders[index];
                        return Padding( // Use the local OrderCard
                          padding: EdgeInsets.only(bottom: 15.h),
                          child: home_order_card.OrderCard(
                            key: ValueKey("${order.orderId}_${order.orderType}"),
                            onAccept: () => _handleAcceptOrder(context, homeVM, order, isOnline),
                            orderid: order.orderId,
                            orderNumber: order.orderNumber,
                            name: order.name,
                            by: order.by,
                            address: order.address,
                            orderType: order.orderType,
                            isPaid: order.isPaid,
                            isDetailsPage: true,
                            items: order.items,
                          ),
                        );
                      },
                    ),
            ),
            ),
          ]
        ),
      ),
    );
  }

  Widget _buildTypeToggle(OrderType type, String label) {
    final isActive = _selectedType == type;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() => _selectedType = type);
          final homeVM = context.read<HomeViewModel>();
          final orderVM = context.read<OrderViewModel>();
          Future.wait([homeVM.refreshOrders(), orderVM.fetchAllOrders()]);
        },
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
      onPressed: () {
        final orderVM = context.read<OrderViewModel>();
        vm.setSelectedFilter(filterKey);
        Future.wait([vm.refreshOrders(), orderVM.fetchAllOrders()]);
      },
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined, size: 60.sp, color: AppColors.grey.withValues(alpha: 0.4)),
          SizedBox(height: 15.h),
          Text(
            message,
            style: GoogleFonts.poppins(
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.grey,
            ),
          ),
        ],
      ),
    );
  }

  (String title, String subtitle) _resolvePageInfo(HomeViewModel vm, OrderViewModel orderVm, String filter) {
    switch (filter) {
      case "assigned":
        return (AppText.ActiveOrders, "${vm.assignedCount} ${AppText.ActiveTasks}");
      case "completed":
        return (AppText.CompletedOrders, "${vm.completedCount} ${AppText.Delivered}");
      default:
        // Filter header count by order type (Pickup/Delivery) for consistency with the list.
        final count = orderVm.pendingOrders.where((o) => o.orderType == _selectedType).length;
        final suffix = count == 1 ? AppText.OrderSingle : AppText.OrderPlural;
        return (AppText.NewOrders, "$count $suffix ${AppText.ReviewedConfirmed}");
    }
  }

  Future<void> _handleAcceptOrder(BuildContext context, HomeViewModel vm, OrderModel order, bool isOnline) async {
    final connectivity = context.read<ConnectivityViewModel>();
    if (!await connectivity.refreshConnection()) {
      final messenger = ScaffoldMessenger.of(context);
      messenger.showSnackBar(SnackBar(content: Text(AppText.UrOffline)));
      return;
    }

    // Capture the navigator reference BEFORE the async gap (await)
    // to avoid the "deactivated widget's ancestor" error later.
    final navigator = Navigator.of(context, rootNavigator: true);

    await context.read<OrderViewModel>().acceptOrder(order.orderId, order.orderType);
    context.read<HomeViewModel>().setSelectedFilter("assigned");

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
    
    // Use the captured navigator instead of looking it up again via context
    if (mounted) {
      navigator.pop();
    }
  }
 }
