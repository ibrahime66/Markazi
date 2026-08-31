import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part 'sync_queue_item.g.dart';

/// Type d'opération en attente de synchronisation (CDC section 20).
@HiveType(typeId: 10)
enum SyncOperation {
  @HiveField(0)
  update,
  @HiveField(1)
  delete,
}

/// Entité concernée par une action hors ligne en attente (CDC section 20).
@HiveType(typeId: 11)
enum SyncEntityType {
  @HiveField(0)
  payment,
  @HiveField(1)
  attendance,
  @HiveField(2)
  guardian,
  @HiveField(3)
  recitation,
}

/// Une action de saisie effectuée hors ligne, en attente de synchronisation
/// avec le serveur (CDC section 20 : "toute action de saisie effectuée hors
/// ligne [...] est stockée localement avec un statut 'en attente de
/// synchronisation'"). Corrige doc/audit.md, point D2 : ces échecs étaient
/// auparavant seulement journalisés (`print`/`debugPrint`) et perdus.
///
/// Ne stocke pas les données elles-mêmes : au moment du rejeu, la donnée
/// locale actuelle (déjà à jour dans le cache Hive de l'entité, écrite en
/// premier par le repository) est relue et renvoyée au serveur. Si l'élève
/// modifie plusieurs fois hors ligne, une seule tentative de rejeu suffit —
/// elle porte toujours sur le dernier état local connu.
@HiveType(typeId: 9)
class SyncQueueItem extends Equatable {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final SyncEntityType entityType;

  @HiveField(2)
  final SyncOperation operation;

  @HiveField(3)
  final String entityId;

  @HiveField(4)
  final DateTime createdAt;

  const SyncQueueItem({
    required this.id,
    required this.entityType,
    required this.operation,
    required this.entityId,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, entityType, operation, entityId, createdAt];
}
