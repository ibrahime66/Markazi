import '../models/class_model.dart';
import '../repositories/class_repository.dart';
import 'auth_service.dart';
import 'package:uuid/uuid.dart';

/// Service pour la gestion des classes
/// Encapsule la logique métier pour les classes
class ClassService {
  final ClassRepository _repository;
  final AuthService _authService;
  final String _markazId;

  ClassService(this._repository, this._authService) : _markazId = '';

  /// Crée une nouvelle classe avec validation
  Future<ClassModel> createClass({
    required String name,
    required String level,
    required String description,
    required String teacherName,
    int maxStudents = 20,
    String? schedule,
    String? room,
  }) async {
    // Validation des entrées
    if (name.trim().isEmpty) {
      throw Exception('Le nom de la classe est obligatoire');
    }

    if (level.trim().isEmpty) {
      throw Exception('Le niveau de la classe est obligatoire');
    }

    if (teacherName.trim().isEmpty) {
      throw Exception('Le nom de l\'enseignant est obligatoire');
    }

    if (maxStudents < 1 || maxStudents > 50) {
      throw Exception('Le nombre maximum d\'élèves doit être entre 1 et 50');
    }

    final markazId = _authService.currentMarkazId;
    if (markazId == null) {
      throw Exception('Utilisateur non authentifié');
    }

    // Vérifier si une classe avec le même nom existe déjà
    final existingClasses = _repository.getClassesByMarkaz(markazId);
    if (existingClasses.any((c) => c.name.toLowerCase() == name.toLowerCase())) {
      throw Exception('Une classe avec ce nom existe déjà');
    }

    // Créer la nouvelle classe
    final newClass = ClassModel(
      id: const Uuid().v4(),
      name: name.trim(),
      level: level.trim(),
      description: description.trim(),
      teacherId: _authService.currentUser?.id ?? 'unknown',
      teacherName: teacherName.trim(),
      maxStudents: maxStudents,
      studentIds: [],
      markazId: markazId,
      createdAt: DateTime.now(),
      schedule: schedule?.trim(),
      room: room?.trim(),
    );

    await _repository.addClass(newClass);
    return newClass;
  }

  /// Met à jour une classe
  Future<ClassModel> updateClass({
    required String classId,
    String? name,
    String? level,
    String? description,
    String? teacherName,
    int? maxStudents,
    String? schedule,
    String? room,
    bool? isActive,
  }) async {
    final existingClass = _repository.getClassById(classId);
    if (existingClass == null) {
      throw Exception('Classe non trouvée');
    }

    // Vérifier l'accès à cette classe
    if (!_authService.hasAccessToMarkaz(existingClass.markazId)) {
      throw Exception('Accès refusé à cette classe');
    }

    // Validation si le nom est modifié
    if (name != null && name.trim().isNotEmpty) {
      final markazId = _authService.currentMarkazId;
      if (markazId != null) {
        final existingClasses = _repository.getClassesByMarkaz(markazId);
        if (existingClasses.any((c) => 
            c.id != classId && 
            c.name.toLowerCase() == name!.toLowerCase())) {
          throw Exception('Une classe avec ce nom existe déjà');
        }
      }
    }

    // Validation du nombre maximum d'élèves
    if (maxStudents != null && (maxStudents < 1 || maxStudents > 50)) {
      throw Exception('Le nombre maximum d\'élèves doit être entre 1 et 50');
    }

    // Vérifier qu'on ne réduit pas le nombre de places en dessous du nombre actuel d'élèves
    if (maxStudents != null && maxStudents < existingClass.currentStudentCount) {
      throw Exception('Impossible de réduire le nombre de places en dessous du nombre actuel d\'élèves (${existingClass.currentStudentCount})');
    }

    final updatedClass = existingClass.copyWith(
      name: name?.trim(),
      level: level?.trim(),
      description: description?.trim(),
      teacherName: teacherName?.trim(),
      maxStudents: maxStudents,
      schedule: schedule?.trim(),
      room: room?.trim(),
      isActive: isActive,
    );

    await _repository.updateClass(updatedClass);
    return updatedClass;
  }

  /// Supprime une classe
  Future<void> deleteClass(String classId) async {
    final existingClass = _repository.getClassById(classId);
    if (existingClass == null) {
      throw Exception('Classe non trouvée');
    }

    // Vérifier l'accès à cette classe
    if (!_authService.hasAccessToMarkaz(existingClass.markazId)) {
      throw Exception('Accès refusé à cette classe');
    }

    // Vérifier que la classe n'a pas d'élèves
    if (existingClass.studentIds.isNotEmpty) {
      throw Exception('Impossible de supprimer une classe contenant des élèves');
    }

    await _repository.removeClass(classId);
  }

  /// Ajoute un élève à une classe
  Future<void> addStudentToClass(String classId, String studentId) async {
    final existingClass = _repository.getClassById(classId);
    if (existingClass == null) {
      throw Exception('Classe non trouvée');
    }

    // Vérifier l'accès à cette classe
    if (!_authService.hasAccessToMarkaz(existingClass.markazId)) {
      throw Exception('Accès refusé à cette classe');
    }

    if (existingClass.isFull) {
      throw Exception('La classe est déjà pleine (${existingClass.maxStudents} élèves)');
    }

    if (existingClass.studentIds.contains(studentId)) {
      throw Exception('L\'élève est déjà dans cette classe');
    }

    await _repository.addStudentToClass(classId, studentId);
  }

  /// Retire un élève d'une classe
  Future<void> removeStudentFromClass(String classId, String studentId) async {
    final existingClass = _repository.getClassById(classId);
    if (existingClass == null) {
      throw Exception('Classe non trouvée');
    }

    // Vérifier l'accès à cette classe
    if (!_authService.hasAccessToMarkaz(existingClass.markazId)) {
      throw Exception('Accès refusé à cette classe');
    }

    if (!existingClass.studentIds.contains(studentId)) {
      throw Exception('L\'élève n\'est pas dans cette classe');
    }

    await _repository.removeStudentFromClass(classId, studentId);
  }

  /// Récupère une classe par ID
  ClassModel? getClassById(String classId) {
    final classModel = _repository.getClassById(classId);
    if (classModel == null) return null;

    // Vérifier l'accès
    if (!_authService.hasAccessToMarkaz(classModel.markazId)) {
      throw Exception('Accès refusé à cette classe');
    }

    return classModel;
  }

  /// Récupère toutes les classes de la markaz actuelle
  List<ClassModel> getAllClasses() {
    final markazId = _authService.currentMarkazId;
    if (markazId == null) {
      throw Exception('Utilisateur non authentifié');
    }

    return _repository.getClassesByMarkaz(markazId);
  }

  /// Récupère les classes actives de la markaz actuelle
  List<ClassModel> getActiveClasses() {
    final markazId = _authService.currentMarkazId;
    if (markazId == null) {
      throw Exception('Utilisateur non authentifié');
    }

    return _repository.getActiveClassesByMarkaz(markazId);
  }

  /// Récupère les classes par niveau
  List<ClassModel> getClassesByLevel(String level) {
    final markazId = _authService.currentMarkazId;
    if (markazId == null) {
      throw Exception('Utilisateur non authentifié');
    }

    return _repository.getClassesByLevel(markazId, level);
  }

  /// Récupère les classes disponibles (non pleines)
  List<ClassModel> getAvailableClasses() {
    final markazId = _authService.currentMarkazId;
    if (markazId == null) {
      throw Exception('Utilisateur non authentifié');
    }

    return _repository.getAvailableClasses(markazId);
  }

  /// Obtient des statistiques sur les classes
  Map<String, dynamic> getClassStatistics() {
    final markazId = _authService.currentMarkazId;
    if (markazId == null) {
      throw Exception('Utilisateur non authentifié');
    }

    return _repository.getClassStatistics(markazId);
  }

  /// Synchronise les données depuis Firebase pour la markaz actuelle
  Future<void> syncFromFirebase() async {
    final markazId = _authService.currentMarkazId;
    if (markazId != null) {
      print('Début sync Firebase classes pour markaz: $markazId');
      await _repository.syncFromMarkaz(markazId);
      print('Sync Firebase classes terminée');
    } else {
      print('Impossible de sync classes: markazId null');
    }
  }

  /// Vérifie si un élève est dans une classe
  bool isStudentInClass(String studentId) {
    final classes = getActiveClasses();
    return classes.any((classModel) => classModel.studentIds.contains(studentId));
  }

  /// Récupère la classe d'un élève
  ClassModel? getStudentClass(String studentId) {
    final classes = getActiveClasses();
    try {
      return classes.firstWhere((classModel) => classModel.studentIds.contains(studentId));
    } catch (e) {
      return null;
    }
  }

  /// Groupes prédéfinis
  static List<String> get predefinedLevels => [
    'Groupe Nouroul Bayan',
    'Groupe Djouzou Amma',
    'Groupe Djouzou Kahf',
    'Groupe Djouzou Taha',
    'Groupe Alif Lam Mim',
    'Groupe Taha',
    'Groupe Ayaatoul Kursi',
    'Groupe Al-Mulk',
    'Groupe Yassin',
  ];

  /// Salles prédéfinies
  static List<String> get predefinedRooms => [
    'Salle A',
    'Salle B',
    'Salle C',
    'Salle D',
    'Salle E',
    'Bibliothèque',
    'Salle de prière',
    'Extérieur',
  ];

  /// Emplois du temps prédéfinis
  static List<String> get predefinedSchedules => [
    'Lun, Mer, Ven - 16h-18h',
    'Mar, Jeu - 16h-18h',
    'Sam, Dim - 9h-11h',
    'Lun, Mar, Mer, Jeu, Ven - 17h-19h',
    'Week-end - 14h-16h',
  ];
}
