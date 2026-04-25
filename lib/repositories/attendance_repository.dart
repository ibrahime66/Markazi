import 'package:hive_flutter/hive_flutter.dart';
import '../models/attendance.dart';
import '../datasources/firebase_attendance_datasource.dart';
import '../services/firebase_helper.dart';

/// Repository pour la gestion des données Attendance
/// Utilise Firebase avec cache Hive local pour mode hors ligne
class AttendanceRepository {
  static const String _boxName = 'attendances';
  late Box<Attendance> _box;
  final FirebaseAttendanceDatasource _firebaseDatasource = FirebaseAttendanceDatasource();

  /// Initialise le repository et ouvre la box Hive
  Future<void> init() async {
    _box = await Hive.openBox<Attendance>(_boxName);
    
    // Synchroniser depuis Firebase au démarrage si disponible
    if (FirebaseHelper.isAvailable) {
      await Future.delayed(const Duration(seconds: 1));
      await _syncFromFirebase();
    }
  }

  /// Ajoute une nouvelle présence
  Future<void> addAttendance(Attendance attendance) async {
    // Sauvegarder localement d'abord (cache)
    await _box.put(attendance.id, attendance);
    
    // Synchroniser avec Firebase si disponible
    if (FirebaseHelper.isAvailable) {
      try {
        await _firebaseDatasource.addAttendance(attendance, attendance.markazId);
      } catch (e) {
        print('Erreur sync Firebase attendance: $e');
      }
    }
  }

  /// Supprime une présence par ID
  Future<void> removeAttendance(String attendanceId) async {
    // Supprimer localement
    await _box.delete(attendanceId);
    
    // Synchroniser avec Firebase si disponible
    if (FirebaseHelper.isAvailable) {
      try {
        await _firebaseDatasource.deleteAttendance(attendanceId);
      } catch (e) {
        print('Erreur sync Firebase attendance: $e');
      }
    }
  }

  /// Met à jour une présence
  Future<void> updateAttendance(Attendance attendance) async {
    // Mettre à jour localement
    await _box.put(attendance.id, attendance);
    
    // Synchroniser avec Firebase si disponible
    if (FirebaseHelper.isAvailable) {
      try {
        await _firebaseDatasource.updateAttendance(attendance);
      } catch (e) {
        print('Erreur sync Firebase attendance: $e');
      }
    }
  }

  /// Récupère une présence par ID
  Attendance? getAttendanceById(String attendanceId) {
    return _box.get(attendanceId);
  }

  /// Récupère toutes les présences
  List<Attendance> getAllAttendances() {
    return _box.values.toList();
  }

  /// Récupère toutes les présences d'un élève
  List<Attendance> getAttendancesByStudent(String studentId) {
    return _box.values.where((att) => att.studentId == studentId).toList();
  }

  /// Récupère toutes les présences d'une Markaz
  List<Attendance> getAttendancesByMarkaz(String markazId) {
    return _box.values.where((att) => att.markazId == markazId).toList();
  }

  /// Obtient les présences du jour pour une Markaz
  List<Attendance> getTodayAttendanceByMarkaz(String markazId) {
    final today = DateTime.now();
    return _box.values
        .where((att) =>
            att.markazId == markazId &&
            att.date.year == today.year &&
            att.date.month == today.month &&
            att.date.day == today.day)
        .toList();
  }

  /// Retourne le taux de présence d'un élève (en %)
  double getAttendanceRateForStudent(String studentId) {
    final allAttendances = getAttendancesByStudent(studentId);
    if (allAttendances.isEmpty) return 0.0;

    final presentCount =
        allAttendances.where((att) => att.status.name == 'present').length;
    return (presentCount / allAttendances.length) * 100;
  }

  /// Retourne le nombre d'absences d'un élève
  int getAbsenceCountForStudent(String studentId) {
    return _box.values
        .where(
            (att) => att.studentId == studentId && att.status.name == 'absent')
        .length;
  }

  /// Retourne le nombre de présences d'un élève
  int getPresentCountForStudent(String studentId) {
    return _box.values
        .where(
            (att) => att.studentId == studentId && att.status.name == 'present')
        .length;
  }

  /// Retourne le nombre total de présences pour une Markaz
  int getTotalAttendanceCountByMarkaz(String markazId) {
    return _box.values.where((att) => att.markazId == markazId).length;
  }

  /// Efface toutes les présences (utile pour les tests)
  Future<void> clearAll() async {
    await _box.clear();
  }

  /// Ferme la box (utile à l'arrêt de l'app)
  Future<void> close() async {
    await _box.close();
  }

  /// Synchronise les données depuis Firebase vers le cache local
  Future<void> _syncFromFirebase({String? markazId}) async {
    try {
      if (markazId != null) {
        // Récupérer les présences de cette markaz depuis Firebase
        final firebaseAttendances = await _firebaseDatasource.getAttendanceByMarkaz(markazId);
        
        // Vider le cache local et mettre à jour avec les données Firebase
        await _box.clear();
        for (final attendance in firebaseAttendances) {
          await _box.put(attendance.id, attendance);
        }
        
        print('Sync Firebase: ${firebaseAttendances.length} présences synchronisées pour markaz $markazId');
      } else {
        print('Sync Firebase: markazId non spécifié, sync ignorée');
      }
    } catch (e) {
      print('Erreur sync attendances depuis Firebase: $e');
    }
  }

  /// Force la synchronisation depuis Firebase pour une markaz spécifique
  Future<void> syncFromMarkaz(String markazId) async {
    await _syncFromFirebase(markazId: markazId);
  }
}
