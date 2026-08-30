import 'package:flutter/foundation.dart';
import '../models/class_model.dart';
import '../datasources/hive_class_datasource.dart';
import '../datasources/api_class_datasource.dart';

/// Repository pour la gestion des données des classes.
/// Utilise l'API Laravel avec cache Hive local pour mode hors ligne.
class ClassRepository {
  final HiveClassDataSource _hiveDataSource;
  final ApiClassDatasource _apiDataSource;

  ClassRepository(this._hiveDataSource, this._apiDataSource);

  /// Initialise le repository et ouvre la box Hive via le data source
  Future<void> init() async {
    await _hiveDataSource.init();
  }

  /// Ajoute une nouvelle classe. Retourne la classe telle que persistée
  /// côté serveur (avec son identifiant réel).
  Future<ClassModel> addClass(ClassModel classModel) async {
    final saved = await _apiDataSource.addClass(classModel, classModel.markazId);
    await _hiveDataSource.addClass(saved);
    return saved;
  }

  /// Supprime une classe par ID
  Future<void> removeClass(String classId) async {
    await _hiveDataSource.deleteClass(classId);
    try {
      await _apiDataSource.deleteClass(classId);
    } catch (e) {
      debugPrint('Erreur sync API (suppression classe) : $e');
    }
  }

  /// Met à jour une classe
  Future<void> updateClass(ClassModel classModel) async {
    await _hiveDataSource.updateClass(classModel);
    try {
      final saved = await _apiDataSource.updateClass(classModel);
      await _hiveDataSource.updateClass(saved);
    } catch (e) {
      debugPrint('Erreur sync API (mise à jour classe) : $e');
    }
  }

  /// Récupère une classe par ID
  ClassModel? getClassById(String classId) {
    return _hiveDataSource.getClassById(classId);
  }

  /// Récupère toutes les classes
  List<ClassModel> getAllClasses() {
    return _hiveDataSource.getAllClasses();
  }

  /// Récupère toutes les classes d'une Markaz
  List<ClassModel> getClassesByMarkaz(String markazId) {
    return _hiveDataSource.getClassesByMarkaz(markazId);
  }

  /// Récupère les classes actives d'une Markaz
  List<ClassModel> getActiveClassesByMarkaz(String markazId) {
    return _hiveDataSource.getActiveClassesByMarkaz(markazId);
  }

  /// Récupère les classes par niveau
  List<ClassModel> getClassesByLevel(String markazId, String level) {
    return _hiveDataSource.getClassesByLevel(markazId, level);
  }

  /// Ajoute un élève à une classe
  Future<void> addStudentToClass(String classId, String studentId) async {
    await _hiveDataSource.addStudentToClass(classId, studentId);
    try {
      await _apiDataSource.addStudentToClass(classId, studentId);
    } catch (e) {
      debugPrint('Erreur sync API (affectation élève) : $e');
    }
  }

  /// Retire un élève d'une classe
  Future<void> removeStudentFromClass(String classId, String studentId) async {
    await _hiveDataSource.removeStudentFromClass(classId, studentId);
    try {
      await _apiDataSource.removeStudentFromClass(classId, studentId);
    } catch (e) {
      debugPrint('Erreur sync API (retrait élève) : $e');
    }
  }

  /// Récupère les classes disponibles (non pleines)
  List<ClassModel> getAvailableClasses(String markazId) {
    return _hiveDataSource.getAvailableClasses(markazId);
  }

  /// Statistiques sur les classes
  Map<String, dynamic> getClassStatistics(String markazId) {
    final classes = _hiveDataSource.getClassesByMarkaz(markazId);
    final activeClasses = classes.where((c) => c.isActive).toList();

    final totalStudents = activeClasses.fold<int>(
      0, (sum, classModel) => sum + classModel.currentStudentCount
    );

    final totalCapacity = activeClasses.fold<int>(
      0, (sum, classModel) => sum + classModel.maxStudents
    );

    final classesByLevel = <String, List<ClassModel>>{};
    for (final classModel in activeClasses) {
      classesByLevel.putIfAbsent(classModel.level, () => []).add(classModel);
    }

    return {
      'totalClasses': classes.length,
      'activeClasses': activeClasses.length,
      'totalStudents': totalStudents,
      'totalCapacity': totalCapacity,
      'occupancyRate': totalCapacity > 0
          ? ((totalStudents / totalCapacity) * 100).toStringAsFixed(1)
          : '0.0',
      'classesByLevel': classesByLevel.map((level, classes) =>
          MapEntry(level, classes.length)),
      'availablePlaces': totalCapacity - totalStudents,
    };
  }

  /// Efface toutes les classes (utile pour les tests)
  Future<void> clearAll() async {
    await _hiveDataSource.clearAll();
  }

  /// Ferme la box (utile à l'arrêt de l'app)
  Future<void> close() async {
    await _hiveDataSource.close();
  }

  /// Recharge le cache local depuis l'API pour la Markaz donnée.
  Future<void> syncFromMarkaz(String markazId) async {
    try {
      final classes = await _apiDataSource.getClassesByMarkaz(markazId);
      await _hiveDataSource.clearAll();
      for (final classModel in classes) {
        await _hiveDataSource.addClass(classModel);
      }
    } catch (e) {
      debugPrint('Erreur sync API (classes) : $e');
    }
  }
}
