import 'dart:io';
import 'package:flutter/foundation.dart';

class AppConfig {
  static const String _productionHost = 'https://buyback-nexoravn-backend-production.up.railway.app/api/v1';
  static const String _defaultHost = 'http://localhost:8080/api/v1';
  static const String _androidEmulatorHost = 'http://10.0.2.2:8080/api/v1';

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
