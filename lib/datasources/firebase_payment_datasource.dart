import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/payment.dart';

/// Datasource Firebase pour les paiements
/// Gère la synchronisation avec Firestore
class FirebasePaymentDatasource {
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;
  static const String _collection = 'payments';

  /// Ajoute un paiement à Firestore
  Future<void> addPayment(Payment payment, String markazId) async {
    try {
      await _firestore.collection(_collection).doc(payment.id).set({
        'id': payment.id,
        'studentId': payment.studentId,
        'markazId': markazId,
        'amount': payment.amount,
        'status': payment.status.toString().split('.').last,
        'date': payment.date.toIso8601String(),
        'createdAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Erreur Firebase: $e');
    }
  }

  /// Met à jour un paiement dans Firestore
  Future<void> updatePayment(Payment payment) async {
    try {
      await _firestore.collection(_collection).doc(payment.id).update({
        'amount': payment.amount,
        'status': payment.status.toString().split('.').last,
        'date': payment.date.toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Erreur Firebase: $e');
    }
  }

  /// Supprime un paiement de Firestore
  Future<void> deletePayment(String paymentId) async {
    try {
      await _firestore.collection(_collection).doc(paymentId).delete();
    } catch (e) {
      throw Exception('Erreur Firebase: $e');
    }
  }

  /// Récupère tous les paiements d'une Markaz en temps réel
  Stream<List<Payment>> getPaymentsByMarkazStream(String markazId) {
    return _firestore
        .collection(_collection)
        .where('markazId', isEqualTo: markazId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => _mapDocToPayment(doc)).toList();
    }).handleError((e) {
      throw Exception('Erreur Firebase Stream: $e');
    });
  }

  /// Récupère tous les paiements d'une Markaz (une seule fois)
  Future<List<Payment>> getPaymentsByMarkaz(String markazId) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('markazId', isEqualTo: markazId)
          .orderBy('date', descending: true)
          .get();

      return snapshot.docs.map((doc) => _mapDocToPayment(doc)).toList();
    } catch (e) {
      throw Exception('Erreur Firebase: $e');
    }
  }

  /// Convertit un document Firestore en Payment
  Payment _mapDocToPayment(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final statusStr = data['status'] as String;
    final status =
        statusStr == 'paid' ? PaymentStatus.paid : PaymentStatus.unpaid;

    return Payment(
      id: data['id'] as String,
      studentId: data['studentId'] as String,
      markazId: data['markazId'] as String,
      amount: (data['amount'] as num).toDouble(),
      status: status,
      date: DateTime.parse(data['date'] as String),
    );
  }
}
