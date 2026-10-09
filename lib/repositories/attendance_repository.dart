import 'package:flutter/foundation.dart';
import '../models/attendance.dart';
import '../models/sync_queue_item.dart';
import '../datasources/hive_attendance_datasource.dart';
import '../datasources/api_attendance_datasource.dart';
import '../services/api_client.dart';
import '../services/sync_queue_service.dart';

/// Repository pour la gestion des données Attendance.
/// Utilise l'API Laravel avec cache Hive local pour mode hors ligne.
class AttendanceRepository {
  final HiveAttendanceDataSource _hiveDataSource;
  final ApiAttendanceDatasource _apiDataSource;
  final SyncQueueService _syncQueue;

  AttendanceRepository(this._hiveDataSource, this._apiDataSource, this._syncQueue);

  /// Initialise le repository et ouvre la box Hive via le data source
  Future<void> init() async {
    await _hiveDataSource.init();
  }

  /// Ajoute une nouvelle présence. Retourne la présence telle que persistée
  /// côté serveur (avec son identifiant réel).
  ///
  /// Hors ligne (CDC §20 : présences "lecture et saisie" hors ligne) : la
  /// présence est conservée localement et envoyée à la reconnexion, avec sa
  /// date réelle de saisie.
  Future<Attendance> addAttendance(Attendance attendance) async {
    try {
      final saved = await _apiDataSource.addAttendance(attendance, attendance.markazId);
      await _hiveDataSource.addAttendance(saved);
      return saved;
    } catch (e, st) {
      if (!ApiClient.isOfflineError(e)) ApiClient.throwReadable(e, st);
      debugPrint('Hors ligne : présence mise en file ($e)');
      await _hiveDataSource.addAttendance(attendance);
      await _syncQueue.enqueue(
        entityType: SyncEntityType.attendance,
        operation: SyncOperation.create,
        entityId: attendance.id,
      );
      return attendance;
    }
  }

  /// Supprime une présence par ID (mise en file si le serveur est
  /// injoignable ; un refus du serveur restaure la présence et remonte
  /// l'erreur).
  Future<void> removeAttendance(String attendanceId) async {
    final previous = _hiveDataSource.getAttendanceById(attendanceId);
    await _hiveDataSource.deleteAttendance(attendanceId);

    if (_syncQueue.hasPendingCreate(SyncEntityType.attendance, attendanceId)) {
      await _syncQueue.enqueue(
        entityType: SyncEntityType.attendance,
        operation: SyncOperation.delete,
        entityId: attendanceId,
      );
      return;
    }

    try {
      await _apiDataSource.deleteAttendance(attendanceId);
      await _syncQueue.resolve(SyncEntityType.attendance, attendanceId);
    } catch (e, st) {
      if (!ApiClient.isOfflineError(e)) {
        if (previous != null) await _hiveDataSource.addAttendance(previous);
        ApiClient.throwReadable(e, st);
      }
      debugPrint('Hors ligne : suppression de présence mise en file ($e)');
      await _syncQueue.enqueue(
        entityType: SyncEntityType.attendance,
        operation: SyncOperation.delete,
        entityId: attendanceId,
      );
    }
  }

  /// Met à jour une présence (mise en file pour rejeu automatique si le
  /// serveur est injoignable — CDC section 20, doc/audit.md points D2/F5 ;
  /// un refus du serveur annule la modification locale et remonte l'erreur).
  Future<void> updateAttendance(Attendance attendance) async {
    final previous = _hiveDataSource.getAttendanceById(attendance.id);
    await _hiveDataSource.updateAttendance(attendance);

    if (_syncQueue.hasPendingCreate(SyncEntityType.attendance, attendance.id)) {
      await _syncQueue.enqueue(
        entityType: SyncEntityType.attendance,
        operation: SyncOperation.update,
        entityId: attendance.id,
      );
      return;
    }

    try {
      final saved = await _apiDataSource.updateAttendance(attendance);
      await _hiveDataSource.updateAttendance(saved);
      await _syncQueue.resolve(SyncEntityType.attendance, attendance.id);
    } catch (e, st) {
      if (!ApiClient.isOfflineError(e)) {
        if (previous != null) await _hiveDataSource.updateAttendance(previous);
        ApiClient.throwReadable(e, st);
      }
      debugPrint('Hors ligne : mise à jour de présence mise en file ($e)');
      await _syncQueue.enqueue(
        entityType: SyncEntityType.attendance,
        operation: SyncOperation.update,
        entityId: attendance.id,
      );
    }
  }

  /// Rejoue une création faite hors ligne — réservé à SyncOrchestrator.
  /// Remplace l'identifiant temporaire local par l'identifiant serveur.
  Future<void> retrySyncCreate(String attendanceId, DateTime performedAt) async {
    final attendance = _hiveDataSource.getAttendanceById(attendanceId);
    if (attendance == null) return;
    final saved = await _apiDataSource.addAttendance(
      attendance,
      attendance.markazId,
      performedAt: performedAt,
    );
    await _hiveDataSource.deleteAttendance(attendanceId);
    await _hiveDataSource.addAttendance(saved);
  }

  /// Rejoue une mise à jour en attente — réservé à SyncOrchestrator.
  Future<void> retrySyncUpdate(String attendanceId, DateTime performedAt) async {
    final attendance = _hiveDataSource.getAttendanceById(attendanceId);
    if (attendance == null) return;
    final saved = await _apiDataSource.updateAttendance(attendance, performedAt: performedAt);
    await _hiveDataSource.updateAttendance(saved);
  }

  /// Rejoue une suppression en attente — réservé à SyncOrchestrator.
  Future<void> retrySyncDelete(String attendanceId, DateTime performedAt) async {
    await _apiDataSource.deleteAttendance(attendanceId, performedAt: performedAt);
  }

  /// Retire du cache local une présence créée hors ligne dont l'envoi a été
  /// abandonné par l'utilisateur.
  Future<void> discardLocal(String attendanceId) async {
    await _hiveDataSource.deleteAttendance(attendanceId);
  }

  /// Résumé lisible pour l'écran "Synchronisation".
  String? describe(String attendanceId) {
    return _hiveDataSource.getAttendanceById(attendanceId)?.lesson;
  }

  /// Récupère une présence par ID
  Attendance? getAttendanceById(String attendanceId) {
    return _hiveDataSource.getAttendanceById(attendanceId);
  }

  /// Récupère toutes les présences
  List<Attendance> getAllAttendances() {
    return _hiveDataSource.getAllAttendances();
  }

  /// Récupère toutes les présences d'un élève
  List<Attendance> getAttendancesByStudent(String studentId) {
    return _hiveDataSource.getAttendancesByStudent(studentId);
  }

  /// Récupère toutes les présences d'une Markaz
  List<Attendance> getAttendancesByMarkaz(String markazId) {
    return _hiveDataSource.getAttendancesByMarkaz(markazId);
  }

  /// Obtient les présences du jour pour une Markaz
  List<Attendance> getTodayAttendanceByMarkaz(String markazId) {
    return _hiveDataSource.getTodayAttendanceByMarkaz(markazId);
  }

  /// Retourne le taux de présence d'un élève (en %)
  double getAttendanceRateForStudent(String studentId) {
    return _hiveDataSource.getAttendanceRateForStudent(studentId);
  }

  /// Retourne le nombre d'absences d'un élève
  int getAbsenceCountForStudent(String studentId) {
    return _hiveDataSource.getAbsenceCountForStudent(studentId);
  }

  /// Retourne le nombre de présences d'un élève
  int getPresentCountForStudent(String studentId) {
    return _hiveDataSource.getPresentCountForStudent(studentId);
  }

  /// Retourne le nombre total de présences pour une Markaz
  int getTotalAttendanceCountByMarkaz(String markazId) {
    return _hiveDataSource.getTotalAttendanceCountByMarkaz(markazId);
  }

  /// Efface toutes les présences (utile pour les tests)
  Future<void> clearAll() async {
    await _hiveDataSource.clearAll();
  }

  /// Ferme la box (utile à l'arrêt de l'app)
  Future<void> close() async {
    await _hiveDataSource.close();
  }

  /// Recharge le cache local depuis l'API pour la Markaz donnée, sans
  /// écraser les saisies locales encore en attente de synchronisation
  /// (CDC §20).
  Future<void> syncFromMarkaz(String markazId) async {
    try {
      final attendances = await _apiDataSource.getAttendanceByMarkaz(markazId);
      final pendingIds = _syncQueue.pendingIds(SyncEntityType.attendance);
      final pendingLocal = pendingIds
          .map(_hiveDataSource.getAttendanceById)
          .whereType<Attendance>()
          .toList();
      await _hiveDataSource.clearAll();
      for (final attendance in attendances) {
        if (pendingIds.contains(attendance.id)) continue;
        await _hiveDataSource.addAttendance(attendance);
      }
      for (final attendance in pendingLocal) {
        await _hiveDataSource.addAttendance(attendance);
      }
    } catch (e) {
      debugPrint('Erreur sync API (présences) : $e');
    }
  }
}
