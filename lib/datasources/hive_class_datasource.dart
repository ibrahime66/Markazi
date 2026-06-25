import 'package:hive/hive.dart';
import '../models/class_model.dart';

/// Hive data source for ClassModel entities.
class HiveClassDataSource {
  static const String _boxName = 'classes';
  late Box<ClassModel> _box;

  /// Initialise la boîte Hive.
  Future<void> init() async {
    _box = await Hive.openBox<ClassModel>(_boxName);
  }

  /// Ajoute une classe.
  Future<void> addClass(ClassModel classModel) async {
    await _box.put(classModel.id, classModel);
  }

  /// Met à jour une classe.
  Future<void> updateClass(ClassModel classModel) async {
    await _box.put(classModel.id, classModel);
  }

  /// Supprime une classe par ID.
  Future<void> deleteClass(String id) async {
    await _box.delete(id);
  }

  /// Récupère une classe par ID.
  ClassModel? getClassById(String id) {
    return _box.get(id);
  }

  /// Récupère toutes les classes.
  List<ClassModel> getAllClasses() {
    return _box.values.toList();
  }

  /// Récupère les classes d'une markaz.
  List<ClassModel> getClassesByMarkaz(String markazId) {
    return _box.values.where((c) => c.markazId == markazId).toList();
  }

  /// Récupère les classes actives d'une markaz.
  List<ClassModel> getActiveClassesByMarkaz(String markazId) {
    return _box.values
        .where((c) => c.markazId == markazId && c.isActive)
        .toList();
  }

  /// Récupère les classes par niveau et markaz.
  List<ClassModel> getClassesByLevel(String markazId, String level) {
    return _box.values
        .where((c) =>
            c.markazId == markazId && c.level == level && c.isActive)
        .toList();
  }

  /// Ajoute un élève à une classe (retourne la classe mise à jour).
  Future<ClassModel> addStudentToClass(String classId, String studentId) async {
    final classModel = _box.get(classId);
    if (classModel != null) {
      final updated = classModel.addStudent(studentId);
      await _box.put(classId, updated);
      return updated;
    }
    throw Exception('Classe non trouvée');
  }

  /// Retire un élève d'une classe (retourne la classe mise à jour).
  Future<ClassModel> removeStudentFromClass(String classId, String studentId) async {
    final classModel = _box.get(classId);
    if (classModel != null) {
      final updated = classModel.removeStudent(studentId);
      await _box.put(classId, updated);
      return updated;
    }
    throw Exception('Classe non trouvée');
  }

  /// Récupère les classes disponibles (non pleines) pour une markaz.
  List<ClassModel> getAvailableClasses(String markazId) {
    return _box.values
        .where((c) =>
            c.markazId == markazId &&
            !c.isFull &&
            c.isActive)
        .toList();
  }

  /// Efface toutes les classes.
  Future<void> clearAll() async {
    await _box.clear();
  }

  /// Ferme la boîte.
  Future<void> close() async {
    await _box.close();
  }
}