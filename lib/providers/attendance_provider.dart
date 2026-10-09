import 'package:flutter/foundation.dart';
import '../models/attendance.dart';
import '../services/attendance_service.dart';

/// Provider pour gérer la liste des présences
/// Utilise ChangeNotifier et AttendanceService pour la logique métier
class AttendanceProvider extends ChangeNotifier {
  final AttendanceService _service;
  List<Attendance> _attendances = [];
  String? _errorMessage;

  AttendanceProvider(this._service);

  /// Getter pour accéder à la liste des présences
  List<Attendance> get attendances => _attendances;

  /// Getter pour accéder au dernier message d'erreur
  String? get errorMessage => _errorMessage;

  /// Charge les présences depuis le service
  Future<void> loadAttendances() async {
    try {
      _errorMessage = null;
      _attendances = _service.getTodayAttendance();
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  /// Marque un élève présent
  Future<void> markPresent({
    required String studentId,
    required String markazId,
    required String lesson,
  }) async {
    try {
      _errorMessage = null;
      final newAttendance = await _service.markPresent(
        studentId: studentId,
        markazId: markazId,
        lesson: lesson,
      );
      _attendances = [..._attendances, newAttendance];
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  /// Marque un élève absent
  Future<void> markAbsent({
    required String studentId,
    required String markazId,
    required String lesson,
  }) async {
    try {
      _errorMessage = null;
      final newAttendance = await _service.markAbsent(
        studentId: studentId,
        markazId: markazId,
        lesson: lesson,
      );
      _attendances = [..._attendances, newAttendance];
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  /// Marque un élève comme tardif
  Future<void> markLate({
    required String studentId,
    required String markazId,
    required String lesson,
  }) async {
    try {
      _errorMessage = null;
      final newAttendance = await _service.markLate(
        studentId: studentId,
        markazId: markazId,
        lesson: lesson,
      );
      _attendances = [..._attendances, newAttendance];
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  /// Marque une absence justifiée (CDC §8.6)
  Future<void> markJustified({
    required String studentId,
    required String markazId,
    required String lesson,
  }) async {
    try {
      _errorMessage = null;
      final newAttendance = await _service.markJustified(
        studentId: studentId,
        markazId: markazId,
        lesson: lesson,
      );
      _attendances = [..._attendances, newAttendance];
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  /// Corrige une présence déjà enregistrée (statut et/ou leçon).
  Future<Attendance> updateAttendance({
    required String attendanceId,
    required AttendanceStatus status,
    required String lesson,
  }) async {
    try {
      _errorMessage = null;
      final updated = await _service.updateAttendance(
        attendanceId: attendanceId,
        status: status,
        lesson: lesson,
      );
      _attendances = [
        for (final a in _attendances) a.id == updated.id ? updated : a,
      ];
      notifyListeners();
      return updated;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  /// Obtient le taux de présence hebdomadaire d'un élève
  Map<String, dynamic> getWeeklyAttendanceRate(String studentId) {
    try {
      _errorMessage = null;
      return _service.getWeeklyAttendanceRate(studentId);
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return {};
    }
  }

  /// Obtient le taux de présence mensuel d'un élève
  Map<String, dynamic> getMonthlyAttendanceRate(String studentId) {
    try {
      _errorMessage = null;
      return _service.getMonthlyAttendanceRate(studentId);
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return {};
    }
  }

  /// Obtient les statistiques de présence pour la markaz
  Map<String, dynamic> get statistics =>
      _service.getMarkzaAttendanceStatistics();

  /// Génère un rapport hebdomadaire
  Future<Map<String, dynamic>> generateWeeklyReport() async {
    try {
      _errorMessage = null;
      return await _service.generateWeeklyReport();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  /// Génère un rapport mensuel
  Future<Map<String, dynamic>> generateMonthlyReport({
    int? month,
    int? year,
  }) async {
    try {
      _errorMessage = null;
      return await _service.generateMonthlyReport(month: month, year: year);
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  /// Efface le message d'erreur
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
