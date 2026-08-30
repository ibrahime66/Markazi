import 'package:flutter/foundation.dart' show debugPrint;
import 'package:dio/dio.dart';
import '../models/user.dart';
import 'api_client.dart';
import 'token_storage.dart';

/// Service d'authentification — CDC section 8.1 / 14.
/// Authentification par token via l'API Laravel (Sanctum), un token par
/// appareil, persisté de façon sécurisée pour restaurer la session au démarrage.
class AuthService {
  final Dio _dio = ApiClient.instance.dio;
  final TokenStorage _tokenStorage = TokenStorage();

  User? _currentUser;

  /// Utilisateur actuellement authentifié
  User? get currentUser => _currentUser;

  /// Vérifie si l'utilisateur est authentifié
  bool get isAuthenticated => _currentUser != null;

  /// Restaure la session au démarrage à partir du token stocké localement.
  Future<void> initializeUser() async {
    final token = await _tokenStorage.getToken();
    if (token == null) return;

    try {
      final response = await _dio.get('/auth/me');
      _currentUser = User.fromApiJson(response.data as Map<String, dynamic>);
    } catch (e) {
      debugPrint('AuthService.initializeUser: session invalide ou expirée: $e');
      await _tokenStorage.clearToken();
      _currentUser = null;
    }
  }

  /// Connexion : un token par appareil (CDC section 14). Le Markaz de
  /// l'utilisateur est toujours dérivé côté serveur, jamais fourni par le client.
  Future<User> login({
    required String email,
    required String password,
  }) async {
    if (email.isEmpty || password.isEmpty) {
      throw Exception('Email et mot de passe requis');
    }

    try {
      final response = await _dio.post('/auth/login', data: {
        'email': email,
        'password': password,
        'device_name': 'flutter-app',
      });

      final data = response.data as Map<String, dynamic>;
      await _tokenStorage.saveToken(data['token'] as String);
      _currentUser = User.fromApiJson(data['user'] as Map<String, dynamic>);

      return _currentUser!;
    } on DioException catch (e) {
      throw Exception(ApiClient.describeError(e));
    }
  }

  /// Inscription du Maître : crée son compte ET la fiche de son Markaz
  /// (CDC section 8.1 / 8.2).
  Future<User> register({
    required String name,
    required String email,
    required String password,
    required String markazName,
    String? markazCity,
    String? markazPhone,
    String? markazAddress,
  }) async {
    if (name.isEmpty || email.isEmpty || password.isEmpty || markazName.isEmpty) {
      throw Exception('Tous les champs obligatoires doivent être remplis');
    }

    if (password.length < 6) {
      throw Exception('Mot de passe trop court (6+ caractères)');
    }

    try {
      final response = await _dio.post('/auth/register', data: {
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': password,
        'markaz_name': markazName,
        if (markazCity != null) 'markaz_city': markazCity,
        if (markazPhone != null) 'markaz_phone': markazPhone,
        if (markazAddress != null) 'markaz_address': markazAddress,
      });

      final data = response.data as Map<String, dynamic>;
      await _tokenStorage.saveToken(data['token'] as String);
      _currentUser = User.fromApiJson(data['user'] as Map<String, dynamic>);

      return _currentUser!;
    } on DioException catch (e) {
      throw Exception(ApiClient.describeError(e));
    }
  }

  /// Demande l'envoi du code de réinitialisation par email (CDC section
  /// 8.1). Corrige doc/audit.md, point C2 : ce flux n'existait pas du tout
  /// côté app (aucun écran, aucune méthode) alors que l'API le supportait.
  Future<void> forgotPassword({required String email}) async {
    if (email.isEmpty) {
      throw Exception('Email requis');
    }
    try {
      await _dio.post('/auth/password/forgot', data: {'email': email});
    } on DioException catch (e) {
      throw Exception(ApiClient.describeError(e));
    }
  }

  /// Réinitialise le mot de passe à partir du code reçu par email.
  Future<void> resetPassword({
    required String email,
    required String token,
    required String password,
  }) async {
    if (email.isEmpty || token.isEmpty || password.isEmpty) {
      throw Exception('Tous les champs sont obligatoires');
    }
    if (password.length < 6) {
      throw Exception('Mot de passe trop court (6+ caractères)');
    }
    try {
      await _dio.post('/auth/password/reset', data: {
        'email': email,
        'token': token,
        'password': password,
        'password_confirmation': password,
      });
    } on DioException catch (e) {
      throw Exception(ApiClient.describeError(e));
    }
  }

  /// Déconnexion : révoque uniquement le token de l'appareil courant côté serveur.
  Future<void> logout() async {
    try {
      await _dio.post('/auth/logout');
    } catch (e) {
      debugPrint('AuthService.logout: erreur réseau ignorée: $e');
    } finally {
      await _tokenStorage.clearToken();
      _currentUser = null;
    }
  }

  /// markazId de l'utilisateur courant, pour filtrage/affichage côté client.
  /// L'isolation réelle des données est appliquée côté serveur (CDC section 16).
  String? get currentMarkazId => _currentUser?.markazId;

  bool hasAccessToMarkaz(String markazId) {
    return _currentUser != null && _currentUser!.markazId == markazId;
  }

  void dispose() {}
}
