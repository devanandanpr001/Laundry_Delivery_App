import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:quick_popup_manager/quick_popup_manager.dart';

class AppLoader {
  static String? _currentLoaderId;
  static void show() {
    if (_currentLoaderId != null) return;

    _currentLoaderId = DateTime.now().millisecondsSinceEpoch.toString();

    QuickPopupManager().showDialogPopup(
      barrierDismissible: false,
      barrierColor: Colors.transparent,
      animation: const AnimationConfig.fade(),
      style: PopupStyle(
        backgroundColor: Colors.transparent,
        elevation: 0,
        padding: EdgeInsets.zero,
        dialogAlignment: Alignment.center,
      ),
      confirmText: '',
      cancelText: '',
      onConfirm: null,
      onCancel: null,
      content: Center(
        child: Material(
          color: Colors.transparent,
          child: SizedBox(
            width: 120,
            height: 120,
            child: Lottie.asset('assets/gifs/Loading_animation_blue.json', fit: BoxFit.contain, repeat: true),
          ),
        ),
      ),
    );
  }

  /// Hides the loading overlay
  static void hide() {
    if (_currentLoaderId != null) {
      QuickPopupManager().dismissAll();
      _currentLoaderId = null;
    }
  }

  static void showResult({
    required String title,
    required String message,
    bool isError = false,
    VoidCallback? onOk,
  }) {
    hide();
    QuickPopupManager().showDialogPopup(
      barrierDismissible: false,
      animation: const AnimationConfig.scale(),
      style: PopupStyle(
        backgroundColor: Colors.transparent,
        elevation: 0,
        padding: EdgeInsets.zero,
      ),
      confirmText: '',
      cancelText: '',
      onConfirm: null,
      onCancel: null,
      content: Center(
        child: Container(
          width: 330,
          margin: EdgeInsets.symmetric(horizontal: 24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.18),
                blurRadius: 30,
                spreadRadius: 8,
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isError ? Icons.error_outline_rounded : Icons.check_circle_outline_rounded,
                  color: isError ? Colors.redAccent : const Color(0xFF42B883),
                  size: 58,
                ),
                SizedBox(height: 22),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1E293B),
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 12),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                    height: 1.45,
                  ),
                ),
                SizedBox(height: 32),
                GestureDetector(
                  onTap: () {
                    QuickPopupManager().dismissAll();
                    if (onOk != null) onOk();
                  },
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: isError ? Colors.redAccent : const Color(0xFF42B883),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      "OK",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Future<T?> navigateWithTask<T>(
    BuildContext context, {
    required Future<void> Function() task,
    required Widget page,
    RouteSettings? settings,
  }) async {
    show();
    try {
      await task();
      hide();
    } catch (e) {
      hide();
      showResult(
        title: "Connection Issue",
        message: e.toString().replaceFirst("Exception: ", ""),
        isError: true,
      );
      return null;
    }

    if (!context.mounted) return null;

    return Navigator.push<T>(
      context,
      PageRouteBuilder(
        settings: settings,
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 320),
      ),
    );
  }

  static Future<T?> navigateReplacementWithTask<T, TO>(
    BuildContext context, {
    required Future<void> Function() task,
    required Widget page,
    RouteSettings? settings,
  }) async {
    show();
    try {
      await task();
      hide();
    } catch (e) {
      hide();
      showResult(title: "Task Failed", message: e.toString(), isError: true);
      return null;
    }

    if (!context.mounted) return null;

    return Navigator.pushReplacement<T, TO>(
      context,
      PageRouteBuilder(
        settings: settings,
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  static Future<T?> navigateAndRemoveUntilWithTask<T>(
    BuildContext context, {
    required Future<void> Function() task,
    required Widget page,
    RouteSettings? settings,
  }) async {
    show();
    try {
      await task();
      hide();
    } catch (e) {
      hide();
      showResult(title: "Task Failed", message: e.toString(), isError: true);
      return null;
    }

    if (!context.mounted) return null;

    return Navigator.pushAndRemoveUntil<T>(
      context,
      PageRouteBuilder(
        settings: settings,
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
      (route) => false,
    );
  }

  static Future<T?> navigateWithLoader<T>(
    BuildContext context,
    Widget page, {
    RouteSettings? settings,
  }) async {
    return navigateWithTask<T>(
      context,
      task: () => Future.delayed(const Duration(milliseconds: 650)),
      page: page,
      settings: settings,
    );
  }
}