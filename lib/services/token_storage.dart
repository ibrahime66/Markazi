import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Stockage sécurisé du token d'authentification (un token par appareil,
/// CDC section 14). Utilisé par ApiClient et AuthService.
class TokenStorage {
  static const _storage = FlutterSecureStorage();
  static const _tokenKey = 'markazi_auth_token';

  Future<void> saveToken(String token) => _storage.write(key: _tokenKey, value: token);

  Future<String?> getToken() => _storage.read(key: _tokenKey);

  Future<void> clearToken() => _storage.delete(key: _tokenKey);
}
