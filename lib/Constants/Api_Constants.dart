class ApiConstants {
  static const String baseUrl = 'http://192.168.0.105:5001/api';
  static const String login = '/delivery/auth/login';
  static const String verifyOtp = '/delivery/auth/verify-otp';
  static const String resendOtp = '/delivery/auth/resend-otp';
  static const String refreshToken = '/delivery/auth/refresh-token';
  static const String forgotPassword = '/delivery/auth/forgot-password';
  static const String verifyForgotOtp = '/delivery/auth/verify-forgot-otp';
  static const String resetPassword = '/delivery/auth/reset-password';
  static const String profile = '/delivery/auth/profile';
  static const String logout = '/delivery/auth/logout';
}

// verify otp
// http://localhost:5001/api/delivery/auth/verify-otp
// resend otp
// http://localhost:5001/api/delivery/auth/resend-otp
// Refresh Token
// http://localhost:5001/api/delivery/auth/refresh-token
// Forgot Password Flow
// http://localhost:5001/api/delivery/auth/forgot-password
// verify otp for pass
// http://localhost:5001/api/delivery/auth/verify-forgot-otp
// rest pass
// http://localhost:5001/api/delivery/auth/reset-password
// Profile
// http://localhost:5001/api/delivery/auth/profile
// Logout
// http://localhost:5001/api/delivery/auth/logout