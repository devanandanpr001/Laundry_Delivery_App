import 'package:flutter/material.dart';
import 'package:ziya_laundry_deliveryapp/AuthSection/data/model/user_model.dart';
import 'package:ziya_laundry_deliveryapp/AuthSection/data/repositories/auth_repository.dart';
import '../../Constants/validators/signup_validators.dart';
import 'base_viewmodel.dart';

class LoginViewModel extends BaseViewModel {
  final AuthRepository _repository = AuthRepository();
  final UserModel _loginModel = UserModel();
  
  String? loginNameError;
  String? loginMobileError;
  String? loginPasswordError;

  String get loginName => _loginModel.name;
  String get loginNumber => _loginModel.mobile;
  bool get isRememberMe => _loginModel.rememberMe;

  void updateLoginName(String value) {
    _loginModel.name = value;
    loginNameError = null;
    notifyListeners();
  }

  void updateLoginMobile(String value) {
    _loginModel.mobile = value;
    loginMobileError = null;
    notifyListeners();
  }

  void updateLoginPassword(String value) {
    _loginModel.password = value;
    loginPasswordError = null;
    notifyListeners();
  }

  void toggleRememberMe(bool value) {
    _loginModel.rememberMe = value;
    notifyListeners();
  }

  bool validateLogin() {
    loginMobileError = SignupValidator.validateMobile(_loginModel.mobile);

    notifyListeners();
    return loginMobileError == null;
  }

  Future<bool> submitLogin() async {
    if (!validateLogin()) return false;
    
    setError(null);
    setLoading(true);
    try {
      // Logic: Centralized through Repository
      final result = await _repository.login(_loginModel.mobile);

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
      final result = await _repository.verifyOtp(loginNumber, pin);
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
}