import '../models/attendance.dart';
import '../datasources/hive_attendance_datasource.dart';
import '../datasources/firebase_attendance_datasource.dart';
import '../services/firebase_helper.dart';

/// Repository pour la gestion des données Attendance
/// Utilise Firebase avec cache Hive local pour mode hors ligne
class AttendanceRepository {
  final HiveAttendanceDataSource _hiveDataSource;
  final FirebaseAttendanceDataSource _firebaseDataSource;

  AttendanceRepository(this._hiveDataSource, this._firebaseDataSource);

  /// Initialise le repository et ouvre la box Hive via le data source
  Future<void> init() async {
    await _hiveDataSource.init();

    // Synchroniser depuis Firebase au démarrage si disponible
    if (FirebaseHelper.isAvailable) {
      await Future.delayed(const Duration(seconds: 1));
      await _syncFromFirebase();
    }
  }

  /// Ajoute une nouvelle présence
  Future<void> addAttendance(Attendance attendance) async {
    // Sauvegarder localement d'abord (cache)
    await _hiveDataSource.addAttendance(attendance);

    // Synchroniser avec Firebase si disponible
    if (FirebaseHelper.isAvailable) {
      try {
        await _firebaseDataSource.addAttendance(attendance, attendance.markazId);
      } catch (e) {
        print('Erreur sync Firebase attendance: $e');
      }
    }
  }

  /// Supprime une présence par ID
  Future<void> removeAttendance(String attendanceId) async {
    // Supprimer localement
    await _hiveDataSource.deleteAttendance(attendanceId);

    // Synchroniser avec Firebase si disponible
    if (FirebaseHelper.isAvailable) {
      try {
        await _firebaseDataSource.deleteAttendance(attendanceId);
      } catch (e) {
        print('Erreur sync Firebase attendance: $e');
      }
    }
  }

  /// Met à jour une présence
  Future<void> updateAttendance(Attendance attendance) async {
    // Mettre à jour localement
    await _hiveDataSource.updateAttendance(attendance);

    // Synchroniser avec Firebase si disponible
    if (FirebaseHelper.isAvailable) {
      try {
        await _firebaseDataSource.updateAttendance(attendance);
      } catch (e) {
        print('Erreur sync Firebase attendance: $e');
      }
    }
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

  /// Synchronise les données depuis Firebase vers le cache local
  Future<void> _syncFromFirebase({String? markazId}) async {
    try {
      if (markazId != null) {
        // Récupérer les présences de cette markaz depuis Firebase
        final firebaseAttendances = await _firebaseDataSource.getAttendanceByMarkaz(markazId);

        // Vider le cache local et mettre à jour avec les données Firebase
        await _hiveDataSource.clearAll();
        for (final attendance in firebaseAttendances) {
          await _hiveDataSource.addAttendance(attendance);
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