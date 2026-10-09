import '../document_engine/models/document_metadata.dart';
import '../document_engine/models/markaz_branding.dart';
import '../models/attendance.dart';
import '../models/class_model.dart';
import '../models/payment.dart';
import '../models/recitation.dart';
import '../models/student.dart';
import '../utils/course_days.dart';

/// Construit les données du rapport de groupe (CDC §11.3) à partir du cache
/// local — fonction pure, sans accès réseau ni widget, pour être testable.
///
/// - Période : semaine (lundi → dimanche) ou mois en cours ; les jours de
///   cours ne sont comptés que jusqu'à aujourd'hui (le reste de la période
///   n'a pas encore eu lieu).
/// - Taux de présence = jours présents / jours de cours (même règle que le
///   serveur, CDC §8.6) ; une absence justifiée compte comme une absence.
/// - Paiement : statut du paiement du mois de la période.
class ClassReportBuilder {
  ClassReportBuilder._();

  static ClassReportMetadata build({
    required MarkazBranding markaz,
    required List<String> workingDays,
    required ClassModel group,
    required List<Student> students,
    required List<Attendance> attendances,
    required List<Recitation> recitations,
    required List<Payment> payments,
    required bool monthly,
    required DateTime now,
  }) {
    final today = DateTime(now.year, now.month, now.day);
    final DateTime start;
    final DateTime end;
    if (monthly) {
      start = DateTime(today.year, today.month, 1);
      end = DateTime(today.year, today.month + 1, 0);
    } else {
      start = today.subtract(Duration(days: today.weekday - 1));
      end = start.add(const Duration(days: 6));
    }
    final countedUntil = end.isAfter(today) ? today : end;
    final courseDays = countCourseDays(start, countedUntil, workingDays);

    bool inPeriod(DateTime d) {
      final day = DateTime(d.year, d.month, d.day);
      return !day.isBefore(start) && !day.isAfter(end);
    }

    final members = group.studentIds
        .map((id) => students.where((s) => s.id == id).firstOrNull)
        .whereType<Student>()
        .toList()
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

    var totalPaid = 0.0;
    final rows = <ClassReportRow>[];
    for (final student in members) {
      final own = attendances.where((a) => a.studentId == student.id && inPeriod(a.date));
      final present = own.where((a) => a.status == AttendanceStatus.present).length;
      final absent = own.where((a) => a.status.isAbsence).length;
      final late = own.where((a) => a.status == AttendanceStatus.late).length;

      final monthPayments = payments.where((p) =>
          p.studentId == student.id &&
          p.date.year == start.year &&
          p.date.month == start.month);
      final paid = monthPayments.where((p) => p.status == PaymentStatus.paid);
      totalPaid += paid.fold<double>(0, (sum, p) => sum + p.amount);

      rows.add(ClassReportRow(
        studentName: student.name,
        presentDays: present,
        absentDays: absent,
        lateDays: late,
        attendanceRate: courseDays == 0 ? 0 : present / courseDays * 100,
        recitations: recitations
            .where((r) => r.studentId == student.id && inPeriod(r.date))
            .length,
        paymentStatus: paid.isNotEmpty
            ? 'Payé'
            : monthPayments.isNotEmpty
                ? 'Non payé'
                : 'Non enregistré',
      ));
    }

    return ClassReportMetadata(
      markaz: markaz,
      className: group.name,
      teacherName: group.teacherName,
      isMonthly: monthly,
      periodStart: start,
      periodEnd: end,
      courseDays: courseDays,
      rows: rows,
      totalPaid: totalPaid,
    );
  }
}
