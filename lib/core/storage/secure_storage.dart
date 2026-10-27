import 'dart:convert';
import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path_provider/path_provider.dart';

/// Token/PIN storage.
///
/// Primary store: [FlutterSecureStorage] (secure, Android/iOS). Because the
/// trial may also run on Windows/web dev where the plugin can be unavailable,
/// every value is mirrored to a local file in the app-support directory so a
/// session survives app restarts on any supported platform.
class SecureStorage {
  SecureStorage({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';
  static const _pinKey = 'kiosk_pin';

  final FlutterSecureStorage _storage;

  Future<File> _fallbackFile() async {
    final dir = await getApplicationSupportDirectory();
    return File('${dir.path}${Platform.pathSeparator}session.json');
  }

  Future<Map<String, String>> _readFallback() async {
    try {
      final file = await _fallbackFile();
      if (!await file.exists()) return const {};
      final decoded = jsonDecode(await file.readAsString());
      if (decoded is! Map) return const {};
      return decoded.map((k, v) => MapEntry(k.toString(), v.toString()));
    } catch (_) {
      return const {};
    }
  }

  Future<void> _writeFallback(Map<String, String> entries) async {
    try {
      final current = await _readFallback();
      current.addAll(entries);
      final file = await _fallbackFile();
      await file.writeAsString(jsonEncode(current), flush: true);
    } catch (_) {
      // Best-effort; secure storage remains the primary path on mobile.
    }
  }

  Future<String?> _secureRead(String key) async {
    try {
      return await _storage.read(key: key);
    } catch (_) {
      return null;
    }
  }

  Future<void> _secureWrite(String key, String value) async {
    try {
      await _storage.write(key: key, value: value);
    } catch (_) {
      // Ignored; the file mirror is the fallback.
    }
  }

  Future<void> _secureDelete(String key) async {
    try {
      await _storage.delete(key: key);
    } catch (_) {}
  }

  Future<String?> readAccessToken() async {
    final secure = await _secureRead(_accessTokenKey);
    if (secure != null && secure.isNotEmpty) return secure;
    return (await _readFallback())[_accessTokenKey];
  }

  Future<void> writeAccessToken(String token) async {
    await _secureWrite(_accessTokenKey, token);
    await _writeFallback({_accessTokenKey: token});
  }

  Future<String?> readRefreshToken() async {
    final secure = await _secureRead(_refreshTokenKey);
    if (secure != null && secure.isNotEmpty) return secure;
    return (await _readFallback())[_refreshTokenKey];
  }

  Future<void> writeRefreshToken(String token) async {
    await _secureWrite(_refreshTokenKey, token);
    await _writeFallback({_refreshTokenKey: token});
  }

  Future<String?> readPin() async {
    final secure = await _secureRead(_pinKey);
    if (secure != null && secure.isNotEmpty) return secure;
    return (await _readFallback())[_pinKey];
  }

  Future<void> writePin(String pin) async {
    await _secureWrite(_pinKey, pin);
    await _writeFallback({_pinKey: pin});
  }

  /// Clears all auth-related data (used on logout).
  Future<void> clear() async {
    await _secureDelete(_accessTokenKey);
    await _secureDelete(_refreshTokenKey);
    await _secureDelete(_pinKey);
    try {
      final file = await _fallbackFile();
      if (await file.exists()) await file.delete();
    } catch (_) {}
  }
}
