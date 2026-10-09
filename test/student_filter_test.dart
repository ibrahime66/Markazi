import 'package:flutter_test/flutter_test.dart';
import 'package:markazi/models/class_model.dart';
import 'package:markazi/models/student.dart';
import 'package:markazi/utils/student_filter.dart';

/// CDC §8.3 — recherche et filtrage des élèves.
Student _s(String id, String name, String phone) => Student(
      id: id,
      name: name,
      parentPhone: phone,
      markazId: 'm1',
      createdAt: DateTime(2026),
    );

void main() {
  final students = [
    _s('1', 'Amadou Diallo', '622 18 09 33'),
    _s('2', 'Hélène Camara', '655000111'),
    _s('3', 'Ibrahima Sow', '620123456'),
  ];
  final classes = [
    ClassModel(
      id: 'c1',
      name: 'Hifz',
      level: '',
      description: '',
      teacherId: '',
      teacherName: '',
      maxStudents: 30,
      studentIds: const ['1', '2'],
      markazId: 'm1',
      createdAt: DateTime(2026),
    ),
  ];

  List<String> names(List<Student> list) => list.map((s) => s.name).toList();

  test('sans critère : tous les élèves', () {
    expect(filterStudents(students), hasLength(3));
  });

  test('par nom, sans tenir compte des majuscules ni des accents', () {
    expect(names(filterStudents(students, query: 'helene')), ['Hélène Camara']);
    expect(names(filterStudents(students, query: 'DIALLO')), ['Amadou Diallo']);
  });

  test('par téléphone, espaces ignorés', () {
    expect(names(filterStudents(students, query: '6221809')), ['Amadou Diallo']);
    expect(names(filterStudents(students, query: '622 18')), ['Amadou Diallo']);
  });

  test('par groupe et sans groupe', () {
    expect(names(filterStudents(students, groupFilter: 'c1', classes: classes)),
        ['Amadou Diallo', 'Hélène Camara']);
    expect(names(filterStudents(students, groupFilter: studentFilterNoGroup, classes: classes)),
        ['Ibrahima Sow']);
  });

  test('recherche combinée au filtre de groupe', () {
    expect(filterStudents(students, query: 'ibrahima', groupFilter: 'c1', classes: classes),
        isEmpty);
  });
}
