import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
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
      onResponse: (response, handler) {
        isOnline.value = true;
        handler.next(response);
      },
      onError: (error, handler) async {
        // Toute réponse du serveur (même une erreur 4xx/5xx) prouve que la
        // connexion fonctionne ; seule une erreur réseau signifie "hors ligne".
        isOnline.value = !isOfflineError(error);
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

  /// État de connexion au serveur, déduit du résultat de la dernière
  /// requête (CDC §20 : "indicateur visuel clair dans l'interface signalant
  /// l'état de connexion"). Pas de dépendance supplémentaire : c'est la
  /// joignabilité réelle de l'API qui compte, pas seulement le Wi-Fi.
  final ValueNotifier<bool> isOnline = ValueNotifier<bool>(true);

  /// Vrai si l'erreur signifie "serveur injoignable" (pas de réseau, délai
  /// dépassé) — seul cas où une saisie doit être mise en file d'attente
  /// hors ligne (CDC §20). Une réponse du serveur (422, 409, 403…) est un
  /// refus réel : la mettre en file la ferait rejouer et échouer sans fin.
  static bool isOfflineError(Object error) {
    if (error is! DioException) return false;
    if (error.response != null) return false;
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
      case DioExceptionType.unknown:
        return true;
      default:
        return false;
    }
  }

  /// En-tête portant la date réelle d'une action rejouée après une période
  /// hors ligne (lu côté serveur par le middleware CapturePerformedAt —
  /// CDC §27 : l'historique garde la date de réalisation).
  static Options? performedAtOptions(DateTime? performedAt) {
    if (performedAt == null) return null;
    return Options(headers: {
      'X-Performed-At': performedAt.toUtc().toIso8601String(),
    });
  }

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
