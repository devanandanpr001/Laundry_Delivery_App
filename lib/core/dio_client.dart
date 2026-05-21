import 'dart:async';
import 'package:dio/dio.dart';
import 'package:ziya_laundry_deliveryapp/Constants/Api_Constants.dart';
import 'package:ziya_laundry_deliveryapp/AuthSection/viewmodel/login_viewmodel.dart';
import 'package:ziya_laundry_deliveryapp/Orders/viewmodel/order_viewmodel.dart';
import 'package:ziya_laundry_deliveryapp/Orders/widget/service_viewmodel.dart';
import 'package:ziya_laundry_deliveryapp/core/api_exception.dart';
import 'package:ziya_laundry_deliveryapp/core/connectivity_service.dart';
import 'package:ziya_laundry_deliveryapp/core/network_exceptions.dart';
import 'package:ziya_laundry_deliveryapp/core/token_service.dart';
import 'package:ziya_laundry_deliveryapp/common_widgets/session_expired_dialog.dart';
import 'package:ziya_laundry_deliveryapp/Home/viewmodel/home_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart'; // Import for GlobalKey and AlertDialog

class DioClient {
  static final DioClient _instance = DioClient._internal();
  late final Dio _dio;
  final TokenService _tokenService = TokenService();
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  bool _isRefreshing = false;
  bool _sessionExpiredTriggered = false;
  final List<Completer<void>> _refreshQueue = [];
  
  static void Function()? onSessionExpired;

  Dio get dio => _dio;

  factory DioClient() => _instance;

  DioClient._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        responseType: ResponseType.json,
      ),
    );
    _dio.interceptors.add(_createInterceptor());
    _dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        request: true,
        requestHeader: true,
      ),
    );
  }

  Future<void> _handleSessionExpired() async {
    if (_sessionExpiredTriggered) return;
    _sessionExpiredTriggered = true;

    await _tokenService.deleteTokens();
    _clearQueue(error: "Session Expired");
    _isRefreshing = false; // Reset refresh flag

    // Professional: Handle global session expired UI via navigatorKey
    // This ensures the dialog appears regardless of which screen the user is currently viewing.
    final context = navigatorKey.currentContext;
    if (context != null) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => SessionExpiredDialog(
          expirationTime: const Duration(seconds: 5),
          onLoginAgain: () {
            // Clear UI states and navigate to login
            try {
              // Notify all relevant ViewModels to clear their data
              context.read<OrderViewModel>().clearAllCachedData();
              context.read<ServiceViewModel>().clearAllCachedData();
              context.read<HomeViewModel>().resetSessionExpired();
              context.read<LoginViewModel>().clearFields();
            } catch (e) {
              debugPrint("DioClient: Error clearing viewmodel state: $e");
            }
            
            navigatorKey.currentState?.pushNamedAndRemoveUntil('/login', (route) => false);
          },
        ),
      );
    }

    // Notify ViewModels to clear local cached data
    onSessionExpired?.call();

    _sessionExpiredTriggered = false; 
    debugPrint("DioClient: Session expired triggered.");
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
        ];
        
        final isAuthRequest = authPaths.any((path) => options.path.contains(path));

        if (!isAuthRequest) {
          final accessToken = await _tokenService.getAccessToken();
          // Reject request if token is missing or empty for protected endpoints
          if (accessToken == null || accessToken.isEmpty) {
            debugPrint("DioClient: Token is missing or empty for protected request: ${options.path}");
            await _handleSessionExpired();
            return handler.reject(
              DioException(
                requestOptions: options,
                error: "Session expired - no valid token",
                type: DioExceptionType.unknown,
              ),
            );
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
        ];

        final isAuthRequest = authPaths.any((path) => e.requestOptions.path.contains(path));

        // Handle 401 Unauthorized - Token expired or invalid
        if (e.response?.statusCode == 401 && !isAuthRequest) {
          if (_isRefreshing) {
            final completer = Completer<void>();
            _refreshQueue.add(completer);

            try {
              await completer.future;
              final token = await _tokenService.getAccessToken();
              if (token == null || token.isEmpty) {
                await _handleSessionExpired();
                return handler.reject(e);
              }
              e.requestOptions.headers['Authorization'] = 'Bearer $token';
              final response = await _dio.fetch(e.requestOptions);
              return handler.resolve(response);
            } catch (err) {
              return handler.reject(e);
            }
          }

          _isRefreshing = true;
          try {
            final refreshToken = await _tokenService.getRefreshToken();
            if (refreshToken == null || refreshToken.isEmpty) {
              _isRefreshing = false;
              await _handleSessionExpired();
              return handler.reject(e);
            }

            // Use a new Dio instance for the refresh token request to avoid interceptor recursion
            final refreshDio = Dio(BaseOptions(baseUrl: ApiConstants.baseUrl));
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
                _clearQueue();
                e.requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';
                return handler.resolve(await _dio.fetch(e.requestOptions));
              }
            }
            await _handleSessionExpired();
            return handler.reject(e);
          } catch (err) {
            debugPrint("DioClient: Refresh failed: $err");
            await _handleSessionExpired();
            return handler.reject(e);
          } finally {
            _isRefreshing = false;
          }
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

  void _clearQueue({dynamic error}) {
    for (var completer in _refreshQueue) {
      if (!completer.isCompleted) {
        if (error != null) {
          completer.completeError(error);
        } else {
          completer.complete();
        }
      }
    }
    _refreshQueue.clear();
  }
}