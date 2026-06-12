// import 'package:flutter/material.dart';
// import 'package:ziya_laundry_deliveryapp/core/widgets/session_expiry_card.dart';
// import 'package:ziya_laundry_deliveryapp/features/AuthSection/View/LogIn_screen.dart';

// /// Global instance for managing session expiry dialog
// late SessionExpiryDialogManager sessionExpiryDialogManager;

// class SessionExpiryDialogManager {
//   final GlobalKey<NavigatorState> navigatorKey;
//   final AuthCheckBloc authCheckBloc;
//   bool _isDialogShowing = false;
//   int _retryCount = 0;
//   static const int _maxRetries = 3;

//   SessionExpiryDialogManager(this.navigatorKey, this.authCheckBloc);

//   void showGlobalSessionExpiredDialog() {
//     // Prevent duplicate dialogs while one is already showing
//     if (_isDialogShowing) {
//       debugPrint(
//         '⚠️ Session Expiry Dialog: Already showing, ignoring duplicate call',
//       );
//       return;
//     }

//     _isDialogShowing = true;
//     _retryCount = 0;
//     debugPrint('✅ Session Expiry Dialog: Attempting to show dialog...');
//     _attemptShowDialog();
//   }

//   void _attemptShowDialog() {
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       try {
//         final context = navigatorKey.currentContext;

//         if (context == null) {
//           _retryCount++;
//           if (_retryCount < _maxRetries) {
//             debugPrint(
//               '⚠️ Session Expiry Dialog: Context is null (retry $_retryCount/$_maxRetries). Retrying...',
//             );
//             Future.delayed(
//               const Duration(milliseconds: 150),
//               _attemptShowDialog,
//             );
//             return;
//           } else {
//             debugPrint(
//               '❌ Session Expiry Dialog Error: Failed to get context after $_maxRetries retries',
//             );
//             _isDialogShowing = false;
//             return;
//           }
//         }

//         debugPrint(
//           '📱 Session Expiry Dialog: AuthCheckBloc status = ${authCheckBloc.state.status}',
//         );

//         // Show the dialog
//         debugPrint('🎯 Session Expiry Dialog: Showing dialog now...');
//         showDialog(
//               context: context,
//               barrierDismissible: false,
//               builder: (BuildContext dialogContext) {
//                 return PopScope(
//                   canPop: false,
//                   child: Dialog(
//                     backgroundColor: Colors.transparent,
//                     elevation: 0,
//                     child: SessionExpiryCard(
//                       onLoginAgain: () {
//                         debugPrint(
//                           '👤 Session Expiry Dialog: User clicked "Login Again"',
//                         );
//                         try {
//                           // Trigger logout using the global bloc instance
//                           authCheckBloc.add(LoggedOut());
//                           debugPrint(
//                             '✅ LoggedOut event added to AuthCheckBloc',
//                           );

//                           // Close the dialog and navigate to login screen
//                           if (Navigator.of(dialogContext).canPop()) {
//                             Navigator.of(dialogContext).pop();
//                             debugPrint('✅ Dialog popped');
//                           }

//                           // Use pushAndRemoveUntil to ensure clean navigation to LoginScreen
//                           Future.delayed(const Duration(milliseconds: 100), () {
//                             debugPrint('🚀 Navigating to LoginScreen...');
//                             Navigator.of(
//                               navigatorKey.currentContext!,
//                             ).pushAndRemoveUntil(
//                               MaterialPageRoute(
//                                 builder: (_) => const LoginScreen(),
//                               ),
//                               (route) => false,
//                             );
//                             debugPrint('✅ Navigated to LoginScreen');
//                           });
//                         } catch (e) {
//                           debugPrint('❌ Error in onLoginAgain: $e');
//                           if (Navigator.of(dialogContext).canPop()) {
//                             Navigator.of(dialogContext).pop();
//                           }
//                         }
//                       },
//                     ),
//                   ),
//                 );
//               },
//             )
//             .then((_) {
//               debugPrint('✅ Session Expiry Dialog: Dialog closed');
//               _isDialogShowing = false;
//             })
//             .catchError((e) {
//               debugPrint('❌ Session Expiry Dialog Error: $e');
//               _isDialogShowing = false;
//             });
//       } catch (e) {
//         debugPrint('❌ Session Expiry Dialog Exception: $e');
//         _isDialogShowing = false;
//       }
//     });
//   }
// }
