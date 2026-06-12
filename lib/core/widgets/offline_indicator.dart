import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ziya_laundry_deliveryapp/Constants/app_colors.dart';
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
  bool _isExiting = false;

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
        if (_noInternetPopup != null) {
          setState(() => _isExiting = true);
          // Trigger the internal rebuild of the overlay to start exit animation
          _noInternetPopup?.markNeedsBuild();
          // Wait for animation to finish before removal
          Future.delayed(const Duration(milliseconds: 400), () {
            _removePopup();
          });
        }
      }
    };
  }

  void _showNoInternetPopup() {
    // Prevent duplicate popups
    if (_noInternetPopup != null) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      try { // Start of try block
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
          builder: (context) {
            return TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOutCubic,
              tween: Tween(
                begin: _isExiting ? 0.0 : 100.0, 
                end: _isExiting ? 100.0 : 0.0
              ),
              builder: (context, value, child) {
                return Positioned(
                  bottom: 40.h - value,
                  left: 16.w,
                  right: 16.w,
                  child: Opacity(
                    opacity: ((100 - value) / 100).clamp(0.0, 1.0),
                    child: child,
                  ),
                );
              },
              child: Material(
                color: Colors.transparent,
                child: Container(
                  width: double.infinity,
                  height: 45.h,
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  decoration: BoxDecoration(
                    color: AppColors.grey.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(12.r),
                    boxShadow: const [ // Added const and corrected closing bracket
                      BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 4))
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(CupertinoIcons.wifi_exclamationmark, color: Colors.white),
                      SizedBox(width: 12.w),
                      Text(
                        "No Internet Connection",
                        style: TextStyle(color: Colors.white, fontSize: 14.sp, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );

        overlay.insert(_noInternetPopup!); // This is now correctly inside the try block
      } catch (e) { // End of try-catch block
        debugPrint('Failed to show offline indicator: $e');
        _noInternetPopup = null;
      }
    }); // Corrected: closing ')' for addPostFrameCallback
  }

  void _removePopup() {
    _noInternetPopup?.remove();
    _noInternetPopup = null;
    _isExiting = false;
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
