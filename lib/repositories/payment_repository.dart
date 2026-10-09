import 'package:flutter/foundation.dart';
import '../models/payment.dart';
import '../models/sync_queue_item.dart';
import '../datasources/hive_payment_datasource.dart';
import '../datasources/api_payment_datasource.dart';
import '../services/api_client.dart';
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
  ///
  /// Hors ligne (CDC §20 : "la saisie de nouveaux paiements hors ligne est
  /// mise en file d'attente") : le paiement est conservé localement sous son
  /// identifiant temporaire, sans numéro de reçu, et envoyé à la reconnexion.
  Future<Payment> addPayment(Payment payment, {bool confirmDuplicate = false}) async {
    try {
      final saved = await _apiDataSource.addPayment(
        payment,
        payment.markazId,
        confirmDuplicate: confirmDuplicate,
      );
      await _hiveDataSource.addPayment(saved);
      return saved;
    } catch (e, st) {
      if (!ApiClient.isOfflineError(e)) ApiClient.throwReadable(e, st);
      debugPrint('Hors ligne : paiement mis en file ($e)');
      await _hiveDataSource.addPayment(payment);
      await _syncQueue.enqueue(
        entityType: SyncEntityType.payment,
        operation: SyncOperation.create,
        entityId: payment.id,
      );
      return payment;
    }
  }

  /// Supprime un paiement localement. Pas de suppression côté API en V1
  /// (traçabilité financière, voir ApiPaymentDatasource.deletePayment) ;
  /// un paiement créé hors ligne et jamais envoyé est simplement retiré de
  /// la file.
  Future<void> removePayment(String paymentId) async {
    await _hiveDataSource.deletePayment(paymentId);
    await _syncQueue.enqueue(
      entityType: SyncEntityType.payment,
      operation: SyncOperation.delete,
      entityId: paymentId,
    );
  }

  /// Met à jour un paiement. Retourne la version faisant foi : celle
  /// renvoyée par le serveur (avec son éventuel numéro de reçu) si la
  /// synchronisation réussit, sinon la version locale en attente de
  /// synchronisation (mise en file pour rejeu automatique — CDC section 20,
  /// doc/audit.md points D2/F5). Un refus du serveur (validation…) annule la
  /// modification locale et remonte l'erreur à l'écran.
  Future<Payment> updatePayment(Payment payment) async {
    final previous = _hiveDataSource.getPaymentById(payment.id);
    await _hiveDataSource.updatePayment(payment);

    // Créé hors ligne, pas encore sur le serveur : la création en file
    // enverra cet état à jour.
    if (_syncQueue.hasPendingCreate(SyncEntityType.payment, payment.id)) {
      await _syncQueue.enqueue(
        entityType: SyncEntityType.payment,
        operation: SyncOperation.update,
        entityId: payment.id,
      );
      return payment;
    }

    try {
      final saved = await _apiDataSource.updatePayment(payment);
      await _hiveDataSource.updatePayment(saved);
      await _syncQueue.resolve(SyncEntityType.payment, payment.id);
      return saved;
    } catch (e, st) {
      if (!ApiClient.isOfflineError(e)) {
        if (previous != null) await _hiveDataSource.updatePayment(previous);
        ApiClient.throwReadable(e, st);
      }
      debugPrint('Hors ligne : mise à jour du paiement mise en file ($e)');
      await _syncQueue.enqueue(
        entityType: SyncEntityType.payment,
        operation: SyncOperation.update,
        entityId: payment.id,
      );
      return payment;
    }
  }

  /// Rejoue une création faite hors ligne — réservé à SyncOrchestrator.
  /// Remplace l'identifiant temporaire local par l'identifiant serveur.
  /// Ne rattrape PAS l'erreur : l'appelant doit savoir si le rejeu a échoué
  /// pour décider de garder l'action en file ou non.
  Future<void> retrySyncCreate(String paymentId, DateTime performedAt) async {
    final payment = _hiveDataSource.getPaymentById(paymentId);
    if (payment == null) return;
    final saved = await _apiDataSource.addPayment(
      payment,
      payment.markazId,
      performedAt: performedAt,
    );
    await _hiveDataSource.deletePayment(paymentId);
    await _hiveDataSource.addPayment(saved);
  }

  /// Rejoue une mise à jour en attente — réservé à SyncOrchestrator.
  Future<void> retrySyncUpdate(String paymentId, DateTime performedAt) async {
    final payment = _hiveDataSource.getPaymentById(paymentId);
    if (payment == null) return;
    final saved = await _apiDataSource.updatePayment(payment, performedAt: performedAt);
    await _hiveDataSource.updatePayment(saved);
  }

  /// Rejoue une suppression en attente — réservé à SyncOrchestrator (sans
  /// effet côté API en V1, voir [removePayment]).
  Future<void> retrySyncDelete(String paymentId) async {
    await _apiDataSource.deletePayment(paymentId);
  }

  /// Retire du cache local un paiement créé hors ligne dont l'envoi a été
  /// abandonné par l'utilisateur.
  Future<void> discardLocal(String paymentId) async {
    await _hiveDataSource.deletePayment(paymentId);
  }

  /// Résumé lisible pour l'écran "Synchronisation".
  String? describe(String paymentId) {
    final payment = _hiveDataSource.getPaymentById(paymentId);
    if (payment == null) return null;
    return payment.amount.toStringAsFixed(0);
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

  /// Recharge le cache local depuis l'API pour la Markaz donnée, sans
  /// écraser les saisies locales encore en attente de synchronisation
  /// (CDC §20 — sinon une saisie hors ligne serait perdue au redémarrage).
  Future<void> syncFromMarkaz(String markazId) async {
    try {
      final payments = await _apiDataSource.getPaymentsByMarkaz(markazId);
      final pendingIds = _syncQueue.pendingIds(SyncEntityType.payment);
      final pendingLocal = pendingIds
          .map(_hiveDataSource.getPaymentById)
          .whereType<Payment>()
          .toList();
      await _hiveDataSource.clearAll();
      for (final payment in payments) {
        if (pendingIds.contains(payment.id)) continue;
        await _hiveDataSource.addPayment(payment);
      }
      for (final payment in pendingLocal) {
        await _hiveDataSource.addPayment(payment);
      }
    } catch (e) {
      debugPrint('Erreur sync API (paiements) : $e');
    }
  }
}
