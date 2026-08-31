import '../models/attendance.dart';
import '../services/api_client.dart';

/// Datasource API (Laravel/MySQL) pour les présences — remplace l'ancien
/// FirebaseAttendanceDatasource.
class ApiAttendanceDatasource {
  final _dio = ApiClient.instance.dio;

  Future<Attendance> addAttendance(Attendance attendance, String markazId) async {
    final response = await _dio.post('/attendances', data: {
      'student_id': int.parse(attendance.studentId),
      'date': attendance.date.toIso8601String().split('T').first,
      'status': _statusToApi(attendance.status),
      'lesson': attendance.lesson,
    });
    return _mapJsonToAttendance(response.data as Map<String, dynamic>, markazId);
  }

  /// Corrige une présence existante via PUT /attendances/{id} (doc/audit.md,
  /// point B3 — cette route n'existait pas auparavant).
  Future<Attendance> updateAttendance(Attendance attendance) async {
    final response = await _dio.put('/attendances/${attendance.id}', data: {
      'student_id': int.parse(attendance.studentId),
      'date': attendance.date.toIso8601String().split('T').first,
      'status': _statusToApi(attendance.status),
      'lesson': attendance.lesson,
    });
    return _mapJsonToAttendance(response.data as Map<String, dynamic>, attendance.markazId);
  }

  Future<void> deleteAttendance(String attendanceId) async {
    await _dio.delete('/attendances/$attendanceId');
  }

  Future<List<Attendance>> getAttendanceByMarkaz(String markazId) async {
    final response = await _dio.get('/attendances', queryParameters: {'per_page': 500});
    final data = (response.data as Map<String, dynamic>)['data'] as List<dynamic>;
    return data
        .map((json) => _mapJsonToAttendance(json as Map<String, dynamic>, markazId))
        .toList();
  }

  String _statusToApi(AttendanceStatus status) {
    switch (status) {
      case AttendanceStatus.present:
        return 'present';
      case AttendanceStatus.absent:
        return 'absent';
      case AttendanceStatus.late:
        return 'late';
    }
  }

  AttendanceStatus _statusFromApi(String? status) {
    switch (status) {
      case 'present':
        return AttendanceStatus.present;
      case 'late':
        return AttendanceStatus.late;
      case 'absent':
      case 'justified':
      default:
        return AttendanceStatus.absent;
    }
  }

  Attendance _mapJsonToAttendance(Map<String, dynamic> json, String markazId) {
    return Attendance(
      id: json['id'].toString(),
      studentId: json['student_id'].toString(),
      markazId: markazId,
      date: DateTime.parse(json['date'] as String),
      status: _statusFromApi(json['status'] as String?),
      lesson: json['lesson'] as String? ?? '',
    );
  }
}
