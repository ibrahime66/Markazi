import 'package:hive_flutter/hive_flutter.dart';
import '../models/payment.dart';
import '../datasources/firebase_payment_datasource.dart';
import '../services/firebase_helper.dart';

/// Repository pour la gestion des données Payment
/// Utilise Firebase avec cache Hive local pour mode hors ligne
class PaymentRepository {
  static const String _boxName = 'payments';
  late Box<Payment> _box;
  final FirebasePaymentDatasource _firebaseDatasource = FirebasePaymentDatasource();

  /// Initialise le repository et ouvre la box Hive
  Future<void> init() async {
    _box = await Hive.openBox<Payment>(_boxName);
    
    // Synchroniser depuis Firebase au démarrage si disponible
    if (FirebaseHelper.isAvailable) {
      await Future.delayed(const Duration(seconds: 1));
      await _syncFromFirebase();
    }
  }

  /// Ajoute un nouveau paiement
  Future<void> addPayment(Payment payment) async {
    // Sauvegarder localement d'abord (cache)
    await _box.put(payment.id, payment);
    
    // Synchroniser avec Firebase si disponible
    if (FirebaseHelper.isAvailable) {
      try {
        await _firebaseDatasource.addPayment(payment, payment.markazId);
      } catch (e) {
        print('Erreur sync Firebase payment: $e');
      }
    }
  }

  /// Supprime un paiement par ID
  Future<void> removePayment(String paymentId) async {
    // Supprimer localement
    await _box.delete(paymentId);
    
    // Synchroniser avec Firebase si disponible
    if (FirebaseHelper.isAvailable) {
      try {
        await _firebaseDatasource.deletePayment(paymentId);
      } catch (e) {
        print('Erreur sync Firebase payment: $e');
      }
    }
  }

  /// Met à jour un paiement
  Future<void> updatePayment(Payment payment) async {
    // Mettre à jour localement
    await _box.put(payment.id, payment);
    
    // Synchroniser avec Firebase si disponible
    if (FirebaseHelper.isAvailable) {
      try {
        await _firebaseDatasource.updatePayment(payment);
      } catch (e) {
        print('Erreur sync Firebase payment: $e');
      }
    }
  }

  /// Récupère un paiement par ID
  Payment? getPaymentById(String paymentId) {
    return _box.get(paymentId);
  }

  /// Récupère tous les paiements
  List<Payment> getAllPayments() {
    return _box.values.toList();
  }

  /// Récupère tous les paiements d'un élève
  List<Payment> getPaymentsByStudent(String studentId) {
    return _box.values
        .where((payment) => payment.studentId == studentId)
        .toList();
  }

  /// Récupère tous les paiements d'une Markaz
  List<Payment> getPaymentsByMarkaz(String markazId) {
    return _box.values
        .where((payment) => payment.markazId == markazId)
        .toList();
  }

  /// Récupère les paiements en attente d'une Markaz
  List<Payment> getPendingPaymentsByMarkaz(String markazId) {
    return _box.values
        .where((payment) =>
            payment.markazId == markazId && payment.status.name == 'unpaid')
        .toList();
  }

  /// Retourne le montant total payé pour un élève
  double getTotalPaymentForStudent(String studentId) {
    return _box.values
        .where((payment) =>
            payment.studentId == studentId && payment.status.name == 'paid')
        .fold(0.0, (sum, payment) => sum + payment.amount);
  }

  /// Retourne le montant total des paiements en attente
  double getTotalPendingPayments(String markazId) {
    return _box.values
        .where((payment) =>
            payment.markazId == markazId && payment.status.name == 'unpaid')
        .fold(0.0, (sum, payment) => sum + payment.amount);
  }

  /// Retourne le nombre de paiements en attente
  int getPendingPaymentsCount(String markazId) {
    return _box.values
        .where((payment) =>
            payment.markazId == markazId && payment.status.name == 'unpaid')
        .length;
  }

  /// Efface tous les paiements (utile pour les tests)
  Future<void> clearAll() async {
    await _box.clear();
  }

  /// Ferme la box (utile à l'arrêt de l'app)
  Future<void> close() async {
    await _box.close();
  }

  /// Synchronise les données depuis Firebase vers le cache local
  Future<void> _syncFromFirebase({String? markazId}) async {
    try {
      if (markazId != null) {
        // Récupérer les paiements de cette markaz depuis Firebase
        final firebasePayments = await _firebaseDatasource.getPaymentsByMarkaz(markazId);
        
        // Vider le cache local et mettre à jour avec les données Firebase
        await _box.clear();
        for (final payment in firebasePayments) {
          await _box.put(payment.id, payment);
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
