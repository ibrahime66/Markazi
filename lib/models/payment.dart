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

  const Payment({
    required this.id,
    required this.studentId,
    required this.markazId,
    required this.amount,
    required this.status,
    required this.date,
    this.receiptNumber,
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
  }) {
    return Payment(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      markazId: markazId ?? this.markazId,
      amount: amount ?? this.amount,
      status: status ?? this.status,
      date: date ?? this.date,
      receiptNumber: receiptNumber ?? this.receiptNumber,
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
    );
  }

  @override
  List<Object?> get props =>
      [id, studentId, markazId, amount, status, date, receiptNumber];

  @override
  String toString() =>
      'Payment(id: $id, studentId: $studentId, markazId: $markazId, amount: $amount, status: ${status.name}, date: $date, receiptNumber: $receiptNumber)';
}
