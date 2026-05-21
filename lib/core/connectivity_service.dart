import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:ziya_laundry_deliveryapp/core/network_status.dart';

class ConnectivityService {
  ConnectivityService._internal() {
    _connectivity = Connectivity();
    _subscription = _connectivity.onConnectivityChanged.listen(_onConnectivityChanged);
    _updateConnectivity();
    _pollingTimer = Timer.periodic(const Duration(seconds: 12), (_) => _updateConnectivity());
  }

  static final ConnectivityService instance = ConnectivityService._internal();

  late final Connectivity _connectivity;
  late final StreamSubscription<List<ConnectivityResult>> _subscription;
  late final Timer _pollingTimer;
  final StreamController<ConnectionStatus> _connectionController = StreamController<ConnectionStatus>.broadcast();

  ConnectionStatus _status = ConnectionStatus.disconnected;
  List<ConnectivityResult>? _lastConnectivityResult;

  Stream<ConnectionStatus> get statusStream => _connectionController.stream;
  ConnectionStatus get status => _status;
  bool get isConnected =>
      _status == ConnectionStatus.connectedViaWifi ||
      _status == ConnectionStatus.connectedViaMobile;

  Future<void> _updateConnectivity() async {
    final result = await _connectivity.checkConnectivity();
    _lastConnectivityResult = result;
    await _evaluateConnectivity(result);
  }

  Future<void> _onConnectivityChanged(List<ConnectivityResult> result) async {
    _lastConnectivityResult = result;
    await _evaluateConnectivity(result);
  }

  Future<void> _evaluateConnectivity(List<ConnectivityResult> result) async {
    final nextStatus = await _statusFromResult(result);
    if (_status == nextStatus) return;
    _status = nextStatus;
    _connectionController.add(_status);
  }

  Future<ConnectionStatus> _statusFromResult(List<ConnectivityResult> result) async {
    if (result.isEmpty || result.contains(ConnectivityResult.none)) return ConnectionStatus.disconnected;
    final hasInternet = await _hasInternetAccess();
    if (!hasInternet) return ConnectionStatus.connectedButNoInternet;
    if (result.contains(ConnectivityResult.wifi)) return ConnectionStatus.connectedViaWifi;
    if (result.contains(ConnectivityResult.mobile)) return ConnectionStatus.connectedViaMobile;
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
