import 'markaz_branding.dart';

/// Métadonnées communes à tout document généré.
abstract class DocumentMetadata {
  final MarkazBranding markaz;

  const DocumentMetadata({required this.markaz});
}

/// Métadonnées d'un reçu de paiement (CDC section 8.7 / 21).
class PaymentReceiptMetadata extends DocumentMetadata {
  final String receiptNumber;
  final DateTime date;
  final String studentName;
  final String? parentName;
  final String? parentPhone;
  final double amountPaid;
  final String month; // ex: "Août 2026"
  final String paymentMethod;
  final String status;
  final String recordedByName;

  const PaymentReceiptMetadata({
    required super.markaz,
    required this.receiptNumber,
    required this.date,
    required this.studentName,
    this.parentName,
    this.parentPhone,
    required this.amountPaid,
    required this.month,
    required this.paymentMethod,
    required this.status,
    required this.recordedByName,
  });
}

/// Une ligne de présence/récitation pour le rapport hebdomadaire.
class DailyEntry {
  final DateTime date;
  final String status; // Présent / Absent / Retard
  final String lesson;
  final String? observation;

  const DailyEntry({
    required this.date,
    required this.status,
    required this.lesson,
    this.observation,
  });
}

/// Métadonnées d'un rapport hebdomadaire par élève (CDC section 8.8).
class WeeklyReportMetadata extends DocumentMetadata {
  final String studentName;
  final String? className;
  final DateTime weekStart;
  final DateTime weekEnd;
  final List<DailyEntry> entries;
  final double attendanceRate;

  const WeeklyReportMetadata({
    required super.markaz,
    required this.studentName,
    this.className,
    required this.weekStart,
    required this.weekEnd,
    required this.entries,
    required this.attendanceRate,
  });
}

/// Un paiement listé dans le rapport mensuel.
class MonthlyPaymentEntry {
  final DateTime date;
  final double amount;
  final String status;

  const MonthlyPaymentEntry({
    required this.date,
    required this.amount,
    required this.status,
  });
}

/// Métadonnées d'un rapport mensuel par élève (CDC section 8.8).
class MonthlyReportMetadata extends DocumentMetadata {
  final String studentName;
  final String? className;
  final int month;
  final int year;
  final int totalDays;
  final int presentDays;
  final int absentDays;
  final double attendanceRate;
  final List<MonthlyPaymentEntry> payments;

  const MonthlyReportMetadata({
    required super.markaz,
    required this.studentName,
    this.className,
    required this.month,
    required this.year,
    required this.totalDays,
    required this.presentDays,
    required this.absentDays,
    required this.attendanceRate,
    required this.payments,
  });
}
