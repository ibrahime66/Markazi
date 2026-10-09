import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part 'payment.g.dart';

/// Énumération des statuts de paiement
@HiveType(typeId: 2)
enum PaymentStatus {
  @HiveField(0)
  paid,
  @HiveField(1)
  unpaid,
}

/// Modèle représentant un paiement d'un élève
@HiveType(typeId: 1)
class Payment extends Equatable {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String studentId;

  @HiveField(2)
  final String markazId;

  @HiveField(3)
  final double amount;

  @HiveField(4)
  final PaymentStatus status;

  @HiveField(5)
  final DateTime date;

  /// Numéro de reçu attribué par le serveur (CDC section 21 : séquence
  /// unique par Markaz, ex. "MK-1-2026-000123"). Null tant que le paiement
  /// n'est pas marqué payé.
  @HiveField(6)
  final String? receiptNumber;

  /// Jour exact où l'élève a payé (distinct de [date], qui désigne le MOIS
  /// concerné par le paiement). Optionnel : reste `null` pour un paiement
  /// marqué "non payé". Affiché sur le reçu (CDC 8.7 / 21).
  @HiveField(7)
  final DateTime? paidAt;

  /// Mode de paiement (CDC §8.7) : 'cash' (espèces) ou 'other' (autre :
  /// mobile money, virement…), mêmes valeurs que l'API. Nullable pour les
  /// paiements déjà en cache avant l'ajout du champ : voir [mode].
  @HiveField(8)
  final String? paymentMode;

  /// Observation libre saisie avec le paiement (CDC §8.7).
  @HiveField(9)
  final String? observation;

  /// Mode de paiement effectif ('cash' par défaut).
  String get mode => paymentMode ?? 'cash';

  const Payment({
    required this.id,
    required this.studentId,
    required this.markazId,
    required this.amount,
    required this.status,
    required this.date,
    this.receiptNumber,
    this.paidAt,
    this.paymentMode,
    this.observation,
  });

  /// Crée une nouvelle instance avec les modifications
  Payment copyWith({
    String? id,
    String? studentId,
    String? markazId,
    double? amount,
    PaymentStatus? status,
    DateTime? date,
    String? receiptNumber,
    DateTime? paidAt,
    String? paymentMode,
    String? observation,
  }) {
    return Payment(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      markazId: markazId ?? this.markazId,
      amount: amount ?? this.amount,
      status: status ?? this.status,
      date: date ?? this.date,
      receiptNumber: receiptNumber ?? this.receiptNumber,
      paidAt: paidAt ?? this.paidAt,
      paymentMode: paymentMode ?? this.paymentMode,
      observation: observation ?? this.observation,
    );
  }

  /// Convertit un Payment en JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'studentId': studentId,
      'markazId': markazId,
      'amount': amount,
      'status': status.name,
      'date': date.toIso8601String(),
      'receiptNumber': receiptNumber,
      'paidAt': paidAt?.toIso8601String(),
      'paymentMode': paymentMode,
      'observation': observation,
    };
  }

  /// Crée un Payment à partir de JSON
  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'] as String? ?? '',
      studentId: json['studentId'] as String? ?? '',
      markazId: json['markazId'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      status:
          json['status'] == 'paid' ? PaymentStatus.paid : PaymentStatus.unpaid,
      date: json['date'] != null
          ? DateTime.parse(json['date'] as String)
          : DateTime.now(),
      receiptNumber: json['receiptNumber'] as String?,
      paidAt: json['paidAt'] != null
          ? DateTime.parse(json['paidAt'] as String)
          : null,
      paymentMode: json['paymentMode'] as String?,
      observation: json['observation'] as String?,
    );
  }

  @override
  List<Object?> get props => [
        id,
        studentId,
        markazId,
        amount,
        status,
        date,
        receiptNumber,
        paidAt,
        paymentMode,
        observation,
      ];

  @override
  String toString() =>
      'Payment(id: $id, studentId: $studentId, markazId: $markazId, amount: $amount, status: ${status.name}, date: $date, receiptNumber: $receiptNumber, paidAt: $paidAt)';
}
