import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../../../core/storage/secure_storage_service.dart';
import '../models/user_model.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final client = ref.watch(apiClientProvider);
  final storage = ref.watch(secureStorageProvider);
  return AuthRepository(client, storage);
});

class AuthRepository {
  final ApiClient _client;
  final SecureStorageService _storage;

  AuthRepository(this._client, this._storage);

  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    final response = await _client.post(
      '/auth/login',
      data: {
        'email': email.trim(),
        'password': password,
      },
    );

    if (response is Map<String, dynamic>) {
      final access = response['accessToken'] as String?;
      final refresh = response['refreshToken'] as String?;
      final userJson = response['user'] as Map<String, dynamic>?;

      if (access != null && refresh != null && userJson != null) {
        final user = UserModel.fromJson(userJson);
        await _storage.saveTokens(accessToken: access, refreshToken: refresh);
        await _storage.saveUser(user.toJson());
        return user;
      }
    }

    throw Exception('Phản hồi đăng nhập không hợp lệ');
  }

  Future<UserModel> loginWithGoogle({
    String? idToken,
    String? accessToken,
    String? displayName,
    String? email,
  }) async {
    final response = await _client.post(
      '/auth/google',
      data: {
        'idToken': ?idToken,
        'accessToken': ?accessToken,
        'displayName': ?displayName,
        'email': ?email,
      },
    );

    if (response is Map<String, dynamic>) {
      final access = response['accessToken'] as String?;
      final refresh = response['refreshToken'] as String?;
      final userJson = response['user'] as Map<String, dynamic>?;

      if (access != null && refresh != null && userJson != null) {
        final user = UserModel.fromJson(userJson);
        await _storage.saveTokens(accessToken: access, refreshToken: refresh);
        await _storage.saveUser(user.toJson());
        return user;
      }
    }

    throw Exception('Phản hồi đăng nhập không hợp lệ');
  }

  Future<UserModel?> getMe() async {
    try {
      final response = await _client.get('/auth/me');
      if (response is Map<String, dynamic>) {
        final user = UserModel.fromJson(response);
        await _storage.saveUser(user.toJson());
        return user;
      }
    } catch (_) {
      // Fallback to local stored user if offline
      final cached = await _storage.getUser();
      if (cached != null) return UserModel.fromJson(cached);
    }
    return null;
  }

  Future<void> logout() async {
    try {
      await _client.post('/auth/logout');
    } catch (_) {}
    await _storage.clearAuth();
  }
}
