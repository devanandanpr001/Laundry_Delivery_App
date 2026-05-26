// import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// class TokenService {
//   final _storage = const FlutterSecureStorage();

//   static const _accessTokenKey = 'accessToken';
//   static const _refreshTokenKey = 'refreshToken';

//   Future<void> saveTokens({
//     required String accessToken,
//     required String refreshToken,
//   }) async {
//     await _storage.write(key: _accessTokenKey, value: accessToken);
//     await _storage.write(key: _refreshTokenKey, value: refreshToken);
//   }

//   Future<String?> getAccessToken() async {
//     return await _storage.read(key: _accessTokenKey);
//   }

//   Future<String?> getRefreshToken() async {
//     return await _storage.read(key: _refreshTokenKey);
//   }

//   Future<void> deleteTokens() async {
//     await _storage.delete(key: _accessTokenKey);
//     await _storage.delete(key: _refreshTokenKey);
//   }
// }
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenService {
  final _storage = const FlutterSecureStorage();

  static const _accessTokenKey = 'accessToken';
  static const _refreshTokenKey = 'refreshToken';

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _storage.write(key: _accessTokenKey, value: accessToken);
    await _storage.write(key: _refreshTokenKey, value: refreshToken);
  }

  Future<String?> getAccessToken() async {
    return await _storage.read(key: _accessTokenKey);
  }

  Future<String?> getRefreshToken() async {
    return await _storage.read(key: _refreshTokenKey);
  }
  /// Parse the access token (assumed JWT) and return expiry DateTime if present.
  Future<DateTime?> getAccessTokenExpiry() async {
    final token = await getAccessToken();
    if (token == null) return null;
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;
      final payload = parts[1];
      String normalized = base64Url.normalize(payload);
      final decoded = utf8.decode(base64Url.decode(normalized));
      final map = json.decode(decoded) as Map<String, dynamic>;
      if (map.containsKey('exp')) {
        final exp = map['exp'];
        final expInt = exp is int ? exp : int.tryParse(exp.toString());
        if (expInt != null) {
          return DateTime.fromMillisecondsSinceEpoch(expInt * 1000);
        }
      }
    } catch (_) {
      // ignore and return null on any parsing error
    }
    return null;
  }

  /// Returns true if access token will expire within [threshold].
  Future<bool> isAccessTokenExpiringSoon({Duration threshold = const Duration(seconds: 30)}) async {
    final expiry = await getAccessTokenExpiry();
    if (expiry == null) return false;
    final now = DateTime.now().toUtc();
    return expiry.isBefore(now.add(threshold));
  }
  Future<void> deleteTokens() async {
     await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
 }
}
