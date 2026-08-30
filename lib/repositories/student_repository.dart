import 'package:flutter/foundation.dart';
import '../models/student.dart';
import '../datasources/hive_student_datasource.dart';
import '../datasources/api_student_datasource.dart';

/// Repository pour la gestion des données Student.
/// Utilise l'API Laravel avec cache Hive local pour mode hors ligne (CDC section 20).
///
/// La création est "API-first" : contrairement à l'ancien schéma Firestore,
/// l'identifiant est attribué par le serveur (clé primaire MySQL) et ne peut
/// pas être choisi côté client. Une création requiert donc une connexion ;
/// les modifications restent tolérantes au mode hors ligne (cache local
/// mis à jour immédiatement, synchronisation best-effort en arrière-plan).
class StudentRepository {
  final HiveStudentDataSource _hiveDataSource;
  final ApiStudentDatasource _apiDataSource;

  StudentRepository(this._hiveDataSource, this._apiDataSource);

  /// Initialise le repository et ouvre la box Hive via le data source.
  Future<void> init() async {
    await _hiveDataSource.init();
  }

  /// Ajoute un nouvel élève. Retourne l'élève tel que persisté côté serveur
  /// (avec son identifiant réel), qui est aussi celui mis en cache local.
  Future<Student> addStudent(Student student) async {
    final saved = await _apiDataSource.addStudent(student, student.markazId);
    await _hiveDataSource.addStudent(saved);
    return saved;
  }

  /// Supprime un élève par ID.
  Future<void> removeStudent(String studentId) async {
    await _hiveDataSource.deleteStudent(studentId);
    try {
      await _apiDataSource.deleteStudent(studentId);
    } catch (e) {
      debugPrint('Erreur sync API (suppression élève) : $e');
    }
  }

  /// Met à jour un élève.
  Future<void> updateStudent(Student student) async {
    await _hiveDataSource.updateStudent(student);
    try {
      final saved = await _apiDataSource.updateStudent(student, student.markazId);
      await _hiveDataSource.updateStudent(saved);
    } catch (e) {
      debugPrint('Erreur sync API (mise à jour élève) : $e');
    }
  }

  /// Rattache (ou détache si [guardianId] est null) un élève à un tuteur
  /// (doc/audit.md, point I5). Comme pour l'affectation à un groupe, c'est
  /// une modification légère : on renvoie la version serveur (avec le
  /// lien à jour) et on met à jour le cache local en conséquence.
  Future<Student> setGuardian(String studentId, String? guardianId) async {
    final saved = await _apiDataSource.setGuardian(studentId, guardianId);
    await _hiveDataSource.updateStudent(saved);
    return saved;
  }

  /// Récupère un élève par ID.
  Student? getStudentById(String studentId) {
    return _hiveDataSource.getStudentById(studentId);
  }

  /// Récupère tous les élèves.
  List<Student> getAllStudents() {
    return _hiveDataSource.getAllStudents();
  }

  /// Récupère tous les élèves d'une Markaz.
  List<Student> getStudentsByMarkaz(String markazId) {
    return _hiveDataSource.getStudentsByMarkaz(markazId);
  }

  /// Retourne le nombre total d'élèves.
  int getTotalStudents() {
    return _hiveDataSource.getTotalStudents();
  }

  /// Retourne le nombre d'élèves dans une Markaz.
  int getStudentCountByMarkaz(String markazId) {
    return _hiveDataSource.getStudentCountByMarkaz(markazId);
  }

  /// Efface tous les élèves (utile pour les tests).
  Future<void> clearAll() async {
    await _hiveDataSource.clearAll();
  }

  /// Ferme la box (utile à l'arrêt de l'app).
  Future<void> close() async {
    await _hiveDataSource.close();
  }

  /// Recharge le cache local depuis l'API pour la Markaz donnée
  /// (à appeler après connexion, CDC section 20).
  Future<void> syncFromMarkaz(String markazId) async {
    try {
      final students = await _apiDataSource.getStudentsByMarkaz(markazId);
      await _hiveDataSource.clearAll();
      for (final student in students) {
        await _hiveDataSource.addStudent(student);
      }
    } catch (e) {
      debugPrint('Erreur sync API (élèves) : $e');
    }
  }
}
