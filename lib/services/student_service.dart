import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/student.dart';
import '../repositories/student_repository.dart';
import 'auth_service.dart';
import 'class_service.dart';

/// Service métier pour la gestion des élèves
/// Centralise la logique métier et les validations
class StudentService {
  final StudentRepository _repository;
  final AuthService _authService;
  final ClassService? _classService;

  StudentService(this._repository, this._authService, [this._classService]);

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
        'Numéro de téléphone invalide',
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

    // Objet local temporaire : son id sera remplacé par celui attribué par le
    // serveur (clé primaire MySQL) dès la réponse de l'API.
    const uuid = Uuid();
    final student = Student(
      id: uuid.v4(),
      name: name.trim(),
      parentPhone: parentPhone.trim(),
      markazId: finalMarkazId,
      createdAt: DateTime.now(),
    );

    // Persister et retourner l'élève tel qu'enregistré côté serveur
    return await _repository.addStudent(student);
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
          'Numéro de téléphone invalide');
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

    // Retirer l'élève de tous les groupes où il était inscrit
    if (_classService != null) {
      try {
        final allClasses = _classService!.getAllClasses();
        for (final classModel in allClasses) {
          if (classModel.studentIds.contains(studentId)) {
            await _classService!.removeStudentFromClass(classModel.id, studentId);
          }
        }
      } catch (e) {
        // Si erreur lors du retrait des groupes, on continue quand même
        debugPrint('Erreur lors du retrait de l\'élève des groupes: $e');
      }
    }

    await _repository.removeStudent(studentId);
  }

  /// Rattache (ou détache si [guardianId] est null) un élève à un tuteur
  /// (doc/audit.md, point I5).
  Future<Student> setGuardian(String studentId, String? guardianId) async {
    final existingStudent = _repository.getStudentById(studentId);
    if (existingStudent == null) {
      throw Exception('Élève non trouvé');
    }

    if (!_authService.hasAccessToMarkaz(existingStudent.markazId)) {
      throw Exception('Accès refusé à cette Markaz');
    }

    return await _repository.setGuardian(studentId, guardianId);
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

  /// Valide un numéro de téléphone. Auparavant limité à exactement 9
  /// chiffres (numéro guinéen) — bloquant pour un déploiement Play Store
  /// touchant d'autres pays (doc/audit.md, point I3). On se contente
  /// désormais d'une longueur plausible pour un numéro réel.
  bool _isValidPhoneNumber(String phoneNumber) {
    final cleanedPhone = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
    return cleanedPhone.length >= 6 && cleanedPhone.length <= 15;
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

  /// Synchronise les données depuis l'API pour la markaz actuelle
  Future<void> syncFromApi() async {
    final markazId = _authService.currentMarkazId;
    if (markazId != null) {
      debugPrint('Début sync API pour markaz: $markazId');
      await _repository.syncFromMarkaz(markazId);
      debugPrint('Sync API terminée');
    } else {
      debugPrint('Impossible de sync: markazId null');
    }
  }

  /// Synchronise les données depuis l'API pour un markaz spécifique
  Future<void> syncFromMarkaz(String markazId) async {
    await _repository.syncFromMarkaz(markazId);
  }
}
