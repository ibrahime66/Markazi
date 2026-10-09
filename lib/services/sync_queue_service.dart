import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/sync_queue_item.dart';

/// Persiste les actions de saisie faites hors ligne, pour un rejeu
/// automatique à la reconnexion (CDC section 20). Voir doc/audit.md, points
/// D2 et F5.
///
/// Une seule action en attente par entité : les saisies successives hors
/// ligne sont fusionnées (le rejeu relit toujours le dernier état local).
///  - modification d'une entité créée hors ligne → reste une création ;
///  - suppression d'une entité créée hors ligne → plus rien à envoyer ;
///  - suppression d'une entité modifiée hors ligne → seule la suppression
///    est rejouée.
class SyncQueueService {
  static const _boxName = 'sync_queue';
  late Box<SyncQueueItem> _box;

  Future<void> init() async {
    _box = await Hive.openBox<SyncQueueItem>(_boxName);
  }

  /// Ajoute (ou fusionne) une action en attente pour une entité.
  Future<void> enqueue({
    required SyncEntityType entityType,
    required SyncOperation operation,
    required String entityId,
    DateTime? performedAt,
    String? payload,
  }) async {
    final now = performedAt ?? DateTime.now();
    final pending = _pendingFor(entityType, entityId);
    final pendingCreate =
        pending.where((i) => i.operation == SyncOperation.create).firstOrNull;

    switch (operation) {
      case SyncOperation.create:
        if (pendingCreate != null) return;
        await _add(entityType, operation, entityId, now, payload);
        return;

      case SyncOperation.update:
        // Création ou modification déjà en file : on garde l'action
        // existante (même place dans l'ordre chronologique), en mettant à
        // jour sa date réelle et en effaçant un éventuel refus précédent.
        final mergeInto = pendingCreate ??
            pending.where((i) => i.operation == SyncOperation.update).firstOrNull;
        if (mergeInto != null) {
          await _box.put(
            mergeInto.id,
            mergeInto.copyWith(performedAt: now, clearError: true, payload: payload),
          );
          return;
        }
        await _add(entityType, operation, entityId, now, payload);
        return;

      case SyncOperation.delete:
        if (pendingCreate != null) {
          // Jamais arrivée sur le serveur : rien à supprimer là-bas.
          await _box.deleteAll(pending.map((i) => i.id));
          return;
        }
        await _box.deleteAll(
          pending.where((i) => i.operation == SyncOperation.update).map((i) => i.id),
        );
        if (pending.any((i) => i.operation == SyncOperation.delete)) return;
        await _add(entityType, operation, entityId, now, payload);
        return;
    }
  }

  Future<void> _add(
    SyncEntityType entityType,
    SyncOperation operation,
    String entityId,
    DateTime performedAt,
    String? payload,
  ) async {
    const uuid = Uuid();
    final item = SyncQueueItem(
      id: uuid.v4(),
      entityType: entityType,
      operation: operation,
      entityId: entityId,
      createdAt: DateTime.now(),
      performedAt: performedAt,
      payload: payload,
    );
    await _box.put(item.id, item);
  }

  List<SyncQueueItem> _pendingFor(SyncEntityType entityType, String entityId) {
    return _box.values
        .where((i) => i.entityType == entityType && i.entityId == entityId)
        .toList();
  }

  /// Action en attente pour cette entité, s'il y en a une.
  SyncQueueItem? pendingFor(SyncEntityType entityType, String entityId) {
    return _pendingFor(entityType, entityId).firstOrNull;
  }

  /// Vrai si l'entité n'existe encore que localement (créée hors ligne).
  bool hasPendingCreate(SyncEntityType entityType, String entityId) {
    return _pendingFor(entityType, entityId)
        .any((i) => i.operation == SyncOperation.create);
  }

  /// Identifiants des entités d'un type ayant une action en attente
  /// (éventuellement limitée à une opération). Utilisé au rechargement
  /// depuis le serveur pour ne pas écraser une saisie locale pas encore
  /// envoyée.
  Set<String> pendingIds(SyncEntityType entityType, {SyncOperation? operation}) {
    return _box.values
        .where((i) =>
            i.entityType == entityType &&
            (operation == null || i.operation == operation))
        .map((i) => i.entityId)
        .toSet();
  }

  /// Retire de la file toutes les actions d'une entité (ex. modification
  /// enfin envoyée avec succès en direct : l'ancienne action en attente est
  /// devenue inutile, et la rejouer créerait un faux conflit).
  Future<void> resolve(SyncEntityType entityType, String entityId) async {
    await _box.deleteAll(_pendingFor(entityType, entityId).map((i) => i.id));
  }

  /// Enregistre un refus du serveur : l'action reste en file, visible avec
  /// son message dans l'écran "Synchronisation".
  Future<void> markFailed(String id, String error) async {
    final item = _box.get(id);
    if (item == null) return;
    await _box.put(id, item.copyWith(lastError: error));
  }

  Future<void> remove(String id) async {
    await _box.delete(id);
  }

  /// Actions en attente, dans l'ordre chronologique de rejeu.
  List<SyncQueueItem> getAll() =>
      _box.values.toList()..sort((a, b) => a.createdAt.compareTo(b.createdAt));

  int get pendingCount => _box.length;

  /// Nombre d'actions refusées par le serveur, à traiter par l'utilisateur.
  int get failedCount => _box.values.where((i) => i.lastError != null).length;

  /// Notifié à chaque ajout/suppression dans la file — permet à l'UI de
  /// refléter en direct le nombre d'actions en attente (CDC section 20),
  /// y compris quand un repository met en file une action sans passer par
  /// SyncQueueProvider (ex. échec silencieux d'une mise à jour).
  ValueListenable<Box<SyncQueueItem>> listenable() => _box.listenable();

  Future<void> close() async {
    await _box.close();
  }
}
