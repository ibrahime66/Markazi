import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import '../models/sync_queue_item.dart';
import '../repositories/attendance_repository.dart';
import '../repositories/class_repository.dart';
import '../repositories/guardian_repository.dart';
import '../repositories/payment_repository.dart';
import '../repositories/recitation_repository.dart';
import '../repositories/student_repository.dart';
import 'api_client.dart';
import 'sync_queue_service.dart';

/// Résultat d'un passage de synchronisation.
class SyncReport {
  /// Actions envoyées et acceptées par le serveur.
  final int synced;

  /// Actions refusées par le serveur (restent en file avec leur message).
  final int failed;

  /// Vrai si le serveur est resté injoignable (rejeu interrompu, actions
  /// restantes conservées pour la prochaine tentative).
  final bool offline;

  const SyncReport({this.synced = 0, this.failed = 0, this.offline = false});
}

/// Rejoue les actions hors ligne en attente (CDC section 20 : "à la
/// reconnexion, une synchronisation automatique rejoue les actions en
/// attente dans leur ordre chronologique, avec accusé de réception de l'API
/// pour chaque élément"). Voir doc/audit.md, points D2 et F5.
///
/// Ordre impératif (correctif F5) : rejouer la file AVANT de recharger le
/// cache depuis le serveur. L'ancien démarrage rechargeait d'abord, ce qui
/// écrasait les saisies locales en attente par la version serveur… puis
/// renvoyait cette version serveur : la saisie hors ligne était perdue.
///
/// Chaque action est envoyée avec sa date réelle (en-tête X-Performed-At) :
/// le serveur l'utilise pour dater l'historique et tracer les conflits.
class SyncOrchestrator {
  final SyncQueueService _queue;
  final PaymentRepository _paymentRepository;
  final AttendanceRepository _attendanceRepository;
  final GuardianRepository _guardianRepository;
  final RecitationRepository _recitationRepository;
  final ClassRepository _classRepository;
  final StudentRepository _studentRepository;

  Future<SyncReport>? _running;

  SyncOrchestrator({
    required SyncQueueService queue,
    required PaymentRepository paymentRepository,
    required AttendanceRepository attendanceRepository,
    required GuardianRepository guardianRepository,
    required RecitationRepository recitationRepository,
    required ClassRepository classRepository,
    required StudentRepository studentRepository,
  })  : _queue = queue,
        _paymentRepository = paymentRepository,
        _attendanceRepository = attendanceRepository,
        _guardianRepository = guardianRepository,
        _recitationRepository = recitationRepository,
        _classRepository = classRepository,
        _studentRepository = studentRepository;

  int get pendingCount => _queue.pendingCount;

  int get failedCount => _queue.failedCount;

  List<SyncQueueItem> get pendingItems => _queue.getAll();

  /// Notifié en direct à chaque changement de la file (ajout ou retrait),
  /// pour l'indicateur visuel de l'UI (CDC section 20).
  ValueListenable<Box<SyncQueueItem>> get queueListenable => _queue.listenable();

  /// Rejoue la file. Un seul passage à la fois : un appel concurrent attend
  /// le passage en cours au lieu d'envoyer deux fois la même action.
  Future<SyncReport> replayPending() {
    return _running ??= _replay().whenComplete(() => _running = null);
  }

  Future<SyncReport> _replay() async {
    var synced = 0;
    var failed = 0;

    for (final item in _queue.getAll()) {
      try {
        await _replayOne(item);
        await _queue.remove(item.id);
        synced++;
      } catch (e) {
        if (ApiClient.isOfflineError(e)) {
          // Toujours hors ligne : inutile d'essayer la suite, et l'ordre
          // chronologique est préservé pour la prochaine tentative.
          debugPrint('Rejeu interrompu, serveur injoignable : $e');
          return SyncReport(synced: synced, failed: failed, offline: true);
        }
        // Refus du serveur : conservé avec son message pour que
        // l'utilisateur décide (réessayer après correction, ou abandonner).
        debugPrint('Rejeu refusé (${item.entityType}/${item.operation} ${item.entityId}) : $e');
        await _queue.markFailed(item.id, ApiClient.describeError(e));
        failed++;
      }
    }
    return SyncReport(synced: synced, failed: failed);
  }

  /// Synchronisation complète : rejeu de la file, PUIS rechargement de tous
  /// les caches depuis le serveur (en préservant ce qui reste en attente).
  Future<SyncReport> syncAll(String markazId) async {
    final report = await replayPending();
    if (report.offline) return report;
    await Future.wait([
      _studentRepository.syncFromMarkaz(markazId),
      _classRepository.syncFromMarkaz(markazId),
      _attendanceRepository.syncFromMarkaz(markazId),
      _paymentRepository.syncFromMarkaz(markazId),
      _guardianRepository.syncFromMarkaz(markazId),
      _recitationRepository.syncFromMarkaz(markazId),
    ]);
    return report;
  }

  /// Abandonne une action en attente (choix explicite de l'utilisateur
  /// depuis l'écran "Synchronisation"). Une création jamais envoyée est
  /// retirée du cache local ; pour une modification/suppression, le
  /// prochain rechargement restaurera la version du serveur.
  Future<void> discard(SyncQueueItem item) async {
    await _queue.remove(item.id);
    if (item.operation != SyncOperation.create) return;
    switch (item.entityType) {
      case SyncEntityType.payment:
        await _paymentRepository.discardLocal(item.entityId);
      case SyncEntityType.attendance:
        await _attendanceRepository.discardLocal(item.entityId);
      case SyncEntityType.recitation:
        await _recitationRepository.discardLocal(item.entityId);
      case SyncEntityType.guardian:
      case SyncEntityType.classModel:
      case SyncEntityType.studentClass:
        break;
    }
  }

  /// Résumé lisible de l'entité concernée (montant, leçon, nom…), ou null
  /// si elle n'est plus dans le cache local.
  String? describe(SyncQueueItem item) {
    switch (item.entityType) {
      case SyncEntityType.payment:
        return _paymentRepository.describe(item.entityId);
      case SyncEntityType.attendance:
        return _attendanceRepository.describe(item.entityId);
      case SyncEntityType.guardian:
        return _guardianRepository.describe(item.entityId);
      case SyncEntityType.recitation:
        return _recitationRepository.describe(item.entityId);
      case SyncEntityType.classModel:
        return _classRepository.describe(item.entityId);
      case SyncEntityType.studentClass:
        final student = _studentRepository.getStudentById(item.entityId)?.name;
        final target = item.payload ?? '';
        final className =
            target.isEmpty ? null : _classRepository.describe(target);
        return [student, className].whereType<String>().join(' → ');
    }
  }

  Future<void> _replayOne(SyncQueueItem item) {
    final date = item.actionDate;
    final id = item.entityId;
    switch (item.entityType) {
      case SyncEntityType.payment:
        switch (item.operation) {
          case SyncOperation.create:
            return _paymentRepository.retrySyncCreate(id, date);
          case SyncOperation.update:
            return _paymentRepository.retrySyncUpdate(id, date);
          case SyncOperation.delete:
            return _paymentRepository.retrySyncDelete(id);
        }

      case SyncEntityType.attendance:
        switch (item.operation) {
          case SyncOperation.create:
            return _attendanceRepository.retrySyncCreate(id, date);
          case SyncOperation.update:
            return _attendanceRepository.retrySyncUpdate(id, date);
          case SyncOperation.delete:
            return _attendanceRepository.retrySyncDelete(id, date);
        }

      case SyncEntityType.recitation:
        switch (item.operation) {
          case SyncOperation.create:
            return _recitationRepository.retrySyncCreate(id, date);
          case SyncOperation.update:
            return _recitationRepository.retrySyncUpdate(id, date);
          case SyncOperation.delete:
            return _recitationRepository.retrySyncDelete(id, date);
        }

      case SyncEntityType.guardian:
        return item.operation == SyncOperation.delete
            ? _guardianRepository.retrySyncDelete(id, date)
            : _guardianRepository.retrySyncUpdate(id, date);

      case SyncEntityType.classModel:
        return item.operation == SyncOperation.delete
            ? _classRepository.retrySyncDelete(id, date)
            : _classRepository.retrySyncUpdate(id, date);

      case SyncEntityType.studentClass:
        return _classRepository.retrySyncStudentClass(id, item.payload ?? '', date);
    }
  }
}
