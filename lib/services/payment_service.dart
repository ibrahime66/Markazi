import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../datasources/api_payment_datasource.dart' show PaymentDuplicateException;
import '../models/payment.dart';
import '../repositories/payment_repository.dart';
import '../repositories/student_repository.dart';
import 'auth_service.dart';

/// Service métier pour la gestion des paiements
/// Centralise la logique métier, les validations et la génération de rapports
class PaymentService {
  final PaymentRepository _repository;
  final StudentRepository _studentRepository;
  final AuthService _authService;

  PaymentService(
    this._repository,
    this._studentRepository,
    this._authService,
  );

  /// Crée un nouveau paiement.
  ///
  /// La détection des doublons (même élève, même mois, déjà payé — CDC
  /// 8.7) est du ressort du serveur, seul à connaître l'état réel de tous
  /// les paiements du Markaz. En cas de doublon détecté, l'appel lève
  /// [PaymentDuplicateException] ; le rappeler avec [confirmDuplicate] à
  /// `true` force l'enregistrement malgré tout.
  Future<Payment> createPayment({
    required String studentId,
    required double amount,
    required PaymentStatus status,
    String? markazId,
    DateTime? date,
    bool confirmDuplicate = false,
  }) async {
    // Validations
    if (amount <= 0) {
      throw Exception('Le montant doit être supérieur à 0');
    }

    // Vérifier que l'élève existe
    final student = _studentRepository.getStudentById(studentId);
    if (student == null) {
      throw Exception('Élève non trouvé');
    }

    // Utiliser le markazId de l'élève ou celui fourni
    final finalMarkazId = markazId ?? student.markazId;

    // Vérifier l'accès multi-markaz
    if (!_authService.hasAccessToMarkaz(finalMarkazId)) {
      throw Exception('Accès refusé à cette Markaz');
    }

    // Créer le paiement
    const uuid = Uuid();
    final payment = Payment(
      id: uuid.v4(),
      studentId: studentId,
      markazId: finalMarkazId,
      amount: amount,
      status: status,
      date: date ?? DateTime.now(),
    );

    return await _repository.addPayment(payment, confirmDuplicate: confirmDuplicate);
  }

  /// Marque un paiement comme payé
  Future<Payment> markAsPaid(String paymentId) async {
    final payment = _repository.getPaymentById(paymentId);
    if (payment == null) {
      throw Exception('Paiement non trouvé');
    }

    // Vérifier l'accès multi-markaz
    if (!_authService.hasAccessToMarkaz(payment.markazId)) {
      throw Exception('Accès refusé à cette Markaz');
    }

    final updatedPayment = payment.copyWith(
      status: PaymentStatus.paid,
    );

    // Retourne la version confirmée par le serveur (avec son numéro de
    // reçu réel) plutôt que la simple copie locale.
    return await _repository.updatePayment(updatedPayment);
  }

  /// Marque un paiement comme non payé
  Future<Payment> markAsUnpaid(String paymentId) async {
    final payment = _repository.getPaymentById(paymentId);
    if (payment == null) {
      throw Exception('Paiement non trouvé');
    }

    // Vérifier l'accès multi-markaz
    if (!_authService.hasAccessToMarkaz(payment.markazId)) {
      throw Exception('Accès refusé à cette Markaz');
    }

    final updatedPayment = payment.copyWith(
      status: PaymentStatus.unpaid,
    );

    return await _repository.updatePayment(updatedPayment);
  }

  /// Génère un reçu de paiement
  /// Phase 4: Intégration avec une librairie PDF (ex: pdf, printing)
  Future<Map<String, dynamic>> generatePaymentReceipt(
    String paymentId,
  ) async {
    final payment = _repository.getPaymentById(paymentId);
    if (payment == null) {
      throw Exception('Paiement non trouvé');
    }

    // Vérifier l'accès multi-markaz
    if (!_authService.hasAccessToMarkaz(payment.markazId)) {
      throw Exception('Accès refusé à cette Markaz');
    }

    final student = _studentRepository.getStudentById(payment.studentId);
    if (student == null) {
      throw Exception('Élève non trouvé');
    }

    // Retourner un modèle simulé (Phase 4: générer vrai PDF)
    return {
      'receiptNumber': 'RC-${payment.id.substring(0, 8).toUpperCase()}',
      'date': DateTime.now().toIso8601String(),
      'amount': payment.amount,
      'currency': 'MAD',
      'studentName': student.name,
      'studentPhone': student.parentPhone,
      'markazId': payment.markazId,
      'status': payment.status == PaymentStatus.paid ? 'PAYÉ' : 'NON PAYÉ',
      'notes': 'Ce reçu a été généré automatiquement.',
    };
  }

  /// Obtient les statistiques de paiement pour la markaz actuelle
  Map<String, dynamic> getPaymentStatistics() {
    final markazId = _authService.currentMarkazId;
    if (markazId == null) {
      throw Exception('Utilisateur non authentifié');
    }

    final allPayments = _repository.getAllPayments();
    final markazPayments =
        allPayments.where((p) => p.markazId == markazId).toList();

    final paidAmount = markazPayments
        .where((p) => p.status == PaymentStatus.paid)
        .fold<double>(0, (sum, p) => sum + p.amount);

    final unpaidAmount = markazPayments
        .where((p) => p.status == PaymentStatus.unpaid)
        .fold<double>(0, (sum, p) => sum + p.amount);

    return {
      'totalPayments': markazPayments.length,
      'totalPaidAmount': paidAmount,
      'totalUnpaidAmount': unpaidAmount,
      'paidPercentage': markazPayments.isEmpty
          ? 0
          : (paidAmount / (paidAmount + unpaidAmount) * 100).toStringAsFixed(2),
      'recentPayments': markazPayments.toList()
        ..sort((a, b) => b.date.compareTo(a.date))
        ..take(10).toList(),
    };
  }

  /// Obtient les paiements en attente pour une markaz
  List<Payment> getPendingPayments() {
    final markazId = _authService.currentMarkazId;
    if (markazId == null) {
      throw Exception('Utilisateur non authentifié');
    }

    return _repository.getPendingPaymentsByMarkaz(markazId);
  }

  /// Obtient tous les paiements pour une markaz (payés et non payés)
  List<Payment> getAllPayments() {
    final markazId = _authService.currentMarkazId;
    if (markazId == null) {
      throw Exception('Utilisateur non authentifié');
    }

    return _repository.getPaymentsByMarkaz(markazId);
  }

  /// Synchronise les données depuis l'API pour la markaz actuelle
  Future<void> syncFromApi() async {
    final markazId = _authService.currentMarkazId;
    if (markazId != null) {
      debugPrint('Début sync API payments pour markaz: $markazId');
      await _repository.syncFromMarkaz(markazId);
      debugPrint('Sync API payments terminée');
    } else {
      debugPrint('Impossible de sync payments: markazId null');
    }
  }
}
