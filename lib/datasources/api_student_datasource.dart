import '../models/student.dart';
import '../services/api_client.dart';

/// Datasource API (Laravel/MySQL) pour les élèves — remplace l'ancien
/// FirebaseStudentDatasource. L'identifiant réel (clé primaire auto-
/// incrémentée) est toujours attribué par le serveur : les méthodes de
/// création/mise à jour renvoient l'entité telle que persistée côté API.
class ApiStudentDatasource {
  final _dio = ApiClient.instance.dio;

  Future<Student> addStudent(Student student, String markazId) async {
    final response = await _dio.post('/students', data: {
      'name': student.name,
      'parent_phone': student.parentPhone,
      if (student.guardianId != null) 'guardian_id': int.parse(student.guardianId!),
    });
    return _mapJsonToStudent(response.data as Map<String, dynamic>, markazId);
  }

  Future<Student> updateStudent(Student student, String markazId) async {
    final response = await _dio.put('/students/${student.id}', data: {
      'name': student.name,
      'parent_phone': student.parentPhone,
    });
    return _mapJsonToStudent(response.data as Map<String, dynamic>, markazId);
  }

  Future<void> deleteStudent(String studentId) async {
    await _dio.delete('/students/$studentId');
  }

  /// Rattache (ou détache si [guardianId] est null) un élève à un tuteur —
  /// même schéma que l'affectation à un groupe (`class_id`) : une
  /// modification ciblée d'un seul champ plutôt qu'une mise à jour
  /// complète du profil (doc/audit.md, point I5).
  Future<Student> setGuardian(String studentId, String? guardianId) async {
    final response = await _dio.put('/students/$studentId', data: {
      'guardian_id': guardianId != null ? int.parse(guardianId) : null,
    });
    // markazId n'est pas renvoyé par l'API (dérivé de l'utilisateur
    // connecté côté serveur) ; on le déduit de l'élève courant côté appelant.
    return _mapJsonToStudent(
      response.data as Map<String, dynamic>,
      response.data['markaz_id']?.toString() ?? '',
    );
  }

  Future<List<Student>> getStudentsByMarkaz(String markazId) async {
    final response = await _dio.get('/students', queryParameters: {'per_page': 500});
    final data = (response.data as Map<String, dynamic>)['data'] as List<dynamic>;
    return data
        .map((json) => _mapJsonToStudent(json as Map<String, dynamic>, markazId))
        .toList();
  }

  Student _mapJsonToStudent(Map<String, dynamic> json, String markazId) {
    return Student(
      id: json['id'].toString(),
      name: json['name'] as String? ?? '',
      parentPhone: json['parent_phone'] as String? ?? '',
      markazId: markazId,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      guardianId: json['guardian_id']?.toString(),
    );
  }
}
