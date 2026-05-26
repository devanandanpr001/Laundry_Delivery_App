import 'package:flutter/material.dart';
import 'package:ziya_laundry_deliveryapp/core/Constants/app_colors.dart';

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

    return RefreshIndicator(
      onRefresh: onRefresh,
      edgeOffset: 8.0,
      displacement: 120.0,
      color: AppColors.primaryBlue,
      backgroundColor: AppColors.white,
      notificationPredicate: (ScrollNotification notification) {
        return notification.depth == 0;
      },
      child: child,
    );
  }
}
