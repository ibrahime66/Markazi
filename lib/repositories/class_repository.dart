import '../models/class_model.dart';
import '../datasources/hive_class_datasource.dart';
import '../datasources/firebase_class_datasource.dart';
import '../services/firebase_helper.dart';

/// Repository pour la gestion des données des classes
/// Utilise Firebase avec cache Hive local pour mode hors ligne
class ClassRepository {
  final HiveClassDataSource _hiveDataSource;
  final FirebaseClassDataSource _firebaseDataSource;

  ClassRepository(this._hiveDataSource, this._firebaseDataSource);

  /// Initialise le repository et ouvre la box Hive via le data source
  Future<void> init() async {
    await _hiveDataSource.init();

    // Synchroniser depuis Firebase au démarrage si disponible
    if (FirebaseHelper.isAvailable) {
      await Future.delayed(const Duration(seconds: 1));
      await _syncFromFirebase();
    }
  }

  /// Ajoute une nouvelle classe
  Future<void> addClass(ClassModel classModel) async {
    // Sauvegarder localement d'abord (cache)
    await _hiveDataSource.addClass(classModel);

    // Synchroniser avec Firebase si disponible
    if (FirebaseHelper.isAvailable) {
      try {
        await _firebaseDataSource.addClass(classModel, classModel.markazId);
      } catch (e) {
        print('Erreur sync Firebase class: $e');
      }
    }
  }

  /// Supprime une classe par ID
  Future<void> removeClass(String classId) async {
    // Supprimer localement
    await _hiveDataSource.deleteClass(classId);

    // Synchroniser avec Firebase si disponible
    if (FirebaseHelper.isAvailable) {
      try {
        await _firebaseDataSource.deleteClass(classId);
      } catch (e) {
        print('Erreur sync Firebase class: $e');
      }
    }
  }

  /// Met à jour une classe
  Future<void> updateClass(ClassModel classModel) async {
    // Mettre à jour localement
    await _hiveDataSource.updateClass(classModel);

    // Synchroniser avec Firebase si disponible
    if (FirebaseHelper.isAvailable) {
      try {
        await _firebaseDataSource.updateClass(classModel);
      } catch (e) {
        print('Erreur sync Firebase class: $e');
      }
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
    // Synchroniser avec Firebase si disponible
    if (FirebaseHelper.isAvailable) {
      try {
        final updated = await _hiveDataSource.getClassById(classId);
        if (updated != null) {
          await _firebaseDataSource.updateClass(updated);
        }
      } catch (e) {
        print('Erreur sync Firebase class: $e');
      }
    }
  }

  /// Retire un élève d'une classe
  Future<void> removeStudentFromClass(String classId, String studentId) async {
    await _hiveDataSource.removeStudentFromClass(classId, studentId);
    // Synchroniser avec Firebase si disponible
    if (FirebaseHelper.isAvailable) {
      try {
        final updated = await _hiveDataSource.getClassById(classId);
        if (updated != null) {
          await _firebaseDataSource.updateClass(updated);
        }
      } catch (e) {
        print('Erreur sync Firebase class: $e');
      }
    }
  }

  /// Récupère les classes disponibles (non pleines)
  List<ClassModel> getAvailableClasses(String markazId) {
    return _hiveDataSource.getAvailableClasses(markazId);
  }

  /// Statistiques sur les classes
  Map<String, dynamic> getClassStatistics(String markazId) {
    // Delegate to hive data source for collections, then compute statistics.
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

  /// Synchronise les données depuis Firebase vers le cache local
  Future<void> _syncFromFirebase({String? markazId}) async {
    try {
      if (markazId != null) {
        // Récupérer les classes de cette markaz depuis Firebase
        final firebaseClasses = await _firebaseDataSource.getClassesByMarkaz(markazId);

        // Vider le cache local et mettre à jour avec les données Firebase
        await _hiveDataSource.clearAll();
        for (final classModel in firebaseClasses) {
          await _hiveDataSource.addClass(classModel);
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