import 'package:dio/dio.dart';
import '../models/payment.dart';
import '../services/api_client.dart';

/// Levée quand le serveur refuse un paiement car un paiement "payé" existe
/// déjà pour cet élève ce mois-ci (CDC 8.7 : "détection des doublons
/// évidents"). Distincte d'une erreur générique pour que l'écran puisse
/// proposer à l'utilisateur de confirmer explicitement au lieu de bloquer
/// silencieusement l'enregistrement.
class PaymentDuplicateException implements Exception {
  final String message;
  const PaymentDuplicateException(this.message);

  @override
  String toString() => message;
}

/// Datasource API (Laravel/MySQL) pour les paiements — remplace l'ancien
/// FirebasePaymentDatasource.
class ApiPaymentDatasource {
  final _dio = ApiClient.instance.dio;

  Future<Payment> addPayment(
    Payment payment,
    String markazId, {
    bool confirmDuplicate = false,
    DateTime? performedAt,
  }) async {
    try {
      final response = await _dio.post('/payments',
          options: ApiClient.performedAtOptions(performedAt),
          data: {
            'student_id': int.parse(payment.studentId),
            'amount': payment.amount,
            'month': payment.date.toIso8601String().split('T').first,
            'status': _statusToApi(payment.status),
            'payment_mode': payment.mode,
        if (payment.observation != null && payment.observation!.trim().isNotEmpty)
          'observation': payment.observation!.trim(),
            if (payment.paidAt != null)
              'paid_at': payment.paidAt!.toIso8601String(),
            if (confirmDuplicate) 'confirm_duplicate': true,
          });
      return _mapJsonToPayment(response.data as Map<String, dynamic>, markazId);
    } on DioException catch (e) {
      // Serveur injoignable : l'erreur réseau doit remonter telle quelle
      // pour que le repository mette la saisie en file (CDC §20).
      if (ApiClient.isOfflineError(e)) rethrow;
      final data = e.response?.data;
      if (e.response?.statusCode == 409 &&
          data is Map &&
          data['duplicate'] == true) {
        throw PaymentDuplicateException(
          data['message'] as String? ??
              'Un paiement existe déjà pour cet élève ce mois-ci.',
        );
      }
      throw ApiException(ApiClient.describeError(e));
    }
  }

  /// Change le statut d'un paiement existant (ex. marquer "payé") via
  /// PATCH /payments/{id} — modifie l'enregistrement en place au lieu d'en
  /// recréer un (voir doc/audit.md, point A2 : l'ancienne implémentation
  /// re-postait un nouveau paiement, doublant le montant compté et perdant
  /// le vrai numéro de reçu).
  Future<Payment> updatePayment(Payment payment,
      {DateTime? performedAt}) async {
    final response = await _dio.patch('/payments/${payment.id}',
        options: ApiClient.performedAtOptions(performedAt),
        data: {
          'status': _statusToApi(payment.status),
        });
    return _mapJsonToPayment(
        response.data as Map<String, dynamic>, payment.markazId);
  }

  Future<void> deletePayment(String paymentId) async {
    // Pas de suppression exposée côté API en V1 : un paiement enregistré par
    // erreur se corrige par un nouvel enregistrement, pas par suppression
    // silencieuse (traçabilité financière — CDC section 19).
  }

  Future<List<Payment>> getPaymentsByMarkaz(String markazId) async {
    final response =
        await _dio.get('/payments', queryParameters: {'per_page': 500});
    final data =
        (response.data as Map<String, dynamic>)['data'] as List<dynamic>;
    return data
        .map(
            (json) => _mapJsonToPayment(json as Map<String, dynamic>, markazId))
        .toList();
  }

  String _statusToApi(PaymentStatus status) {
    return status == PaymentStatus.paid ? 'paid' : 'unpaid';
  }

  Payment _mapJsonToPayment(Map<String, dynamic> json, String markazId) {
    return Payment(
      id: json['id'].toString(),
      studentId: json['student_id'].toString(),
      markazId: markazId,
      amount: (json['amount'] is String)
          ? double.parse(json['amount'] as String)
          : (json['amount'] as num).toDouble(),
      status:
          json['status'] == 'paid' ? PaymentStatus.paid : PaymentStatus.unpaid,
      date: DateTime.parse(json['month'] as String),
      receiptNumber: json['receipt_number'] as String?,
      paidAt: json['paid_at'] != null
          ? DateTime.parse(json['paid_at'] as String)
          : null,
      paymentMode: json['payment_mode'] as String?,
      observation: json['observation'] as String?,
    );
  }
}
