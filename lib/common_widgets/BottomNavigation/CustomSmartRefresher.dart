import 'package:flutter/material.dart';
import 'package:s_liquid_pull_to_refresh/s_liquid_pull_to_refresh.dart';
import 'package:ziya_laundry_deliveryapp/Constants/app_colors.dart';

class CustomSmartRefresher extends StatelessWidget {
  final Widget child;
  final Future<void> Function() onRefresh;
  final bool enablePullDown;

  const CustomSmartRefresher({
    super.key,
    required this.child,
    required this.onRefresh,
    this.enablePullDown = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!enablePullDown) return child;

    return SLiquidPullToRefresh(
      onRefresh: onRefresh,
      height: 150,
      animSpeedFactor: 1.3,
      showChildOpacityTransition: false,
      borderWidth: 3,
      color: AppColors.primaryBlue,
      backgroundColor: AppColors.white.withValues(alpha:0.2),
      child: child,
    );
  }
}
