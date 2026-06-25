import '../models/student.dart';
import '../datasources/hive_student_datasource.dart';
import '../datasources/firebase_student_datasource.dart';
import '../services/firebase_helper.dart';

/// Repository for the gestion des données Student.
/// Utilise Firebase avec cache Hive local pour mode hors ligne
class StudentRepository {
  final HiveStudentDataSource _hiveDataSource;
  final FirebaseStudentDataSource _firebaseDataSource;

  StudentRepository(this._hiveDataSource, this._firebaseDataSource);

  /// Initialise le repository et ouvre la box Hive via le data source.
  Future<void> init() async {
    await _hiveDataSource.init();

    // Synchroniser depuis Firebase au démarrage si disponible
    if (FirebaseHelper.isAvailable) {
      // Attendre un peu pour que Firebase soit complètement initialisé
      await Future.delayed(const Duration(seconds: 1));
      await _syncFromFirebase();
    }
  }

  /// Synchronise les données depuis Firebase vers le cache local.
  Future<void> _syncFromFirebase({String? markazId}) async {
    try {
      if (markazId != null) {
        // Récupérer les élèves de cette markaz depuis Firebase
        final firebaseStudents = await _firebaseDataSource.getStudentsByMarkaz(markazId);

        // Vider le cache local et mettre à jour avec les données Firebase
        await _hiveDataSource.clearAll();
        for (final student in firebaseStudents) {
          await _hiveDataSource.addStudent(student);
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

  /// Force la synchronisation depuis Firebase pour une markaz spécifique.
  Future<void> syncFromMarkaz(String markazId) async {
    await _syncFromFirebase(markazId: markazId);
  }

  /// Ajoute un nouvel élève.
  Future<void> addStudent(Student student) async {
    // Sauvegarder localement d'abord (cache)
    await _hiveDataSource.addStudent(student);

    // Synchroniser avec Firebase si disponible
    if (FirebaseHelper.isAvailable) {
      try {
        await _firebaseDataSource.addStudent(student, student.markazId);
      } catch (e) {
        print('Erreur sync Firebase: $e');
        // Continue en mode local même si Firebase échoue
      }
    }
  }

  /// Supprime un élève par ID.
  Future<void> removeStudent(String studentId) async {
    // Supprimer localement
    await _hiveDataSource.deleteStudent(studentId);

    // Synchroniser avec Firebase si disponible
    if (FirebaseHelper.isAvailable) {
      try {
        await _firebaseDataSource.deleteStudent(studentId);
      } catch (e) {
        print('Erreur sync Firebase: $e');
      }
    }
  }

  /// Met à jour un élève.
  Future<void> updateStudent(Student student) async {
    // Mettre à jour localement
    await _hiveDataSource.updateStudent(student);

    // Synchroniser avec Firebase si disponible
    if (FirebaseHelper.isAvailable) {
      try {
        await _firebaseDataSource.updateStudent(student, student.markazId);
      } catch (e) {
        print('Erreur sync Firebase: $e');
      }
    }
  }

  /// Récupère un élève par ID.
  Student? getStudentById(String studentId) {
    return _hiveDataSource.getStudentById(studentId);
  }

  /// Récupère tous les élèves.
  List<Student> getAllStudents() {
    return _hiveDataSource.getAllStudents();
  }

  /// Récupère tous les élèves d'une Markaz.
  List<Student> getStudentsByMarkaz(String markazId) {
    return _hiveDataSource.getStudentsByMarkaz(markazId);
  }

  /// Retourne le nombre total d'élèves.
  int getTotalStudents() {
    return _hiveDataSource.getTotalStudents();
  }

  /// Retourne le nombre d'élèves dans une Markaz.
  int getStudentCountByMarkaz(String markazId) {
    return _hiveDataSource.getStudentCountByMarkaz(markazId);
  }

  /// Efface tous les élèves (utile pour les tests).
  Future<void> clearAll() async {
    await _hiveDataSource.clearAll();
  }

  /// Ferme la box (utile à l'arrêt de l'app).
  Future<void> close() async {
    await _hiveDataSource.close();
  }
}