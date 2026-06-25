import 'package:hive/hive.dart';
import '../models/payment.dart';

/// DataSource Hive pour les paiements.
class HivePaymentDataSource {
  static const String _boxName = 'payments';
  late Box<Payment> _box;

  /// Initialise la boîte Hive.
  Future<void> init() async {
    _box = await Hive.openBox<Payment>(_boxName);
  }

  /// Ajoute un paiement.
  Future<void> addPayment(Payment payment) async {
    await _box.put(payment.id, payment);
  }

  /// Met à jour un paiement.
  Future<void> updatePayment(Payment payment) async {
    await _box.put(payment.id, payment);
  }

  /// Supprime un paiement par ID.

  Future<void> deletePayment(String paymentId) async {
    await _box.delete(paymentId);
  }

  /// Récupère un paiement par ID.
  Payment? getPaymentById(String paymentId) {
    return _box.get(paymentId);
  }

  /// Récupère tous les paiements.
  List<Payment> getAllPayments() {
    return _box.values.toList();
  }

  /// Récupère les paiements d'un étudiant.
  List<Payment> getPaymentsByStudent(String studentId) {
    return _box.values.where((p) => p.studentId == studentId).toList();
  }

  /// Récupère les paiements d'une markaz.
  List<Payment> getPaymentsByMarkaz(String markazId) {
    return _box.values.where((p) => p.markazId == markazId).toList();
  }

  /// Récupère les paiements en attente d'une markaz.
  List<Payment> getPendingPaymentsByMarkaz(String markazId) {
    return _box.values
        .where((p) =>
            p.markazId == markazId && p.status.name == 'unpaid')
        .toList();
  }

  /// Retourne le montant total payé pour un étudiant.
  double getTotalPaymentForStudent(String studentId) {
    return _box.values
        .where((p) =>
            p.studentId == studentId && p.status.name == 'paid')
        .fold(0.0, (sum, p) => sum + p.amount);
  }

  /// Retourne le montant total des paiements en attente.
  double getTotalPendingPayments(String markazId) {
    return _box.values
        .where((p) =>
            p.markazId == markazId && p.status.name == 'unpaid')
        .fold(0.0, (sum, p) => sum + p.amount);
  }

  /// Retourne le nombre de paiements en attente.
  int getPendingPaymentsCount(String markazId) {
    return _box.values
        .where((p) =>
            p.markazId == markazId && p.status.name == 'unpaid')
        .length;
  }

  /// Efface tous les paiements.
  Future<void> clearAll() async {
    await _box.clear();
  }

  /// Ferme la boîte.
  Future<void> close() async {
    await _box.close();
  }
}