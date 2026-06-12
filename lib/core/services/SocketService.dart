import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:ziya_laundry_deliveryapp/Constants/api_constants.dart';
import 'dart:developer' as dev;

import 'package:ziya_laundry_deliveryapp/core/services/token_service.dart';
import 'dart:async';

class SocketService {
  static final SocketService _instance = SocketService._internal();
  IO.Socket? _socket;
  final TokenService _tokenService = TokenService();

  String? _userId;
  String? _role;

  factory SocketService() => _instance;

  SocketService._internal();

  bool get isConnected => _socket?.connected ?? false;

  Future<void> connect({required String userId, required String role}) async {
    _userId = userId;
    _role = role;

    final token = await _tokenService.getAccessToken();

    if (token == null || token.isEmpty) {
      dev.log(
        '⚠️ Aborting Socket connection: No token available.',
        name: 'SocketService',
      );
      return;
    }

    final String socketUrl = ApiConstants.baseUrl.split('/api')[0];

    if (_socket != null) {
      dev.log('🔄 Updating Socket credentials...', name: 'SocketService');

      final currentAuth = _socket!.auth;
      final String? oldToken = (currentAuth is Map)
          ? currentAuth['token']
          : null;
      final bool tokenChanged = oldToken != token;

      _socket!.auth = {'token': token};
      _socket!.io.options?['auth'] = {'token': token};

      if (tokenChanged) {
        dev.log('🔑 Token changed, reconnecting...', name: 'SocketService');
        _socket!.disconnect();
        _socket!.connect();
      } else if (!_socket!.connected) {
        dev.log(
          '🔌 Socket not connected, initiating connect...',
          name: 'SocketService',
        );
        _socket!.connect();
      } else {
        dev.log(
          '📡 Socket already connected, asserting room join...',
          name: 'SocketService',
        );
        joinRoom();
      }
      return;
    }

    dev.log('🔌 Connecting Socket to: $socketUrl', name: 'SocketService');

    _socket = IO.io(
      socketUrl,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .setAuth({'token': token})
          .disableAutoConnect()
          .enableReconnection()
          .setReconnectionAttempts(10)
          .setReconnectionDelay(5000)
          .build(),
    );

    _registerCoreEventListeners();

    _socket!.connect();
  }

  /// 🔐 REGISTER CORE EVENT LISTENERS
  /// Registers the basic socket lifecycle events and ensures automatic room joining.
  void _registerCoreEventListeners() {
    _socket!.on('connect', (_) {
      dev.log(
        '✅ Socket Connected',
        name: 'SocketService',
      );
      print('✅ Socket Connected');

      joinRoom();

      _socket?.emit(
        'ping-status',
        {
          'connected': true,
        },
      );
    });

    _socket!.on('reconnect', (_) {
      dev.log(
        '🔁 Socket Reconnected',
        name: 'SocketService',
      );
      print('🔁 Socket Reconnected');

      joinRoom();
    });

    /// ❌ DISCONNECT
    _socket!.on('disconnect', (_) {
      dev.log('❌ Socket Disconnected', name: 'SocketService');
      print('❌ Socket Disconnected');
    });

    /// ⚠️ ERRORS
    _socket!.on('connect_error', (err) {
      dev.log('⚠️ Socket Connection Error: $err', name: 'SocketService');
      print('⚠️ Socket Connection Error: $err');
    });
    _socket!.on('reconnect_error', (err) {
      dev.log(
        '⚠️ Reconnect Error: $err',
        name: 'SocketService',
      );
      print('⚠️ Reconnect Error: $err');
    });

    _socket!.on('reconnect_failed', (err) {
      dev.log(
        '❌ Reconnect Failed: $err',
        name: 'SocketService',
      );
      print('❌ Reconnect Failed: $err');
    });

    _socket!.on('error', (err) {
      dev.log('⚠️ Socket Error: $err', name: 'SocketService');
      print('⚠️ Socket Error: $err');
    });
  }

  /// Syncs connection when app resumes. Uses stored credentials.
  Future<void> syncConnection() async {
    if (_userId == null || _role == null) return;

    dev.log('🔄 Syncing connection for $_userId...', name: 'SocketService');
    await connect(userId: _userId!, role: _role!);
  }

  /// 🔥 SOLID JOIN FUNCTION
  /// Emits the 'join' event to the server to enter the user-specific room.
  void joinRoom() {
    if (_socket == null || !_socket!.connected) {
      dev.log('📡 Join delayed: Socket not connected.', name: 'SocketService');
      return;
    }

    if ((_userId?.isNotEmpty ?? false) && (_role?.isNotEmpty ?? false)) {
      dev.log(
        '📡 Emitting Join → ID: $_userId, Role: $_role',
        name: 'SocketService',
      );
      _socket!.emit('join', {'userId': _userId, 'role': _role});
    } else {
      dev.log('⚠️ Join skipped: Missing userId/role', name: 'SocketService');
    }
  }

  /// 📦 JOIN ORDER ROOM
  /// Emits 'join-order' event to subscribe to specific order updates.
  void joinOrderRoom(String orderId) {
    if (_socket == null || !_socket!.connected) {
      dev.log(
        '📡 Order room join delayed: Socket not connected.',
        name: 'SocketService',
      );
      return;
    }

    dev.log('📦 Joining order room: $orderId', name: 'SocketService');
    _socket!.emit('join-order', {'orderId': orderId});
  }

  /// 🏢 JOIN BRANCH ROOM
  /// Emits 'join-branch' event to subscribe to updates for a specific branch.
  /// This is required to receive 'items-verified' events.
  void joinBranchRoom(String branchId) {
    if (_socket == null || !_socket!.connected) {
      dev.log('📡 Branch room join delayed: Socket not connected.', name: 'SocketService');
      return;
    }

    dev.log('🏢 Joining branch room: $branchId', name: 'SocketService');
    _socket!.emit('join-branch', {'branchId': branchId});
  }

  void sendLocation({
    required String orderId,
    required double latitude,
    required double longitude,
  }) {
    if (_socket == null || !_socket!.connected) {
      dev.log(
        '📡 Location send delayed: Socket not connected.',
        name: 'SocketService',
      );
      return;
    }

    dev.log(
      '📍 Sending location for order $orderId: ($latitude, $longitude)',
      name: 'SocketService',
    );
    _socket!.emit(
      'send-location',
      {
        'orderId': orderId,
        'lat': latitude,
        'lng': longitude,
      },
    );
  }

  /// 👂 LISTEN
  void on(String event, dynamic Function(dynamic) handler) {
    _socket?.off(event); // Prevent accidental duplicate registrations
    _socket?.on(event, handler);
  }

  /// 📡 LISTEN FOR ORDER CHANGES
  void listenOrderChanges(void Function(dynamic) handler) {
    dev.log('👂 Registered listener for: order-change', name: 'SocketService');
    _socket?.off('order-change');
    _socket?.on('order-change', handler);
  }

  /// ✅ LISTEN FOR ITEMS VERIFIED
  void listenItemsVerified(void Function(dynamic) handler) {
    dev.log('👂 Registered listener for: items-verified', name: 'SocketService');
    _socket?.off('items-verified');
    _socket?.on('items-verified', handler);
  }

  /// 🔔 NOTIFICATION
  void listenNotificationChange(void Function(dynamic) handler) {
    dev.log('👂 Registered listener for: notification-change', name: 'SocketService');
    _socket?.off('notification-change');
    _socket?.on('notification-change', handler);
  }

  ///  LISTEN FOR LOCATION UPDATES
  void listenLocationUpdates(void Function(dynamic) handler) {
    dev.log('👂 Registered listener for: receive-location', name: 'SocketService');
    _socket?.off('receive-location');
    _socket?.on('receive-location', handler);
  }

  /// ✔️ LISTEN FOR SUCCESSFUL JOIN
  void listenJoinSuccess(void Function(dynamic) handler) {
    dev.log('👂 Registered listener for: joined-successfully', name: 'SocketService');
    _socket?.off('joined-successfully'); // Re-add off for consistency with other listenXXX methods
    _socket?.on('joined-successfully', handler);
  }

  /// Add Connection Status Callback
  void listenConnectionStatus(void Function(bool connected) callback) {
    _socket?.on('connect', (_) => callback(true)); // No off() here, as this is a global status
    _socket?.on('disconnect', (_) => callback(false)); // No off() here, as this is a global status
  }

  /// Add Safe Emit
  ///  EMIT
  void emit(String event, dynamic data) {
    if (_socket == null || !_socket!.connected) {
      dev.log(
        '⚠️ Cannot emit "$event". Socket not connected.',
        name: 'SocketService',
      );
      return;
    }

    dev.log(
      '📡 Emitting: $event',
      name: 'SocketService',
    );

    _socket!.emit(event, data);
  }

  /// 🔚 LEAVE ORDER ROOM
  /// Leaves the specific order room when order is completed or closed.
  void leaveOrderRoom(String orderId) {
    if (_socket == null || !_socket!.connected) {
      dev.log(
        '🔚 Leave delayed: Socket not connected.',
        name: 'SocketService',
      );
      return;
    }

    dev.log('🔚 Leaving order room: $orderId', name: 'SocketService');
    _socket!.emit('leave-order', {'orderId': orderId});
  }

  /// 🧹 REMOVE LISTENER
  void off(String event) {
    _socket?.off(event);
  }

  /// 🔌 DISCONNECT
  void disconnect() {
    if (_socket != null) {
      _socket?.clearListeners(); // Clears all registered listeners
      _socket?.disconnect();
      _socket?.dispose(); // Releases resources
    }
    _socket = null;
    _userId = null;
    _role = null;
  }

  /// Add Connection Wait Helper
  Future<bool> waitForConnection({
    Duration timeout = const Duration(seconds: 10),
  }) async {
    final completer = Completer<bool>();

    if (isConnected) {
      return true;
    }

    // Use .once to ensure the listener is removed after the first event
    _socket?.once('connect', (_) {
      if (!completer.isCompleted) {
        completer.complete(true);
      }
    });

    Future.delayed(timeout, () {
      if (!completer.isCompleted) {
        completer.complete(false);
      }
    });

    return completer.future;
  }
} 