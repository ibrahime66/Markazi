import 'package:uuid/uuid.dart';
import '../models/attendance.dart';
import '../repositories/attendance_repository.dart';
import '../repositories/student_repository.dart';
import 'auth_service.dart';

/// Service métier pour la gestion des présences
/// Centralise la logique métier et les analytics d'assiduité
class AttendanceService {
  final AttendanceRepository _repository;
  final StudentRepository _studentRepository;
  final AuthService _authService;

  AttendanceService(
    this._repository,
    this._studentRepository,
    this._authService,
  );

  /// Marque un élève comme présent
  Future<Attendance> markPresent({
    required String studentId,
    required String markazId,
    required String lesson,
  }) async {
    return _recordAttendance(
      studentId,
      markazId,
      AttendanceStatus.present,
      lesson,
    );
  }

  /// Marque un élève comme absent
  Future<Attendance> markAbsent({
    required String studentId,
    required String markazId,
    required String lesson,
  }) async {
    return _recordAttendance(
      studentId,
      markazId,
      AttendanceStatus.absent,
      lesson,
    );
  }

  /// Marque un élève comme tardif
  Future<Attendance> markLate({
    required String studentId,
    required String markazId,
    required String lesson,
  }) async {
    return _recordAttendance(
      studentId,
      markazId,
      AttendanceStatus.late,
      lesson,
    );
  }

  /// Enregistre une présence
  Future<Attendance> _recordAttendance(
    String studentId,
    String markazId,
    AttendanceStatus status,
    String lesson,
  ) async {
    // Vérifier que l'élève existe
    final student = _studentRepository.getStudentById(studentId);
    if (student == null) {
      throw Exception('Élève non trouvé');
    }

    // Vérifier l'accès multi-markaz
    if (!_authService.hasAccessToMarkaz(markazId)) {
      throw Exception('Accès refusé à cette Markaz');
    }

    // Vérifier que la leçon n'est pas vide
    if (lesson.isEmpty) {
      throw Exception('Le nom de la leçon est obligatoire');
    }

    // Vérifier s'il y a déjà un enregistrement pour aujourd'hui
    if (_hasAlreadyRecorded(studentId, markazId, lesson)) {
      throw Exception(
        'Cet élève a déjà une présence enregistrée pour cette leçon.',
      );
    }

    // Créer l'enregistrement
    const uuid = Uuid();
    final attendance = Attendance(
      id: uuid.v4(),
      studentId: studentId,
      markazId: markazId,
      date: DateTime.now(),
      status: status,
      lesson: lesson.trim(),
    );

    await _repository.addAttendance(attendance);
    return attendance;
  }

  /// Calcule le taux de présence hebdomadaire d'un élève
  Map<String, dynamic> getWeeklyAttendanceRate(
    String studentId, {
    DateTime? referenceDate,
  }) {
    final student = _studentRepository.getStudentById(studentId);
    if (student == null) {
      throw Exception('Élève non trouvé');
    }

    // Vérifier l'accès multi-markaz
    if (!_authService.hasAccessToMarkaz(student.markazId)) {
      throw Exception('Accès refusé à cet élève');
    }

    final now = referenceDate ?? DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 7));

    final allAttendances = _repository.getAllAttendances();
    final weekAttendances = allAttendances
        .where((a) =>
            a.studentId == studentId &&
            a.date.isAfter(weekStart) &&
            a.date.isBefore(weekEnd))
        .toList();

    final present = weekAttendances
        .where((a) => a.status == AttendanceStatus.present)
        .length;
    final absent = weekAttendances
        .where((a) => a.status == AttendanceStatus.absent)
        .length;
    final late =
        weekAttendances.where((a) => a.status == AttendanceStatus.late).length;

    final total = weekAttendances.length;
    final rate =
        total == 0 ? '0.00' : (present / total * 100).toStringAsFixed(2);

    return {
      'weekStart': weekStart.toIso8601String(),
      'weekEnd': weekEnd.toIso8601String(),
      'presentCount': present,
      'absentCount': absent,
      'lateCount': late,
      'totalRecords': total,
      'attendanceRate': '$rate%',
      'status': _getAttendanceStatus(double.parse(rate)),
    };
  }

  /// Calcule le taux de présence mensuel d'un élève
  Map<String, dynamic> getMonthlyAttendanceRate(
    String studentId, {
    int? month,
    int? year,
  }) {
    final student = _studentRepository.getStudentById(studentId);
    if (student == null) {
      throw Exception('Élève non trouvé');
    }

    // Vérifier l'accès multi-markaz
    if (!_authService.hasAccessToMarkaz(student.markazId)) {
      throw Exception('Accès refusé à cet élève');
    }

    final now = DateTime.now();
    final targetMonth = month ?? now.month;
    final targetYear = year ?? now.year;

    final monthStart = DateTime(targetYear, targetMonth);
    final monthEnd = DateTime(targetYear, targetMonth + 1);

    final allAttendances = _repository.getAllAttendances();
    final monthAttendances = allAttendances
        .where((a) =>
            a.studentId == studentId &&
            a.date.isAfter(monthStart) &&
            a.date.isBefore(monthEnd))
        .toList();

    final present = monthAttendances
        .where((a) => a.status == AttendanceStatus.present)
        .length;
    final absent = monthAttendances
        .where((a) => a.status == AttendanceStatus.absent)
        .length;
    final late =
        monthAttendances.where((a) => a.status == AttendanceStatus.late).length;

    final total = monthAttendances.length;
    final rate =
        total == 0 ? '0.00' : (present / total * 100).toStringAsFixed(2);

    return {
      'month': targetMonth,
      'year': targetYear,
      'presentCount': present,
      'absentCount': absent,
      'lateCount': late,
      'totalRecords': total,
      'attendanceRate': '$rate%',
      'recommendedAction': _getRecommendedAction(double.parse(rate), absent),
    };
  }

  /// Génère un rapport hebdomadaire simulé
  /// Phase 4: Intégration PDF
  Future<Map<String, dynamic>> generateWeeklyReport() async {
    final markazId = _authService.currentMarkazId;
    if (markazId == null) {
      throw Exception('Utilisateur non authentifié');
    }

    final allAttendances = _repository.getAllAttendances();
    final weekAttendances =
        allAttendances.where((a) => a.markazId == markazId).toList();

    return {
      'reportType': 'HEBDOMADAIRE',
      'markazId': markazId,
      'generatedDate': DateTime.now().toIso8601String(),
      'totalRecords': weekAttendances.length,
      'summary': 'Rapport hebdomadaire des présences généré automatiquement.',
    };
  }

  /// Génère un rapport mensuel simulé
  /// Phase 4: Intégration PDF
  Future<Map<String, dynamic>> generateMonthlyReport({
    int? month,
    int? year,
  }) async {
    final markazId = _authService.currentMarkazId;
    if (markazId == null) {
      throw Exception('Utilisateur non authentifié');
    }

    final now = DateTime.now();
    final targetMonth = month ?? now.month;
    final targetYear = year ?? now.year;

    return {
      'reportType': 'MENSUEL',
      'markazId': markazId,
      'month': targetMonth,
      'year': targetYear,
      'generatedDate': DateTime.now().toIso8601String(),
      'summary':
          'Rapport mensuel des présences pour $targetMonth/$targetYear généré automatiquement.',
    };
  }

  /// Obtient les statistiques d'usage pour la markaz
  Map<String, dynamic> getMarkzaAttendanceStatistics() {
    final markazId = _authService.currentMarkazId;
    if (markazId == null) {
      throw Exception('Utilisateur non authentifié');
    }

    final allAttendances = _repository.getAllAttendances();
    final markazAttendances =
        allAttendances.where((a) => a.markazId == markazId).toList();

    final present = markazAttendances
        .where((a) => a.status == AttendanceStatus.present)
        .length;
    final absent = markazAttendances
        .where((a) => a.status == AttendanceStatus.absent)
        .length;
    final late = markazAttendances
        .where((a) => a.status == AttendanceStatus.late)
        .length;

    return {
      'totalRecords': markazAttendances.length,
      'presentCount': present,
      'absentCount': absent,
      'lateCount': late,
      'averageAttendanceRate': markazAttendances.isEmpty
          ? '0%'
          : '${(present / markazAttendances.length * 100).toStringAsFixed(2)}%',
    };
  }

  /// Obtient les présences d'aujourd'hui pour une markaz
  List<Attendance> getTodayAttendance() {
    final markazId = _authService.currentMarkazId;
    if (markazId == null) {
      throw Exception('Utilisateur non authentifié');
    }

    return _repository.getTodayAttendanceByMarkaz(markazId);
  }

  /// Vérifie s'il y a déjà un enregistrement
  bool _hasAlreadyRecorded(
    String studentId,
    String markazId,
    String lesson,
  ) {
    final today = DateTime.now();
    final todayStart = DateTime(today.year, today.month, today.day);
    final todayEnd = todayStart.add(const Duration(days: 1));

    final allAttendances = _repository.getAllAttendances();
    return allAttendances.any((a) =>
        a.studentId == studentId &&
        a.markazId == markazId &&
        a.lesson == lesson &&
        a.date.isAfter(todayStart) &&
        a.date.isBefore(todayEnd));
  }

  /// Obtient le statut de présence basé sur le pourcentage
  String _getAttendanceStatus(double rate) {
    if (rate >= 90) return 'EXCELLENT';
    if (rate >= 80) return 'BON';
    if (rate >= 70) return 'ACCEPTABLE';
    if (rate >= 60) return 'FAIBLE';
    return 'TRÈS FAIBLE';
  }

  /// Recommande une action basée sur le taux et le nombre d'absences
  String _getRecommendedAction(double rate, int absentCount) {
    if (rate < 60 && absentCount > 3) {
      return 'CONTACTER LES PARENTS - Absences fréquentes';
    }
    if (rate < 70) {
      return 'ALERTER - Assiduité insuffisante';
    }
    if (rate >= 90) {
      return 'BON - Continuer ainsi';
    }
    return 'SURVEILLER - Amélioration nécessaire';
  }

  /// Synchronise les données depuis Firebase pour la markaz actuelle
  Future<void> syncFromFirebase() async {
    final markazId = _authService.currentMarkazId;
    if (markazId != null) {
      print('Début sync Firebase attendance pour markaz: $markazId');
      await _repository.syncFromMarkaz(markazId);
      print('Sync Firebase attendance terminée');
    } else {
      print('Impossible de sync attendance: markazId null');
    }
  }
}
