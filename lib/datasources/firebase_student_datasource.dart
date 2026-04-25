import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/student.dart';

/// Datasource Firebase pour les étudiants
/// Gère la synchronisation avec Firestore
class FirebaseStudentDatasource {
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;
  static const String _collection = 'students';

  /// Ajoute un élève à Firestore
  Future<void> addStudent(Student student, String markazId) async {
    try {
      await _firestore.collection(_collection).doc(student.id).set({
        'id': student.id,
        'name': student.name,
        'parentPhone': student.parentPhone,
        'markazId': markazId,
        'createdAt': student.createdAt.toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Erreur Firebase: $e');
    }
  }

  /// Met à jour un élève dans Firestore
  Future<void> updateStudent(Student student, String markazId) async {
    try {
      await _firestore.collection(_collection).doc(student.id).update({
        'name': student.name,
        'parentPhone': student.parentPhone,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Erreur Firebase: $e');
    }
  }

  /// Supprime un élève de Firestore
  Future<void> deleteStudent(String studentId) async {
    try {
      await _firestore.collection(_collection).doc(studentId).delete();
    } catch (e) {
      throw Exception('Erreur Firebase: $e');
    }
  }

  /// Récupère un élève de Firestore
  Future<Student?> getStudent(String studentId) async {
    try {
      final doc = await _firestore.collection(_collection).doc(studentId).get();
      if (!doc.exists) return null;
      return _mapDocToStudent(doc);
    } catch (e) {
      throw Exception('Erreur Firebase: $e');
    }
  }

  /// Récupère tous les élèves d'une Markaz en temps réel
  Stream<List<Student>> getStudentsByMarkazStream(String markazId) {
    return _firestore
        .collection(_collection)
        .where('markazId', isEqualTo: markazId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => _mapDocToStudent(doc)).toList();
    }).handleError((e) {
      throw Exception('Erreur Firebase Stream: $e');
    });
  }

  /// Récupère tous les élèves d'une Markaz (une seule fois)
  Future<List<Student>> getStudentsByMarkaz(String markazId) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('markazId', isEqualTo: markazId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) => _mapDocToStudent(doc)).toList();
    } catch (e) {
      throw Exception('Erreur Firebase: $e');
    }
  }

  /// Convertit un document Firestore en Student
  Student _mapDocToStudent(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Student(
      id: data['id'] as String,
      name: data['name'] as String,
      parentPhone: data['parentPhone'] as String,
      markazId: data['markazId'] as String,
      createdAt: DateTime.parse(data['createdAt'] as String),
    );
  }
}
