import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../firebase_options.dart';

/// Helper pour gérer la disponibilité de Firebase
class FirebaseHelper {
  static bool _initialized = false;
  static bool _hasError = false;
  static String _errorMessage = '';

  /// Vérifier si Firebase est disponible et configuré
  static bool get isAvailable => _initialized && !_hasError;

  /// Obtenir le statut d'initialisation
  static bool get isInitialized => _initialized;

  /// Obtenir le message d'erreur si présent
  static String get errorMessage => _errorMessage;

  /// Initialiser Firebase et tracker les erreurs
  static Future<void> init() async {
    try {
      // Marquer comme en cours d'initialisation
      _initialized = false;
      _hasError = false;
      _errorMessage = '';

      // Vérifier que Firebase n'est pas déjà initialisé
      if (Firebase.apps.isNotEmpty) {
        _initialized = true;
        _hasError = false;
        print('Firebase déjà initialisé');
        return;
      }

      // Sur le web, Firebase s'auto-initialise via le HTML config
      // On skip l'initialisation manuelle qui cause des problèmes
      if (kIsWeb) {
        print('Firebase sur le web - auto-initialisation via HTML');
        _initialized = true;
        _hasError = false;
        return;
      }

      // Pour les plateformes natives (Android, iOS, Windows, macOS, Linux)
      // Initialiser Firebase avec les options appropriées
      print('Initialisation Firebase pour plateforme native...');
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      _initialized = true;
      _hasError = false;
      print('Firebase initialisé avec succès');
    } catch (e) {
      _initialized = true;
      _hasError = true;
      _errorMessage = e.toString();
      print('FirebaseHelper.init() erreur: $e');
      // Ne pas lever l'exception, continuer avec dégradation gracieuse
    }
  }

  /// Reset l'état (pour les tests)
  static void reset() {
    _initialized = false;
    _hasError = false;
    _errorMessage = '';
  }

  /// Test de connexion Firebase
  static Future<bool> testConnection() async {
    try {
      if (!isAvailable) {
        print('❌ Firebase non disponible: $errorMessage');
        return false;
      }
      
      // Test simple: essayer de lire Firestore
      final firestore = FirebaseFirestore.instance;
      await firestore.collection('test').limit(1).get();
      
      print('✅ Firebase connecté avec succès!');
      return true;
    } catch (e) {
      print('❌ Erreur connexion Firebase: $e');
      return false;
    }
  }
}
