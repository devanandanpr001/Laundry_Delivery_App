import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenService {
  static const _accessTokenKey = 'accessToken';
  static const _refreshTokenKey = 'refreshToken';

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _storage.write(
      key: _accessTokenKey,
      value: accessToken,
    );
    await _storage.write(
      key: _refreshTokenKey,
      value: refreshToken,
    );

    // Verify and print status as requested
    final savedAccessToken = await getAccessToken();
    final savedRefreshToken = await getRefreshToken();
    final isAccessSaved = savedAccessToken == accessToken;
    final isRefreshSaved = savedRefreshToken == refreshToken;

    debugPrint(
      "TokenService: Access Token saved successfully? $isAccessSaved (Length: ${savedAccessToken?.length ?? 0})",
    );
    debugPrint(
      "TokenService: Refresh Token saved successfully? $isRefreshSaved (Length: ${savedRefreshToken?.length ?? 0})",
    );
  }

  Future<String?> getAccessToken() async {
    return _storage.read(key: _accessTokenKey);
  }

  Future<String?> getRefreshToken() async {
    return _storage.read(key: _refreshTokenKey);
  }

  Future<DateTime?> getAccessTokenExpiry() async {
    final token = await getAccessToken();

    if (token == null || token.isEmpty) {
      return null;
    }

    try {
      final parts = token.split('.');

      if (parts.length != 3) {
        return null;
      }

      final payload = parts[1];

      final normalized = base64Url.normalize(payload);

      final decoded = utf8.decode(base64Url.decode(normalized));

      final data = json.decode(decoded) as Map<String, dynamic>;

      final exp = data['exp'];

      if (exp == null) {
        return null;
      }

      final expSeconds = exp is int ? exp : int.tryParse(exp.toString());

      if (expSeconds == null) {
        return null;
      }

      return DateTime.fromMillisecondsSinceEpoch(
        expSeconds * 1000,
        isUtc: true,
      );
    } catch (_) {
      return null;
    }
  }

  /// Parse the refresh token (assumed JWT) and return expiry DateTime if present.
  Future<DateTime?> getRefreshTokenExpiry() async {
    final token = await getRefreshToken();

    if (token == null || token.isEmpty) {
      return null;
    }

    try {
      final parts = token.split('.');

      if (parts.length != 3) {
        return null;
      }

      final payload = parts[1];

      final normalized = base64Url.normalize(payload);

      final decoded = utf8.decode(base64Url.decode(normalized));

      final data = json.decode(decoded) as Map<String, dynamic>;

      final exp = data['exp'];

      if (exp == null) return null;

      final expSeconds = exp is int ? exp : int.tryParse(exp.toString());

      if (expSeconds == null) return null;

      return DateTime.fromMillisecondsSinceEpoch(expSeconds * 1000, isUtc: true);
    } catch (_) {
      return null;
    }
  }

  /// Returns true if the refresh token is expired or cannot be parsed.
  Future<bool> isRefreshTokenExpired() async {
    final expiry = await getRefreshTokenExpiry();
    if (expiry == null) {
      return true; // Treat unparseable/missing refresh token as expired
    }
    return expiry.isBefore(DateTime.now().toUtc());
  }

  Future<bool> isAccessTokenExpiringSoon({
    Duration threshold = const Duration(minutes: 2),
  }) async {
    final expiry = await getAccessTokenExpiry();

    if (expiry == null) {
      // Some backends issue opaque tokens or JWTs without an exp claim.
      // In that case, avoid refreshing on every request and let a real 401
      // response trigger the refresh flow.
      return false;
    }

    debugPrint("Access Token Expiry: $expiry");
    debugPrint("Current Time: ${DateTime.now().toUtc()}");

    return expiry.isBefore(
      DateTime.now().toUtc().add(threshold),
    );
  }

  Future<void> deleteTokens() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);

    // Verify deletion
    final accessToken = await getAccessToken();
    final refreshToken = await getRefreshToken();
    final isAccessDeleted = accessToken == null || accessToken.isEmpty;
    final isRefreshDeleted = refreshToken == null || refreshToken.isEmpty;

    debugPrint(
      "TokenService: Access Token deleted successfully? $isAccessDeleted",
    );
    debugPrint(
      "TokenService: Refresh Token deleted successfully? $isRefreshDeleted",
    );
  }
}
