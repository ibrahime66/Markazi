import 'package:hive_flutter/hive_flutter.dart';
import '../models/student.dart';

/// Hive data source for Student entities.
class HiveStudentDataSource {
  static const String _boxName = 'students';
  late Box<Student> _box;

  /// Initialise la boîte Hive.
  Future<void> init() async {
    _box = await Hive.openBox<Student>(_boxName);
  }

  /// Ajoute un étudiant.
  Future<void> addStudent(Student student) async {
    await _box.put(student.id, student);
  }

  /// Met à jour un étudiant.
  Future<void> updateStudent(Student student) async {
    await _box.put(student.id, student);
  }

  /// Supprime un étudiant par ID.
  Future<void> deleteStudent(String id) async {
    await _box.delete(id);
  }

  /// Récupère un étudiant par ID.
  Student? getStudentById(String id) {
    return _box.get(id);
  }

  /// Récupère tous les étudiants.
  List<Student> getAllStudents() {
    return _box.values.toList();
  }

  /// Récupère tous les étudiants d'une markaz.
  List<Student> getStudentsByMarkaz(String markazId) {
    return _box.values.where((student) => student.markazId == markazId).toList();
  }

  /// Retourne le nombre total d'étudiants.
  int getTotalStudents() => _box.length;

  /// Retourne le nombre d'étudiants dans une markaz.
  int getStudentCountByMarkaz(String markazId) =>
      _box.values.where((student) => student.markazId == markazId).length;

  /// Efface tous les étudiants.
  Future<void> clearAll() async {
    await _box.clear();
  }

  /// Ferme la boîte Hive.
  Future<void> close() async {
    await _box.close();
  }
}