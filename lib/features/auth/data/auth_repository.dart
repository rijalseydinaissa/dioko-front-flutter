import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:payments_app/core/http_client.dart';
import 'package:payments_app/core/providers.dart';
import 'package:payments_app/features/auth/data/token_storage.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final client = ref.read(httpClientProvider);
  final storage = ref.read(secureStorageProvider);
  return AuthRepository(client, storage);
});

class AuthRepository {
  final HttpClient _http;
  final TokenStorage _storage;
  AuthRepository(this._http, this._storage);

  // Inscription avec name, email et password
  Future<void> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    await _http.post('/auth/register', data: {
      'name': name,
      'email': email,
      'password': password,
      'password_confirmation': passwordConfirmation,
      // balance et is_active sont initialisés côté backend
    });
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    final res = await _http.post('/auth/login', data: {
      'email': email,
      'password': password,
    });

    final data = res.data['data'] as Map<String, dynamic>;
    final access = data['token'] as String?;
    final refresh = data['refresh_token']
        as String?; // peut être null si backend ne renvoie pas

    if (access != null) await _storage.saveToken(access);
    if (refresh != null) await _storage.saveRefreshToken(refresh);
    if (access == null) {
      throw Exception('Le token d\'accès est manquant dans la réponse');
    }
  }

  Future<void> logout() async {
    try {
      await _http.post('/auth/logout');
    } finally {
      await _storage.clear();
    }
  }

  Future<Map<String, dynamic>?> me() async {
    final res = await _http.get('/auth/me');
    return (res.data as Map<String, dynamic>?);
  }

  Future<bool> isAuthenticated() async => (await _storage.readToken()) != null;
}
