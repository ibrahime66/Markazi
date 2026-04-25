import 'package:uuid/uuid.dart';
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

  /// Crée un nouveau paiement
  Future<Payment> createPayment({
    required String studentId,
    required double amount,
    required PaymentStatus status,
    String? markazId,
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

    // Vérifier les doublons (même montant même jour)
    if (_hasDuplicatePayment(studentId, amount, finalMarkazId)) {
      throw Exception('Ce paiement semble déjà enregistré (doublon)');
    }

    // Créer le paiement
    const uuid = Uuid();
    final payment = Payment(
      id: uuid.v4(),
      studentId: studentId,
      markazId: finalMarkazId,
      amount: amount,
      status: status,
      date: DateTime.now(),
    );

    await _repository.addPayment(payment);
    return payment;
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

    await _repository.updatePayment(updatedPayment);
    return updatedPayment;
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

    await _repository.updatePayment(updatedPayment);
    return updatedPayment;
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

  /// Vérifie les doublons
  bool _hasDuplicatePayment(
    String studentId,
    double amount,
    String markazId,
  ) {
    final today = DateTime.now();
    final todayStart = DateTime(today.year, today.month, today.day);
    final todayEnd = todayStart.add(const Duration(days: 1));

    final allPayments = _repository.getAllPayments();
    return allPayments.any((p) =>
        p.studentId == studentId &&
        p.markazId == markazId &&
        p.amount == amount &&
        p.date.isAfter(todayStart) &&
        p.date.isBefore(todayEnd));
  }

  /// Synchronise les données depuis Firebase pour la markaz actuelle
  Future<void> syncFromFirebase() async {
    final markazId = _authService.currentMarkazId;
    if (markazId != null) {
      print('Début sync Firebase payments pour markaz: $markazId');
      await _repository.syncFromMarkaz(markazId);
      print('Sync Firebase payments terminée');
    } else {
      print('Impossible de sync payments: markazId null');
    }
  }
}
