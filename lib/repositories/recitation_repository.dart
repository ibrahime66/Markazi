import 'package:flutter/foundation.dart';
import '../models/recitation.dart';
import '../models/sync_queue_item.dart';
import '../datasources/hive_recitation_datasource.dart';
import '../datasources/api_recitation_datasource.dart';
import '../services/api_client.dart';
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
  /// serveur (avec son identifiant réel). Hors ligne (CDC §20 : récitations
  /// "lecture et saisie" hors ligne), conservée localement et envoyée à la
  /// reconnexion.
  Future<Recitation> addRecitation(Recitation recitation) async {
    try {
      final saved = await _apiDataSource.addRecitation(recitation, recitation.markazId);
      await _hiveDataSource.addRecitation(saved);
      return saved;
    } catch (e, st) {
      if (!ApiClient.isOfflineError(e)) ApiClient.throwReadable(e, st);
      debugPrint('Hors ligne : récitation mise en file ($e)');
      await _hiveDataSource.addRecitation(recitation);
      await _syncQueue.enqueue(
        entityType: SyncEntityType.recitation,
        operation: SyncOperation.create,
        entityId: recitation.id,
      );
      return recitation;
    }
  }

  /// Rejoue une création faite hors ligne — réservé à SyncOrchestrator.
  /// Remplace l'identifiant temporaire local par l'identifiant serveur.
  Future<void> retrySyncCreate(String recitationId, DateTime performedAt) async {
    final recitation = _hiveDataSource.getRecitationById(recitationId);
    if (recitation == null) return;
    final saved = await _apiDataSource.addRecitation(
      recitation,
      recitation.markazId,
      performedAt: performedAt,
    );
    await _hiveDataSource.deleteRecitation(recitationId);
    await _hiveDataSource.addRecitation(saved);
  }

  /// Retire du cache local une récitation créée hors ligne dont l'envoi a
  /// été abandonné par l'utilisateur.
  Future<void> discardLocal(String recitationId) async {
    await _hiveDataSource.deleteRecitation(recitationId);
  }

  /// Résumé lisible pour l'écran "Synchronisation".
  String? describe(String recitationId) {
    return _hiveDataSource.getRecitationById(recitationId)?.surah;
  }

  Future<void> updateRecitation(Recitation recitation) async {
    final previous = _hiveDataSource.getRecitationById(recitation.id);
    await _hiveDataSource.updateRecitation(recitation);

    if (_syncQueue.hasPendingCreate(SyncEntityType.recitation, recitation.id)) {
      await _syncQueue.enqueue(
        entityType: SyncEntityType.recitation,
        operation: SyncOperation.update,
        entityId: recitation.id,
      );
      return;
    }

    try {
      final saved = await _apiDataSource.updateRecitation(recitation, recitation.markazId);
      await _hiveDataSource.updateRecitation(saved);
      await _syncQueue.resolve(SyncEntityType.recitation, recitation.id);
    } catch (e, st) {
      if (!ApiClient.isOfflineError(e)) {
        if (previous != null) await _hiveDataSource.updateRecitation(previous);
        ApiClient.throwReadable(e, st);
      }
      debugPrint('Hors ligne : mise à jour de récitation mise en file ($e)');
      await _syncQueue.enqueue(
        entityType: SyncEntityType.recitation,
        operation: SyncOperation.update,
        entityId: recitation.id,
      );
    }
  }

  Future<void> removeRecitation(String recitationId) async {
    final previous = _hiveDataSource.getRecitationById(recitationId);
    await _hiveDataSource.deleteRecitation(recitationId);

    if (_syncQueue.hasPendingCreate(SyncEntityType.recitation, recitationId)) {
      await _syncQueue.enqueue(
        entityType: SyncEntityType.recitation,
        operation: SyncOperation.delete,
        entityId: recitationId,
      );
      return;
    }

    try {
      await _apiDataSource.deleteRecitation(recitationId);
      await _syncQueue.resolve(SyncEntityType.recitation, recitationId);
    } catch (e, st) {
      if (!ApiClient.isOfflineError(e)) {
        if (previous != null) await _hiveDataSource.addRecitation(previous);
        ApiClient.throwReadable(e, st);
      }
      debugPrint('Hors ligne : suppression de récitation mise en file ($e)');
      await _syncQueue.enqueue(
        entityType: SyncEntityType.recitation,
        operation: SyncOperation.delete,
        entityId: recitationId,
      );
    }
  }

  /// Rejoue une mise à jour en attente — réservé à SyncOrchestrator.
  /// Ne rattrape PAS l'erreur : l'appelant décide de garder l'action en file.
  Future<void> retrySyncUpdate(String recitationId, DateTime performedAt) async {
    final recitation = _hiveDataSource.getRecitationById(recitationId);
    if (recitation == null) return;
    final saved = await _apiDataSource.updateRecitation(recitation, recitation.markazId, performedAt: performedAt);
    await _hiveDataSource.updateRecitation(saved);
  }

  /// Rejoue une suppression en attente — réservé à SyncOrchestrator.
  Future<void> retrySyncDelete(String recitationId, DateTime performedAt) async {
    await _apiDataSource.deleteRecitation(recitationId, performedAt: performedAt);
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

  /// Recharge le cache local depuis l'API pour la Markaz donnée, sans
  /// écraser les saisies locales encore en attente de synchronisation
  /// (CDC §20).
  Future<void> syncFromMarkaz(String markazId) async {
    try {
      final remote = await _apiDataSource.getRecitationsByMarkaz(markazId);
      final pendingIds = _syncQueue.pendingIds(SyncEntityType.recitation);
      final pendingLocal = pendingIds
          .map(_hiveDataSource.getRecitationById)
          .whereType<Recitation>()
          .toList();
      await _hiveDataSource.clearAll();
      for (final recitation in remote) {
        if (pendingIds.contains(recitation.id)) continue;
        await _hiveDataSource.addRecitation(recitation);
      }
      for (final recitation in pendingLocal) {
        await _hiveDataSource.addRecitation(recitation);
      }
    } catch (e) {
      debugPrint('Erreur sync API (récitations) : $e');
    }
  }
}
