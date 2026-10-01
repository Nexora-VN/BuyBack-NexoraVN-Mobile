import 'dart:io';
import 'package:flutter/foundation.dart';

class AppConfig {
  static const String _productionHost = 'http://14.225.224.82:3001/api/v1';
  static const String _defaultHost = 'http://14.225.224.82:3001/api/v1';
  static const String _androidEmulatorHost = 'http://14.225.224.82:3001/api/v1';

  static String get baseUrl {
    const fromEnv = String.fromEnvironment('API_BASE_URL');
    if (fromEnv.isNotEmpty) return fromEnv;

    if (kReleaseMode) {
      return _productionHost;
    }

    if (!kIsWeb && Platform.isAndroid) {
      return _androidEmulatorHost;
    }
    return _defaultHost;
  }
}
