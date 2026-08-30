import 'package:flutter/foundation.dart';
import '../models/recitation.dart';
import '../models/sync_queue_item.dart';
import '../datasources/hive_recitation_datasource.dart';
import '../datasources/api_recitation_datasource.dart';
import '../services/sync_queue_service.dart';

/// Repository pour la gestion des données Recitation.
/// Utilise l'API Laravel avec cache Hive local pour mode hors ligne.
class RecitationRepository {
  final HiveRecitationDataSource _hiveDataSource;
  final ApiRecitationDatasource _apiDataSource;
  final SyncQueueService _syncQueue;

  RecitationRepository(this._hiveDataSource, this._apiDataSource, this._syncQueue);

  Future<void> init() async {
    await _hiveDataSource.init();
  }

  /// Ajoute une nouvelle récitation. Retourne la version persistée côté
  /// serveur (avec son identifiant réel).
  Future<Recitation> addRecitation(Recitation recitation) async {
    final saved = await _apiDataSource.addRecitation(recitation, recitation.markazId);
    await _hiveDataSource.addRecitation(saved);
    return saved;
  }

  Future<void> updateRecitation(Recitation recitation) async {
    await _hiveDataSource.updateRecitation(recitation);
    try {
      final saved = await _apiDataSource.updateRecitation(recitation, recitation.markazId);
      await _hiveDataSource.updateRecitation(saved);
    } catch (e) {
      debugPrint('Erreur sync API (mise à jour récitation) : $e');
      await _syncQueue.enqueue(
        entityType: SyncEntityType.recitation,
        operation: SyncOperation.update,
        entityId: recitation.id,
      );
    }
  }

  Future<void> removeRecitation(String recitationId) async {
    await _hiveDataSource.deleteRecitation(recitationId);
    try {
      await _apiDataSource.deleteRecitation(recitationId);
    } catch (e) {
      debugPrint('Erreur sync API (suppression récitation) : $e');
      await _syncQueue.enqueue(
        entityType: SyncEntityType.recitation,
        operation: SyncOperation.delete,
        entityId: recitationId,
      );
    }
  }

  /// Rejoue une mise à jour en attente — réservé à SyncOrchestrator.
  Future<void> retrySyncUpdate(String recitationId) async {
    final recitation = _hiveDataSource.getRecitationById(recitationId);
    if (recitation == null) return;
    final saved = await _apiDataSource.updateRecitation(recitation, recitation.markazId);
    await _hiveDataSource.updateRecitation(saved);
  }

  /// Rejoue une suppression en attente — réservé à SyncOrchestrator.
  Future<void> retrySyncDelete(String recitationId) async {
    await _apiDataSource.deleteRecitation(recitationId);
  }

  Recitation? getRecitationById(String recitationId) {
    return _hiveDataSource.getRecitationById(recitationId);
  }

  List<Recitation> getAllRecitations() {
    return _hiveDataSource.getAllRecitations();
  }

  List<Recitation> getRecitationsByMarkaz(String markazId) {
    return _hiveDataSource.getRecitationsByMarkaz(markazId);
  }

  List<Recitation> getRecitationsByStudent(String studentId) {
    return _hiveDataSource.getRecitationsByStudent(studentId);
  }

  Future<void> clearAll() async {
    await _hiveDataSource.clearAll();
  }

  Future<void> close() async {
    await _hiveDataSource.close();
  }

  /// Recharge le cache local depuis l'API pour la Markaz donnée.
  Future<void> syncFromMarkaz(String markazId) async {
    try {
      final recitations = await _apiDataSource.getRecitationsByMarkaz(markazId);
      await _hiveDataSource.clearAll();
      for (final recitation in recitations) {
        await _hiveDataSource.addRecitation(recitation);
      }
    } catch (e) {
      debugPrint('Erreur sync API (récitations) : $e');
    }
  }
}
