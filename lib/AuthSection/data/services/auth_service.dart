import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ziya_laundry_deliveryapp/Constants/Api_Constants.dart';
import '../model/user_model.dart';

abstract class IAuthService {
  Future<Map<String, dynamic>> login(String phone);
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
}
class AuthService implements IAuthService {
  @override
  Future<Map<String, dynamic>> login(String phone) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.login}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phone': phone}),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'msg': 'Server connection failed'};
    }
  }

  @override
  Future<Map<String, dynamic>> verifyOtp(String phone, String otp) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.verifyOtp}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phone': phone, 'otp': otp}),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'msg': 'Connection failed'};
    }
  }

  @override
  Future<Map<String, dynamic>> resendOtp(String phone) async {
    try {
      final cleanPhone = phone.trim();
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.resendOtp}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phone': cleanPhone}),
      );
      return jsonDecode(response.body) as Map<String, dynamic>;
    } catch (e) {
      return {'success': false, 'msg': 'Connection failed'};
    }
  }

  @override
  Future<Map<String, dynamic>> refreshToken(String token) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.refreshToken}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refreshToken': token}),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'msg': 'Connection failed'};
    }
  }

  @override
  Future<Map<String, dynamic>> forgotPassword(String phone) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.forgotPassword}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phone': phone}),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'msg': 'Connection failed'};
    }
  }

  @override
  Future<Map<String, dynamic>> verifyForgotOtp(String phone, String otp) async {
    try {
      // Ensure no accidental spaces are sent to the backend
      final cleanPhone = phone.trim();
      final cleanOtp = otp.trim();

      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.verifyForgotOtp}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phone': cleanPhone, 'otp': cleanOtp}),
      );
      return jsonDecode(response.body) as Map<String, dynamic>;
    } catch (e) {
      return {'success': false, 'msg': 'Connection failed'};
    }
  }

  @override
  Future<Map<String, dynamic>> resetPassword(String phone, String password, String confirmPassword) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.resetPassword}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phone': phone, 'password': password, 'confirmPassword': confirmPassword}),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'msg': 'Connection failed'};
    }
  }

  @override
  Future<Map<String, dynamic>> getProfile(String token) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.profile}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'msg': 'Connection failed'};
    }
  }

  @override
  Future<Map<String, dynamic>> logout(String token) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.logout}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'msg': 'Connection failed'};
    }
  }

  @override
  Future<bool> sendOtp(String phoneNumber) async {
    await Future.delayed(const Duration(seconds: 2)); // Mock API Delay
    return true;
  }

  @override
  Future<bool> registerUser(UserModel user) async {
    await Future.delayed(const Duration(seconds: 2)); // Mock API Delay
    // Example: return await dio.post('/register', data: user.toJson());
    return true;
  }
}