import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:ziya_laundry_deliveryapp/core/network/network_status.dart';

class ConnectivityService {
  ConnectivityService._internal() {
    _connectivity = Connectivity();
    // Listen with a dynamic handler to support differing connectivity_plus signatures
    _subscription = _connectivity.onConnectivityChanged.listen((dynamic evt) {
      ConnectivityResult res;
      if (evt is List && evt.isNotEmpty) {
        res = evt.first as ConnectivityResult;
      } else if (evt is ConnectivityResult) {
        res = evt;
      } else {
        res = ConnectivityResult.none;
      }
      _onConnectivityChanged(res);
    });
    _updateConnectivity();
    _pollingTimer = Timer.periodic(const Duration(seconds: 12), (_) => _updateConnectivity());
  }

  static final ConnectivityService instance = ConnectivityService._internal();

  late final Connectivity _connectivity;
  late final StreamSubscription<dynamic> _subscription;
  late final Timer _pollingTimer;
  final StreamController<ConnectionStatus> _connectionController = StreamController<ConnectionStatus>.broadcast();

  ConnectionStatus _status = ConnectionStatus.disconnected;
  ConnectivityResult? _lastConnectivityResult;

  /// Last raw connectivity result as reported by `connectivity_plus`.
  ConnectivityResult? get lastConnectivityResult => _lastConnectivityResult;

  Stream<ConnectionStatus> get statusStream => _connectionController.stream;
  ConnectionStatus get status => _status;
  bool get isConnected =>
      _status == ConnectionStatus.connectedViaWifi ||
      _status == ConnectionStatus.connectedViaMobile;

  Future<void> _updateConnectivity() async {
    final dynamic result = await _connectivity.checkConnectivity();
    // handle both ConnectivityResult and List<ConnectivityResult>
    if (result is List && result.isNotEmpty) {
      _lastConnectivityResult = result.first;
      final nextStatus = await _statusFromResult(result.first);
      if (_status == nextStatus) return;
      _status = nextStatus;
      _connectionController.add(_status);
      return;
    }
    if (result is ConnectivityResult) {
      _lastConnectivityResult = result;
      final nextStatus = await _statusFromResult(result);
      if (_status == nextStatus) return;
      _status = nextStatus;
      _connectionController.add(_status);
    }
  }

  Future<void> _onConnectivityChanged(ConnectivityResult result) async {
    _lastConnectivityResult = result;
    final nextStatus = await _statusFromResult(result);
    if (_status == nextStatus) return;
    _status = nextStatus;
    _connectionController.add(_status);
  }

  Future<ConnectionStatus> _statusFromResult(ConnectivityResult result) async {
    if (result == ConnectivityResult.none) return ConnectionStatus.disconnected;
    final hasInternet = await _hasInternetAccess();
    if (!hasInternet) return ConnectionStatus.connectedButNoInternet;
    if (result == ConnectivityResult.wifi) return ConnectionStatus.connectedViaWifi;
    if (result == ConnectivityResult.mobile) return ConnectionStatus.connectedViaMobile;
    return ConnectionStatus.connectedButNoInternet;
  }

  Future<bool> _hasInternetAccess() async {
    try {
      final uri = Uri.parse('https://www.google.com/generate_204');
      final request = await HttpClient().getUrl(uri).timeout(const Duration(seconds: 5));
      final response = await request.close().timeout(const Duration(seconds: 5));
      return response.statusCode == 204 || response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Future<bool> checkConnection() async {
    await _updateConnectivity();
    return isConnected;
  }

  void dispose() {
    _subscription.cancel();
    _pollingTimer.cancel();
    _connectionController.close();
  }
}
