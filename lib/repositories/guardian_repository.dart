import 'package:flutter/foundation.dart';
import '../models/guardian.dart';
import '../models/sync_queue_item.dart';
import '../datasources/hive_guardian_datasource.dart';
import '../datasources/api_guardian_datasource.dart';
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
    await _hiveDataSource.updateGuardian(guardian);
    try {
      final saved = await _apiDataSource.updateGuardian(guardian, guardian.markazId);
      await _hiveDataSource.updateGuardian(saved);
    } catch (e) {
      debugPrint('Erreur sync API (mise à jour tuteur) : $e');
      await _syncQueue.enqueue(
        entityType: SyncEntityType.guardian,
        operation: SyncOperation.update,
        entityId: guardian.id,
      );
    }
  }

  Future<void> removeGuardian(String guardianId) async {
    await _hiveDataSource.deleteGuardian(guardianId);
    try {
      await _apiDataSource.deleteGuardian(guardianId);
    } catch (e) {
      debugPrint('Erreur sync API (suppression tuteur) : $e');
      await _syncQueue.enqueue(
        entityType: SyncEntityType.guardian,
        operation: SyncOperation.delete,
        entityId: guardianId,
      );
    }
  }

  /// Rejoue une mise à jour en attente — réservé à SyncOrchestrator.
  Future<void> retrySyncUpdate(String guardianId) async {
    final guardian = _hiveDataSource.getGuardianById(guardianId);
    if (guardian == null) return;
    final saved = await _apiDataSource.updateGuardian(guardian, guardian.markazId);
    await _hiveDataSource.updateGuardian(saved);
  }

  /// Rejoue une suppression en attente — réservé à SyncOrchestrator.
  Future<void> retrySyncDelete(String guardianId) async {
    await _apiDataSource.deleteGuardian(guardianId);
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

  /// Recharge le cache local depuis l'API pour la Markaz donnée.
  Future<void> syncFromMarkaz(String markazId) async {
    try {
      final guardians = await _apiDataSource.getGuardiansByMarkaz(markazId);
      await _hiveDataSource.clearAll();
      for (final guardian in guardians) {
        await _hiveDataSource.addGuardian(guardian);
      }
    } catch (e) {
      debugPrint('Erreur sync API (tuteurs) : $e');
    }
  }
}
