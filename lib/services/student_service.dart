import 'package:uuid/uuid.dart';
import '../models/student.dart';
import '../repositories/student_repository.dart';
import 'auth_service.dart';

/// Service métier pour la gestion des élèves
/// Centralise la logique métier et les validations
class StudentService {
  final StudentRepository _repository;
  final AuthService _authService;

  StudentService(this._repository, this._authService);

  /// Crée un nouvel élève avec validations métier
  Future<Student> createStudent({
    required String name,
    required String parentPhone,
    String? markazId,
  }) async {
    // Validation du nom
    if (name.isEmpty) {
      throw Exception('Le nom de l\'élève est obligatoire');
    }

    if (name.length < 3) {
      throw Exception('Le nom doit contenir au moins 3 caractères');
    }

    // Validation du numéro parent
    if (!_isValidPhoneNumber(parentPhone)) {
      throw Exception(
        'Numéro de téléphone invalide. Format accepté: 9 chiffres (ex: 622180933)',
      );
    }

    // Utiliser le markazId de l'utilisateur actuel si non fourni
    final finalMarkazId = markazId ?? _authService.currentMarkazId;

    if (finalMarkazId == null) {
      throw Exception('Markaz ID obligatoire et pas d\'utilisateur connecté');
    }

    // Vérifier l'accès multi-markaz
    if (!_authService.hasAccessToMarkaz(finalMarkazId)) {
      throw Exception('Accès refusé à cette Markaz');
    }

    // Créer l'élève
    const uuid = Uuid();
    final student = Student(
      id: uuid.v4(),
      name: name.trim(),
      parentPhone: parentPhone.trim(),
      markazId: finalMarkazId,
      createdAt: DateTime.now(),
    );

    // Persister
    await _repository.addStudent(student);

    return student;
  }

  /// Valide et met à jour un élève
  Future<Student> updateStudent({
    required String studentId,
    required String name,
    required String parentPhone,
  }) async {
    // Récupérer l'élève existant
    final existingStudent = _repository.getStudentById(studentId);
    if (existingStudent == null) {
      throw Exception('Élève non trouvé');
    }

    // Vérifier l'accès multi-markaz
    if (!_authService.hasAccessToMarkaz(existingStudent.markazId)) {
      throw Exception('Accès refusé à cette Markaz');
    }

    // Validations
    if (name.isEmpty || name.length < 3) {
      throw Exception('Nom invalide (3+ caractères)');
    }

    if (!_isValidPhoneNumber(parentPhone)) {
      throw Exception(
          'Numéro de téléphone invalide. Format accepté: 9 chiffres (ex: 622180933)');
    }

    // Mettre à jour
    final updatedStudent = existingStudent.copyWith(
      name: name.trim(),
      parentPhone: parentPhone.trim(),
    );

    await _repository.updateStudent(updatedStudent);

    return updatedStudent;
  }

  /// Supprime un élève (soft delete dans une vraie app)
  Future<void> deleteStudent(String studentId) async {
    final student = _repository.getStudentById(studentId);
    if (student == null) {
      throw Exception('Élève non trouvé');
    }

    // Vérifier l'accès multi-markaz
    if (!_authService.hasAccessToMarkaz(student.markazId)) {
      throw Exception('Accès refusé à cette Markaz');
    }

    await _repository.removeStudent(studentId);
  }

  /// Récupère tous les élèves de la Markaz actuelle
  List<Student> getStudentsForCurrentMarkaz() {
    final markazId = _authService.currentMarkazId;
    if (markazId == null) {
      throw Exception('Utilisateur non authentifié');
    }
    return _repository.getStudentsByMarkaz(markazId);
  }

  /// Récupère un élève avec vérification d'accès
  Student? getStudentById(String studentId) {
    final student = _repository.getStudentById(studentId);
    if (student != null && !_authService.hasAccessToMarkaz(student.markazId)) {
      throw Exception('Accès refusé à cet élève');
    }
    return student;
  }

  /// Obtient des statistiques sur les élèves
  Map<String, dynamic> getStudentStatistics() {
    final markazId = _authService.currentMarkazId;
    if (markazId == null) {
      throw Exception('Utilisateur non authentifié');
    }

    final students = _repository.getStudentsByMarkaz(markazId);
    return {
      'totalCount': students.length,
      'byMonth': _groupStudentsByMonth(students),
      'latestAdditions': students.toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt))
        ..take(5).toList(),
    };
  }

  /// Valide un numéro de téléphone guinéen (9 chiffres)
  bool _isValidPhoneNumber(String phoneNumber) {
    final cleanedPhone = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');

    // Format accepté: 9 chiffres (numéro guinéen)
    // Exemple: 622180933
    return RegExp(r'^\d{9}$').hasMatch(cleanedPhone);
  }

  /// Groupe les élèves par mois de création
  Map<String, int> _groupStudentsByMonth(List<Student> students) {
    final grouped = <String, int>{};
    for (final student in students) {
      final monthKey = '${student.createdAt.year}-'
          '${student.createdAt.month.toString().padLeft(2, '0')}';
      grouped[monthKey] = (grouped[monthKey] ?? 0) + 1;
    }
    return grouped;
  }

  /// Synchronise les données depuis Firebase pour la markaz actuelle
  Future<void> syncFromFirebase() async {
    final markazId = _authService.currentMarkazId;
    if (markazId != null) {
      print('Début sync Firebase pour markaz: $markazId');
      await _repository.syncFromMarkaz(markazId);
      print('Sync Firebase terminée');
    } else {
      print('Impossible de sync: markazId null');
    }
  }

  /// Synchronise les données depuis Firebase pour un markaz spécifique
  Future<void> syncFromMarkaz(String markazId) async {
    await _repository.syncFromMarkaz(markazId);
  }
}
