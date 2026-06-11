import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ziya_laundry_deliveryapp/core/Constants/app_colors.dart';
import 'package:ziya_laundry_deliveryapp/core/services/network_service.dart';


/// Manages and displays an offline indicator overlay when internet is unavailable.
/// Wrap your MaterialApp's home or builder with this widget.
class OfflineIndicatorWrapper extends StatefulWidget {
  final Widget child;
  final GlobalKey<NavigatorState> navigatorKey;

  const OfflineIndicatorWrapper({
    super.key,
    required this.child,
    required this.navigatorKey,
  });

  @override
  State<OfflineIndicatorWrapper> createState() =>
      _OfflineIndicatorWrapperState();
}

class _OfflineIndicatorWrapperState extends State<OfflineIndicatorWrapper> {
  OverlayEntry? _noInternetPopup;
  bool _waitingForOverlay = false;

  @override
  void initState() {
    super.initState();
    _setupNetworkListener();
  }

  void _setupNetworkListener() {
    // Set up listener for connection changes
    NetworkService.instance.onStatusChange = (isOnline) {
      if (!mounted) return;

      if (!isOnline) {
        _showNoInternetPopup();
      } else {
        _removePopup();
      }
    };
  }

  void _showNoInternetPopup() {
    // Prevent duplicate popups
    if (_noInternetPopup != null) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      try {
        final overlay = widget.navigatorKey.currentState?.overlay;
        if (overlay == null) {
          if (!_waitingForOverlay) {
            _waitingForOverlay = true;
            Future.delayed(const Duration(milliseconds: 100), () {
              _waitingForOverlay = false;
              if (!mounted) return;
              _showNoInternetPopup();
            });
          }
          return;
        }

        _noInternetPopup = OverlayEntry(
          builder: (context) => Positioned(
            bottom: 40.h,
            left: 16.w,
            right: 16.w,
            child: Material(
              color: Colors.transparent,
              child: Container(
                width: double.infinity,
                height: 40.h,
                //margin: EdgeInsets.symmetric(horizontal: 5.w),
                padding: EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.grey.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(CupertinoIcons.info, color: Colors.white),
                    SizedBox(width: 12),
                    const Text(
                      "No Internet Connection",
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );

        overlay.insert(_noInternetPopup!);
      } catch (e) {
        debugPrint('Failed to show offline indicator: $e');
        _noInternetPopup = null;
      }
    });
  }

  void _removePopup() {
    _noInternetPopup?.remove();
    _noInternetPopup = null;
  }

  @override
  void dispose() {
    _removePopup();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
