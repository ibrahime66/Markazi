import 'package:hive_flutter/hive_flutter.dart';
import '../models/student.dart';
import '../datasources/firebase_student_datasource.dart';
import '../services/firebase_helper.dart';

/// Repository pour la gestion des données Student
/// Utilise Firebase avec cache Hive local pour mode hors ligne
class StudentRepository {
  static const String _boxName = 'students';
  late Box<Student> _box;
  final FirebaseStudentDatasource _firebaseDatasource = FirebaseStudentDatasource();

  /// Initialise le repository et ouvre la box Hive
  Future<void> init() async {
    _box = await Hive.openBox<Student>(_boxName);
    
    // Synchroniser depuis Firebase au démarrage si disponible
    if (FirebaseHelper.isAvailable) {
      // Attendre un peu pour que Firebase soit complètement initialisé
      await Future.delayed(const Duration(seconds: 1));
      await _syncFromFirebase();
    }
  }

  /// Synchronise les données depuis Firebase vers le cache local
  Future<void> _syncFromFirebase({String? markazId}) async {
    try {
      if (markazId != null) {
        // Récupérer les élèves de cette markaz depuis Firebase
        final firebaseStudents = await _firebaseDatasource.getStudentsByMarkaz(markazId);
        
        // Vider le cache local et mettre à jour avec les données Firebase
        await _box.clear();
        for (final student in firebaseStudents) {
          await _box.put(student.id, student);
        }
        
        print('Sync Firebase: ${firebaseStudents.length} élèves synchronisés pour markaz $markazId');
      } else {
        // Si pas de markazId, récupérer tous les élèves et filtrer localement
        // Pour l'instant, on ne fait rien pour éviter de charger des données d'autres markaz
        print('Sync Firebase: markazId non spécifié, sync ignorée');
      }
    } catch (e) {
      print('Erreur sync depuis Firebase: $e');
    }
  }

  /// Force la synchronisation depuis Firebase pour une markaz spécifique
  Future<void> syncFromMarkaz(String markazId) async {
    await _syncFromFirebase(markazId: markazId);
  }

  /// Ajoute un nouvel élève
  Future<void> addStudent(Student student) async {
    // Sauvegarder localement d'abord (cache)
    await _box.put(student.id, student);
    
    // Synchroniser avec Firebase si disponible
    if (FirebaseHelper.isAvailable) {
      try {
        await _firebaseDatasource.addStudent(student, student.markazId);
      } catch (e) {
        print('Erreur sync Firebase: $e');
        // Continue en mode local même si Firebase échoue
      }
    }
  }

  /// Supprime un élève par ID
  Future<void> removeStudent(String studentId) async {
    // Supprimer localement
    await _box.delete(studentId);
    
    // Synchroniser avec Firebase si disponible
    if (FirebaseHelper.isAvailable) {
      try {
        await _firebaseDatasource.deleteStudent(studentId);
      } catch (e) {
        print('Erreur sync Firebase: $e');
      }
    }
  }

  /// Met à jour un élève
  Future<void> updateStudent(Student student) async {
    // Mettre à jour localement
    await _box.put(student.id, student);
    
    // Synchroniser avec Firebase si disponible
    if (FirebaseHelper.isAvailable) {
      try {
        await _firebaseDatasource.updateStudent(student, student.markazId);
      } catch (e) {
        print('Erreur sync Firebase: $e');
      }
    }
  }

  /// Récupère un élève par ID
  Student? getStudentById(String studentId) {
    return _box.get(studentId);
  }

  /// Récupère tous les élèves
  List<Student> getAllStudents() {
    return _box.values.toList();
  }

  /// Récupère tous les élèves d'une Markaz
  List<Student> getStudentsByMarkaz(String markazId) {
    return _box.values
        .where((student) => student.markazId == markazId)
        .toList();
  }

  /// Retourne le nombre total d'élèves
  int getTotalStudents() {
    return _box.length;
  }

  /// Retourne le nombre d'élèves dans une Markaz
  int getStudentCountByMarkaz(String markazId) {
    return _box.values.where((student) => student.markazId == markazId).length;
  }

  /// Efface tous les élèves (utile pour les tests)
  Future<void> clearAll() async {
    await _box.clear();
  }

  /// Ferme la box (utile à l'arrêt de l'app)
  Future<void> close() async {
    await _box.close();
  }
}
