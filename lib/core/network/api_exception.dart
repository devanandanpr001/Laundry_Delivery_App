import 'package:dio/dio.dart';
import 'package:ziya_laundry_deliveryapp/core/network/network_exceptions.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException({required this.message, this.statusCode});

  @override
  String toString() => message;

  factory ApiException.fromDioError(DioException dioError) {
    String message;
    switch (dioError.type) {
      case DioExceptionType.cancel:
        if (dioError.error is NoInternetException) {
          message = (dioError.error as NoInternetException).message;
        } else {
          message = "Request to API server was cancelled.";
        }
        break;
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        message = "Connection timeout. Please check your internet connection.";
        break;
      case DioExceptionType.badResponse:
        message = _handleError(
          dioError.response?.statusCode,
          dioError.response?.data,
        );
        break;
      case DioExceptionType.connectionError:
        if (dioError.error is NoInternetException) {
          message = (dioError.error as NoInternetException).message;
        } else {
          message = "Connection error. Please check your internet connection.";
        }
        break;
      default:
        message = "An unexpected error occurred. Please try again.";
        break;
    }
    return ApiException(
      message: message,
      statusCode: dioError.response?.statusCode,
    );
  }

  static String _handleError(int? statusCode, dynamic error) {
    String getMessage() {
      if (error is Map<String, dynamic>) {
        if (error['message'] is String) return error['message'] as String;
        if (error['msg'] is String) return error['msg'] as String;
      }
      return "An unknown error occurred.";
    }

    switch (statusCode) {
      case 400:
        return getMessage();
      case 401:
        return getMessage();
      case 403:
        return "You don't have permission to access this resource.";
      case 404:
        return "The requested resource was not found.";
      case 429:
        return getMessage();
      case 500:
        final serverMessage = getMessage();
        return serverMessage != "An unknown error occurred." 
            ? serverMessage 
            : 'Internal server error. Please try again later.';
      default:
        return 'Oops, something went wrong.';
    }
  }
}