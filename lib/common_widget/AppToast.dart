import 'package:flutter/material.dart';
import 'package:quick_popup_manager/quick_popup_manager.dart';

/// A helper class to show consistent toast messages throughout the app.
class AppToast {
  static final _animationConfig = AnimationConfig(
    type: AnimationType.slideFromTop,
    duration: const Duration(milliseconds: 600),
    curve: Curves.easeInOutQuad,
  );

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
      position: PopupPosition.top,
      style: PopupStyle.warning(),
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
}