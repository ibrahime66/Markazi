import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import '../models/sync_queue_item.dart';
import '../repositories/payment_repository.dart';
import '../repositories/attendance_repository.dart';
import '../repositories/guardian_repository.dart';
import '../repositories/recitation_repository.dart';
import 'sync_queue_service.dart';

/// Rejoue les actions hors ligne en attente (CDC section 20 : "à la
/// reconnexion, une synchronisation automatique rejoue les actions en
/// attente dans leur ordre chronologique, avec accusé de réception de l'API
/// pour chaque élément"). Voir doc/audit.md, point D2.
///
/// Appelé au démarrage de l'app (après la synchronisation initiale) et à
/// chaque synchronisation manuelle déclenchée par l'utilisateur. Chaque
/// action retentée passe par la méthode `retrySync*` du repository
/// correspondant, qui ne rattrape PAS ses erreurs (contrairement aux
/// méthodes normales `update*`/`remove*`) : si l'appareil est toujours hors
/// ligne, l'exception remonte ici et l'action reste en file pour la
/// prochaine tentative.
class SyncOrchestrator {
  final SyncQueueService _queue;
  final PaymentRepository _paymentRepository;
  final AttendanceRepository _attendanceRepository;
  final GuardianRepository _guardianRepository;
  final RecitationRepository _recitationRepository;

  SyncOrchestrator({
    required SyncQueueService queue,
    required PaymentRepository paymentRepository,
    required AttendanceRepository attendanceRepository,
    required GuardianRepository guardianRepository,
    required RecitationRepository recitationRepository,
  })  : _queue = queue,
        _paymentRepository = paymentRepository,
        _attendanceRepository = attendanceRepository,
        _guardianRepository = guardianRepository,
        _recitationRepository = recitationRepository;

  int get pendingCount => _queue.pendingCount;

  /// Notifié en direct à chaque changement de la file (ajout ou retrait),
  /// pour l'indicateur visuel de l'UI (CDC section 20).
  ValueListenable<Box<SyncQueueItem>> get queueListenable => _queue.listenable();

  Future<void> replayPending() async {
    final items = _queue.getAll()..sort((a, b) => a.createdAt.compareTo(b.createdAt));

    for (final item in items) {
      try {
        await _replayOne(item);
        await _queue.remove(item.id);
      } catch (e) {
        // Toujours hors ligne ou erreur serveur transitoire : on retente au
        // prochain appel, l'élément reste en file.
        debugPrint('Rejeu différé (${item.entityType}/${item.operation} ${item.entityId}) : $e');
      }
    }
  }

  Future<void> _replayOne(SyncQueueItem item) {
    switch (item.entityType) {
      case SyncEntityType.payment:
        return item.operation == SyncOperation.delete
            ? _paymentRepository.retrySyncDelete(item.entityId)
            : _paymentRepository.retrySyncUpdate(item.entityId);

      case SyncEntityType.attendance:
        return item.operation == SyncOperation.delete
            ? _attendanceRepository.retrySyncDelete(item.entityId)
            : _attendanceRepository.retrySyncUpdate(item.entityId);

      case SyncEntityType.guardian:
        return item.operation == SyncOperation.delete
            ? _guardianRepository.retrySyncDelete(item.entityId)
            : _guardianRepository.retrySyncUpdate(item.entityId);

      case SyncEntityType.recitation:
        return item.operation == SyncOperation.delete
            ? _recitationRepository.retrySyncDelete(item.entityId)
            : _recitationRepository.retrySyncUpdate(item.entityId);
    }
  }
}
