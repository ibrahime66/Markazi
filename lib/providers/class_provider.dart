import 'package:flutter/foundation.dart';
import '../models/class_model.dart';
import '../services/class_service.dart';

/// Provider pour gérer la liste des classes
/// Utilise ChangeNotifier et ClassService pour la logique métier
class ClassProvider extends ChangeNotifier {
  final ClassService _service;
  List<ClassModel> _classes = [];
  String? _errorMessage;
  bool _isLoading = false;

  ClassProvider(this._service);

  /// Getter pour accéder à la liste des classes
  List<ClassModel> get classes => _classes;

  /// Getter pour accéder au dernier message d'erreur
  String? get errorMessage => _errorMessage;

  /// Getter pour l'état de chargement
  bool get isLoading => _isLoading;

  /// Charge les classes depuis le service (filtrées par markaz actuel)
  Future<void> loadClasses() async {
    try {
      _errorMessage = null;
      _isLoading = true;
      notifyListeners();

      _classes = _service.getActiveClasses();
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Charge toutes les classes (y compris inactives)
  Future<void> loadAllClasses() async {
    try {
      _errorMessage = null;
      _isLoading = true;
      notifyListeners();

      _classes = _service.getAllClasses();
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Ajoute une nouvelle classe avec validations métier
  Future<void> addClass({
    required String name,
    required String level,
    required String description,
    required String teacherName,
    int maxStudents = 30,
    String? schedule,
    String? room,
  }) async {
    try {
      _errorMessage = null;
      _isLoading = true;
      notifyListeners();

      final newClass = await _service.createClass(
        name: name,
        level: level,
        description: description,
        teacherName: teacherName,
        maxStudents: maxStudents,
        schedule: schedule,
        room: room,
      );
      
      _classes = [..._classes, newClass];
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Met à jour une classe
  Future<void> updateClass({
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
    try {
      _errorMessage = null;
      _isLoading = true;
      notifyListeners();

      final updatedClass = await _service.updateClass(
        classId: classId,
        name: name,
        level: level,
        description: description,
        teacherName: teacherName,
        maxStudents: maxStudents,
        schedule: schedule,
        room: room,
        isActive: isActive,
      );
      
      _classes = _classes.map((classModel) {
        if (classModel.id == updatedClass.id) {
          return updatedClass;
        }
        return classModel;
      }).toList();
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Supprime une classe
  Future<void> deleteClass(String classId) async {
    try {
      _errorMessage = null;
      _isLoading = true;
      notifyListeners();

      await _service.deleteClass(classId);
      _classes = _classes.where((classModel) => classModel.id != classId).toList();
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Ajoute un élève à une classe
  Future<void> addStudentToClass(String classId, String studentId) async {
    try {
      _errorMessage = null;
      await _service.addStudentToClass(classId, studentId);
      
      // Mettre à jour la classe localement
      final classIndex = _classes.indexWhere((c) => c.id == classId);
      if (classIndex != -1) {
        _classes[classIndex] = _classes[classIndex].addStudent(studentId);
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  /// Retire un élève d'une classe
  Future<void> removeStudentFromClass(String classId, String studentId) async {
    try {
      _errorMessage = null;
      await _service.removeStudentFromClass(classId, studentId);
      
      // Mettre à jour la classe localement
      final classIndex = _classes.indexWhere((c) => c.id == classId);
      if (classIndex != -1) {
        _classes[classIndex] = _classes[classIndex].removeStudent(studentId);
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  /// Récupère une classe par ID
  ClassModel? getClassById(String classId) {
    try {
      return _service.getClassById(classId);
    } catch (e) {
      _errorMessage = e.toString();
      return null;
    }
  }

  /// Récupère les classes par niveau
  List<ClassModel> getClassesByLevel(String level) {
    try {
      return _service.getClassesByLevel(level);
    } catch (e) {
      _errorMessage = e.toString();
      return [];
    }
  }

  /// Récupère les classes disponibles (non pleines)
  List<ClassModel> getAvailableClasses() {
    try {
      return _service.getAvailableClasses();
    } catch (e) {
      _errorMessage = e.toString();
      return [];
    }
  }

  /// Vérifie si un élève est dans une classe
  bool isStudentInClass(String studentId) {
    try {
      return _service.isStudentInClass(studentId);
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    }
  }

  /// Récupère la classe d'un élève
  ClassModel? getStudentClass(String studentId) {
    try {
      return _service.getStudentClass(studentId);
    } catch (e) {
      _errorMessage = e.toString();
      return null;
    }
  }

  /// Retourne le nombre total de classes
  int get totalClasses => _classes.length;

  /// Retourne le nombre de classes actives
  int get activeClassesCount => _classes.where((c) => c.isActive).length;

  /// Retourne le nombre total d'élèves dans toutes les classes
  int get totalStudentsInClasses => _classes
      .where((c) => c.isActive)
      .fold(0, (sum, classModel) => sum + classModel.currentStudentCount);

  /// Retourne la capacité totale des classes
  int get totalCapacity => _classes
      .where((c) => c.isActive)
      .fold(0, (sum, classModel) => sum + classModel.maxStudents);

  /// Obtient les statistiques sur les classes
  Map<String, dynamic> get statistics => _service.getClassStatistics();

  /// Efface le message d'erreur
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Synchronise les données depuis l'API
  Future<void> syncFromApi() async {
    try {
      _errorMessage = null;
      _isLoading = true;
      notifyListeners();

      await _service.syncFromApi();
      await loadClasses(); // Recharger les données locales
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
