import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TokenStorage {
  static const _kAccessKey = 'access_token';
  static const _kRefreshKey = 'refresh_token';

  final _secureStorage = const FlutterSecureStorage();

  bool get _isWeb => kIsWeb;
  bool get _isMobile => !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  Future<void> saveToken(String token) async {
    if (_isMobile) {
      await _secureStorage.write(key: _kAccessKey, value: token);
    } else {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kAccessKey, token);
    }
  }

  Future<String?> readToken() async {
    if (_isMobile) {
      return await _secureStorage.read(key: _kAccessKey);
    } else {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_kAccessKey);
    }
  }

  Future<void> saveRefreshToken(String token) async {
    if (_isMobile) {
      await _secureStorage.write(key: _kRefreshKey, value: token);
    } else {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kRefreshKey, token);
    }
  }

  Future<String?> readRefreshToken() async {
    if (_isMobile) {
      return await _secureStorage.read(key: _kRefreshKey);
    } else {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_kRefreshKey);
    }
  }

  Future<void> clear() async {
    if (_isMobile) {
      await _secureStorage.deleteAll();
    } else {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_kAccessKey);
      await prefs.remove(_kRefreshKey);
    }
  }
}
