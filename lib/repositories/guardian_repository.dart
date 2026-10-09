import 'package:flutter/foundation.dart';
import '../models/guardian.dart';
import '../models/sync_queue_item.dart';
import '../datasources/hive_guardian_datasource.dart';
import '../datasources/api_guardian_datasource.dart';
import '../services/api_client.dart';
import '../services/sync_queue_service.dart';

/// Repository pour la gestion des données Guardian.
/// Utilise l'API Laravel avec cache Hive local pour mode hors ligne.
class GuardianRepository {
  final HiveGuardianDataSource _hiveDataSource;
  final ApiGuardianDatasource _apiDataSource;
  final SyncQueueService _syncQueue;

  GuardianRepository(this._hiveDataSource, this._apiDataSource, this._syncQueue);

  Future<void> init() async {
    await _hiveDataSource.init();
  }

  /// Ajoute un nouveau tuteur. Retourne le tuteur tel que persisté côté
  /// serveur (avec son identifiant réel).
  Future<Guardian> addGuardian(Guardian guardian) async {
    final saved = await _apiDataSource.addGuardian(guardian, guardian.markazId);
    await _hiveDataSource.addGuardian(saved);
    return saved;
  }

  Future<void> updateGuardian(Guardian guardian) async {
    final previous = _hiveDataSource.getGuardianById(guardian.id);
    await _hiveDataSource.updateGuardian(guardian);

    if (_syncQueue.hasPendingCreate(SyncEntityType.guardian, guardian.id)) {
      await _syncQueue.enqueue(
        entityType: SyncEntityType.guardian,
        operation: SyncOperation.update,
        entityId: guardian.id,
      );
      return;
    }

    try {
      final saved = await _apiDataSource.updateGuardian(guardian, guardian.markazId);
      await _hiveDataSource.updateGuardian(saved);
      await _syncQueue.resolve(SyncEntityType.guardian, guardian.id);
    } catch (e, st) {
      if (!ApiClient.isOfflineError(e)) {
        if (previous != null) await _hiveDataSource.updateGuardian(previous);
        ApiClient.throwReadable(e, st);
      }
      debugPrint('Hors ligne : mise à jour de tuteur mise en file ($e)');
      await _syncQueue.enqueue(
        entityType: SyncEntityType.guardian,
        operation: SyncOperation.update,
        entityId: guardian.id,
      );
    }
  }

  Future<void> removeGuardian(String guardianId) async {
    final previous = _hiveDataSource.getGuardianById(guardianId);
    await _hiveDataSource.deleteGuardian(guardianId);

    if (_syncQueue.hasPendingCreate(SyncEntityType.guardian, guardianId)) {
      await _syncQueue.enqueue(
        entityType: SyncEntityType.guardian,
        operation: SyncOperation.delete,
        entityId: guardianId,
      );
      return;
    }

    try {
      await _apiDataSource.deleteGuardian(guardianId);
      await _syncQueue.resolve(SyncEntityType.guardian, guardianId);
    } catch (e, st) {
      if (!ApiClient.isOfflineError(e)) {
        if (previous != null) await _hiveDataSource.addGuardian(previous);
        ApiClient.throwReadable(e, st);
      }
      debugPrint('Hors ligne : suppression de tuteur mise en file ($e)');
      await _syncQueue.enqueue(
        entityType: SyncEntityType.guardian,
        operation: SyncOperation.delete,
        entityId: guardianId,
      );
    }
  }

  /// Rejoue une mise à jour en attente — réservé à SyncOrchestrator.
  /// Ne rattrape PAS l'erreur : l'appelant décide de garder l'action en file.
  Future<void> retrySyncUpdate(String guardianId, DateTime performedAt) async {
    final guardian = _hiveDataSource.getGuardianById(guardianId);
    if (guardian == null) return;
    final saved = await _apiDataSource.updateGuardian(guardian, guardian.markazId, performedAt: performedAt);
    await _hiveDataSource.updateGuardian(saved);
  }

  /// Rejoue une suppression en attente — réservé à SyncOrchestrator.
  Future<void> retrySyncDelete(String guardianId, DateTime performedAt) async {
    await _apiDataSource.deleteGuardian(guardianId, performedAt: performedAt);
  }

  /// Résumé lisible pour l'écran "Synchronisation".
  String? describe(String guardianId) {
    return _hiveDataSource.getGuardianById(guardianId)?.name;
  }

  Guardian? getGuardianById(String guardianId) {
    return _hiveDataSource.getGuardianById(guardianId);
  }

  List<Guardian> getAllGuardians() {
    return _hiveDataSource.getAllGuardians();
  }

  List<Guardian> getGuardiansByMarkaz(String markazId) {
    return _hiveDataSource.getGuardiansByMarkaz(markazId);
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
      final remote = await _apiDataSource.getGuardiansByMarkaz(markazId);
      final pendingIds = _syncQueue.pendingIds(SyncEntityType.guardian);
      final pendingLocal = pendingIds
          .map(_hiveDataSource.getGuardianById)
          .whereType<Guardian>()
          .toList();
      await _hiveDataSource.clearAll();
      for (final guardian in remote) {
        if (pendingIds.contains(guardian.id)) continue;
        await _hiveDataSource.addGuardian(guardian);
      }
      for (final guardian in pendingLocal) {
        await _hiveDataSource.addGuardian(guardian);
      }
    } catch (e) {
      debugPrint('Erreur sync API (tuteurs) : $e');
    }
  }
}
