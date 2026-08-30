import 'package:dio/dio.dart';
import 'api_config.dart';
import 'token_storage.dart';

/// Client HTTP centralisé (Dio) avec intercepteur d'authentification —
/// CDC section 15 : "Client HTTP centralisé (Dio) avec intercepteurs pour
/// l'authentification, la gestion des erreurs et le rafraîchissement de session."
class ApiClient {
  ApiClient._internal() {
    dio = Dio(BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
      headers: {'Accept': 'application/json'},
    ));

    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _tokenStorage.getToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        // Session expirée ou révoquée côté serveur : on nettoie le token local.
        if (error.response?.statusCode == 401) {
          await _tokenStorage.clearToken();
        }
        handler.next(error);
      },
    ));
  }

  static final ApiClient instance = ApiClient._internal();

  late final Dio dio;
  final TokenStorage _tokenStorage = TokenStorage();

  /// Convertit une DioException en message d'erreur exploitable en français.
  static String describeError(Object error) {
    if (error is DioException) {
      final data = error.response?.data;
      if (data is Map && data['message'] is String) {
        return data['message'] as String;
      }
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return 'Le serveur ne répond pas. Vérifiez votre connexion.';
        case DioExceptionType.connectionError:
          return 'Impossible de joindre le serveur. Vérifiez votre connexion internet.';
        default:
          return 'Erreur de communication avec le serveur.';
      }
    }
    return error.toString();
  }
}
