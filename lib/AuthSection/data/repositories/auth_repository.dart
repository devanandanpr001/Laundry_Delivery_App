import '../services/auth_service.dart';
import '../model/user_model.dart';

class AuthRepository {
  final IAuthService _authService = AuthService();

  Future<Map<String, dynamic>> login(String name, String mobile, String password) async {
    try {
      return await _authService.login(name, mobile, password);
    } catch (e) {
      return {'success': false, 'msg': e.toString()};
    }
  }

  Future<Map<String, dynamic>> verifyOtp(String phone, String otp) async {
    try {
      return await _authService.verifyOtp(phone, otp);
    } catch (e) {
      return {'success': false, 'msg': e.toString()};
    }
  }

  Future<Map<String, dynamic>> resendOtp(String phone) async {
    try {
      return await _authService.resendOtp(phone);
    } catch (e) {
      return {'success': false, 'msg': e.toString()};
    }
  }

  Future<Map<String, dynamic>> refreshToken(String token) async {
    try {
      return await _authService.refreshToken(token);
    } catch (e) {
      return {'success': false, 'msg': e.toString()};
    }
  }

  Future<Map<String, dynamic>> forgotPassword(String phone) async {
    try {
      return await _authService.forgotPassword(phone);
    } catch (e) {
      return {'success': false, 'msg': e.toString()};
    }
  }

  Future<Map<String, dynamic>> verifyForgotOtp(String phone, String otp) async {
    try {
      return await _authService.verifyForgotOtp(phone, otp);
    } catch (e) {
      return {'success': false, 'msg': e.toString()};
    }
  }

  Future<Map<String, dynamic>> resetPassword(String phone, String password, String confirmPassword) async {
    try {
      return await _authService.resetPassword(phone, password, confirmPassword);
    } catch (e) {
      return {'success': false, 'msg': e.toString()};
    }
  }

  Future<Map<String, dynamic>> getProfile(String token) async {
    return await _authService.getProfile(token);
  }

  Future<Map<String, dynamic>> logout(String token) async {
    return await _authService.logout(token);
  }

  Future<bool> sendOtp(String phoneNumber) async {
    try {
      return await _authService.sendOtp(phoneNumber);
    } catch (e) {
      return false;
    }
  }

  Future<bool> register(UserModel user) async {
    try {
      return await _authService.registerUser(user);
    } catch (e) {
      return false;
    }
  }
}