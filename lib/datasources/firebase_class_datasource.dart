import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/class_model.dart';

/// Datasource Firebase pour les classes
/// Gère la synchronisation avec Firestore
class FirebaseClassDatasource {
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;
  static const String _collection = 'classes';

  /// Ajoute une classe à Firestore
  Future<void> addClass(ClassModel classModel, String markazId) async {
    try {
      await _firestore.collection(_collection).doc(classModel.id).set({
        'id': classModel.id,
        'name': classModel.name,
        'level': classModel.level,
        'description': classModel.description,
        'teacherId': classModel.teacherId,
        'teacherName': classModel.teacherName,
        'maxStudents': classModel.maxStudents,
        'studentIds': classModel.studentIds,
        'markazId': markazId,
        'createdAt': classModel.createdAt.toIso8601String(),
        'isActive': classModel.isActive,
        'schedule': classModel.schedule,
        'room': classModel.room,
      });
    } catch (e) {
      throw Exception('Erreur Firebase: $e');
    }
  }

  /// Met à jour une classe dans Firestore
  Future<void> updateClass(ClassModel classModel) async {
    try {
      await _firestore.collection(_collection).doc(classModel.id).update({
        'name': classModel.name,
        'level': classModel.level,
        'description': classModel.description,
        'teacherId': classModel.teacherId,
        'teacherName': classModel.teacherName,
        'maxStudents': classModel.maxStudents,
        'studentIds': classModel.studentIds,
        'isActive': classModel.isActive,
        'schedule': classModel.schedule,
        'room': classModel.room,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Erreur Firebase: $e');
    }
  }

  /// Supprime une classe de Firestore
  Future<void> deleteClass(String classId) async {
    try {
      await _firestore.collection(_collection).doc(classId).delete();
    } catch (e) {
      throw Exception('Erreur Firebase: $e');
    }
  }

  /// Récupère toutes les classes d'une Markaz en temps réel
  Stream<List<ClassModel>> getClassesByMarkazStream(String markazId) {
    return _firestore
        .collection(_collection)
        .where('markazId', isEqualTo: markazId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => _mapDocToClass(doc)).toList();
    }).handleError((e) {
      throw Exception('Erreur Firebase Stream: $e');
    });
  }

  /// Récupère toutes les classes d'une Markaz (une seule fois)
  Future<List<ClassModel>> getClassesByMarkaz(String markazId) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('markazId', isEqualTo: markazId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) => _mapDocToClass(doc)).toList();
    } catch (e) {
      throw Exception('Erreur Firebase: $e');
    }
  }

  /// Récupère les classes actives d'une Markaz
  Future<List<ClassModel>> getActiveClassesByMarkaz(String markazId) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('markazId', isEqualTo: markazId)
          .where('isActive', isEqualTo: true)
          .orderBy('name')
          .get();

      return snapshot.docs.map((doc) => _mapDocToClass(doc)).toList();
    } catch (e) {
      throw Exception('Erreur Firebase: $e');
    }
  }

  /// Récupère les classes par niveau
  Future<List<ClassModel>> getClassesByLevel(String markazId, String level) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('markazId', isEqualTo: markazId)
          .where('level', isEqualTo: level)
          .where('isActive', isEqualTo: true)
          .orderBy('name')
          .get();

      return snapshot.docs.map((doc) => _mapDocToClass(doc)).toList();
    } catch (e) {
      throw Exception('Erreur Firebase: $e');
    }
  }

  /// Récupère une classe par ID
  Future<ClassModel?> getClassById(String classId) async {
    try {
      final doc = await _firestore.collection(_collection).doc(classId).get();
      if (doc.exists) {
        return _mapDocToClass(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Erreur Firebase: $e');
    }
  }

  /// Ajoute un élève à une classe
  Future<void> addStudentToClass(String classId, String studentId) async {
    try {
      final classDoc = await _firestore.collection(_collection).doc(classId).get();
      if (classDoc.exists) {
        final classData = classDoc.data()!;
        final studentIds = List<String>.from(classData['studentIds'] ?? []);
        
        if (!studentIds.contains(studentId)) {
          studentIds.add(studentId);
          await _firestore.collection(_collection).doc(classId).update({
            'studentIds': studentIds,
            'updatedAt': DateTime.now().toIso8601String(),
          });
        }
      }
    } catch (e) {
      throw Exception('Erreur Firebase: $e');
    }
  }

  /// Retire un élève d'une classe
  Future<void> removeStudentFromClass(String classId, String studentId) async {
    try {
      final classDoc = await _firestore.collection(_collection).doc(classId).get();
      if (classDoc.exists) {
        final classData = classDoc.data()!;
        final studentIds = List<String>.from(classData['studentIds'] ?? []);
        
        studentIds.remove(studentId);
        await _firestore.collection(_collection).doc(classId).update({
          'studentIds': studentIds,
          'updatedAt': DateTime.now().toIso8601String(),
        });
      }
    } catch (e) {
      throw Exception('Erreur Firebase: $e');
    }
  }

  /// Convertit un document Firestore en ClassModel
  ClassModel _mapDocToClass(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return ClassModel(
      id: data['id'] as String? ?? doc.id,
      name: data['name'] as String? ?? '',
      level: data['level'] as String? ?? '',
      description: data['description'] as String? ?? '',
      teacherId: data['teacherId'] as String? ?? '',
      teacherName: data['teacherName'] as String? ?? '',
      maxStudents: data['maxStudents'] as int? ?? 20,
      studentIds: (data['studentIds'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      markazId: data['markazId'] as String? ?? '',
      createdAt: data['createdAt'] != null
          ? DateTime.parse(data['createdAt'] as String)
          : DateTime.now(),
      isActive: data['isActive'] as bool? ?? true,
      schedule: data['schedule'] as String?,
      room: data['room'] as String?,
    );
  }
}
