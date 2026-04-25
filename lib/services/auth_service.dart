import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../models/user.dart';
import 'firebase_helper.dart';

/// Service d'authentification Firebase
/// Phase 5: Authentification réelle avec Firebase
/// Graceful degradation si Firebase n'est pas disponible
class AuthService {
  // Lazy getters pour éviter l'instanciation avant Firebase.initializeApp()
  fb_auth.FirebaseAuth get _auth => fb_auth.FirebaseAuth.instance;
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  User? _currentUser;

  /// Utilisateur actuellement authentifié
  User? get currentUser => _currentUser;

  /// Vérifie si l'utilisateur est authentifié
  bool get isAuthenticated => _currentUser != null;

  /// Initialiser l'utilisateur au démarrage
  /// IMPORTANT: On skip complètement sur web pour éviter les erreurs Firebase
  Future<void> initializeUser() async {
    try {
      // Skip sur web - Firebase s'auto-initialise mais n'est pas prêt au démarrage
      if (kIsWeb) {
        print('AuthService.initializeUser: Skip sur web');
        return;
      }

      // Skip si Firebase n'est pas disponible
      if (!FirebaseHelper.isAvailable) {
        print('AuthService.initializeUser: Firebase non disponible');
        return;
      }

      try {
        final firebaseUser = _auth.currentUser;
        if (firebaseUser != null) {
          await _loadUserFromFirestore(firebaseUser.uid);
        }
      } on Exception catch (e) {
        // Gérer les FirebaseExceptions et autres erreurs d'initialisation
        print('AuthService.initializeUser Firebase error: $e');
        // Continuer sans interruption - pas critique au démarrage
      }
    } catch (e) {
      // Fallback pour les erreurs non-prévues
      print('AuthService.initializeUser unexpected error: $e');
    }
  }

  /// Login avec Firebase Authentication
  Future<User> login({
    required String email,
    required String password,
    required String markazId,
  }) async {
    try {
      // Validation basique
      if (email.isEmpty || password.isEmpty) {
        throw Exception('Email et mot de passe requis');
      }

      if (password.length < 6) {
        throw Exception('Mot de passe trop court (6+ caractères)');
      }

      // Vérifier que Firebase est disponible
      if (!FirebaseHelper.isAvailable) {
        throw Exception(
          'Configuration Firebase manquante. Veuillez configurer Firebase pour utiliser la connexion.',
        );
      }

      // Authentifier avec Firebase - utiliser une détection sécurisée pour web et native
      late final fb_auth.UserCredential userCredential;
      try {
        userCredential = await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
      } catch (authError) {
        // Essayer de caster en FirebaseAuthException (native)
        if (authError is fb_auth.FirebaseAuthException) {
          // DEBUG: Afficher le code et message exacts pour le débogage
          print(
              'DEBUG Login FirebaseAuthException Code: ${authError.code}, Message: ${authError.message}');

          // Gérer selon le code d'erreur
          switch (authError.code) {
            case 'user-not-found':
              throw Exception('Utilisateur non trouvé');
            case 'wrong-password':
              throw Exception('Mot de passe incorrect');
            case 'invalid-email':
              throw Exception('Email invalide');
            case 'user-disabled':
              throw Exception('Compte désactivé');
            case 'too-many-requests':
              throw Exception(
                  'Trop de tentatives. Réessayez dans quelques minutes.');
            default:
              throw Exception(
                  'Erreur d\'authentification: ${authError.message ?? authError.code}');
          }
        } else {
          // Fallback pour web où le casting FirebaseAuthException peut échouer
          // Utiliser string-based error detection
          String errorMsg = authError.toString().toLowerCase();

          if (errorMsg.contains('user-not-found')) {
            throw Exception('Utilisateur non trouvé');
          } else if (errorMsg.contains('wrong-password')) {
            throw Exception('Mot de passe incorrect');
          } else if (errorMsg.contains('invalid-email')) {
            throw Exception('Email invalide');
          } else if (errorMsg.contains('user-disabled')) {
            throw Exception('Compte désactivé');
          } else if (errorMsg.contains('too-many-requests')) {
            throw Exception(
                'Trop de tentatives. Réessayez dans quelques minutes.');
          } else if (errorMsg.contains('network')) {
            throw Exception(
                'Erreur réseau. Vérifiez votre connexion internet.');
          } else {
            // Pour web: afficher plus de détails au debug
            print('DEBUG Login Error (Web): $authError');
            throw Exception('Erreur d\'authentification');
          }
        }
      }

      // Charger les données utilisateur - aussi des opérations Firestore
      try {
        await _loadUserFromFirestore(userCredential.user!.uid);
      } catch (firestoreError) {
        // Gérer les erreurs Firestore (peuvent être TypeError sur web)
        String errorMsg = firestoreError.toString().toLowerCase();
        if (errorMsg.contains('network')) {
          throw Exception('Erreur réseau lors du chargement du profil.');
        } else if (errorMsg.contains('permission')) {
          throw Exception('Erreur d\'accès au profil utilisateur.');
        } else {
          // Le document n'existe pas - créer un profil par défaut
          print(
              'Warning: User not in Firestore, creating default profile: $firestoreError');

          // Créer automatiquement le profil utilisateur avec les infos Firebase
          _currentUser = User(
            id: userCredential.user!.uid,
            name: userCredential.user?.displayName ?? 'Utilisateur',
            email: userCredential.user?.email ?? '',
            role: UserRole.teacher,
            markazId: markazId,
            createdAt: DateTime.now(),
          );

          // Sauvegarder dans Firestore en background (ne pas bloquer la connexion)
          try {
            await _firestore
                .collection('users')
                .doc(_currentUser!.id)
                .set(_currentUser!.toJson());
            print('User profile créé automatiquement dans Firestore');
          } catch (saveError) {
            print(
                'Warning: Could not save user profile to Firestore: $saveError');
            // Continuer quand même - l'utilisateur est au moins en mémoire
          }
        }
      }

      if (_currentUser == null) {
        throw Exception('Utilisateur non trouvé. Veuillez vous enregistrer.');
      }

      // Vérifier que l'utilisateur a accès à cette markaz
      if (_currentUser!.markazId != markazId) {
        throw Exception('Accès refusé à cette Markaz');
      }

      return _currentUser!;
    } on Exception catch (e) {
      print('Login Exception: $e');
      rethrow;
    } catch (e) {
      print('Login Unexpected error: $e');
      throw Exception('Erreur inconnue lors de la connexion');
    }
  }

  /// Enregistrement avec Firebase
  Future<User> register({
    required String name,
    required String email,
    required String password,
    required String markazId,
  }) async {
    try {
      // Valider les données
      if (name.isEmpty || email.isEmpty || password.isEmpty) {
        throw Exception('Tous les champs sont requis');
      }

      if (password.length < 6) {
        throw Exception('Mot de passe trop court (6+ caractères)');
      }

      // Vérifier que Firebase est disponible
      if (!FirebaseHelper.isAvailable) {
        throw Exception(
          'Configuration Firebase manquante. Veuillez configurer Firebase pour créer un compte.',
        );
      }

      // Créer l'utilisateur dans Firebase Auth - détection sécurisée pour web et native
      late final fb_auth.UserCredential userCredential;
      try {
        userCredential = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
      } catch (authError) {
        // Essayer de caster en FirebaseAuthException (native)
        if (authError is fb_auth.FirebaseAuthException) {
          // DEBUG: Afficher le code et message exacts pour le débogage
          print(
              'DEBUG Register FirebaseAuthException Code: ${authError.code}, Message: ${authError.message}');

          // Gérer selon le code d'erreur
          switch (authError.code) {
            case 'weak-password':
              throw Exception(
                  'Mot de passe trop faible. Utilisez au moins 6 caractères.');
            case 'email-already-in-use':
              throw Exception('Cet email est déjà utilisé');
            case 'invalid-email':
              throw Exception('Email invalide');
            default:
              throw Exception(
                  'Erreur d\'enregistrement: ${authError.message ?? authError.code}');
          }
        } else {
          // Fallback pour web où le casting FirebaseAuthException peut échouer
          String errorMsg = authError.toString().toLowerCase();

          if (errorMsg.contains('weak-password')) {
            throw Exception(
                'Mot de passe trop faible. Utilisez au moins 6 caractères.');
          } else if (errorMsg.contains('email-already-in-use')) {
            throw Exception('Cet email est déjà utilisé');
          } else if (errorMsg.contains('invalid-email')) {
            throw Exception('Email invalide');
          } else if (errorMsg.contains('network')) {
            throw Exception(
                'Erreur réseau. Vérifiez votre connexion internet.');
          } else {
            // Pour web: afficher plus de détails au debug
            print('DEBUG Register Error (Web): $authError');
            throw Exception('Erreur lors de la création du compte');
          }
        }
      }

      // Créer le document utilisateur dans Firestore
      final user = User(
        id: userCredential.user!.uid,
        name: name,
        email: email,
        role: UserRole.teacher,
        markazId: markazId,
        createdAt: DateTime.now(),
      );

      try {
        await _firestore.collection('users').doc(user.id).set(user.toJson());
      } catch (firestoreError) {
        // Gérer les erreurs Firestore (peuvent être TypeError sur web)
        String errorMsg = firestoreError.toString().toLowerCase();
        if (errorMsg.contains('network')) {
          print(
              'Warning: Network error writing user to Firestore: $firestoreError');
        } else if (errorMsg.contains('permission')) {
          print(
              'Warning: Permission error writing user to Firestore: $firestoreError');
        } else {
          // Autres erreurs - log seulement
          print('Warning: Firestore write failed: $firestoreError');
        }
        // Continuer malgré l'erreur - au moins l'utilisateur est créé dans Auth
      }

      _currentUser = user;
      return user;
    } on Exception catch (e) {
      print('Register Exception: $e');
      rethrow;
    } catch (e) {
      print('Register Unexpected error: $e');
      throw Exception('Erreur inconnue lors de la création du compte');
    }
  }

  /// Logout de l'utilisateur
  Future<void> logout() async {
    try {
      try {
        await _auth.signOut();
      } catch (signOutError) {
        // Gérer les erreurs de logout (peuvent être TypeError sur web)
        String errorMsg = signOutError.toString().toLowerCase();
        if (errorMsg.contains('network')) {
          print('Warning: Network error during logout: $signOutError');
        } else {
          print('Warning: Error during logout: $signOutError');
        }
        // Continuer malgré l'erreur - l'important c'est de vider les données locales
      }

      _currentUser = null;
    } catch (e) {
      // Au minimum vider les données locales
      _currentUser = null;
      throw Exception('Erreur lors de la déconnexion.');
    }
  }

  /// Charge les données utilisateur depuis Firestore
  Future<void> _loadUserFromFirestore(String uid) async {
    try {
      // Récupérer le document de l'utilisateur depuis Firestore
      late final DocumentSnapshot<Map<String, dynamic>> doc;
      try {
        doc = await _firestore.collection('users').doc(uid).get();
      } catch (firestoreError) {
        // Gérer les erreurs Firestore (peuvent être TypeError sur web)
        String errorMsg = firestoreError.toString().toLowerCase();
        if (errorMsg.contains('network')) {
          throw Exception('Erreur réseau lors de la récupération du profil.');
        } else if (errorMsg.contains('permission')) {
          throw Exception('Erreur d\'accès au profil utilisateur.');
        } else {
          // Réessayer ou ignorer selon le besoin
          throw Exception('Impossible de charger le profil utilisateur.');
        }
      }

      if (!doc.exists) {
        throw Exception('Profil utilisateur non trouvé.');
      }

      _currentUser = User.fromJson(doc.data()!);
    } catch (e) {
      // Convertir les erreurs en messages clairs
      String errorMsg = e.toString();
      if (errorMsg.contains('Exception:')) {
        // C'est déjà une Exception formatée
        rethrow;
      } else {
        // Erreur inconnue
        throw Exception('Erreur lors du chargement du profil.');
      }
    }
  }

  /// Obtenir l'utilisateur actuel avec markazId pour filtrage multi-markaz
  String? get currentMarkazId => _currentUser?.markazId;

  /// Vérifier que l'utilisateur a accès à un markazId spécifique
  bool hasAccessToMarkaz(String markazId) {
    return _currentUser != null && _currentUser!.markazId == markazId;
  }
}
