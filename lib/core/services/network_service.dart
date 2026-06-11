import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
class NetworkService {
  static final NetworkService instance = NetworkService._();

  NetworkService._();

  final Connectivity _connectivity = Connectivity();

  StreamSubscription<List<ConnectivityResult>>? _subscription;

  bool _isOnline = true;

  bool get isOnline => _isOnline;

  void Function(bool)? _onStatusChange;

  set onStatusChange(void Function(bool)? callback) {
    _onStatusChange = callback;

    callback?.call(_isOnline);
  }

  Future<void> startMonitoring() async {
    await _checkInternet();

    _subscription = _connectivity.onConnectivityChanged.listen((_) async {
      await _checkInternet();
    });
  }

  Future<void> _checkInternet() async {
    bool hasInternet = false;

    try {
      final result = await InternetAddress.lookup(
        'google.com',
      ).timeout(const Duration(seconds: 3));

      hasInternet =
          result.isNotEmpty &&
          result.first.rawAddress.isNotEmpty;
    } on SocketException {
      hasInternet = false;
    } on TimeoutException {
      hasInternet = false;
    } catch (_) {
      hasInternet = false;
    }

    if (_isOnline != hasInternet) {
      _isOnline = hasInternet;

      _onStatusChange?.call(_isOnline);
    }
  }

  void dispose() {
    _subscription?.cancel();
  }
}