import 'package:flutter/foundation.dart';
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

  /// Marque une absence justifiée (CDC §8.6)
  Future<Attendance> markJustified({
    required String studentId,
    required String markazId,
    required String lesson,
  }) async {
    return _recordAttendance(
      studentId,
      markazId,
      AttendanceStatus.justified,
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

    // H7 : le serveur n'accepte qu'une présence par élève et par jour, toutes
    // leçons confondues (contrainte unique student_id+date, updateOrCreate).
    // On applique la même règle ici et on rend la main à l'écran, qui
    // propose de remplacer l'existante au lieu de l'écraser en silence.
    final existing = findTodayAttendance(studentId, markazId);
    if (existing != null) {
      throw AttendanceAlreadyRecordedException(existing);
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

    return await _repository.addAttendance(attendance);
  }

  /// Corrige une présence déjà enregistrée (statut et/ou leçon). La date
  /// n'est volontairement pas modifiable ici : la contrainte serveur
  /// `unique(student_id, date)` ferait échouer la requête si elle entre en
  /// collision avec un autre enregistrement du même élève (voir
  /// doc/audit.md, point H7 : une seule présence par élève et par jour) ;
  /// corriger le statut/la leçon couvre le besoin réel
  /// ("je me suis trompé en pointant la présence") sans ce risque.
  Future<Attendance> updateAttendance({
    required String attendanceId,
    required AttendanceStatus status,
    required String lesson,
  }) async {
    final existing = _repository.getAttendanceById(attendanceId);
    if (existing == null) {
      throw Exception('Présence non trouvée');
    }

    if (!_authService.hasAccessToMarkaz(existing.markazId)) {
      throw Exception('Accès refusé à cette Markaz');
    }

    if (lesson.trim().isEmpty) {
      throw Exception('Le nom de la leçon est obligatoire');
    }

    final updated = existing.copyWith(status: status, lesson: lesson.trim());
    // `updateAttendance` ne renvoie rien : elle écrit en local puis tente le
    // serveur en tâche de fond, avec remise en file en cas d'échec (mode
    // hors ligne — voir le commentaire sur cette méthode). On retourne donc
    // directement la version locale, déjà écrite au moment où l'appel revient.
    await _repository.updateAttendance(updated);
    return updated;
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
        .where((a) => a.status.isAbsence)
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
        .where((a) => a.status.isAbsence)
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
        .where((a) => a.status.isAbsence)
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

  /// Présence déjà enregistrée aujourd'hui pour cet élève, quelle que soit
  /// la leçon — même règle que la contrainte serveur (student_id, date).
  /// Comparaison par jour calendaire : une présence relue depuis l'API est
  /// datée de minuit pile, ce qu'un test `isAfter(minuit)` manquerait.
  Attendance? findTodayAttendance(String studentId, String markazId) {
    final today = DateTime.now();
    for (final a in _repository.getAllAttendances()) {
      if (a.studentId == studentId &&
          a.markazId == markazId &&
          a.date.year == today.year &&
          a.date.month == today.month &&
          a.date.day == today.day) {
        return a;
      }
    }
    return null;
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

  /// Synchronise les données depuis l'API pour la markaz actuelle
  Future<void> syncFromApi() async {
    final markazId = _authService.currentMarkazId;
    if (markazId != null) {
      debugPrint('Début sync API attendance pour markaz: $markazId');
      await _repository.syncFromMarkaz(markazId);
      debugPrint('Sync API attendance terminée');
    } else {
      debugPrint('Impossible de sync attendance: markazId null');
    }
  }
}

/// Levée quand l'élève a déjà une présence enregistrée le jour même
/// (doc/audit.md, point H7). Porte l'enregistrement existant pour que l'écran
/// puisse proposer de le remplacer.
class AttendanceAlreadyRecordedException implements Exception {
  final Attendance existing;

  AttendanceAlreadyRecordedException(this.existing);

  @override
  String toString() =>
      "Cet élève a déjà une présence enregistrée aujourd'hui "
      '(leçon : ${existing.lesson}).';
}
