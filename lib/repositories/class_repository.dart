import 'package:hive_flutter/hive_flutter.dart';
import '../models/class_model.dart';
import '../datasources/firebase_class_datasource.dart';
import '../services/firebase_helper.dart';

/// Repository pour la gestion des données des classes
/// Utilise Firebase avec cache Hive local pour mode hors ligne
class ClassRepository {
  static const String _boxName = 'classes';
  late Box<ClassModel> _box;
  final FirebaseClassDatasource _firebaseDatasource = FirebaseClassDatasource();

  /// Initialise le repository et ouvre la box Hive
  Future<void> init() async {
    _box = await Hive.openBox<ClassModel>(_boxName);
    
    // Synchroniser depuis Firebase au démarrage si disponible
    if (FirebaseHelper.isAvailable) {
      await Future.delayed(const Duration(seconds: 1));
      await _syncFromFirebase();
    }
  }

  /// Ajoute une nouvelle classe
  Future<void> addClass(ClassModel classModel) async {
    // Sauvegarder localement d'abord (cache)
    await _box.put(classModel.id, classModel);
    
    // Synchroniser avec Firebase si disponible
    if (FirebaseHelper.isAvailable) {
      try {
        await _firebaseDatasource.addClass(classModel, classModel.markazId);
      } catch (e) {
        print('Erreur sync Firebase class: $e');
      }
    }
  }

  /// Supprime une classe par ID
  Future<void> removeClass(String classId) async {
    // Supprimer localement
    await _box.delete(classId);
    
    // Synchroniser avec Firebase si disponible
    if (FirebaseHelper.isAvailable) {
      try {
        await _firebaseDatasource.deleteClass(classId);
      } catch (e) {
        print('Erreur sync Firebase class: $e');
      }
    }
  }

  /// Met à jour une classe
  Future<void> updateClass(ClassModel classModel) async {
    // Mettre à jour localement
    await _box.put(classModel.id, classModel);
    
    // Synchroniser avec Firebase si disponible
    if (FirebaseHelper.isAvailable) {
      try {
        await _firebaseDatasource.updateClass(classModel);
      } catch (e) {
        print('Erreur sync Firebase class: $e');
      }
    }
  }

  /// Récupère une classe par ID
  ClassModel? getClassById(String classId) {
    return _box.get(classId);
  }

  /// Récupère toutes les classes
  List<ClassModel> getAllClasses() {
    return _box.values.toList();
  }

  /// Récupère toutes les classes d'une Markaz
  List<ClassModel> getClassesByMarkaz(String markazId) {
    return _box.values
        .where((classModel) => classModel.markazId == markazId)
        .toList();
  }

  /// Récupère les classes actives d'une Markaz
  List<ClassModel> getActiveClassesByMarkaz(String markazId) {
    return _box.values
        .where((classModel) => 
            classModel.markazId == markazId && classModel.isActive)
        .toList();
  }

  /// Récupère les classes par niveau
  List<ClassModel> getClassesByLevel(String markazId, String level) {
    return _box.values
        .where((classModel) => 
            classModel.markazId == markazId && 
            classModel.level == level &&
            classModel.isActive)
        .toList();
  }

  /// Ajoute un élève à une classe
  Future<void> addStudentToClass(String classId, String studentId) async {
    final classModel = getClassById(classId);
    if (classModel != null) {
      final updatedClass = classModel.addStudent(studentId);
      await updateClass(updatedClass);
    }
  }

  /// Retire un élève d'une classe
  Future<void> removeStudentFromClass(String classId, String studentId) async {
    final classModel = getClassById(classId);
    if (classModel != null) {
      final updatedClass = classModel.removeStudent(studentId);
      await updateClass(updatedClass);
    }
  }

  /// Récupère les classes disponibles (non pleines)
  List<ClassModel> getAvailableClasses(String markazId) {
    return _box.values
        .where((classModel) => 
            classModel.markazId == markazId && 
            classModel.isActive && 
            !classModel.isFull)
        .toList();
  }

  /// Statistiques sur les classes
  Map<String, dynamic> getClassStatistics(String markazId) {
    final classes = getClassesByMarkaz(markazId);
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
    await _box.clear();
  }

  /// Ferme la box (utile à l'arrêt de l'app)
  Future<void> close() async {
    await _box.close();
  }

  /// Synchronise les données depuis Firebase vers le cache local
  Future<void> _syncFromFirebase({String? markazId}) async {
    try {
      if (markazId != null) {
        // Récupérer les classes de cette markaz depuis Firebase
        final firebaseClasses = await _firebaseDatasource.getClassesByMarkaz(markazId);
        
        // Vider le cache local et mettre à jour avec les données Firebase
        await _box.clear();
        for (final classModel in firebaseClasses) {
          await _box.put(classModel.id, classModel);
        }
        
        print('Sync Firebase: ${firebaseClasses.length} classes synchronisées pour markaz $markazId');
      } else {
        print('Sync Firebase: markazId non spécifié, sync ignorée');
      }
    } catch (e) {
      print('Erreur sync classes depuis Firebase: $e');
    }
  }

  /// Force la synchronisation depuis Firebase pour une markaz spécifique
  Future<void> syncFromMarkaz(String markazId) async {
    await _syncFromFirebase(markazId: markazId);
  }
}
