import 'package:flutter/foundation.dart';
import '../models/attendance.dart';
import '../models/sync_queue_item.dart';
import '../datasources/hive_attendance_datasource.dart';
import '../datasources/api_attendance_datasource.dart';
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
  Future<Attendance> addAttendance(Attendance attendance) async {
    final saved = await _apiDataSource.addAttendance(attendance, attendance.markazId);
    await _hiveDataSource.addAttendance(saved);
    return saved;
  }

  /// Supprime une présence par ID
  Future<void> removeAttendance(String attendanceId) async {
    await _hiveDataSource.deleteAttendance(attendanceId);
    try {
      await _apiDataSource.deleteAttendance(attendanceId);
    } catch (e) {
      debugPrint('Erreur sync API (suppression présence) : $e');
      await _syncQueue.enqueue(
        entityType: SyncEntityType.attendance,
        operation: SyncOperation.delete,
        entityId: attendanceId,
      );
    }
  }

  /// Met à jour une présence (mise en file pour rejeu automatique en cas
  /// d'échec — CDC section 20, doc/audit.md point D2).
  Future<void> updateAttendance(Attendance attendance) async {
    await _hiveDataSource.updateAttendance(attendance);
    try {
      final saved = await _apiDataSource.updateAttendance(attendance);
      await _hiveDataSource.updateAttendance(saved);
    } catch (e) {
      debugPrint('Erreur sync API (mise à jour présence) : $e');
      await _syncQueue.enqueue(
        entityType: SyncEntityType.attendance,
        operation: SyncOperation.update,
        entityId: attendance.id,
      );
    }
  }

  /// Rejoue une mise à jour en attente — réservé à SyncOrchestrator.
  Future<void> retrySyncUpdate(String attendanceId) async {
    final attendance = _hiveDataSource.getAttendanceById(attendanceId);
    if (attendance == null) return;
    final saved = await _apiDataSource.updateAttendance(attendance);
    await _hiveDataSource.updateAttendance(saved);
  }

  /// Rejoue une suppression en attente — réservé à SyncOrchestrator.
  Future<void> retrySyncDelete(String attendanceId) async {
    await _apiDataSource.deleteAttendance(attendanceId);
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

  /// Recharge le cache local depuis l'API pour la Markaz donnée.
  Future<void> syncFromMarkaz(String markazId) async {
    try {
      final attendances = await _apiDataSource.getAttendanceByMarkaz(markazId);
      await _hiveDataSource.clearAll();
      for (final attendance in attendances) {
        await _hiveDataSource.addAttendance(attendance);
      }
    } catch (e) {
      debugPrint('Erreur sync API (présences) : $e');
    }
  }
}
