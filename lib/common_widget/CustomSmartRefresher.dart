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

/// A customized pull-to-refresh wrapper that provides consistent pull-to-refresh
/// physics and visual styling across the application.
///z
/// It wraps a scrollable [child] and triggers [onRefresh] when pulled down past the top.
/// Safely filters out nested scroll notifications to avoid accidental triggers.
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
  State<CustomSmartRefresher> createState() => _CustomSmartRefresherState();
}

class _CustomSmartRefresherState extends State<CustomSmartRefresher> {
  bool _isRefreshing = false;

  Future<void> _handleRefresh() async {
    if (_isRefreshing) return;

    if (mounted) {
      setState(() {
        _isRefreshing = true;
      });
    }

    try {
      await widget.onRefresh();
    } catch (e, stackTrace) {
      debugPrint('Refresh Error: $e\n$stackTrace');
    } finally {
      if (mounted) {
        setState(() {
          _isRefreshing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enablePullDown) {
      return widget.child;
    }

    return RefreshIndicator(
      onRefresh: _handleRefresh,
      color: widget.indicatorColor ?? AppColors.primaryBlue,
      backgroundColor: widget.backgroundColor ?? AppColors.white,
      displacement: 40.0,
      edgeOffset: 8.0,
      strokeWidth: 2.5,
      notificationPredicate: (ScrollNotification notification) {

        return notification.depth == 0;
      },
      child: widget.child,
    );
  }
}