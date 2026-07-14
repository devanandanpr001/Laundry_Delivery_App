import 'dart:ui';
import 'package:flutter/material.dart';

/// A collection of toast messages used exclusively for development and testing.
class TestingToast {
  /// Shows a toast with the OTP for debugging purposes.
  ///
  /// This toast remains visible for 30 seconds to allow for easy copying or viewing.
  static void showTestOtp(BuildContext context, String otp) {
    _showTestingToast(context,
        title: "Test OTP",
        message: otp,
        icon: Icons.password_rounded,
        backgroundColor: const Color(0xFF5856D6), // A distinct purple color
        iconColor: const Color(0xFF5856D6));
  }

  static void _showTestingToast(
    BuildContext context, {
    required String title,
    required String message,
    required IconData icon,
    required Color backgroundColor,
    required Color iconColor,
  }) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;
    bool isAnimatingOut = false;
    StateSetter? overlaySetState;

    entry = OverlayEntry(
      builder: (context) {
        return StatefulBuilder(
          builder: (builderContext, setState) {
            overlaySetState = (fn) {
              if (builderContext.mounted) setState(fn);
            };

            return TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 500),
              curve: isAnimatingOut ? Curves.easeInBack : Curves.easeOutBack,
              tween: Tween(
                begin: isAnimatingOut ? 0.0 : -120.0,
                end: isAnimatingOut ? -120.0 : 0.0,
              ),
              onEnd: () {
                if (isAnimatingOut && entry.mounted && builderContext.mounted) {
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
                        color: const Color.fromRGBO(255, 255, 255, 0.95),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: backgroundColor.withAlpha(38), // 0.15 alpha
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                        border: Border.all(color: backgroundColor.withAlpha(51), width: 1.5), // 0.2 alpha
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: backgroundColor.withAlpha(30), // 0.12 alpha
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
    Future.delayed(const Duration(seconds: 10), () {
      if (entry.mounted && overlaySetState != null && !isAnimatingOut) {
        overlaySetState!(() => isAnimatingOut = true);
      }
    });
  }
}