import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../models/markaz.dart';
import 'api_client.dart';

/// Service d'accès à la fiche du Markaz courant (CDC section 8.2 / 17 :
/// GET/PUT /api/markaz). L'identifiant du Markaz est toujours dérivé de
/// l'utilisateur authentifié côté serveur, jamais transmis par le client.
class MarkazService {
  final Dio _dio = ApiClient.instance.dio;

  Future<Markaz> getMarkaz() async {
    try {
      final response = await _dio.get('/markaz');
      return Markaz.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException(ApiClient.describeError(e));
    }
  }

  /// Envoie le logo du Markaz (CDC §8.2 / §21) — image déjà réduite par
  /// l'app (CDC §25), 2 Mo maximum côté serveur.
  Future<Markaz> uploadLogo(Uint8List bytes, String fileName) async {
    try {
      final response = await _dio.post(
        '/markaz/logo',
        data: FormData.fromMap({
          'logo': MultipartFile.fromBytes(bytes, filename: fileName),
        }),
      );
      return Markaz.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException(ApiClient.describeError(e));
    }
  }

  /// Télécharge le logo (route authentifiée, réservée au Markaz).
  Future<Uint8List> downloadLogo() async {
    try {
      final response = await _dio.get<List<int>>(
        '/markaz/logo',
        options: Options(responseType: ResponseType.bytes),
      );
      return Uint8List.fromList(response.data ?? const []);
    } on DioException catch (e) {
      throw ApiException(ApiClient.describeError(e));
    }
  }

  Future<Markaz> deleteLogo() async {
    try {
      final response = await _dio.delete('/markaz/logo');
      return Markaz.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException(ApiClient.describeError(e));
    }
  }

  Future<Markaz> updateMarkaz(Map<String, dynamic> data) async {
    try {
      final response = await _dio.put('/markaz', data: data);
      return Markaz.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException(ApiClient.describeError(e));
    }
  }
}
