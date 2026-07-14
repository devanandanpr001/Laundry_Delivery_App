import 'package:flutter/material.dart';
import 'package:ziya_laundry_deliveryapp/features/AuthSection/data/repositories/auth_repository.dart';
import 'base_viewmodel.dart';
import 'package:ziya_laundry_deliveryapp/common_widget/testing_toast.dart';

class ForgotPasswordViewModel extends BaseViewModel {
  final AuthRepository _repository = AuthRepository();

  final TextEditingController mobileController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  String? _verifiedOtp;
  String? _otp; // To store the OTP for testing toast
  String? _resetToken;

  Future<bool> sendOtp(BuildContext context) async {
    final String phoneNumber = mobileController.text.trim();

    if (phoneNumber.isEmpty || phoneNumber.length < 10) return false;

    // Clear previous OTP for a fresh request
    _otp = null;
    notifyListeners();

    setLoading(true);
    try {
      final result = await _repository.forgotPassword(phoneNumber);
      if (result['success'] == true) {
        // Store OTP for testing toast if available in the response
        if (result['otp'] != null) {
          _otp = result['otp'].toString();
          TestingToast.showTestOtp(context, _otp!);
        }
        return true;
      } else {
        setError(result['msg'] ?? "Failed to send OTP");
        return false;
      }
    } catch (e) {
      setError("Server error");
      return false;
    } finally {
      setLoading(false);
    }
  }

  Future<bool> verifyOtp(String pin) async {
    setLoading(true);
    try {
      final String phoneNumber = mobileController.text.trim();
      final result = await _repository.verifyForgotOtp(phoneNumber, pin);
      if (result['success'] == true) {
        _verifiedOtp = pin.trim();
        _resetToken = _extractResetToken(result);
        return true;
      } else {
        setError(result['msg'] ?? "Invalid OTP");
        return false;
      }
    } finally {
      setLoading(false);
    }
  }

  Future<bool> resendOtp() async {
    final String phoneNumber = mobileController.text.trim();

    if (phoneNumber.isEmpty || phoneNumber.length < 10) return false;

    setLoading(true);
    try {
      final result = await _repository.resendForgotOtp(phoneNumber);
      if (result['success'] == true) {
        _verifiedOtp = null;
        _resetToken = null;
        return true;
      } else {
        setError(result['msg'] ?? "Failed to resend OTP");
        return false;
      }
    } finally {
      setLoading(false);
    }
  }

  Future<bool> submitReset(String phone) async {
    setLoading(true);
    try {
      final result = await _repository.resetPassword(
        phone,
        newPasswordController.text,
        confirmPasswordController.text,
        otp: _verifiedOtp,
        resetToken: _resetToken,
      );
      if (result['success'] == true) {
        _verifiedOtp = null;
        _resetToken = null;
        return true;
      } else {
        setError(result['msg'] ?? "Failed to reset password");
        return false;
      }
    } catch (e) {
      setError("Reset failed");
      return false;
    } finally {
      setLoading(false);
    }
  }

  String? _extractResetToken(Map<String, dynamic> response) {
    final candidates = [
      response['resetToken'],
      response['token'],
      response['data'] is Map ? response['data']['resetToken'] : null,
      response['data'] is Map ? response['data']['token'] : null,
    ];

    for (final candidate in candidates) {
      final value = candidate?.toString().trim();
      if (value != null && value.isNotEmpty) return value;
    }

    return null;
  }

  /// Clears all text controllers and resets internal state.
  void clearAllFields() {
    mobileController.clear();
    newPasswordController.clear();
    confirmPasswordController.clear();
    _verifiedOtp = null;
    _resetToken = null;
  }
}
