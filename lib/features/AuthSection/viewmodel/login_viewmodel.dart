import 'package:flutter/material.dart';
import 'package:ziya_laundry_deliveryapp/core/validators/Validators.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ziya_laundry_deliveryapp/features/AuthSection/data/repositories/auth_repository.dart';
import 'package:ziya_laundry_deliveryapp/core/services/token_service.dart';
import 'package:ziya_laundry_deliveryapp/core/services/SocketService.dart';
import 'base_viewmodel.dart';

class LoginViewModel extends BaseViewModel {
  final AuthRepository _repository = AuthRepository();
  
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final TokenService _tokenService = TokenService();

  // Controllers for input fields
  final TextEditingController nameController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool _isRememberMe = false; // Directly manage rememberMe state
  
  String? loginNameError;
  String? loginMobileError;
  String? loginPasswordError;

  bool get isRememberMe => _isRememberMe;
  String get loginName => nameController.text.trim();
  String get loginNumber => mobileController.text.trim();

  /// Load saved credentials when screen opens
  Future<void> loadSavedCredentials() async {
    try {
      final savedName = await _secureStorage.read(key: 'saved_name');
      final savedMobile = await _secureStorage.read(key: 'saved_mobile');
      final savedPassword = await _secureStorage.read(key: 'saved_password');
      final savedRememberMe = await _secureStorage.read(key: 'remember_me');

      if (savedRememberMe == 'true' &&
          savedName != null &&
          savedMobile != null &&
          savedPassword != null) {
        _isRememberMe = true;
        nameController.text = savedName;
        mobileController.text = savedMobile;
        passwordController.text = savedPassword;
      } else {
        // If remember_me is not true, or any credential is missing,
        // ensure fields are empty and _isRememberMe is false.
        _isRememberMe = false;
        nameController.clear();
        mobileController.clear();
        passwordController.clear();
        await _secureStorage.write(key: 'remember_me', value: 'false'); // Ensure storage reflects this
      }
    } catch (e) {
      debugPrint("Failed to load saved credentials: $e");
      // In case of error, ensure fields are cleared for security
      _isRememberMe = false;
      nameController.clear();
      mobileController.clear();
      passwordController.clear();
      await _secureStorage.write(key: 'remember_me', value: 'false');
    }
    notifyListeners();
  }

  void toggleRememberMe(bool value) {
    _isRememberMe = value;
    notifyListeners();
  }

  Future<void> clearFields() async {
    nameController.clear();
    mobileController.clear();
    passwordController.clear();
    loginNameError = null;
    loginMobileError = null;
    loginPasswordError = null;
    _isRememberMe = false;
    await _clearSavedCredentials(); // Clear secure storage as well
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
        await _saveCredentialsIfNeeded(); // Save credentials if Remember Me is checked
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
    if (loginNumber.isEmpty || loginNumber.length < 10) {
      setError("Please enter a valid mobile number");
      return false;
    }

    setLoading(true);
    try {
      final result = await _repository.resendOtp(loginNumber);
      if (result['success'] == true) {
        return true;
      }

      setError(result['msg'] ?? "Failed to resend OTP");
      return false;
    } catch (e) {
      setError("Failed to resend OTP");
      return false;
    } finally {
      setLoading(false);
    }
  }

  /// Save credentials securely
  Future<void> _saveCredentialsIfNeeded() async {
    if (_isRememberMe) {
      await _secureStorage.write(key: 'saved_name', value: nameController.text.trim());
      await _secureStorage.write(key: 'saved_mobile', value: mobileController.text.trim());
      await _secureStorage.write(key: 'saved_password', value: passwordController.text);
      await _secureStorage.write(key: 'remember_me', value: 'true');
    } else {
      await _clearSavedCredentials();
    }
  }

  /// Clear saved credentials
  Future<void> _clearSavedCredentials() async {
    await _secureStorage.delete(key: 'saved_name');
    await _secureStorage.delete(key: 'saved_mobile');
    await _secureStorage.delete(key: 'saved_password');
    await _secureStorage.write(key: 'remember_me', value: 'false');
  }

  /// Call this on logout or when user wants to clear saved data
  Future<void> clearAllSavedData() async {
    try {
      // 1. Call Backend API while token is still available locally
      await _repository.logout(""); 
    } catch (e) {
      debugPrint("Server Logout failed: $e. Proceeding with local cleanup.");
    }

    // 2. Disconnect Socket
    SocketService().disconnect();

    // 3. Clear Tokens (Access & Refresh)
    await _tokenService.deleteTokens();

    // 4. Safer Remember Me Check from Secure Storage
    final rememberMeString = await _secureStorage.read(key: 'remember_me');
    bool isActuallyRemembered = rememberMeString == 'true';

    if (!isActuallyRemembered) {
      await _clearSavedCredentials();
      nameController.clear();
      mobileController.clear();
      passwordController.clear();
      _isRememberMe = false;
    } else {
      // Keep name, mobile, password in controllers for next login screen
      _isRememberMe = true;
    }

    notifyListeners();
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
