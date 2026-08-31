import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/sync_queue_item.dart';

/// Persiste les actions de saisie hors ligne qui ont échoué, pour un rejeu
/// automatique à la reconnexion (CDC section 20). Voir doc/audit.md, point D2.
class SyncQueueService {
  static const _boxName = 'sync_queue';
  late Box<SyncQueueItem> _box;

  Future<void> init() async {
    _box = await Hive.openBox<SyncQueueItem>(_boxName);
  }

  /// Ajoute une action en attente. Idempotent : si une action identique
  /// (même entité, même opération) est déjà en file, elle n'est pas dupliquée
  /// — inutile de rejouer deux fois la même correction.
  Future<void> enqueue({
    required SyncEntityType entityType,
    required SyncOperation operation,
    required String entityId,
  }) async {
    final alreadyQueued = _box.values.any((item) =>
        item.entityType == entityType &&
        item.operation == operation &&
        item.entityId == entityId);
    if (alreadyQueued) return;

    const uuid = Uuid();
    final item = SyncQueueItem(
      id: uuid.v4(),
      entityType: entityType,
      operation: operation,
      entityId: entityId,
      createdAt: DateTime.now(),
    );
    await _box.put(item.id, item);
  }

  Future<void> remove(String id) async {
    await _box.delete(id);
  }

  List<SyncQueueItem> getAll() => _box.values.toList();

  int get pendingCount => _box.length;

  /// Notifié à chaque ajout/suppression dans la file — permet à l'UI de
  /// refléter en direct le nombre d'actions en attente (CDC section 20),
  /// y compris quand un repository met en file une action sans passer par
  /// SyncQueueProvider (ex. échec silencieux d'une mise à jour).
  ValueListenable<Box<SyncQueueItem>> listenable() => _box.listenable();

  Future<void> close() async {
    await _box.close();
  }
}
