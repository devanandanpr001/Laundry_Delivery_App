import 'dart:async';
import 'package:flutter/material.dart';
import 'package:ziya_laundry_deliveryapp/core/connectivity_service.dart';
import 'package:ziya_laundry_deliveryapp/core/network_status.dart';

class ConnectivityViewModel extends ChangeNotifier {
  final ConnectivityService _service;
  late final StreamSubscription<ConnectionStatus> _subscription;
  ConnectionStatus _status = ConnectionStatus.disconnected;

  ConnectivityViewModel(this._service) {
    _status = _service.status;
    _subscription = _service.statusStream.listen((status) {
      if (_status != status) {
        _status = status;
        notifyListeners();
      }
    });
  }

  ConnectionStatus get status => _status;
  bool get isOnline =>
      _status == ConnectionStatus.connectedViaWifi ||
      _status == ConnectionStatus.connectedViaMobile;

  Future<bool> refreshConnection() async {
    final connected = await _service.checkConnection();
    if (_status != _service.status) {
      _status = _service.status;
      notifyListeners();
    }
    return connected;
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
