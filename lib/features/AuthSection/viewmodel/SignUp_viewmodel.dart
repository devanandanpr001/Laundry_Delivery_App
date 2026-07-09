import 'package:flutter/material.dart';
import 'package:ziya_laundry_deliveryapp/core/validators/Validators.dart';
import 'package:ziya_laundry_deliveryapp/features/AuthSection/data/model/user_model.dart';
import 'package:ziya_laundry_deliveryapp/features/AuthSection/data/repositories/auth_repository.dart';
import 'package:ziya_laundry_deliveryapp/features/AuthSection/data/services/auth_service.dart';
import 'base_viewmodel.dart';

class SignupViewModel extends BaseViewModel {
  final AuthRepository _repository = AuthRepository();
  final AuthService _authService = AuthService();
  final UserModel _signupModel = UserModel();

  String? signupNameError;
  String? signupMobileError;
  String? signupPasswordError;
  String? confirmPasswordError;
  String? agreementError;

  bool get isAgreed => _signupModel.agreed;

  void updateSignupName(String value) {
    _signupModel.name = value;
    signupNameError = null;
    notifyListeners();
  }

  void updateSignupMobile(String value) {
    _signupModel.mobile = value;
    signupMobileError = null;
    notifyListeners();
  }

  void updateSignupPassword(String value) {
    _signupModel.password = value;
    signupPasswordError = null;
    notifyListeners();
  }

  void updateConfirmPassword(String value) {
    _signupModel.confirmPassword = value;
    confirmPasswordError = null;
    notifyListeners();
  }

  void toggleAgreement(bool value) {
    _signupModel.agreed = value;
    agreementError = null;
    notifyListeners();
  }

  bool validateSignup() {
    signupNameError = Validators.validateName(_signupModel.name);
    signupMobileError = Validators.validateMobile(_signupModel.mobile);
    signupPasswordError = Validators.validatePassword(_signupModel.password);
    confirmPasswordError = Validators.validateConfirmPassword(
      _signupModel.password,
      _signupModel.confirmPassword,
    );
    agreementError = Validators.validateAgreement(_signupModel.agreed);

    notifyListeners();

    return signupNameError == null &&
        signupMobileError == null &&
        signupPasswordError == null &&
        confirmPasswordError == null &&
        agreementError == null;
  }

  Future<bool> submitSignup() async {
    if (!validateSignup()) return false;

    setLoading(true);
    try {
      final success = await _repository.register(_signupModel);
      if (success) debugPrint('Signup Success');
      return success;
    } finally {
      setLoading(false);
    }
  }

  Future<String?> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    setLoading(true);
    try {

      if (currentPassword.isEmpty || newPassword.isEmpty || confirmPassword.isEmpty) {
        return "All fields are required";
      }
      final newPasswordError = Validators.validatePassword(newPassword);
      if (newPasswordError != null) return newPasswordError;
      
      if (newPassword != confirmPassword) return "Passwords do not match";
  
      final response = await _authService.changePassword(
        currentPassword,
        newPassword,
        confirmPassword,
      );

      if (response['success'] == true) {
        return null; 
      } else {
        return response['msg'] ?? "Failed to change password";
      }
    } finally {
      setLoading(false);
    }
  }
} 