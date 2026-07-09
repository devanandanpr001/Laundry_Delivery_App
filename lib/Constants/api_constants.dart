import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConstants {
  // static const String baseUrl = 'http://192.168.1.36:5001/api';
  // static const String mediaBaseUrl = 'http://192.168.0.105:5001/';
    static final String baseUrl = dotenv.env['BASE_URL'] ?? '';

    static String get mediaBaseUrl {
      final env = dotenv.env['MEDIA_BASE_URL'];
      if (env != null && env.isNotEmpty) return env.endsWith('/') ? env : '$env/';

      String base = baseUrl;
      if (base.isNotEmpty) {
        if (base.endsWith('/')) {
          base = base.substring(0, base.length - 1);
        }
        if (base.endsWith('/api')) {
          return '${base.substring(0, base.length - 4)}/';
        }
        return '$base/';
      }
      return '';
    }
    
  static const String login = '/delivery/auth/login';
  static const String verifyOtp = '/delivery/auth/verify-otp';
  static const String resendOtp = '/delivery/auth/resend-otp';
  static const String refreshToken = '/delivery/auth/refresh-token';
  static const String forgotPassword = '/delivery/auth/forgot-password';
  static const String verifyForgotOtp = '/delivery/auth/verify-forgot-otp';
  static const String resetPassword = '/delivery/auth/reset-password';
  static const String profile = '/delivery/auth/profile';
  static const String profileImage = '/delivery/auth/profile-image';
  static const String logout = '/delivery/auth/logout';
  static const String onlineStatus = '/delivery-session/session/online-status';
// Orders
  static const String dashboardCounts = '/delivery-session/session/dashboard-counts';
  static const String deliveryOrders = '/delivery-session/session/delivery-orders';
  static const String pickupOrders = '/delivery-session/session/pickup-orders';
  static const String acceptPickup = '/delivery-session/session/accept-pickup';
  static const String acceptDelivery = '/delivery-session/session/accept-delivery';

  // pending connection 
  static const String completedOrders = '/delivery-session/session/orders/completed';
  
  // NEW SPECIFIC ORDER ENDPOINTS
  
  static const String pickupAssignedOrders = '/delivery-session/session/pickup/assigned';
  static const String pickupCompletedOrders = '/delivery-session/session/pickup/completed';
  static const String deliveryAssignedOrders = '/delivery-session/session/delivery/assigned';
  static const String deliveryCompletedOrders = '/delivery-session/session/delivery/completed';
  static const String confirmPickup = '/delivery-session/session/orders/:orderId/confirm-pickup';
  static const String mismatch      = '/delivery-session/session/orders/:orderId/add-mismatch-reason';
  
  // Item ManagementType: String
  
  static const String orderItem = '/delivery-session/session/orders';
  static const String uploadOrderImage = '/delivery-session/session/orders';

  static const String verifyOrder = '/delivery-session/session/orders';
  static const String verifyItems = '/delivery-session/session/orders';

  static const String serviceAvailability = '/delivery-session/services/available';
  static const String selectItems ='/delivery-session/services/:serviceId/items';
  static const String multipleServiceItems = '/delivery-session/services/items/multiple';
  static const String deliverysendotp = '/delivery-session/session/delivery/send-delivery-otp/:orderId';
  static const String  deliveryverifyotp = '/delivery-session/session/delivery/verify-delivery-otp/:orderId';
  static const String  changePassword = '/delivery/auth/change-password';
  static const String  cmsPage = '/delivery-session/cms/page/:type/';
  static const String  notification = '/delivery-session/session/notification';
  static const String  notificationRead = '/delivery-session/session/read';
  static const String  notificationClear = '/delivery-session/session/clear';
  static const String  notificationUndo = '/delivery-session/session/undo';
}