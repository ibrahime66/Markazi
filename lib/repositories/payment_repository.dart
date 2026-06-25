import '../models/payment.dart';
import '../datasources/hive_payment_datasource.dart';
import '../datasources/firebase_payment_datasource.dart';
import '../services/firebase_helper.dart';

/// Repository pour la gestion des données Payment
/// Utilise Firebase avec cache Hive local pour mode hors ligne
class PaymentRepository {
  final HivePaymentDataSource _hiveDataSource;
  final FirebasePaymentDataSource _firebaseDataSource;

  PaymentRepository(this._hiveDataSource, this._firebaseDataSource);

  /// Initialise le repository et ouvre la box Hive via le data source
  Future<void> init() async {
    await _hiveDataSource.init();

    // Synchroniser depuis Firebase au démarrage si disponible
    if (FirebaseHelper.isAvailable) {
      await Future.delayed(const Duration(seconds: 1));
      await _syncFromFirebase();
    }
  }

  /// Ajoute un nouveau paiement
  Future<void> addPayment(Payment payment) async {
    // Sauvegarder localement d'abord (cache)
    await _hiveDataSource.addPayment(payment);

    // Synchroniser avec Firebase si disponible
    if (FirebaseHelper.isAvailable) {
      try {
        await _firebaseDataSource.addPayment(payment, payment.markazId);
      } catch (e) {
        print('Erreur sync Firebase payment: $e');
      }
    }
  }

  /// Supprime un paiement par ID
  Future<void> removePayment(String paymentId) async {
    // Supprimer localement
    await _hiveDataSource.deletePayment(paymentId);

    // Synchroniser avec Firebase si disponible
    if (FirebaseHelper.isAvailable) {
      try {
        await _firebaseDataSource.deletePayment(paymentId);
      } catch (e) {
        print('Erreur sync Firebase payment: $e');
      }
    }
  }

  /// Met à jour un paiement
  Future<void> updatePayment(Payment payment) async {
    // Mettre à jour localement
    await _hiveDataSource.updatePayment(payment);

    // Synchroniser avec Firebase si disponible
    if (FirebaseHelper.isAvailable) {
      try {
        await _firebaseDataSource.updatePayment(payment);
      } catch (e) {
        print('Erreur sync Firebase payment: $e');
      }
    }
  }

  /// Récupère un paiement par ID
  Payment? getPaymentById(String paymentId) {
    return _hiveDataSource.getPaymentById(paymentId);
  }

  /// Récupère tous les paiements
  List<Payment> getAllPayments() {
    return _hiveDataSource.getAllPayments();
  }

  /// Récupère tous les paiements d'un élève
  List<Payment> getPaymentsByStudent(String studentId) {
    return _hiveDataSource.getPaymentsByStudent(studentId);
  }

  /// Récupère tous les paiements d'une Markaz
  List<Payment> getPaymentsByMarkaz(String markazId) {
    return _hiveDataSource.getPaymentsByMarkaz(markazId);
  }

  /// Récupère les paiements en attente d'une Markaz
  List<Payment> getPendingPaymentsByMarkaz(String markazId) {
    return _hiveDataSource.getPendingPaymentsByMarkaz(markazId);
  }

  /// Retourne le montant total payé pour un élève
  double getTotalPaymentForStudent(String studentId) {
    return _hiveDataSource.getTotalPaymentForStudent(studentId);
  }

  /// Retourne le montant total des paiements en attente
  double getTotalPendingPayments(String markazId) {
    return _hiveDataSource.getTotalPendingPayments(markazId);
  }

  /// Retourne le nombre de paiements en attente
  int getPendingPaymentsCount(String markazId) {
    return _hiveDataSource.getPendingPaymentsCount(markazId);
  }

  /// Efface tous les paiements (utile pour les tests)
  Future<void> clearAll() async {
    await _hiveDataSource.clearAll();
  }

  /// Ferme la box (utile à l'arrêt de l'app)
  Future<void> close() async {
    await _hiveDataSource.close();
  }

  /// Synchronise les données depuis Firebase vers le cache local
  Future<void> _syncFromFirebase({String? markazId}) async {
    try {
      if (markazId != null) {
        // Récupérer les paiements de cette markaz depuis Firebase
        final firebasePayments = await _firebaseDataSource.getPaymentsByMarkaz(markazId);

        // Vider le cache local et mettre à jour avec les données Firebase
        await _hiveDataSource.clearAll();
        for (final payment in firebasePayments) {
          await _hiveDataSource.addPayment(payment);
        }

        print('Sync Firebase: ${firebasePayments.length} paiements synchronisés pour markaz $markazId');
      } else {
        print('Sync Firebase: markazId non spécifié, sync ignorée');
      }
    } catch (e) {
      print('Erreur sync payments depuis Firebase: $e');
    }
  }

  /// Force la synchronisation depuis Firebase pour une markaz spécifique
  Future<void> syncFromMarkaz(String markazId) async {
    await _syncFromFirebase(markazId: markazId);
  }
}