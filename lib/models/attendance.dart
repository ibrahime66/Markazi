import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part 'attendance.g.dart';

/// Énumération des statuts de présence
@HiveType(typeId: 4)
enum AttendanceStatus {
  @HiveField(0)
  present,
  @HiveField(1)
  absent,
  @HiveField(2)
  late,
}

/// Modèle représentant une présence
@HiveType(typeId: 3)
class Attendance extends Equatable {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String studentId;

  @HiveField(2)
  final String markazId;

  @HiveField(3)
  final DateTime date;

  @HiveField(4)
  final AttendanceStatus status;

  @HiveField(5)
  final String lesson;

  const Attendance({
    required this.id,
    required this.studentId,
    required this.markazId,
    required this.date,
    required this.status,
    required this.lesson,
  });

  /// Crée une nouvelle instance avec les modifications
  Attendance copyWith({
    String? id,
    String? studentId,
    String? markazId,
    DateTime? date,
    AttendanceStatus? status,
    String? lesson,
  }) {
    return Attendance(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      markazId: markazId ?? this.markazId,
      date: date ?? this.date,
      status: status ?? this.status,
      lesson: lesson ?? this.lesson,
    );
  }

  /// Convertit un Attendance en JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'studentId': studentId,
      'markazId': markazId,
      'date': date.toIso8601String(),
      'status': status.name,
      'lesson': lesson,
    };
  }

  /// Crée un Attendance à partir de JSON
  factory Attendance.fromJson(Map<String, dynamic> json) {
    return Attendance(
      id: json['id'] as String? ?? '',
      studentId: json['studentId'] as String? ?? '',
      markazId: json['markazId'] as String? ?? '',
      date: json['date'] != null
          ? DateTime.parse(json['date'] as String)
          : DateTime.now(),
      status: json['status'] == 'present'
          ? AttendanceStatus.present
          : AttendanceStatus.absent,
      lesson: json['lesson'] as String? ?? '',
    );
  }

  @override
  List<Object?> get props => [id, studentId, markazId, date, status, lesson];

  @override
  String toString() =>
      'Attendance(id: $id, studentId: $studentId, markazId: $markazId, date: $date, status: ${status.name}, lesson: $lesson)';
}
