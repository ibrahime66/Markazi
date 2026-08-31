import '../models/recitation.dart';
import '../services/api_client.dart';

/// Datasource API (Laravel/MySQL) pour les récitations — CDC section 8.5,
/// doc/audit.md point B1.
class ApiRecitationDatasource {
  final _dio = ApiClient.instance.dio;

  Future<Recitation> addRecitation(Recitation recitation, String markazId) async {
    final response = await _dio.post('/recitations', data: _toPayload(recitation));
    return _mapJsonToRecitation(response.data as Map<String, dynamic>, markazId);
  }

  Future<Recitation> updateRecitation(Recitation recitation, String markazId) async {
    final response = await _dio.put('/recitations/${recitation.id}', data: _toPayload(recitation));
    return _mapJsonToRecitation(response.data as Map<String, dynamic>, markazId);
  }

  Future<void> deleteRecitation(String recitationId) async {
    await _dio.delete('/recitations/$recitationId');
  }

  Future<List<Recitation>> getRecitationsByMarkaz(String markazId) async {
    final response = await _dio.get('/recitations', queryParameters: {'per_page': 500});
    final data = (response.data as Map<String, dynamic>)['data'] as List<dynamic>;
    return data
        .map((json) => _mapJsonToRecitation(json as Map<String, dynamic>, markazId))
        .toList();
  }

  Map<String, dynamic> _toPayload(Recitation recitation) {
    return {
      'student_id': int.parse(recitation.studentId),
      'date': recitation.date.toIso8601String().split('T').first,
      'surah': recitation.surah,
      'ayah_from': recitation.ayahFrom,
      'ayah_to': recitation.ayahTo,
      'status': _statusToApi(recitation.status),
      'note': recitation.note,
    };
  }

  String _statusToApi(RecitationStatus status) {
    switch (status) {
      case RecitationStatus.recited:
        return 'recited';
      case RecitationStatus.notRecited:
        return 'not_recited';
      case RecitationStatus.partial:
        return 'partial';
    }
  }

  RecitationStatus _statusFromApi(String? status) {
    switch (status) {
      case 'recited':
        return RecitationStatus.recited;
      case 'partial':
        return RecitationStatus.partial;
      case 'not_recited':
      default:
        return RecitationStatus.notRecited;
    }
  }

  Recitation _mapJsonToRecitation(Map<String, dynamic> json, String markazId) {
    return Recitation(
      id: json['id'].toString(),
      studentId: json['student_id'].toString(),
      markazId: markazId,
      date: DateTime.parse(json['date'] as String),
      surah: json['surah'] as String? ?? '',
      status: _statusFromApi(json['status'] as String?),
      ayahFrom: json['ayah_from'] as int?,
      ayahTo: json['ayah_to'] as int?,
      note: json['note'] as String?,
    );
  }
}
