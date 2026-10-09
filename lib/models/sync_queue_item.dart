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

  /// Création faite hors ligne (doc/audit.md, point F5) : l'entité n'existe
  /// encore que localement, sous un identifiant temporaire (UUID) remplacé
  /// par l'identifiant serveur au rejeu.
  @HiveField(2)
  create,
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

  /// Groupe (classe) : modification ou suppression.
  @HiveField(4)
  classModel,

  /// Affectation d'un élève à un groupe : `entityId` est l'élève,
  /// `payload` l'identifiant du groupe cible (vide = retiré de tout groupe).
  @HiveField(5)
  studentClass,
}

/// Une action de saisie effectuée hors ligne, en attente de synchronisation
/// avec le serveur (CDC section 20 : "toute action de saisie effectuée hors
/// ligne [...] est stockée localement avec un statut 'en attente de
/// synchronisation'"). Corrige doc/audit.md, points D2/F5.
///
/// Ne stocke pas les données elles-mêmes : au moment du rejeu, la donnée
/// locale actuelle (déjà à jour dans le cache Hive de l'entité, écrite en
/// premier par le repository) est relue et renvoyée au serveur. Si
/// l'utilisateur modifie plusieurs fois hors ligne, une seule action est
/// rejouée — elle porte toujours sur le dernier état local connu.
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

  /// Date de mise en file — détermine l'ordre chronologique de rejeu.
  @HiveField(4)
  final DateTime createdAt;

  /// Date réelle de la dernière action locale sur cette entité (mise à jour
  /// quand l'utilisateur la modifie encore hors ligne). Envoyée au serveur
  /// (en-tête X-Performed-At) : l'historique garde la date de réalisation,
  /// pas celle de synchronisation (CDC §27).
  @HiveField(5)
  final DateTime? performedAt;

  /// Dernier refus du serveur (validation, doublon…) : l'action reste en
  /// file et est affichée à l'utilisateur, qui peut la réessayer ou
  /// l'abandonner depuis l'écran "Synchronisation".
  @HiveField(6)
  final String? lastError;

  /// Donnée complémentaire propre au type (ex. groupe cible pour
  /// [SyncEntityType.studentClass]).
  @HiveField(7)
  final String? payload;

  const SyncQueueItem({
    required this.id,
    required this.entityType,
    required this.operation,
    required this.entityId,
    required this.createdAt,
    this.performedAt,
    this.lastError,
    this.payload,
  });

  /// Date réelle de l'action, à transmettre au serveur.
  DateTime get actionDate => performedAt ?? createdAt;

  SyncQueueItem copyWith({
    SyncOperation? operation,
    DateTime? performedAt,
    String? lastError,
    bool clearError = false,
    String? payload,
  }) {
    return SyncQueueItem(
      id: id,
      entityType: entityType,
      operation: operation ?? this.operation,
      entityId: entityId,
      createdAt: createdAt,
      performedAt: performedAt ?? this.performedAt,
      lastError: clearError ? null : (lastError ?? this.lastError),
      payload: payload ?? this.payload,
    );
  }

  @override
  List<Object?> get props => [
        id,
        entityType,
        operation,
        entityId,
        createdAt,
        performedAt,
        lastError,
        payload,
      ];
}
