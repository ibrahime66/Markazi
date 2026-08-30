import 'package:flutter/foundation.dart';
import '../models/student.dart';
import '../services/student_service.dart';

/// Provider pour gérer la liste des élèves
/// Utilise ChangeNotifier et StudentService pour la logique métier
/// Communique avec StudentService (pas directement avec repository)
class StudentProvider extends ChangeNotifier {
  final StudentService _service;
  List<Student> _students = [];
  String? _errorMessage;

  StudentProvider(this._service);

  /// Getter pour accéder à la liste des élèves
  List<Student> get students => _students;

  /// Getter pour accéder au dernier message d'erreur
  String? get errorMessage => _errorMessage;

  /// Charge les élèves depuis le service (filtrés par markaz actuel)
  Future<void> loadStudents() async {
    try {
      _errorMessage = null;
      _students = _service.getStudentsForCurrentMarkaz();
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  /// Ajoute un nouvel élève avec validations métier
  Future<void> addStudent({
    required String name,
    required String parentPhone,
    String? markazId,
  }) async {
    try {
      _errorMessage = null;
      final newStudent = await _service.createStudent(
        name: name,
        parentPhone: parentPhone,
        markazId: markazId,
      );
      _students = [..._students, newStudent];
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  /// Supprime un élève par ID
  Future<void> removeStudent(String studentId) async {
    try {
      _errorMessage = null;
      await _service.deleteStudent(studentId);
      _students =
          _students.where((student) => student.id != studentId).toList();
      
      // Retirer l'élève de tous les groupes où il était inscrit
      // Note: Cette opération nécessite d'accéder au ClassProvider
      // mais on ne peut pas injecter de provider dans un autre provider
      // On va gérer cela au niveau du service
      
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  /// Met à jour un élève
  Future<void> updateStudent({
    required String studentId,
    required String name,
    required String parentPhone,
  }) async {
    try {
      _errorMessage = null;
      final updatedStudent = await _service.updateStudent(
        studentId: studentId,
        name: name,
        parentPhone: parentPhone,
      );
      _students = _students.map((student) {
        if (student.id == updatedStudent.id) {
          return updatedStudent;
        }
        return student;
      }).toList();
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  /// Rattache (ou détache si [guardianId] est null) un élève à un tuteur
  /// (doc/audit.md, point I5).
  Future<void> setGuardian(String studentId, String? guardianId) async {
    try {
      _errorMessage = null;
      final updated = await _service.setGuardian(studentId, guardianId);
      _students = _students.map((s) => s.id == updated.id ? updated : s).toList();
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  /// Récupère un élève par ID
  Student? getStudentById(String studentId) {
    try {
      return _service.getStudentById(studentId);
    } catch (e) {
      _errorMessage = e.toString();
      return null;
    }
  }

  /// Retourne le nombre total d'élèves de la markaz actuelle
  int get totalStudents => _students.length;

  /// Obtient les statistiques sur les élèves
  Map<String, dynamic> get statistics => _service.getStudentStatistics();

  /// Efface le message d'erreur
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
