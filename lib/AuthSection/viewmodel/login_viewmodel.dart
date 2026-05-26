import 'package:flutter/material.dart';
import 'package:ziya_laundry_deliveryapp/AuthSection/data/repositories/auth_repository.dart';
import '../../core/validators/Validators.dart';
import 'base_viewmodel.dart';

class LoginViewModel extends BaseViewModel {
  final AuthRepository _repository = AuthRepository();
  
  // Controllers for input fields
  final TextEditingController nameController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool _rememberMe = false; // Directly manage rememberMe state
  
  String? loginNameError;
  String? loginMobileError;
  String? loginPasswordError;

  bool get isRememberMe => _rememberMe;
  String get loginName => nameController.text;
  String get loginNumber => mobileController.text;

  void updateLoginName(String value) {
    nameController.text = value; // Update controller text
    loginNameError = null;
    notifyListeners();
  }

  void updateLoginMobile(String value) {
    mobileController.text = value; 
    loginMobileError = null;
    notifyListeners();
  }

  void updateLoginPassword(String value) {
    passwordController.text = value; // Update controller text
    loginPasswordError = null;
    notifyListeners();
  }

  void toggleRememberMe(bool value) {
    _rememberMe = value;
    notifyListeners();
  }

  void clearFields() {
    nameController.clear();
    mobileController.clear();
    passwordController.clear();
    loginNameError = null;
    loginMobileError = null;
    loginPasswordError = null;
    _rememberMe = false;
    notifyListeners();
  }

  bool validateLogin() {
    loginNameError = Validators.validateName(nameController.text);
    loginMobileError = Validators.validateMobile(mobileController.text);
    loginPasswordError = Validators.validatePassword(passwordController.text);

    notifyListeners();
    return loginNameError == null &&
           loginMobileError == null && 
           loginPasswordError == null;
  }

  Future<bool> submitLogin() async {
    if (!validateLogin()) return false;
    
    setError(null);
    setLoading(true);
    try {
      // Logic: Centralized through Repository
      final result = await _repository.login(
        nameController.text, // Passed with no changes
        mobileController.text.trim(),
        passwordController.text, // Do not trim passwords
      );

      debugPrint("LOGIN RESPONSE: $result");

      if (result['success'] == true) {
        return true;
      } else {
        setError(result['msg'] ?? "Login failed");
        return false;
      }
    } catch (e) {
      setError("Server error. Please try again later.");
      return false;
    } finally {
      setLoading(false);
    }
  }

  Future<bool> verifyOtp(String pin) async {
    setLoading(true);
    try {
      final result = await _repository.verifyOtp(mobileController.text, pin);
      if (result['success'] == true) {
        return true;
      } else {
        setError(result['msg'] ?? "Invalid OTP");
        return false;
      }
    } catch (e) {
      setError("Verification failed");
      return false;
    } finally {
      setLoading(false);
    }
  }

  Future<bool> resendOtp() async {
    final result = await _repository.resendOtp(loginNumber);
    if (result['success'] != true) {
      setError(result['msg'] ?? "Failed to resend OTP");
    }
    return result['success'] == true;
  }

  @override
  void dispose() {
    nameController.dispose();
    mobileController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}