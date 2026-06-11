import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:quick_popup_manager/quick_popup_manager.dart';

import 'package:ziya_laundry_deliveryapp/features/Home/viewmodel/home_viewmodel.dart';
/// A helper class to show consistent toast messages throughout the app.
class AppToast {
  static final _animationConfig = AnimationConfig(
    type: AnimationType.slideFromTop,
    duration: const Duration(milliseconds: 600),
    curve: Curves.easeInOutQuad,
  );

  /// Specialized toast for a successful login.
  static void showLoginSuccess({String? name}) {
    showSuccess(
      title: "Login Successful",
      message: name != null ? "Welcome back, $name!" : "Welcome back to Juggle Laundry!",
    );
  }

  /// Shows a success-themed toast.
  static void showSuccess({
    required String title,
    required String message,
    PopupStyle? style,
  }) {
    QuickPopupManager().showToast(
      title: title,
      message: message,
      position: PopupPosition.top,
      style: style ?? PopupStyle.success(),
      animation: _animationConfig,
    );
  }

  /// Shows an error-themed toast.
  static void showError({
    required String title,
    required String message,
  }) {
    QuickPopupManager().showToast(
      title: title,
      message: message,
      position: PopupPosition.top,
      style: PopupStyle.error(),
      animation: _animationConfig,
    );
  }

  /// Shows a warning-themed toast.
static void showWarning({
  required String title,
  required String message,
}) {
  QuickPopupManager().showToast(
    title: title,
    message: message,
    position: PopupPosition.top, // Use the exact hex color
    style: const PopupStyle(
      backgroundColor: Color(0xFFF88D3D),

      titleStyle: TextStyle(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),

      messageStyle: TextStyle(
        color: Colors.white,
        fontSize: 14,
      ),
    ),
    animation: _animationConfig,
  );
}

  /// Shows an info-themed toast.
  static void showInfo({
    required String title,
    required String message,
  }) {
    QuickPopupManager().showToast(
      title: title,
      message: message,
      position: PopupPosition.top,
      style: PopupStyle.info(),
      animation: _animationConfig,
    );
  }

  /// Shows a specialized warning toast with a toggle button to go online.
  static void showOnlineAction(BuildContext context, {required bool isOnline, required HomeViewModel homeVM}) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;

    bool _localOnline = isOnline;
    bool _isSuccess = false;
    bool _isLoading = false;
    bool _isAnimatingOut = false; // New state for exit animation

    StateSetter? _overlaySetState; // To capture setState from StatefulBuilder

    entry = OverlayEntry(
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            _overlaySetState = setState; // Capture setState

            return TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOutCubic,
              // Tween now depends on _isAnimatingOut for smooth exit
              tween: Tween(begin: _isAnimatingOut ? 0.0 : -100.0, end: _isAnimatingOut ? -100.0 : 0.0),
              onEnd: () {
                if (_isAnimatingOut && entry.mounted) {
                  entry.remove(); // Remove the overlay entry only after the exit animation completes
                }
              },
              builder: (context, value, child) {
                return Positioned(
                  top: MediaQuery.of(context).padding.top + 10 + value,
                  left: 15,
                  right: 15,
                  child: Opacity(
                    opacity: ((100 + value) / 100).clamp(0.0, 1.0),
                    child: child,
                  ),
                );
              },
              child: Material(
                color: Colors.transparent,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: _isSuccess ? const Color(0xFF34C759) : const Color(0xFFF88D3D),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [
                      BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 3))
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(_isSuccess ? Icons.check_circle_rounded : Icons.wifi_off_rounded, color: Colors.white, size: 28),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_isSuccess ? "Status Updated" : "Duty Offline", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                            Text(_isSuccess ? "You are now online!" : "Go online to accept orders", style: const TextStyle(color: Colors.white70, fontSize: 12)),
                          ],
                        ),
                      ),
                      Transform.scale(
                        scale: 0.75,
                        child: _isLoading
                          ? const CupertinoActivityIndicator(color: Colors.white)
                          : CupertinoSwitch(
                          value: _localOnline,
                          activeColor: Colors.white,
                          trackColor: Colors.black.withOpacity(0.1),
                          onChanged: (value) async {
                            _overlaySetState!(() => _isLoading = true);
                            bool success = await homeVM.toggleOnlineStatus();
                            if (success) {
                              _overlaySetState!(() {
                                _isLoading = false;
                                _isSuccess = true;
                                _localOnline = true;
                              });
                              Future.delayed(const Duration(seconds: 2), () {
                                if (entry.mounted) {
                                  _overlaySetState!(() => _isAnimatingOut = true);
                                }
                              });
                            } else {
                              _overlaySetState!(() => _isLoading = false);
                              AppToast.showError(
                                title: "Failed",
                                message: "Please check your connection.",
                              );
                              Future.delayed(const Duration(milliseconds: 500), () {
                                if (entry.mounted) {
                                  _overlaySetState!(() => _isAnimatingOut = true);
                                }
                              });
                            }
                          },
                      ),
                    ),
                    ]
                  ),
                ),
              ),
            );
          },
        );
      },
    );

    overlay.insert(entry);
    Future.delayed(const Duration(seconds: 4), () {
      if (entry.mounted && !_isSuccess && !_isLoading && _overlaySetState != null) {
        _overlaySetState!(() => _isAnimatingOut = true);
      }
    });
  }
}