import 'package:dio/dio.dart';
import 'package:ziya_laundry_deliveryapp/core/network/network_exceptions.dart';

class ApiException implements Exception {
  /// The user-facing error message.
  final String message;

  /// The HTTP status code of the response, if available.
  final int? statusCode;

  /// Creates a new [ApiException] with the given [message] and optional [statusCode].
  ApiException({required this.message, this.statusCode});

  @override
  String toString() => message;

  /// Factory constructor to parse a [DioException] into a user-friendly [ApiException].
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

      case DioExceptionType.badCertificate:
        message = "Secure connection could not be established. Please check your network security.";
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

      case DioExceptionType.unknown:
      default:
        if (dioError.error is NoInternetException) {
          message = (dioError.error as NoInternetException).message;
        } else {
          message = "An unexpected error occurred. Please try again.";
        }
        break;
    }

    return ApiException(
      message: message,
      statusCode: dioError.response?.statusCode,
    );
  }

  /// Parses error response details to construct a friendly, readable error message.
  static String _handleError(int? statusCode, dynamic error) {
    String getMessage() {
      if (error == null) return "No response data received from server.";

      if (error is String && error.trim().isNotEmpty) {
        return error.trim();
      }

      if (error is Map<String, dynamic>) {
        // 1. Try 'message' key
        final messageVal = error['message'];
        if (messageVal is String && messageVal.trim().isNotEmpty) {
          return messageVal.trim();
        } else if (messageVal is List) {
          return messageVal.join('\n');
        }

        // 2. Try 'msg' key
        final msgVal = error['msg'];
        if (msgVal is String && msgVal.trim().isNotEmpty) {
          return msgVal.trim();
        } else if (msgVal is List) {
          return msgVal.join('\n');
        }

        // 3. Try 'error' key
        final errorVal = error['error'];
        if (errorVal is String && errorVal.trim().isNotEmpty) {
          return errorVal.trim();
        }

        // 4. Try 'errors' key (common in validation responses)
        final errorsVal = error['errors'];
        if (errorsVal is Map<String, dynamic>) {
          final errorMessages = <String>[];
          for (final value in errorsVal.values) {
            if (value is List) {
              errorMessages.addAll(value.map((e) => e.toString().trim()));
            } else if (value != null) {
              errorMessages.add(value.toString().trim());
            }
          }
          if (errorMessages.isNotEmpty) {
            return errorMessages.join('\n');
          }
        }
      }

      return "An unknown error occurred.";
    }

    switch (statusCode) {
      case 400:
      case 401:
      case 422:
      case 429:
        final msg = getMessage();
        return msg != "An unknown error occurred." ? msg : _getDefaultMessageForStatusCode(statusCode);
      case 403:
        final msg = getMessage();
        return msg != "An unknown error occurred."
            ? msg
            : "You don't have permission to access this resource.";
      case 404:
        return "The requested resource was not found.";
      case 500:
        final serverMessage = getMessage();
        return serverMessage != "An unknown error occurred."
            ? serverMessage
            : 'Internal server error. Please try again later.';
      default:
        final fallback = getMessage();
        return fallback != "An unknown error occurred." ? fallback : 'Oops, something went wrong.';
    }
  }

  /// Returns fallback descriptions for specific HTTP status codes.
  static String _getDefaultMessageForStatusCode(int? statusCode) {
    switch (statusCode) {
      case 400:
        return "Bad request. Please verify the submitted data.";
      case 401:
        return "Session expired or unauthorized. Please log in again.";
      case 422:
        return "Validation failed. Please check the entered fields.";
      case 429:
        return "Too many requests. Please try again later.";
      default:
        return "An error occurred with status code: $statusCode.";
    }
  }
}
