import 'dart:async';
import 'package:dio/dio.dart';
import 'package:ziya_laundry_deliveryapp/Constants/api_constants.dart';
import 'package:ziya_laundry_deliveryapp/core/network/api_exception.dart';
import 'package:ziya_laundry_deliveryapp/core/services/connectivity_service.dart';
import 'package:ziya_laundry_deliveryapp/core/network/network_exceptions.dart';
import 'package:ziya_laundry_deliveryapp/core/services/token_service.dart';
import 'package:ziya_laundry_deliveryapp/core/widgets/session_expired_dialog.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

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

    if (kDebugMode) debugPrint("DioClient: Handling Session Expiry...");
    await _tokenService.deleteTokens();
    _isRefreshing = false;
    _refreshFuture = null;

    // Define routes where the session expired dialog should NOT be shown
    final excludedRoutes = [
      '/login',
      '/forgot-password',
      '/verify-otp',
      '/verify-forgot-otp',
      '/reset-password',
      '/verification',
    ];

    // Get the safest context available from the navigator state for route checking
    final contextForRouteCheck = navigatorKey.currentState?.overlay?.context;
    String? currentRouteName;
    if (contextForRouteCheck != null) {
      currentRouteName = ModalRoute.of(contextForRouteCheck)?.settings.name;
    }

    if (currentRouteName != null && excludedRoutes.contains(currentRouteName)) {
      if (kDebugMode) debugPrint("DioClient: Session expired on an excluded route ($currentRouteName). Not showing dialog. Resetting _sessionExpiredTriggered.");
      _sessionExpiredTriggered = false; // Reset flag as dialog won't be shown
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Notify app layer immediately to stop background syncs/sockets
      onSessionExpired?.call();

      // Get the safest context available from the navigator state
      final context = navigatorKey.currentState?.overlay?.context;
      
      if (context != null && navigatorKey.currentState?.mounted == true) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (dialogContext) => SessionExpiredDialog(
            onLoginAgain: () {
              _sessionExpiredTriggered = false;

              // 1. Close the dialog
              Navigator.of(dialogContext).pop();
              
              // 2. Navigate to login
              navigatorKey.currentState?.pushNamedAndRemoveUntil(
                '/login', 
                (route) => false,
              );
            },
          ),
        );
      } else {
        _sessionExpiredTriggered = false;
      }
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
        await _handleSessionExpired();
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
      await _handleSessionExpired();
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
            await _handleSessionExpired();
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
                if (!_sessionExpiredTriggered) await _handleSessionExpired();
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
            await _handleSessionExpired();
            return handler.reject(e);
          }
          e.requestOptions.extra['retryCount'] = retryCount + 1;

          // Coordinate refresh and queued requests via centralized method
          if (_isRefreshing) {
            try {
              await _refreshFuture;
              final token = await _tokenService.getAccessToken();
              if (token == null || token.isEmpty) {
                if (!_sessionExpiredTriggered) await _handleSessionExpired();
                return handler.reject(e);
              }
              e.requestOptions.headers['Authorization'] = 'Bearer $token';
              final response = await _dio.fetch(e.requestOptions);
              return handler.resolve(response);
            } catch (err) {
              return handler.reject(e);
            }
          }

          final result = await _refreshTokens();
          if (result == _RefreshStatus.success) {
            final token = await _tokenService.getAccessToken();
            if (token == null || token.isEmpty) {
              await _handleSessionExpired();
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

          // Auth failure -> session expired already handled inside _refreshTokens
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