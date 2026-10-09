import 'package:flutter_test/flutter_test.dart';
import 'package:markazi/models/attendance.dart';
import 'package:markazi/repositories/attendance_repository.dart';
import 'package:markazi/repositories/student_repository.dart';
import 'package:markazi/services/attendance_service.dart';
import 'package:markazi/services/auth_service.dart';

/// doc/audit.md, point H7 : le contrôle de doublon côté app doit suivre la
/// règle serveur — une seule présence par élève et par jour, toutes leçons
/// confondues — y compris pour une présence relue depuis l'API, datée de
/// minuit pile.
class _FakeAttendanceRepository extends Fake implements AttendanceRepository {
  _FakeAttendanceRepository(this.items);

  final List<Attendance> items;

  @override
  List<Attendance> getAllAttendances() => items;
}

class _FakeStudentRepository extends Fake implements StudentRepository {}

class _FakeAuthService extends Fake implements AuthService {}

Attendance _attendance(String id, DateTime date, {String lesson = 'Al-Fatiha'}) {
  return Attendance(
    id: id,
    studentId: 's1',
    markazId: 'm1',
    date: date,
    status: AttendanceStatus.present,
    lesson: lesson,
  );
}

AttendanceService _serviceWith(List<Attendance> items) {
  return AttendanceService(
    _FakeAttendanceRepository(items),
    _FakeStudentRepository(),
    _FakeAuthService(),
  );
}

void main() {
  final now = DateTime.now();
  final midnight = DateTime(now.year, now.month, now.day);

  test('une présence relue depuis l’API (minuit pile) est détectée', () {
    final service = _serviceWith([_attendance('a1', midnight)]);
    expect(service.findTodayAttendance('s1', 'm1')?.id, 'a1');
  });

  test('la leçon ne compte pas : une autre leçon le même jour est un doublon', () {
    final service = _serviceWith([_attendance('a1', now, lesson: 'Al-Baqara')]);
    expect(service.findTodayAttendance('s1', 'm1')?.id, 'a1');
  });

  test('une présence de la veille n’est pas un doublon', () {
    final service = _serviceWith([
      _attendance('a1', midnight.subtract(const Duration(minutes: 1))),
    ]);
    expect(service.findTodayAttendance('s1', 'm1'), isNull);
  });

  test('un autre élève ou un autre Markaz n’est pas un doublon', () {
    final service = _serviceWith([_attendance('a1', now)]);
    expect(service.findTodayAttendance('s2', 'm1'), isNull);
    expect(service.findTodayAttendance('s1', 'm2'), isNull);
  });
}
