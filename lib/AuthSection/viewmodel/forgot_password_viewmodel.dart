import 'package:flutter/material.dart';
import 'package:ziya_laundry_deliveryapp/AuthSection/data/repositories/auth_repository.dart';
import '../../Constants/validators/signup_validators.dart';
import 'base_viewmodel.dart';

class ForgotPasswordViewModel extends BaseViewModel {
  final AuthRepository _repository = AuthRepository();

  final TextEditingController mobileController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  Future<bool> sendOtp() async {
    final String phoneNumber = mobileController.text.trim();

    if (phoneNumber.isEmpty || phoneNumber.length < 10) return false;

    setLoading(true);
    try {
      final result = await _repository.forgotPassword(phoneNumber);
      if (result['success'] == true) {
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
      final result = await _repository.resendOtp(phoneNumber);
      if (result['success'] == true) {
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
      );
      if (result['success'] == true) {
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
}