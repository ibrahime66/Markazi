import '../models/class_model.dart';
import '../services/api_client.dart';

/// Datasource API (Laravel/MySQL) pour les classes — remplace l'ancien
/// FirebaseClassDatasource.
///
/// Différence de modélisation avec l'ancien schéma Firestore : côté API, la
/// composition d'une classe n'est pas stockée comme une liste `studentIds`
/// sur la classe, mais normalisée via `students.class_id` (schéma relationnel
/// classique, conforme au CDC section 18). Cette classe reconstitue donc
/// `studentIds` en croisant `/classes` et `/students`, pour ne pas changer la
/// forme du modèle Flutter ni l'UI qui en dépend.
class ApiClassDatasource {
  final _dio = ApiClient.instance.dio;

  Future<ClassModel> addClass(ClassModel classModel, String markazId) async {
    final response =
        await _dio.post('/classes', data: _toRequestBody(classModel));
    return _mapJsonToClass(
        response.data as Map<String, dynamic>, markazId, const []);
  }

  /// [performedAt] : date réelle d'une saisie hors ligne rejouée (CDC §27).
  Future<ClassModel> updateClass(ClassModel classModel,
      {DateTime? performedAt}) async {
    final response = await _dio.put(
      '/classes/${classModel.id}',
      options: ApiClient.performedAtOptions(performedAt),
      data: _toRequestBody(classModel),
    );
    return _mapJsonToClass(
      response.data as Map<String, dynamic>,
      classModel.markazId,
      classModel.studentIds,
    );
  }

  Future<void> deleteClass(String classId, {DateTime? performedAt}) async {
    await _dio.delete('/classes/$classId',
        options: ApiClient.performedAtOptions(performedAt));
  }

  Future<List<ClassModel>> getClassesByMarkaz(String markazId) async {
    final classesResponse =
        await _dio.get('/classes', queryParameters: {'per_page': 200});
    final studentsByClass = await _fetchStudentIdsByClass();

    final data =
        (classesResponse.data as Map<String, dynamic>)['data'] as List<dynamic>;
    return data.map((json) {
      final map = json as Map<String, dynamic>;
      final classId = map['id'].toString();
      return _mapJsonToClass(
          map, markazId, studentsByClass[classId] ?? const []);
    }).toList();
  }

  /// Affecte un élève à une classe (met à jour `students.class_id` côté API).
  Future<void> addStudentToClass(String classId, String studentId) async {
    await _dio
        .put('/students/$studentId', data: {'class_id': int.parse(classId)});
  }

  /// Retire un élève de sa classe.
  Future<void> removeStudentFromClass(String classId, String studentId) async {
    await _dio.put('/students/$studentId', data: {'class_id': null});
  }

  /// Rejoue l'affectation d'un élève faite hors ligne : [classId] est le
  /// groupe cible, `null` pour "aucun groupe" (CDC §20, doc/audit.md F5).
  Future<void> setStudentClass(
    String studentId,
    String? classId, {
    DateTime? performedAt,
  }) async {
    await _dio.put(
      '/students/$studentId',
      options: ApiClient.performedAtOptions(performedAt),
      data: {'class_id': classId == null ? null : int.parse(classId)},
    );
  }

  Future<Map<String, List<String>>> _fetchStudentIdsByClass() async {
    final response =
        await _dio.get('/students', queryParameters: {'per_page': 500});
    final data =
        (response.data as Map<String, dynamic>)['data'] as List<dynamic>;

    final result = <String, List<String>>{};
    for (final json in data) {
      final map = json as Map<String, dynamic>;
      final classId = map['class_id'];
      if (classId == null) continue;
      result
          .putIfAbsent(classId.toString(), () => [])
          .add(map['id'].toString());
    }
    return result;
  }

  Map<String, dynamic> _toRequestBody(ClassModel classModel) {
    return {
      'name': classModel.name,
      'level': classModel.level,
      'description': classModel.description,
      'teacher_name': classModel.teacherName,
      'max_students': classModel.maxStudents,
      'schedule': classModel.schedule,
      'room': classModel.room,
      'is_active': classModel.isActive,
    };
  }

  ClassModel _mapJsonToClass(
    Map<String, dynamic> json,
    String markazId,
    List<String> studentIds,
  ) {
    return ClassModel(
      id: json['id'].toString(),
      name: json['name'] as String? ?? '',
      level: json['level'] as String? ?? '',
      description: json['description'] as String? ?? '',
      teacherId: json['teacher_id']?.toString() ?? '',
      // H5 : nom saisi librement (`teacher_name`), sinon nom du compte lié.
      teacherName: json['teacher_name'] as String? ??
          json['teacher']?['name'] as String? ??
          '',
      maxStudents: json['max_students'] as int? ?? 20,
      studentIds: studentIds,
      markazId: markazId,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      isActive: json['is_active'] as bool? ?? true,
      schedule: json['schedule'] as String?,
      room: json['room'] as String?,
    );
  }
}
