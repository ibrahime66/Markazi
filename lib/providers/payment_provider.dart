import 'package:flutter/foundation.dart';
import '../models/payment.dart';
import '../services/payment_service.dart';

/// Provider pour gérer la liste des paiements
/// Utilise ChangeNotifier et PaymentService pour la logique métier
class PaymentProvider extends ChangeNotifier {
  final PaymentService _service;
  List<Payment> _payments = [];
  String? _errorMessage;

  PaymentProvider(this._service);

  /// Getter pour accéder à la liste des paiements
  List<Payment> get payments => _payments;

  /// Getter pour accéder au dernier message d'erreur
  String? get errorMessage => _errorMessage;

  /// Charge les paiements depuis le service
  Future<void> loadPayments() async {
    try {
      _errorMessage = null;
      _payments = _service.getAllPayments();
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  /// Ajoute un nouveau paiement
  Future<void> addPayment({
    required String studentId,
    required double amount,
    required PaymentStatus status,
    String? markazId,
  }) async {
    try {
      _errorMessage = null;
      final newPayment = await _service.createPayment(
        studentId: studentId,
        amount: amount,
        status: status,
        markazId: markazId,
      );
      _payments = [..._payments, newPayment];
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  /// Marque un paiement comme payé
  Future<void> markAsPaid(String paymentId) async {
    try {
      _errorMessage = null;
      final updatedPayment = await _service.markAsPaid(paymentId);
      _payments = _payments.map((payment) {
        if (payment.id == updatedPayment.id) {
          return updatedPayment;
        }
        return payment;
      }).toList();
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  /// Marque un paiement comme non payé
  Future<void> markAsUnpaid(String paymentId) async {
    try {
      _errorMessage = null;
      final updatedPayment = await _service.markAsUnpaid(paymentId);
      _payments = _payments.map((payment) {
        if (payment.id == updatedPayment.id) {
          return updatedPayment;
        }
        return payment;
      }).toList();
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  /// Obtient les statistiques de paiement
  Map<String, dynamic> get statistics => _service.getPaymentStatistics();

  /// Génère un reçu de paiement
  Future<Map<String, dynamic>> generateReceipt(String paymentId) async {
    try {
      _errorMessage = null;
      return await _service.generatePaymentReceipt(paymentId);
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  /// Efface le message d'erreur
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
