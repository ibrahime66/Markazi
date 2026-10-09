import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:markazi/document_engine/document_service.dart';
import 'package:markazi/document_engine/models/markaz_branding.dart';
import 'package:markazi/models/attendance.dart';
import 'package:markazi/models/class_model.dart';
import 'package:markazi/models/payment.dart';
import 'package:markazi/models/recitation.dart';
import 'package:markazi/models/student.dart';
import 'package:markazi/services/class_report_builder.dart';
import 'package:markazi/utils/course_days.dart';

/// CDC §11.3 — rapport hebdomadaire/mensuel pour un groupe entier.

Student _student(String id, String name) => Student(
      id: id,
      name: name,
      parentPhone: '622000000',
      markazId: 'm1',
      createdAt: DateTime(2026, 1, 1),
    );

Attendance _attendance(String studentId, DateTime date, AttendanceStatus status) => Attendance(
      id: '$studentId-${date.day}',
      studentId: studentId,
      markazId: 'm1',
      date: date,
      status: status,
      lesson: 'Al-Fatiha',
    );

void main() {
  group('Jours de cours (même règle que le serveur)', () {
    test('lundi-vendredi par défaut', () {
      // Semaine du lundi 3 au dimanche 9 août 2026.
      expect(countCourseDays(DateTime(2026, 8, 3), DateTime(2026, 8, 9), const []), 5);
    });

    test('jours configurés par le Markaz', () {
      expect(
        countCourseDays(DateTime(2026, 8, 3), DateTime(2026, 8, 9),
            const ['sat', 'sun', 'mon', 'tue', 'wed', 'thu']),
        6,
      );
    });

    test('bornes incluses, période d’un jour', () {
      expect(countCourseDays(DateTime(2026, 8, 7), DateTime(2026, 8, 7), const []), 1);
      expect(countCourseDays(DateTime(2026, 8, 8), DateTime(2026, 8, 8), const []), 0);
    });
  });

  group('Construction du rapport de groupe', () {
    final group = ClassModel(
      id: 'c1',
      name: 'Groupe Hifz',
      level: 'Débutant',
      description: '',
      teacherId: '',
      teacherName: 'Oustaz Mamadou',
      maxStudents: 30,
      studentIds: const ['s1', 's2'],
      markazId: 'm1',
      createdAt: DateTime(2026, 1, 1),
    );
    final students = [_student('s2', 'Binta'), _student('s1', 'Amadou'), _student('s3', 'Hors groupe')];

    // Vendredi 7 août 2026 : 5 jours de cours écoulés dans la semaine.
    final now = DateTime(2026, 8, 7, 15);

    test('semaine : taux sur les jours de cours écoulés, absence justifiée = absence', () {
      final report = ClassReportBuilder.build(
        markaz: const MarkazBranding(markazName: 'Markaz Al-Nour'),
        workingDays: const [],
        group: group,
        students: students,
        attendances: [
          _attendance('s1', DateTime(2026, 8, 3), AttendanceStatus.present),
          _attendance('s1', DateTime(2026, 8, 4), AttendanceStatus.present),
          _attendance('s1', DateTime(2026, 8, 5), AttendanceStatus.justified),
          _attendance('s1', DateTime(2026, 8, 6), AttendanceStatus.late),
          _attendance('s1', DateTime(2026, 7, 31), AttendanceStatus.present), // semaine précédente
          _attendance('s2', DateTime(2026, 8, 7), AttendanceStatus.absent),
          _attendance('s3', DateTime(2026, 8, 7), AttendanceStatus.present), // autre groupe
        ],
        recitations: [
          Recitation(
            id: 'r1',
            studentId: 's1',
            markazId: 'm1',
            date: DateTime(2026, 8, 4),
            surah: 'Al-Baqara',
            status: RecitationStatus.recited,
          ),
        ],
        payments: [
          Payment(
            id: 'p1',
            studentId: 's1',
            markazId: 'm1',
            amount: 50000,
            status: PaymentStatus.paid,
            date: DateTime(2026, 8, 1),
          ),
          Payment(
            id: 'p2',
            studentId: 's2',
            markazId: 'm1',
            amount: 50000,
            status: PaymentStatus.unpaid,
            date: DateTime(2026, 8, 1),
          ),
        ],
        monthly: false,
        now: now,
      );

      expect(report.periodStart, DateTime(2026, 8, 3));
      expect(report.periodEnd, DateTime(2026, 8, 9));
      expect(report.courseDays, 5);
      expect(report.rows.map((r) => r.studentName), ['Amadou', 'Binta']);

      final amadou = report.rows.first;
      expect(amadou.presentDays, 2);
      expect(amadou.absentDays, 1);
      expect(amadou.lateDays, 1);
      expect(amadou.attendanceRate, 40);
      expect(amadou.recitations, 1);
      expect(amadou.paymentStatus, 'Payé');

      final binta = report.rows.last;
      expect(binta.absentDays, 1);
      expect(binta.attendanceRate, 0);
      expect(binta.paymentStatus, 'Non payé');

      expect(report.totalPaid, 50000);
      expect(report.averageAttendanceRate, 20);
    });

    test('mois : période du 1er au dernier jour, jours de cours jusqu’à aujourd’hui', () {
      final report = ClassReportBuilder.build(
        markaz: const MarkazBranding(markazName: 'Markaz Al-Nour'),
        workingDays: const [],
        group: group,
        students: students,
        attendances: const [],
        recitations: const [],
        payments: const [],
        monthly: true,
        now: now,
      );

      expect(report.periodStart, DateTime(2026, 8, 1));
      expect(report.periodEnd, DateTime(2026, 8, 31));
      // 1er août 2026 = samedi : lun 3 → ven 7 = 5 jours de cours écoulés.
      expect(report.courseDays, 5);
      expect(report.rows.every((r) => r.paymentStatus == 'Non enregistré'), isTrue);
    });
  });

  testWidgets('le PDF du rapport de groupe est réellement généré', (tester) async {
    final report = ClassReportBuilder.build(
      markaz: const MarkazBranding(markazName: 'مركز النور'),
      workingDays: const [],
      group: ClassModel(
        id: 'c1',
        name: 'Groupe Hifz',
        level: '',
        description: '',
        teacherId: '',
        teacherName: '',
        maxStudents: 30,
        studentIds: const ['s1'],
        markazId: 'm1',
        createdAt: DateTime(2026, 1, 1),
      ),
      students: [_student('s1', 'Amadou')],
      attendances: const [],
      recitations: const [],
      payments: const [],
      monthly: true,
      now: DateTime(2026, 8, 7),
    );

    final bytes = await tester.runAsync(() => DocumentService().generateClassReport(report));
    expect(bytes, isNotNull);
    // Signature d'un fichier PDF.
    expect(String.fromCharCodes(bytes!.take(4)), '%PDF');
  });

  testWidgets('un logo illisible n’empêche pas la génération du document', (tester) async {
    final report = ClassReportBuilder.build(
      markaz: MarkazBranding(
        markazName: 'Markaz Al-Nour',
        logoBytes: Uint8List.fromList(List.filled(32, 7)),
      ),
      workingDays: const [],
      group: ClassModel(
        id: 'c1',
        name: 'Groupe',
        level: '',
        description: '',
        teacherId: '',
        teacherName: '',
        maxStudents: 30,
        studentIds: const [],
        markazId: 'm1',
        createdAt: DateTime(2026, 1, 1),
      ),
      students: const [],
      attendances: const [],
      recitations: const [],
      payments: const [],
      monthly: false,
      now: DateTime(2026, 8, 7),
    );

    final bytes = await tester.runAsync(() => DocumentService().generateClassReport(report));
    expect(String.fromCharCodes(bytes!.take(4)), '%PDF');
  });
}
