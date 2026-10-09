import '../models/activity_log_entry.dart';
import 'api_client.dart';

/// Lecture du journal d'activité (CDC section 8.9, `GET /api/activity-logs`)
/// — doc/audit.md, point F4. Lecture seule, sans cache local : le serveur
/// filtre déjà par Markaz (dérivé du token, CDC section 16).
class ActivityLogService {
  final _dio = ApiClient.instance.dio;

  /// Récupère une page du journal, la plus récente en premier.
  /// [entityType] : classe Laravel exacte (ex. `App\Models\Payment`) pour
  /// filtrer par domaine, ou null pour tout afficher.
  Future<ActivityLogPage> fetchPage({
    int page = 1,
    int perPage = 30,
    String? entityType,
  }) async {
    final response = await _dio.get('/activity-logs', queryParameters: {
      'page': page,
      'per_page': perPage,
      if (entityType != null) 'entity_type': entityType,
    });
    return ActivityLogPage.fromJson(response.data as Map<String, dynamic>);
  }
}
