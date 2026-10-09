import 'package:flutter/foundation.dart';
import '../models/class_model.dart';
import '../datasources/hive_class_datasource.dart';
import '../datasources/api_class_datasource.dart';
import '../models/sync_queue_item.dart';
import '../services/api_client.dart';
import '../services/sync_queue_service.dart';

/// Repository pour la gestion des données des classes.
/// Utilise l'API Laravel avec cache Hive local pour mode hors ligne.
class ClassRepository {
  final HiveClassDataSource _hiveDataSource;
  final ApiClassDatasource _apiDataSource;
  final SyncQueueService _syncQueue;

  ClassRepository(this._hiveDataSource, this._apiDataSource, this._syncQueue);

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

  /// Supprime (archive) une classe. Serveur injoignable : mise en file
  /// (CDC §20, doc/audit.md F5) ; refus du serveur : la classe est restaurée
  /// localement et l'erreur remonte (auparavant avalée en silence).
  Future<void> removeClass(String classId) async {
    final previous = _hiveDataSource.getClassById(classId);
    await _hiveDataSource.deleteClass(classId);
    try {
      await _apiDataSource.deleteClass(classId);
      await _syncQueue.resolve(SyncEntityType.classModel, classId);
    } catch (e, st) {
      if (!ApiClient.isOfflineError(e)) {
        if (previous != null) await _hiveDataSource.addClass(previous);
        ApiClient.throwReadable(e, st);
      }
      debugPrint('Hors ligne : suppression de groupe mise en file ($e)');
      await _syncQueue.enqueue(
        entityType: SyncEntityType.classModel,
        operation: SyncOperation.delete,
        entityId: classId,
      );
    }
  }

  /// Met à jour une classe (même règle que [removeClass]).
  Future<void> updateClass(ClassModel classModel) async {
    final previous = _hiveDataSource.getClassById(classModel.id);
    await _hiveDataSource.updateClass(classModel);
    try {
      final saved = await _apiDataSource.updateClass(classModel);
      await _hiveDataSource.updateClass(saved);
      await _syncQueue.resolve(SyncEntityType.classModel, classModel.id);
    } catch (e, st) {
      if (!ApiClient.isOfflineError(e)) {
        if (previous != null) await _hiveDataSource.updateClass(previous);
        ApiClient.throwReadable(e, st);
      }
      debugPrint('Hors ligne : mise à jour de groupe mise en file ($e)');
      await _syncQueue.enqueue(
        entityType: SyncEntityType.classModel,
        operation: SyncOperation.update,
        entityId: classModel.id,
      );
    }
  }

  /// Rejoue une mise à jour de groupe — réservé à SyncOrchestrator.
  Future<void> retrySyncUpdate(String classId, DateTime performedAt) async {
    final classModel = _hiveDataSource.getClassById(classId);
    if (classModel == null) return;
    final saved = await _apiDataSource.updateClass(classModel, performedAt: performedAt);
    await _hiveDataSource.updateClass(saved);
  }

  /// Rejoue une suppression de groupe — réservé à SyncOrchestrator.
  Future<void> retrySyncDelete(String classId, DateTime performedAt) async {
    await _apiDataSource.deleteClass(classId, performedAt: performedAt);
  }

  /// Rejoue une affectation d'élève faite hors ligne — réservé à
  /// SyncOrchestrator. [targetClassId] vide = retiré de tout groupe.
  Future<void> retrySyncStudentClass(
    String studentId,
    String targetClassId,
    DateTime performedAt,
  ) async {
    await _apiDataSource.setStudentClass(
      studentId,
      targetClassId.isEmpty ? null : targetClassId,
      performedAt: performedAt,
    );
  }

  /// Résumé lisible pour l'écran "Synchronisation".
  String? describe(String classId) {
    return _hiveDataSource.getClassById(classId)?.name;
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

  /// Ajoute un élève à une classe.
  ///
  /// `class_id` est la seule source de vérité côté serveur (voir
  /// `ApiClassDatasource`). Un refus du serveur annule la mise à jour locale
  /// et relance l'erreur (doc/audit.md K1 : sinon l'élève semblait affecté
  /// puis disparaissait au rechargement). Serveur injoignable : l'affectation
  /// est mise en file avec le groupe cible (CDC §20) et préservée au
  /// rechargement jusqu'à son envoi.
  Future<void> addStudentToClass(String classId, String studentId) async {
    await _hiveDataSource.addStudentToClass(classId, studentId);
    try {
      await _apiDataSource.addStudentToClass(classId, studentId);
      await _syncQueue.resolve(SyncEntityType.studentClass, studentId);
    } catch (e, st) {
      if (!ApiClient.isOfflineError(e)) {
        debugPrint('Erreur sync API (affectation élève) : $e');
        await _hiveDataSource.removeStudentFromClass(classId, studentId);
        ApiClient.throwReadable(e, st);
      }
      debugPrint('Hors ligne : affectation d\'élève mise en file ($e)');
      await _syncQueue.enqueue(
        entityType: SyncEntityType.studentClass,
        operation: SyncOperation.update,
        entityId: studentId,
        payload: classId,
      );
    }
    // Côté serveur, un élève n'appartient qu'à un groupe : l'affecter ici
    // le retire de son ancien groupe.
    await _removeFromOtherClasses(studentId, keepClassId: classId);
  }

  /// Retire un élève d'une classe (voir note sur `addStudentToClass`).
  Future<void> removeStudentFromClass(String classId, String studentId) async {
    final previous = _hiveDataSource.getClassById(classId);
    await _hiveDataSource.removeStudentFromClass(classId, studentId);
    try {
      await _apiDataSource.removeStudentFromClass(classId, studentId);
      await _syncQueue.resolve(SyncEntityType.studentClass, studentId);
    } catch (e, st) {
      if (!ApiClient.isOfflineError(e)) {
        debugPrint('Erreur sync API (retrait élève) : $e');
        if (previous != null) {
          await _hiveDataSource.addStudentToClass(classId, studentId);
        }
        ApiClient.throwReadable(e, st);
      }
      debugPrint('Hors ligne : retrait d\'élève mis en file ($e)');
      await _syncQueue.enqueue(
        entityType: SyncEntityType.studentClass,
        operation: SyncOperation.update,
        entityId: studentId,
        payload: '',
      );
    }
  }

  Future<void> _removeFromOtherClasses(String studentId, {String? keepClassId}) async {
    for (final other in _hiveDataSource.getAllClasses()) {
      if (other.id != keepClassId && other.studentIds.contains(studentId)) {
        await _hiveDataSource.removeStudentFromClass(other.id, studentId);
      }
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

  /// Recharge le cache local depuis l'API pour la Markaz donnée, sans
  /// écraser les saisies locales encore en attente de synchronisation
  /// (CDC §20) : groupes modifiés/supprimés et affectations d'élèves.
  Future<void> syncFromMarkaz(String markazId) async {
    try {
      final classes = await _apiDataSource.getClassesByMarkaz(markazId);
      final pendingIds = _syncQueue.pendingIds(SyncEntityType.classModel);
      final pendingLocal = pendingIds
          .map(_hiveDataSource.getClassById)
          .whereType<ClassModel>()
          .toList();
      await _hiveDataSource.clearAll();
      for (final classModel in classes) {
        if (pendingIds.contains(classModel.id)) continue;
        await _hiveDataSource.addClass(classModel);
      }
      for (final classModel in pendingLocal) {
        await _hiveDataSource.addClass(classModel);
      }

      // Affectations d'élèves pas encore envoyées : réappliquées par-dessus
      // la composition serveur.
      for (final item in _syncQueue.getAll()) {
        if (item.entityType != SyncEntityType.studentClass) continue;
        final target = item.payload ?? '';
        await _removeFromOtherClasses(item.entityId, keepClassId: target);
        if (target.isNotEmpty && _hiveDataSource.getClassById(target) != null) {
          await _hiveDataSource.addStudentToClass(target, item.entityId);
        }
      }
    } catch (e) {
      debugPrint('Erreur sync API (classes) : $e');
    }
  }
}
