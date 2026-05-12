import 'dart:async';
import 'package:ziya_laundry_deliveryapp/Constants/Api_Constants.dart';
import 'package:ziya_laundry_deliveryapp/core/api_exception.dart';
import 'package:ziya_laundry_deliveryapp/core/dio_client.dart';
import 'package:ziya_laundry_deliveryapp/core/token_service.dart';
import '../model/user_model.dart';

abstract class IAuthService {
  Future<Map<String, dynamic>> login(String name, String phone, String password);
  Future<Map<String, dynamic>> verifyOtp(String phone, String otp);
  Future<Map<String, dynamic>> resendOtp(String phone);
  Future<Map<String, dynamic>> refreshToken(String refreshToken);
  Future<Map<String, dynamic>> forgotPassword(String phone);
  Future<Map<String, dynamic>> verifyForgotOtp(String phone, String otp);
  Future<Map<String, dynamic>> resetPassword(String phone, String password, String confirmPassword);
  Future<Map<String, dynamic>> getProfile(String token);
  Future<Map<String, dynamic>> logout(String token);
  Future<bool> sendOtp(String phoneNumber);
  Future<bool> registerUser(UserModel user);
  Future<Map<String, dynamic>> changePassword(String currentPassword, String newPassword, String confirmPassword);
}
class AuthService implements IAuthService {
  final DioClient _dioClient = DioClient();
  final TokenService _tokenService = TokenService();

  @override
  Future<Map<String, dynamic>> login(String name, String phone, String password) async {
    try {
      final data = await _dioClient.post(ApiConstants.login, data: {
        'name': name, // Passing name exactly as received with no changes
        'phone': phone.trim(),
        'password': password, 
      });
      final response = data as Map<String, dynamic>;

      // If login returns tokens directly, save them here
      if (response['token'] != null) {
        await _tokenService.saveTokens(
          accessToken: response['token'],
          refreshToken: response['refreshToken'],
        );
      }
      return {'success': true, ...response};
    } on ApiException catch (e) {
      return {'success': false, 'msg': e.message};
    } catch (e) {
      return {'success': false, 'msg': 'Server connection failed'};
    }
  }

  @override
  Future<Map<String, dynamic>> verifyOtp(String phone, String otp) async {
    try {
      final data = await _dioClient.post(ApiConstants.verifyOtp, data: {
        'phone': phone.trim(),
        'otp': otp.trim(),
      });
      final response = data as Map<String, dynamic>;

      // Save tokens upon successful verification
      if (response['token'] != null && response['refreshToken'] != null) {
        await _tokenService.saveTokens(
          accessToken: response['token'],
          refreshToken: response['refreshToken'],
        );
      }

      return {'success': true, ...response};
    } on ApiException catch (e) {
      return {'success': false, 'msg': e.message};
    } catch (e) {
      return {'success': false, 'msg': 'Connection failed'};
    }
  }

  @override
  Future<Map<String, dynamic>> resendOtp(String phone) async {
    try {
      final data = await _dioClient.post(ApiConstants.resendOtp, data: {'phone': phone.trim()});
      final response = data as Map<String, dynamic>;
      return {'success': true, ...response};
    } on ApiException catch (e) {
      return {'success': false, 'msg': e.message};
    } catch (e) {
      return {'success': false, 'msg': 'Connection failed'};
    }
  }

  @override
  Future<Map<String, dynamic>> refreshToken(String token) async {
    try {
      final data = await _dioClient.post(ApiConstants.refreshToken, data: {'refreshToken': token});
      final response = data as Map<String, dynamic>;
      return {'success': true, ...response};
    } catch (e) {
      return {'success': false, 'msg': 'Connection failed'};
    }
  }

  @override
  Future<Map<String, dynamic>> forgotPassword(String phone) async {
    try {
      final data = await _dioClient.post(ApiConstants.forgotPassword, data: {'phone': phone});
      final response = data as Map<String, dynamic>;
      return {'success': true, ...response};
    } on ApiException catch (e) {
      return {'success': false, 'msg': e.message};
    } catch (e) {
      return {'success': false, 'msg': 'Connection failed'};
    }
  }

  @override
  Future<Map<String, dynamic>> verifyForgotOtp(String phone, String otp) async {
    try {
      final data = await _dioClient.post(ApiConstants.verifyForgotOtp, data: {
        'phone': phone.trim(),
        'otp': otp.trim(),
      });
      final response = data as Map<String, dynamic>;
      return {'success': true, ...response};
    } on ApiException catch (e) {
      return {'success': false, 'msg': e.message};
    } catch (e) {
      return {'success': false, 'msg': 'Connection failed'};
    }
  }

  @override
  Future<Map<String, dynamic>> resetPassword(String phone, String password, String confirmPassword) async {
    try {
      final data = await _dioClient.post(ApiConstants.resetPassword, data: {
        'phone': phone,
        'password': password,
        'confirmPassword': confirmPassword
      });
      final response = data as Map<String, dynamic>;
      return {'success': true, ...response};
    } on ApiException catch (e) {
      return {'success': false, 'msg': e.message};
    } catch (e) {
      return {'success': false, 'msg': 'Connection failed'};
    }
  }

  @override
  Future<Map<String, dynamic>> getProfile(String token) async {
    try {
      final data = await _dioClient.get(ApiConstants.profile);
      final response = data as Map<String, dynamic>;
      if (response['success'] == true && response['user'] != null) {
        return response['user'] as Map<String, dynamic>;
      }
      return {'success': false, 'msg': 'User profile not found'};
    } on ApiException catch (e) {
      return {'success': false, 'msg': e.message};
    } catch (e) {
      return {'success': false, 'msg': 'Connection failed'};
    }
  }

  @override
  Future<Map<String, dynamic>> logout(String token) async {
    try {
      final data = await _dioClient.post(ApiConstants.logout);
      final response = data as Map<String, dynamic>;
      return {'success': true, ...response};
    } on ApiException catch (e) {
      return {'success': false, 'msg': e.message};
    } catch (e) {
      return {'success': false, 'msg': 'Connection failed'};
    }
  }

  @override
  Future<bool> sendOtp(String phoneNumber) async {
    try {
      final result = await _dioClient.post(ApiConstants.resendOtp, data: {'phone': phoneNumber});
      return true; // Successfully reached without error
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> registerUser(UserModel user) async {
    try {
      final result = await _dioClient.post('/delivery/auth/register', data: {
        'name': user.name,
        'phone': user.mobile,
        'password': user.password,
        'agreed': user.agreed,
      });
      return true; // Successfully reached without error
    } catch (e) {
      return false;
    }
  }

  @override
  Future<Map<String, dynamic>> changePassword(String currentPassword, String newPassword, String confirmPassword) async {
    try {
      final response = await _dioClient.post(ApiConstants.changePassword, data: {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
        'confirmPassword': confirmPassword,
      });
      return {'success': true, ...response};
    } on ApiException catch (e) {
      return {'success': false, 'msg': e.message};
    } catch (e) {
      return {'success': false, 'msg': 'Connection failed'};
    }
  }
}