import 'dart:async';
import 'package:dio/dio.dart';
import 'package:ziya_laundry_deliveryapp/Constants/api_constants.dart';
import 'package:ziya_laundry_deliveryapp/core/network/api_exception.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ziya_laundry_deliveryapp/core/services/connectivity_service.dart';
import 'package:ziya_laundry_deliveryapp/core/network/network_exceptions.dart';
import 'package:ziya_laundry_deliveryapp/core/services/token_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:quick_popup_manager/quick_popup_manager.dart';
import 'package:google_fonts/google_fonts.dart';

enum _RefreshStatus { success, networkFailure, authFailure }

class DioClient {
  static final DioClient _instance = DioClient._internal();
  late final Dio _dio;
  final TokenService _tokenService = TokenService();
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  bool _isRefreshing = false;
  bool _sessionExpiredTriggered = false;
  
  /// Global future to synchronize concurrent refresh requests
  Future<void>? _refreshFuture;
  
  
  static void Function()? onSessionExpired;

  Dio get dio => _dio;

  factory DioClient() => _instance;

  DioClient._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        responseType: ResponseType.json,
      ),
    );
    _dio.interceptors.add(_createInterceptor());
    if (kDebugMode) {
      _dio.interceptors.add(
        LogInterceptor(
          requestBody: true,
          responseBody: true,
          request: true,
          requestHeader: true,
        ),
      );
    }
  }

  Future<void> _handleSessionExpired() async {
    if (_sessionExpiredTriggered) return;
    _sessionExpiredTriggered = true;

    // Notify app layer immediately to stop background syncs/sockets
    _isRefreshing = false;
    _refreshFuture = null;

    try {
      await _tokenService.deleteTokens();
    } catch (e) {
      debugPrint("DioClient: Error clearing tokens: $e");
    }

    // Reliably determine the current route name from the navigator state stack
    final excludedRoutes = [
      '/login', '/forgot-password', '/verify-otp', 
      '/verify-forgot-otp', '/reset-password', '/verification',
    ];

    bool isAlreadyOnAuthScreen = false;
    navigatorKey.currentState?.popUntil((route) {
      if (excludedRoutes.contains(route.settings.name)) {
        isAlreadyOnAuthScreen = true;
      }
      return true;
    });

    if (isAlreadyOnAuthScreen) {
      _sessionExpiredTriggered = false;
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Notify app layer immediately to stop background syncs/sockets
      QuickPopupManager().showDialogPopup(
        barrierDismissible: false,
        animation: const AnimationConfig.scale(),
        style: PopupStyle(
          backgroundColor: Colors.transparent,
          elevation: 0,
          padding: EdgeInsets.zero,
          dialogAlignment: Alignment.center,
        ),
        confirmText: '',
        cancelText: '',
        onConfirm: null,
        onCancel: null,
        content: Center(
          child: Container(
            width: 500.w,
            // margin: EdgeInsets.symmetric(horizontal: 24.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 40.h),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.all(16.r),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon( 
                      Icons.lock_clock_outlined,
                      color: Colors.orange,
                      size: 40.sp,
                    ),
                  ),
                  SizedBox(height: 20.h),
                  Text(
                    "Session Expired",
                    style: GoogleFonts.poppins(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1E293B),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    "Your session has timed out for security. Please log in again to continue.",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 14.sp,
                      color: const Color(0xFF475569),
                      height: 1.5,
                    ),
                  ),
                  SizedBox(height: 24.h),
                  GestureDetector(
                    onTap: () {
                      onSessionExpired?.call();
                      QuickPopupManager().dismissAll();
                      _sessionExpiredTriggered = false;
                      navigatorKey.currentState?.pushNamedAndRemoveUntil(
                        '/login', 
                        (route) => false,
                      );
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color(0xFF42B883),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        "Login Again",
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 16.sp,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  /// Check if token is valid and not empty
  Future<bool> isTokenValid() async {
    final token = await _tokenService.getAccessToken();
    return token != null && token.isNotEmpty;
  }

  /// Clear session without triggering multiple callbacks
  Future<void> clearSession() async {
    await _tokenService.deleteTokens();
    _isRefreshing = false;
  _refreshFuture = null; // Ensure no pending refresh future
  _sessionExpiredTriggered = false; // Reset session expiry flag
  }

  bool _isNetworkError(DioException error) {
    return error.type == DioExceptionType.connectionError ||
        error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout;
  }

  Future<_RefreshStatus> _refreshTokens() async {
    if (_isRefreshing) {
      try {
        await _refreshFuture;
        return _RefreshStatus.success;
      } catch (_) {
        return _RefreshStatus.authFailure;
      }
    }

    _isRefreshing = true;
    final completer = Completer<void>();
    _refreshFuture = completer.future;

    try {
      final refreshToken = await _tokenService.getRefreshToken();
      if (kDebugMode) debugPrint("DioClient: Attempting refresh. RefreshToken found: ${refreshToken != null}");

      if (refreshToken == null || refreshToken.isEmpty) {
        completer.completeError("No refresh token");
        return _RefreshStatus.authFailure;
      }

      final refreshDio = Dio(BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 10),
      ));

      final response = await refreshDio.post(
        ApiConstants.refreshToken,
        data: {'refreshToken': refreshToken},
      );

      if (response.statusCode == 200) {
        final newAccessToken = response.data['token'] ?? response.data['accessToken'];
        final newRefreshToken = response.data['refreshToken'];

        if (newAccessToken != null && newAccessToken.toString().isNotEmpty) {
          await _tokenService.saveTokens(
            accessToken: newAccessToken,
            refreshToken: newRefreshToken ?? refreshToken,
          );
          completer.complete();
          return _RefreshStatus.success;
        }
      }

      completer.completeError("Invalid refresh response");
      await _handleSessionExpired();
      return _RefreshStatus.authFailure;
    } catch (err) {
      if (kDebugMode) debugPrint("DioClient: Refresh failed: $err");
      completer.completeError(err);
      if (err is DioException && _isNetworkError(err)) {
        return _RefreshStatus.networkFailure;
      }
      return _RefreshStatus.authFailure;
    } finally {
      _isRefreshing = false;
      _refreshFuture = null;
    }
  }

  Interceptor _createInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) async {
        if (!await ConnectivityService.instance.checkConnection()) {
          return handler.reject(
            DioException(
              requestOptions: options,
              error: NoInternetException(),
              type: DioExceptionType.connectionError,
            ),
          );
        }

        final authPaths = [
          ApiConstants.login,
          ApiConstants.forgotPassword,
          ApiConstants.verifyOtp,
          ApiConstants.verifyForgotOtp,
          ApiConstants.refreshToken,
          ApiConstants.resetPassword,
          ApiConstants.resendOtp,
        ];
        
        final isAuthRequest = authPaths.any((path) => options.path.contains(path));

        if (!isAuthRequest) {
          final accessToken = await _tokenService.getAccessToken();
          // Reject request if token is missing or empty for protected endpoints
          if (accessToken == null || accessToken.isEmpty) {
            if (kDebugMode) debugPrint("DioClient: Token is missing or empty for protected request: ${options.path}");
            await _handleSessionExpired();
            return handler.reject(
              DioException(
                requestOptions: options,
                error: "Session expired - no valid token",
                type: DioExceptionType.unknown,
              ),
            );
          }

          // If token is expiring soon, proactively attempt refresh
          final isExpiringSoon = await _tokenService.isAccessTokenExpiringSoon();
          if (isExpiringSoon) {
            final refreshResult = await _refreshTokens();
            if (refreshResult == _RefreshStatus.success) {
              final newToken = await _tokenService.getAccessToken();
              if (newToken != null && !options.headers.containsKey('Authorization')) {
                options.headers['Authorization'] = 'Bearer $newToken';
              }
              return handler.next(options);
            }

            if (refreshResult == _RefreshStatus.networkFailure) {
              // If refresh couldn't run due to network, allow request to continue with current token
              if (!options.headers.containsKey('Authorization')) {
                options.headers['Authorization'] = 'Bearer $accessToken';
              }
              return handler.next(options);
            }

            // Auth failure: force session expired
            _handleSessionExpired();
            return handler.reject(
              DioException(
                requestOptions: options,
                error: "Session expired - token refresh failed",
                type: DioExceptionType.unknown,
              ),
            );
          }

          // Normal path: if a refresh is already running, wait for it to finish
          if (_isRefreshing) {
            try {
              await _refreshFuture;
              final token = await _tokenService.getAccessToken();
              if (token == null || token.isEmpty) {
                _handleSessionExpired();
                return handler.reject(
                  DioException(
                    requestOptions: options,
                    error: "Session expired - no valid token after refresh",
                    type: DioExceptionType.unknown,
                  ),
                );
              }
              options.headers['Authorization'] = 'Bearer $token';
              return handler.next(options);
            } catch (_) {
              return handler.reject(
                DioException(
                  requestOptions: options,
                  error: "Session expired - refresh failed",
                  type: DioExceptionType.unknown,
                ),
              );
            }
          }

          if (!options.headers.containsKey('Authorization')) {
            options.headers['Authorization'] = 'Bearer $accessToken';
          }
        }
        return handler.next(options);
      },
      onError: (DioException e, handler) async {

        // List of paths that should NEVER trigger a token refresh cycle
        final authPaths = [
          ApiConstants.login,
          ApiConstants.forgotPassword,
          ApiConstants.verifyOtp,
          ApiConstants.verifyForgotOtp,
          ApiConstants.refreshToken,
          ApiConstants.resetPassword,
          ApiConstants.resendOtp,
        ];

        final isAuthRequest = authPaths.any((path) => e.requestOptions.path.contains(path));

        // Handle 401 Unauthorized - Token expired or invalid
        if (e.response?.statusCode == 401 && !isAuthRequest) {
          // Retry protection: increment retry count
          final int retryCount = e.requestOptions.extra['retryCount'] ?? 0;
          if (retryCount >= 1) {
            if (kDebugMode) debugPrint("DioClient: Max retry reached for ${e.requestOptions.path}");
            _handleSessionExpired();
            return handler.reject(e);
          }
          e.requestOptions.extra['retryCount'] = retryCount + 1;

          if (_isRefreshing) {
            try {
              await _refreshFuture;
              final token = await _tokenService.getAccessToken();
              if (token == null || token.isEmpty) {
                _handleSessionExpired();
                return handler.reject(e);
              }
              e.requestOptions.headers['Authorization'] = 'Bearer $token';
              final response = await _dio.fetch(e.requestOptions);
              return handler.resolve(response);
            } catch (err) {
              _handleSessionExpired();
              return handler.reject(e);
            }
          }

          final result = await _refreshTokens();
          if (result == _RefreshStatus.success) {
             final token = await _tokenService.getAccessToken();
             if (token == null || token.isEmpty) {
               _handleSessionExpired();
               return handler.reject(e);
             }
             e.requestOptions.headers['Authorization'] = 'Bearer $token';
             final response = await _dio.fetch(e.requestOptions);
             return handler.resolve(response);
          }

          if (result == _RefreshStatus.networkFailure) {
            // Allow original 401 to continue to caller as network-related
            return handler.next(e);
          }

          _handleSessionExpired();
          return handler.reject(e);
        }
        // Handle other errors or pass through
        return handler.next(e);
      },
    );
  }

  Future<dynamic> get(String path, {Map<String, dynamic>? queryParameters}) async {
    try {
      final response = await _dio.get(path, queryParameters: queryParameters);
      return response.data;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  Future<dynamic> post(String path, {dynamic data}) async {
    try {
      final response = await _dio.post(path, data: data);
      return response.data;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  Future<dynamic> put(String path, {dynamic data}) async {
    try {
      final response = await _dio.put(path, data: data);
      return response.data;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  Future<dynamic> patch(String path, {dynamic data}) async {
    try {
      final response = await _dio.patch(path, data: data);
      return response.data;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  Future<dynamic> delete(String path, {dynamic data}) async {
    try {
      final response = await _dio.delete(path, data: data);
      return response.data;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }
}