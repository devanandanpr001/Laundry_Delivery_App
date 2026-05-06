class ApiConstants {
  static const String baseUrl = 'http://192.168.0.105:5001/api';
  static const String mediaBaseUrl = 'http://192.168.0.105:5001/'; // Base for images
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
  static const String allOrders = '/delivery-session/session/orders/all';
  static const String markDelivered = '/delivery-session/session/orders/mark-delivered'; // Assuming this endpoint for completing orders
  static const String assignedOrders = '/delivery-session/session/orders/assigned';
  static const String completedOrders = '/delivery-session/session/orders/completed';
  
  // Item Management
  static const String orderItem = '/delivery-session/session/orders'; // Suffix with /:orderId/item
  static const String uploadOrderImage = '/delivery-session/session/orders'; // Suffix with /:orderId/upload-image
  static const String verifyOrder = '/delivery-session/session/orders'; // Suffix with /:orderId/verify
  static const String verifyItems = '/delivery-session/session/orders'; // Suffix with /:orderId/verify-items
  static const String serviceAvailability = '/delivery-session/services/available'; // Suffix with /:orderId/verify
  static const String selact_Items ='/delivery-session/services/:serviceId/items';
  static const String multipleServiceItems = '/delivery-session/services/items/multiple';

}
