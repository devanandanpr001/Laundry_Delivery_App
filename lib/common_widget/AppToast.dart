import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:quick_popup_manager/quick_popup_manager.dart';
import 'package:ziya_laundry_deliveryapp/features/Home/viewmodel/home_viewmodel.dart';

class AppToast {
  static final _animationConfig = AnimationConfig(
    type: AnimationType.slideFromTop,
    duration: const Duration(milliseconds: 600),
    curve: Curves.easeInOutQuad,
  );

  static void _showPremiumToast(
    BuildContext context, {
    required String title,
    required String message,
    required IconData icon,
    required Color backgroundColor,
    required Color iconColor,
    VoidCallback? onUndo,
  }) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;
    bool _isAnimatingOut = false;
    StateSetter? _overlaySetState;

    entry = OverlayEntry(
      builder: (context) {
        return StatefulBuilder(
          builder: (builderContext, setState) {
            // Wrap setState to prevent "setState after dispose" errors
            _overlaySetState = (fn) {
              if (builderContext.mounted) setState(fn);
            };

            return TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 500),
              curve: _isAnimatingOut ? Curves.easeInBack : Curves.easeOutBack,
              tween: Tween(
                begin: _isAnimatingOut ? 0.0 : -120.0,
                end: _isAnimatingOut ? -120.0 : 0.0,
              ),
              onEnd: () {
                if (_isAnimatingOut && entry.mounted && builderContext.mounted) {
                  entry.remove();
                }
              },
              builder: (context, value, child) {
                final progress = ((120 + value) / 120).clamp(0.0, 1.0);
                return Positioned(
                  top: MediaQuery.of(context).padding.top + 10 + value,
                  left: 16,
                  right: 16,
                  child: Opacity(
                    opacity: progress,
                    child: Transform.scale(
                      scale: 0.95 + (0.05 * progress),
                      child: child,
                    ),
                  ),
                );
              },
              child: Material(
                color: Colors.transparent,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.95),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: backgroundColor.withValues(alpha: 0.15),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                        border: Border.all(color: backgroundColor.withValues(alpha: 0.2), width: 1.5),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: backgroundColor.withValues(alpha: 0.12),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(icon, color: iconColor, size: 24),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  title,
                                  style: const TextStyle(
                                    color: Color(0xFF2D3142),
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  message,
                                  style: const TextStyle(
                                    color: Color(0xFF6B7280),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (onUndo != null) ...[
                            const SizedBox(width: 8),
                            InkWell(
                              onTap: () {
                                onUndo();
                                if (entry.mounted && _overlaySetState != null) {
                                  _overlaySetState!(() => _isAnimatingOut = true);
                                }
                              },
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: backgroundColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: backgroundColor.withValues(alpha: 0.3)),
                                ),
                                child: Text(
                                  "Undo",
                                  style: TextStyle(
                                    color: backgroundColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ),
                          ] else ...[
                            const SizedBox(width: 8),
                            InkWell(
                              onTap: () {
                                if (entry.mounted && _overlaySetState != null) {
                                  _overlaySetState!(() => _isAnimatingOut = true);
                                }
                              },
                              borderRadius: BorderRadius.circular(20),
                              child: const Padding(
                                padding: EdgeInsets.all(4.0),
                                child: Icon(Icons.close_rounded, color: Color(0xFF9CA3AF), size: 22),
                              ),
                            ),
                          ]
                        ],
                      ),
                    ),
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
      if (entry.mounted && _overlaySetState != null && !_isAnimatingOut) {
        _overlaySetState!(() => _isAnimatingOut = true);
      }
    });
  }

  // 1. Login
  static void showLoginSuccess(BuildContext context, {String? name}) {
    _showPremiumToast(context, title: "Login Successful", message: name != null ? "Welcome back, $name!" : "Welcome back to Juggle Laundry!", icon: Icons.check_circle_rounded, backgroundColor: const Color(0xFF34C759), iconColor: const Color(0xFF34C759));
  }
  static void showLoginFailed(BuildContext context, {String? error}) {
    _showPremiumToast(context, title: "Login Failed", message: error ?? "Please check your credentials.", icon: Icons.error_rounded, backgroundColor: const Color(0xFFFF3B30), iconColor: const Color(0xFFFF3B30));
  }

  // 2. Forgot Password OTP
  static void showOtpSentSuccess(BuildContext context) {
    _showPremiumToast(context, title: "OTP Sent", message: "A verification code has been sent successfully.", icon: Icons.mark_email_read_rounded, backgroundColor: const Color(0xFF007AFF), iconColor: const Color(0xFF007AFF));
  }
  static void showOtpSentFailed(BuildContext context, {String? error}) {
    _showPremiumToast(context, title: "Failed to Send OTP", message: error ?? "We could not send the OTP. Please try again.", icon: Icons.error_rounded, backgroundColor: const Color(0xFFFF3B30), iconColor: const Color(0xFFFF3B30));
  }

  // 3. Password Changed
  static void showPasswordChangedSuccess(BuildContext context) {
    _showPremiumToast(context, title: "Password Changed", message: "Your password was updated successfully.", icon: Icons.lock_reset_rounded, backgroundColor: const Color(0xFF34C759), iconColor: const Color(0xFF34C759));
  }
  static void showPasswordChangedFailed(BuildContext context, {String? error}) {
    _showPremiumToast(context, title: "Change Password Failed", message: error ?? "Could not change password.", icon: Icons.error_outline_rounded, backgroundColor: const Color(0xFFFF3B30), iconColor: const Color(0xFFFF3B30));
  }

  // 4. Image Upload & Delete
  static void showImageUploadSuccess(BuildContext context) {
    _showPremiumToast(context, title: "Upload Successful", message: "Image uploaded successfully.", icon: Icons.cloud_done_rounded, backgroundColor: const Color(0xFF34C759), iconColor: const Color(0xFF34C759));
  }
  static void showImageDeleteSuccess(BuildContext context) {
    _showPremiumToast(context, title: "Images Deleted", message: "Selected images removed successfully.", icon: Icons.delete_sweep_rounded, backgroundColor: const Color(0xFF34C759), iconColor: const Color(0xFF34C759));
  }
  static void showImageUploadFailed(BuildContext context, {String? error}) {
    _showPremiumToast(context, title: "Upload Failed", message: error ?? "Failed to upload the image.", icon: Icons.cloud_off_rounded, backgroundColor: const Color(0xFFFF3B30), iconColor: const Color(0xFFFF3B30));
  }
  static void showImageDeleteFailed(BuildContext context, {String? error}) {
    _showPremiumToast(context, title: "Delete Failed", message: error ?? "Failed to delete the image.", icon: Icons.delete_forever_rounded, backgroundColor: const Color(0xFFFF3B30), iconColor: const Color(0xFFFF3B30));
  }

  // 5. Items Added & Deleted
  static void showItemAdded(BuildContext context, {required String itemName}) {
    _showPremiumToast(context, title: "Item Added", message: "$itemName has been added.", icon: Icons.add_shopping_cart_rounded, backgroundColor: const Color(0xFF007AFF), iconColor: const Color(0xFF007AFF));
  }
  static void showItemDeleted(BuildContext context, {required String itemName}) {
    _showPremiumToast(context, title: "Item Removed", message: "$itemName has been removed.", icon: Icons.remove_shopping_cart_rounded, backgroundColor: const Color(0xFFFF9500), iconColor: const Color(0xFFFF9500));
  }

  // 6. Order Accepted & Delivered
  static void showOrderAccepted(BuildContext context, {required String orderId}) {
    _showPremiumToast(context, title: "Order Accepted", message: "Order #$orderId is now in progress.", icon: Icons.thumb_up_rounded, backgroundColor: const Color(0xFF34C759), iconColor: const Color(0xFF34C759));
  }
  static void showOrderDelivered(BuildContext context, {required String orderId}) {
    _showPremiumToast(context, title: "Order Delivered", message: "Order #$orderId delivered successfully.", icon: Icons.local_shipping_rounded, backgroundColor: const Color(0xFF34C759), iconColor: const Color(0xFF34C759));
  }

  // 7. Notification Deleted
  static void showNotificationDeleted(BuildContext context, {required VoidCallback onUndo}) {
    _showPremiumToast(context, title: "Notification Deleted", message: "The notification was removed.", icon: Icons.delete_outline_rounded, backgroundColor: const Color(0xFF8E8E93), iconColor: const Color(0xFF8E8E93), onUndo: onUndo);
}

  /// ---------------------------------------------------------
  /// LEGACY METHODS (Fallback for existing code without context)
  /// ---------------------------------------------------------

  static void showWarning({required String title, required String message, BuildContext? context}) {
    if (context != null) {
      _showPremiumToast(context, title: title, message: message, icon: Icons.warning_rounded, backgroundColor: const Color(0xFFF88D3D), iconColor: const Color(0xFFF88D3D));
    } else {
      QuickPopupManager().showToast(title: title, message: message, position: PopupPosition.top, style: const PopupStyle(backgroundColor: Color(0xFFF88D3D), titleStyle: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold), messageStyle: TextStyle(color: Colors.white, fontSize: 14)), animation: _animationConfig);
    }
  }

  static void showInfo({required String title, required String message, BuildContext? context}) {
    if (context != null) {
      _showPremiumToast(context, title: title, message: message, icon: Icons.info_rounded, backgroundColor: const Color(0xFF007AFF), iconColor: const Color(0xFF007AFF));
    } else {
      QuickPopupManager().showToast(title: title, message: message, position: PopupPosition.top, style: PopupStyle.info(), animation: _animationConfig);
    }
  }

  static void showError({
  required BuildContext context,
  required String title,
  required String message,
}) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFFD32F2F),
        elevation: 4,
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        content: Row(
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    message,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
}

  /// Modern Error/Failure Toast with Rose-Red Gradient
  // ... existing code ...

  /// Shows a specialized warning toast with a toggle button to go online.
  static void showOnlineAction(BuildContext context, {required bool isOnline, required HomeViewModel homeVM}) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;

    bool _localOnline = isOnline;
    bool _isSuccess = false;
    bool _isLoading = false;
    bool _isAnimatingOut = false;

    StateSetter? _overlaySetState;

    entry = OverlayEntry(
      builder: (context) {
        return StatefulBuilder(
          builder: (builderContext, setState) {
            // Safe setState wrapper
            _overlaySetState = (fn) {
              if (builderContext.mounted) setState(fn);
            };

            return TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 600),
              curve: _isAnimatingOut ? Curves.easeInBack : Curves.easeOutBack,
              tween: Tween(
                begin: _isAnimatingOut ? 0.0 : -100.0,
                end: _isAnimatingOut ? -100.0 : 0.0,
              ),
              onEnd: () {
                if (_isAnimatingOut && entry.mounted && builderContext.mounted) {
                  entry.remove();
                }
              },
              builder: (context, value, child) {
                final progress = ((100 + value) / 100).clamp(0.0, 1.0);
                return Positioned(
                  top: MediaQuery.of(context).padding.top + 10 + value,
                  left: 15,
                  right: 15,
                  child: Opacity(
                    opacity: progress,
                    child: Transform.scale(
                      scale: 0.95 + (0.05 * progress),
                      child: child,
                    ),
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
                    boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 3))],
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _isSuccess ? Icons.check_circle_rounded : Icons.wifi_off_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _isSuccess ? "Status Updated" : "Duty Offline",
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                            Text(
                              _isSuccess ? "You are now online!" : "Go online to accept orders",
                              style: const TextStyle(color: Colors.white70, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      Transform.scale(
                        scale: 0.75,
                        child: _isLoading
                            ? const CupertinoActivityIndicator(color: Colors.white)
                            : CupertinoSwitch(
                                value: _localOnline,
                                activeTrackColor: Colors.white,
                                inactiveTrackColor: Colors.black.withValues(alpha: 0.1),
                                onChanged: (value) async {
                                  _overlaySetState?.call(() => _isLoading = true);
                                  bool success = await homeVM.toggleOnlineStatus();
                                  if (success) {
                                    _overlaySetState?.call(() {
                                      _isLoading = false;
                                      _isSuccess = true;
                                      _localOnline = true;
                                    });
                                    Future.delayed(const Duration(seconds: 2), () {
                                      if (entry.mounted && builderContext.mounted) {
                                        _overlaySetState?.call(() => _isAnimatingOut = true);
                                      }
                                    });
                                  } else {
                                    _overlaySetState?.call(() => _isLoading = false);
                                    AppToast.showError(message: "Please check your connection.", context: context, title: '');
                                    Future.delayed(const Duration(milliseconds: 500), () {
                                      if (entry.mounted && builderContext.mounted) {
                                        _overlaySetState?.call(() => _isAnimatingOut = true);
                                      }
                                    });
                                  }
                                },
                              ),
                      ),
                    ],
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
