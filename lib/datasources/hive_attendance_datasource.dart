import 'package:hive_flutter/hive_flutter.dart';
import '../models/attendance.dart';

/// Hive data source for Attendance entities.
class HiveAttendanceDataSource {
  static const String _boxName = 'attendances';
  late Box<Attendance> _box;

  /// Initialise la boîte Hive.
  Future<void> init() async {
    _box = await Hive.openBox<Attendance>(_boxName);
  }

  /// Ajoute une présence.
  Future<void> addAttendance(Attendance attendance) async {
    await _box.put(attendance.id, attendance);
  }

  /// Met à jour une présence.
  Future<void> updateAttendance(Attendance attendance) async {
    await _box.put(attendance.id, attendance);
  }

  /// Supprime une présence par ID.
  Future<void> deleteAttendance(String id) async {
    await _box.delete(id);
  }

  /// Récupère une présence par ID.
  Attendance? getAttendanceById(String id) {
    return _box.get(id);
  }

  /// Récupère toutes les présences.
  List<Attendance> getAllAttendances() {
    return _box.values.toList();
  }

  /// Récupère les présences d'un étudiant.
  List<Attendance> getAttendancesByStudent(String studentId) {
    return _box.values.where((a) => a.studentId == studentId).toList();
  }

  /// Récupère les présences d'une markaz.
  List<Attendance> getAttendancesByMarkaz(String markazId) {
    return _box.values.where((a) => a.markazId == markazId).toList();
  }

  /// Récupère les présences d'aujourd'hui pour une markaz.
  List<Attendance> getTodayAttendanceByMarkaz(String markazId) {
    final today = DateTime.now();
    return _box.values
        .where((a) =>
            a.markazId == markazId &&
            a.date.year == today.year &&
            a.date.month == today.month &&
            a.date.day == today.day)
        .toList();
  }

  /// Retourne le taux de présence pour un étudiant (pourcentage).
  double getAttendanceRateForStudent(String studentId) {
    final List<Attendance> atts = _box.values.where((a) => a.studentId == studentId).toList();
    if (atts.isEmpty) return 0.0;
    final int present = atts.where((a) => a.status == AttendanceStatus.present).length;
    return (present / atts.length) * 100.0;
  }

  /// Retourne le nombre d'absences d'un étudiant.
  int getAbsenceCountForStudent(String studentId) {
    return _box.values
        .where((a) => a.studentId == studentId && a.status == AttendanceStatus.absent)
        .length;
  }

  /// Retourne le nombre de présences d'un étudiant.
  int getPresentCountForStudent(String studentId) {
    return _box.values
        .where((a) => a.studentId == studentId && a.status == AttendanceStatus.present)
        .length;
  }

  /// Retourne le nombre total de présences pour une markaz.
  int getTotalAttendanceCountByMarkaz(String markazId) {
    return _box.values.where((a) => a.markazId == markazId).length;
  }

  /// Efface toutes les présences.
  Future<void> clearAll() async {
    await _box.clear();
  }

  /// Ferme la boîte Hive.
  Future<void> close() async {
    await _box.close();
  }
}