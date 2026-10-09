import 'package:dio/dio.dart';
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

  Future<Markaz> updateMarkaz(Map<String, dynamic> data) async {
    try {
      final response = await _dio.put('/markaz', data: data);
      return Markaz.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException(ApiClient.describeError(e));
    }
  }
}
