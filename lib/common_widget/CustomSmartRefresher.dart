// import 'package:flutter/material.dart';
// import 'package:ziya_laundry_deliveryapp/Constants/app_colors.dart';

// class CustomSmartRefresher extends StatelessWidget {
//   final Widget child;
//   final Future<void> Function() onRefresh;
//   final bool enablePullDown;

//   const CustomSmartRefresher({
//     super.key,
//     required this.child,
//     required this.onRefresh,
//     this.enablePullDown = true,
//   });

//   @override
//   Widget build(BuildContext context) {
//     if (!enablePullDown) return child;

//     return RefreshIndicator(
//       onRefresh: onRefresh,
//       edgeOffset: 8.0,
//       displacement: 120.0,
//       color: AppColors.primaryBlue,
//       backgroundColor: AppColors.white,
//       notificationPredicate: (ScrollNotification notification) {
//         return notification.depth == 0;
//       },
//       child: child,
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:ziya_laundry_deliveryapp/Constants/app_colors.dart';
import 'package:s_liquid_pull_to_refresh/s_liquid_pull_to_refresh.dart';

class CustomSmartRefresher extends StatefulWidget {
  final Widget child;
  final Future<void> Function() onRefresh;
  final bool enablePullDown;
  final Color? indicatorColor;
  final Color? backgroundColor;

  const CustomSmartRefresher({
    super.key,
    required this.child,
    required this.onRefresh,
    this.enablePullDown = true,
    this.indicatorColor,
    this.backgroundColor,
  });

  @override
  State<CustomSmartRefresher> createState() =>
      _CustomSmartRefresherState();
}

class _CustomSmartRefresherState
    extends State<CustomSmartRefresher> {
  bool _isRefreshing = false;

  Future<void> _handleRefresh() async {
    if (_isRefreshing) return;

    _isRefreshing = true;

    try {
      await widget.onRefresh();
    } catch (e, stackTrace) {
      debugPrint(
        'Refresh Error: $e\n$stackTrace',
      );
    } finally {
      _isRefreshing = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enablePullDown) {
      return widget.child;
    }

    return SLiquidPullToRefresh(
      onRefresh: _handleRefresh,
      color: widget.backgroundColor ?? AppColors.white,
      backgroundColor: widget.indicatorColor ?? AppColors.primaryBlue,
      height: 80,
      animSpeedFactor: 2.0,
      showChildOpacityTransition: false,
      springAnimationDurationInMilliseconds: 300,
      child: widget.child,
    );
  }
}