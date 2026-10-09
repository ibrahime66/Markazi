import '../models/activity_log_entry.dart';
import '../services/api_client.dart';

/// Une page du journal d'activité (pagination Laravel).
class ActivityLogPage {
  final List<ActivityLogEntry> entries;
  final int currentPage;
  final int lastPage;

  const ActivityLogPage({
    required this.entries,
    required this.currentPage,
    required this.lastPage,
  });

  bool get hasMore => currentPage < lastPage;
}

/// Datasource API du journal d'activité — `GET /api/activity-logs`
/// (CDC §8.9 / §17, doc/audit.md point F4).
class ApiActivityLogDatasource {
  final _dio = ApiClient.instance.dio;

  Future<ActivityLogPage> fetchPage({
    int page = 1,
    int perPage = 30,
    String? category,
    DateTime? dateFrom,
  }) async {
    final response = await _dio.get('/activity-logs', queryParameters: {
      'page': page,
      'per_page': perPage,
      if (category != null) 'category': category,
      if (dateFrom != null)
        'date_from': dateFrom.toIso8601String().split('T').first,
    });

    final body = response.data as Map<String, dynamic>;
    final data = body['data'] as List<dynamic>;
    return ActivityLogPage(
      entries: data
          .map((json) => ActivityLogEntry.fromJson(json as Map<String, dynamic>))
          .toList(),
      currentPage: body['current_page'] as int? ?? page,
      lastPage: body['last_page'] as int? ?? page,
    );
  }
}
