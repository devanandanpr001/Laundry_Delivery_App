// // import 'package:flutter/material.dart';
// // import 'package:provider/provider.dart';
// // import 'package:ziya_laundry_deliveryapp/core/services/SocketService.dart';
// // import 'package:ziya_laundry_deliveryapp/core/services/token_service.dart';
// // import 'package:ziya_laundry_deliveryapp/features/AuthSection/View/LogIn_screen.dart';
// // import 'package:ziya_laundry_deliveryapp/features/AuthSection/data/repositories/auth_repository.dart';
// // import 'package:ziya_laundry_deliveryapp/features/Profile/viewmodel/profile_viewmodel.dart';
// // import 'package:ziya_laundry_deliveryapp/core/network/dio_client.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:ziya_laundry_deliveryapp/core/services/SocketService.dart';
// import 'package:ziya_laundry_deliveryapp/core/services/token_service.dart';
// import 'package:ziya_laundry_deliveryapp/features/AuthSection/data/repositories/auth_repository.dart';
// import 'package:ziya_laundry_deliveryapp/features/Profile/viewmodel/profile_viewmodel.dart';
// import 'package:ziya_laundry_deliveryapp/core/network/dio_client.dart';

// // /// Performs a comprehensive logout, clearing user data, tokens, and navigating to the login screen.
// // /// This function should be called for both manual logout and session expiry scenarios.
// // Future<void> performAppLogout(BuildContext context) async {
// //   try {
// //     // Access ProfileViewModel to clear its state
// //     final profileVM = Provider.of<ProfileViewModel>(context, listen: false);
// /// Performs a comprehensive logout, clearing user data, tokens, and navigating to the login screen.
// Future<void> performAppLogout(BuildContext context) async {
//   try {
//     final token = await TokenService().getAccessToken();
//     if (token != null) {
//       // Hits /delivery/auth/logout via Dio (AuthRepository > AuthService)
//       await AuthRepository().logout(token);
//     }
//   } catch (e) {
//     debugPrint("Logout API Error: $e. Proceeding with local cleanup.");
//   }

// //     // 1. Call Logout API (AuthRepository handles server call and local token clear)
// //     await AuthRepository().logoutUser();
//   // Always perform local cleanup regardless of API success
//   Provider.of<ProfileViewModel>(context, listen: false).clearAllCachedData();
//   SocketService().disconnect();
//   await DioClient().clearSession();

// //     // 2. Clear profile data and disconnect socket
// //     profileVM.clearProfileDataAndDisconnectSocket();
//   if (!context.mounted) return;

// //     // 3. Clear secure storage (redundant if AuthRepository().logoutUser() already does it, but safe)
// //     await TokenService().clearTokens();

// //     // 4. Clear DioClient's internal session state
// //     DioClient().clearSession();

// //     if (!context.mounted) return;

// //     // 5. Navigate to Login Screen and remove all previous routes
// //     Navigator.pushAndRemoveUntil(
// //       context,
// //       MaterialPageRoute(builder: (_) => const LoginScreen()),
// //       (route) => false,
// //     );
// //   } catch (e) {
// //     debugPrint("Logout Error: $e. Forcing local cleanup and navigation.");
// //     // Force local cleanup and navigation even if API call fails
// //     await TokenService().clearTokens();
// //     DioClient().clearSession();
// //     if (!context.mounted) return;
// //     Navigator.pushAndRemoveUntil(
// //       context,
// //       MaterialPageRoute(builder: (_) => const LoginScreen()),
// //       (route) => false,
// //     );
// //   }
// // }
//   // Return to login screen
//   Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
// }
