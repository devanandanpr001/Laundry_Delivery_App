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
  // static const String markDelivered = '/delivery-session/session/orders/mark-delivered'; // Assuming this endpoint for completing orders
  // static const String assignedOrders = '/delivery-session/session/orders/assigned';


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
  
  static const String orderItem = '/delivery-session/session/orders'; // Suffix with /:orderId/item
  static const String uploadOrderImage = '/delivery-session/session/orders'; // Suffix with /:orderId/upload-image

  static const String verifyOrder = '/delivery-session/session/orders'; // Suffix with /:orderId/verify
  static const String verifyItems = '/delivery-session/session/orders'; // Suffix with /:orderId/verify-items

  static const String serviceAvailability = '/delivery-session/services/available'; // Suffix with /:orderId/verify
  static const String selact_Items ='/delivery-session/services/:serviceId/items';
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
