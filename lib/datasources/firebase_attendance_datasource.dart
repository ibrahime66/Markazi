import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/attendance.dart';

/// Datasource Firebase pour les présences
/// Gère la synchronisation avec Firestore
class FirebaseAttendanceDatasource {
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;
  static const String _collection = 'attendance';

  /// Ajoute une présence à Firestore
  Future<void> addAttendance(Attendance attendance, String markazId) async {
    try {
      await _firestore.collection(_collection).doc(attendance.id).set({
        'id': attendance.id,
        'studentId': attendance.studentId,
        'markazId': markazId,
        'date': attendance.date.toIso8601String(),
        'status': attendance.status.toString().split('.').last,
        'lesson': attendance.lesson,
        'createdAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Erreur Firebase: $e');
    }
  }

  /// Met à jour une présence dans Firestore
  Future<void> updateAttendance(Attendance attendance) async {
    try {
      await _firestore.collection(_collection).doc(attendance.id).update({
        'status': attendance.status.toString().split('.').last,
        'lesson': attendance.lesson,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Erreur Firebase: $e');
    }
  }

  /// Supprime une présence de Firestore
  Future<void> deleteAttendance(String attendanceId) async {
    try {
      await _firestore.collection(_collection).doc(attendanceId).delete();
    } catch (e) {
      throw Exception('Erreur Firebase: $e');
    }
  }

  /// Récupère toutes les présences d'une Markaz en temps réel
  Stream<List<Attendance>> getAttendanceByMarkazStream(String markazId) {
    return _firestore
        .collection(_collection)
        .where('markazId', isEqualTo: markazId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => _mapDocToAttendance(doc)).toList();
    }).handleError((e) {
      throw Exception('Erreur Firebase Stream: $e');
    });
  }

  /// Récupère toutes les présences d'une Markaz (une seule fois)
  Future<List<Attendance>> getAttendanceByMarkaz(String markazId) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('markazId', isEqualTo: markazId)
          .orderBy('date', descending: true)
          .get();

      return snapshot.docs.map((doc) => _mapDocToAttendance(doc)).toList();
    } catch (e) {
      throw Exception('Erreur Firebase: $e');
    }
  }

  /// Récupère les présences d'aujourd'hui pour une Markaz
  Future<List<Attendance>> getTodayAttendanceByMarkaz(String markazId) async {
    try {
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final snapshot = await _firestore
          .collection(_collection)
          .where('markazId', isEqualTo: markazId)
          .where('date', isGreaterThanOrEqualTo: startOfDay.toIso8601String())
          .where('date', isLessThan: endOfDay.toIso8601String())
          .get();

      return snapshot.docs.map((doc) => _mapDocToAttendance(doc)).toList();
    } catch (e) {
      throw Exception('Erreur Firebase: $e');
    }
  }

  /// Convertit un document Firestore en Attendance
  Attendance _mapDocToAttendance(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final statusStr = data['status'] as String;

    AttendanceStatus status;
    if (statusStr == 'present') {
      status = AttendanceStatus.present;
    } else if (statusStr == 'absent') {
      status = AttendanceStatus.absent;
    } else {
      status = AttendanceStatus.late;
    }

    return Attendance(
      id: data['id'] as String,
      studentId: data['studentId'] as String,
      markazId: data['markazId'] as String,
      date: DateTime.parse(data['date'] as String),
      status: status,
      lesson: data['lesson'] as String,
    );
  }
}
