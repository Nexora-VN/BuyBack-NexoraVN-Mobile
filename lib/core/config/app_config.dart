import 'dart:io';
import 'package:flutter/foundation.dart';

class AppConfig {
  static const String _defaultHost = 'http://localhost:8080';
  static const String _androidEmulatorHost = 'http://10.0.2.2:8080';

  static String get baseUrl {
    const fromEnv = String.fromEnvironment('API_BASE_URL');
    if (fromEnv.isNotEmpty) return fromEnv;

    if (!kIsWeb && Platform.isAndroid) {
      return _androidEmulatorHost;
    }
    return _defaultHost;
  }
}
