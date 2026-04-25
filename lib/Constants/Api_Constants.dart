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

// Orders

  static const String dashboardCounts = '/delivery-session/session/dashboard-counts';
  static const String deliveryOrders = '/delivery-session/session/delivery-orders';
  static const String pickupOrders = '/delivery-session/session/pickup-orders';
  static const String acceptPickup = '/delivery-session/session/accept-pickup';
  static const String acceptDelivery = '/delivery-session/session/accept-delivery';
  static const String allOrders = '/delivery-session/session/orders/all';
  static const String assignedOrders = '/delivery-session/session/orders/assigned';
}
