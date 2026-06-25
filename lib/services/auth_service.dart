import 'dart:developer' show debugPrint;
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../models/user.dart';
import 'firebase_helper.dart';

/// Service d'authentification Firebase
/// Phase 5: Authentification réelle avec Firebase
/// Gestion de la restauration de session sur toutes les plateformes
class AuthService {
  // Lazy getters pour éviter l'instanciation avant Firebase.initializeApp()
  fb_auth.FirebaseAuth get _auth => fb_auth.FirebaseAuth.instance;
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  User? _currentUser;
  StreamSubscription<fb_auth.User?>? _authStateSubscription;

  /// Utilisateur actuellement authentifié
  User? get currentUser => _currentUser;

  /// Vérifie si l'utilisateur est authentifié
  bool get isAuthenticated => _currentUser != null;

  /// Initialiser l'utilisateur au démarrage
  /// Met en place l'écouteur d'état d'authentification Firebase
  Future<void> initializeUser() async {
    try {
      // Ne rien faire si Firebase n'est pas disponible
      if (!FirebaseHelper.isAvailable) {
        debugPrint('AuthService.initializeUser: Firebase non disponible');
        return;
      }

      // Si un écouteur existe déjà, on ne le réinstalle pas
      if (_authStateSubscription != null) {
        return;
      }

      // Chargement immédiat de l'utilisateur actuel (au cas où le stream n'émet pas immédiatement)
      final firebaseUser = _auth.currentUser;
      if (firebaseUser != null) {
        await _loadUserFromFirestore(firebaseUser.uid);
      }

      // Écoute les changements d'état d'authentification (login, logout, token refresh)
      _authStateSubscription = _auth.authStateChanges().listen(
        (fbUser) async {
          if (fbUser != null) {
            try {
              await _loadUserFromFirestore(fbUser.uid);
            } catch (e) {
              // En cas d'erreur Firestore, on garde l'utilisateur Firebase mais on nettoie le profil local
              debugPrint('AuthService: Erreur lors du chargement du profil Firestore: $e');
              _currentUser = null; // on considère l'utilisateur non authentifié côté app
            }
          } else {
            _currentUser = null;
          }
        },
        onError: (error) {
          debugPrint('AuthService: Erreur du flux d\'authentification: $error');
        },
      );
    } catch (e) {
      debugPrint('AuthService.initializeUser erreur inattendue: $e');
    }
  }

  /// Se connecter avec Firebase Authentication
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

      // Authentifier avec Firebase
      late final fb_auth.UserCredential userCredential;
      try {
        userCredential = await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
      } on fb_auth.FirebaseAuthException catch (authError) {
        debugPrint('AuthService.login FirebaseAuthException: ${authError.code} - ${authError.message}');
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
            throw Exception('Trop de tentatives. Réessayez dans quelques minutes.');
          default:
            throw Exception('Erreur d\'authentification: ${authError.message ?? authError.code}');
        }
      } catch (e) {
        // Fallback pour les plateformes où l'exception n'est pas FirebaseAuthException
        debugPrint('AuthService.login erreur inattendue: $e');
        String errorMsg = e.toString().toLowerCase();
        if (errorMsg.contains('user-not-found')) {
          throw Exception('Utilisateur non trouvé');
        } else if (errorMsg.contains('wrong-password')) {
          throw Exception('Mot de passe incorrect');
        } else if (errorMsg.contains('invalid-email')) {
          throw Exception('Email invalide');
        } else if (errorMsg.contains('user-disabled')) {
          throw Exception('Compte désactivé');
        } else if (errorMsg.contains('too-many-requests')) {
          throw Exception('Trop de tentatives. Réessayez dans quelques minutes.');
        } else if (errorMsg.contains('network')) {
          throw Exception('Erreur réseau. Vérifiez votre connexion internet.');
        } else {
          throw Exception('Erreur d\'authentification');
        }
      }

      // Charger les données utilisateur depuis Firestore
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
          debugPrint('AuthService: Utilisateur absent de Firestore, création d\'un profil par défaut: $firestoreError');

          // Créer automatiquement le profil utilisateur avec les infos Firebase
          _currentUser = User(
            id: userCredential.user!.uid,
            name: userCredential.user?.displayName ?? 'Utilisateur',
            email: userCredential.user?.email ?? '',
            role: UserRole.teacher,
            markazId: markazId,
            createdAt: DateTime.now(),
          );

          // Sauvegarder dans Firestore en arrière‑plan (ne pas bloquer la connexion)
          try {
            await _firestore
                .collection('users')
                .doc(_currentUser!.id)
                .set(_currentUser!.toJson());
            debugPrint('AuthService: Profil utilisateur créé automatiquement dans Firestore');
          } catch (saveError) {
            debugPrint('AuthService: Impossible d\'enregistrer le profil utilisateur dans Firestore: $saveError');
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
      debugPrint('AuthService.login Exception: $e');
      rethrow;
    } catch (e) {
      debugPrint('AuthService.login erreur inattendue: $e');
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

      // Créer l'utilisateur dans Firebase Auth
      late final fb_auth.UserCredential userCredential;
      try {
        userCredential = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
      } on fb_auth.FirebaseAuthException catch (authError) {
        debugPrint('AuthService.register FirebaseAuthException: ${authError.code} - ${authError.message}');
        switch (authError.code) {
          case 'weak-password':
            throw Exception('Mot de passe trop faible. Utilisez au moins 6 caractères.');
          case 'email-already-in-use':
            throw Exception('Cet email est déjà utilisé');
          case 'invalid-email':
            throw Exception('Email invalide');
          default:
            throw Exception('Erreur d\'enregistrement: ${authError.message ?? authError.code}');
        }
      } catch (e) {
        // Fallback pour les plateformes où l'exception n'est pas FirebaseAuthException
        debugPrint('AuthService.register erreur inattendue: $e');
        String errorMsg = e.toString().toLowerCase();
        if (errorMsg.contains('weak-password')) {
          throw Exception('Mot de passe trop faible. Utilisez au moins 6 caractères.');
        } else if (errorMsg.contains('email-already-in-use')) {
          throw Exception('Cet email est déjà utilisé');
        } else if (errorMsg.contains('invalid-email')) {
          throw Exception('Email invalide');
        } else if (errorMsg.contains('network')) {
          throw Exception('Erreur réseau. Vérifiez votre connexion internet.');
        } else {
          throw Exception('Erreur lors de la création du compte');
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
          debugPrint('AuthService: Erreur réseau lors de l\'écriture du profil Firestore: $firestoreError');
        } else if (errorMsg.contains('permission')) {
          debugPrint('AuthService: Erreur de permission lors de l\'écriture du profil Firestore: $firestoreError');
        } else {
          // Autres erreurs - log seulement
          debugPrint('AuthService: Écriture Firestore échouée: $firestoreError');
        }
        // Continuer malgré l'erreur - au moins l'utilisateur est créé dans Auth
      }

      _currentUser = user;
      return user;
    } on Exception catch (e) {
      debugPrint('AuthService.register Exception: $e');
      rethrow;
    } catch (e) {
      debugPrint('AuthService.register erreur inattendue: $e');
      throw Exception('Erreur inconnue lors de la création du compte');
    }
  }

  /// Déconnexion de l'utilisateur
  Future<void> logout() async {
    try {
      try {
        await _auth.signOut();
      } catch (signOutError) {
        // Gérer les erreurs de logout (peuvent être TypeError sur web)
        String errorMsg = signOutError.toString().toLowerCase();
        if (errorMsg.contains('network')) {
          debugPrint('AuthService: Erreur réseau lors de la déconnexion: $signOutError');
        } else {
          debugPrint('AuthService: Erreur lors de la déconnexion: $signOutError');
        }
        // Continuer malgré l'erreur - l'important c'est de vider les données locales
      }

      _currentUser = null;
    } catch (e) {
      // Au minimum vider les données locales
      _currentUser = null;
      debugPrint('AuthService.logout erreur inattendue: $e');
      throw Exception('Erreur lors de la déconnexion.');
    }
  }

  /// Charge les données utilisateur depuis Firestore
  Future<void> _loadUserFromFirestore(String uid) async {
    try {
      // Récupérer le document de l'utilisateur depuis Firestore
      final doc = await _firestore.collection('users').doc(uid).get();

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

  /// Nettoyer les ressources (appelé lors de la.dispose si besoin)
  void dispose() {
    _authStateSubscription?.cancel();
    _authStateSubscription = null;
  }
}