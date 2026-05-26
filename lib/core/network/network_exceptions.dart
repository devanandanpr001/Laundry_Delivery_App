import 'package:ziya_laundry_deliveryapp/core/network/api_exception.dart';

class NoInternetException extends ApiException {
  NoInternetException()
      : super(
          message: "No internet connection. Please check your connection and try again.",
          statusCode: null,
        );
}
