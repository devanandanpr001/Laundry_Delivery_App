import 'package:flutter/material.dart';
import 'package:ziya_laundry_deliveryapp/core/validators/Validators.dart';
import 'package:ziya_laundry_deliveryapp/features/AuthSection/data/repositories/auth_repository.dart';
import 'package:ziya_laundry_deliveryapp/core/services/SocketService.dart';
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
        // Extract user data from response safely
        final userJson = _extractUserMap(result);
        
        // Extract credentials safely to pass to SocketService
        final String userId = (userJson['id'] ?? userJson['_id'] ?? userJson['userId'] ?? '').toString();
        final String role = userJson['role']?.toString() ?? 'USER';

        // Connect socket for the authenticated user session
        await SocketService().connect(userId: userId, role: role);

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

  Map<String, dynamic> _extractUserMap(dynamic response) {
    if (response is! Map) return {};
    if (response['user'] is Map) return Map<String, dynamic>.from(response['user']);
    if (response['data'] is Map) {
      final data = response['data'];
      if (data['user'] is Map) return Map<String, dynamic>.from(data['user']);
      return Map<String, dynamic>.from(data);
    }
    return Map<String, dynamic>.from(response);
  }
}