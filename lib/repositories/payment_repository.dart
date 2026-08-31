import 'package:flutter/foundation.dart';
import '../models/payment.dart';
import '../models/sync_queue_item.dart';
import '../datasources/hive_payment_datasource.dart';
import '../datasources/api_payment_datasource.dart';
import '../services/sync_queue_service.dart';

/// Repository pour la gestion des données Payment.
/// Utilise l'API Laravel avec cache Hive local pour mode hors ligne.
class PaymentRepository {
  final HivePaymentDataSource _hiveDataSource;
  final ApiPaymentDatasource _apiDataSource;
  final SyncQueueService _syncQueue;

  PaymentRepository(this._hiveDataSource, this._apiDataSource, this._syncQueue);

  /// Initialise le repository et ouvre la box Hive via le data source
  Future<void> init() async {
    await _hiveDataSource.init();
  }

  /// Ajoute un nouveau paiement. Retourne le paiement tel que persisté côté
  /// serveur (avec son identifiant réel et son numéro de reçu le cas échéant).
  /// Lève [PaymentDuplicateException] si le serveur détecte qu'un paiement
  /// payé existe déjà pour cet élève ce mois-ci et que [confirmDuplicate]
  /// n'a pas été passé à `true`.
  Future<Payment> addPayment(Payment payment, {bool confirmDuplicate = false}) async {
    final saved = await _apiDataSource.addPayment(
      payment,
      payment.markazId,
      confirmDuplicate: confirmDuplicate,
    );
    await _hiveDataSource.addPayment(saved);
    return saved;
  }

  /// Supprime un paiement par ID
  Future<void> removePayment(String paymentId) async {
    await _hiveDataSource.deletePayment(paymentId);
    try {
      await _apiDataSource.deletePayment(paymentId);
    } catch (e) {
      debugPrint('Erreur sync API (suppression paiement) : $e');
      await _syncQueue.enqueue(
        entityType: SyncEntityType.payment,
        operation: SyncOperation.delete,
        entityId: paymentId,
      );
    }
  }

  /// Met à jour un paiement. Retourne la version faisant foi : celle
  /// renvoyée par le serveur (avec son éventuel numéro de reçu) si la
  /// synchronisation réussit, sinon la version locale en attente de
  /// synchronisation (mise en file pour rejeu automatique — CDC section 20,
  /// doc/audit.md point D2).
  Future<Payment> updatePayment(Payment payment) async {
    await _hiveDataSource.updatePayment(payment);
    try {
      final saved = await _apiDataSource.updatePayment(payment);
      await _hiveDataSource.updatePayment(saved);
      return saved;
    } catch (e) {
      debugPrint('Erreur sync API (mise à jour paiement) : $e');
      await _syncQueue.enqueue(
        entityType: SyncEntityType.payment,
        operation: SyncOperation.update,
        entityId: payment.id,
      );
      return payment;
    }
  }

  /// Rejoue une mise à jour en attente — réservé à SyncOrchestrator.
  /// Ne rattrape PAS l'erreur : l'appelant doit savoir si le rejeu a échoué
  /// pour décider de garder l'action en file ou non.
  Future<void> retrySyncUpdate(String paymentId) async {
    final payment = _hiveDataSource.getPaymentById(paymentId);
    if (payment == null) return;
    final saved = await _apiDataSource.updatePayment(payment);
    await _hiveDataSource.updatePayment(saved);
  }

  /// Rejoue une suppression en attente — réservé à SyncOrchestrator.
  Future<void> retrySyncDelete(String paymentId) async {
    await _apiDataSource.deletePayment(paymentId);
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

  /// Recharge le cache local depuis l'API pour la Markaz donnée.
  Future<void> syncFromMarkaz(String markazId) async {
    try {
      final payments = await _apiDataSource.getPaymentsByMarkaz(markazId);
      await _hiveDataSource.clearAll();
      for (final payment in payments) {
        await _hiveDataSource.addPayment(payment);
      }
    } catch (e) {
      debugPrint('Erreur sync API (paiements) : $e');
    }
  }
}
