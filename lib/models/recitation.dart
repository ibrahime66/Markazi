import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part 'recitation.g.dart';

/// Statut d'une séance de récitation (CDC section 8.5).
@HiveType(typeId: 8)
enum RecitationStatus {
  @HiveField(0)
  recited,
  @HiveField(1)
  notRecited,
  @HiveField(2)
  partial,
}

/// Modèle représentant une séance de récitation coranique — module ajouté
/// pour combler doc/audit.md, point B1 (backend complet, aucune intégration
/// Flutter jusqu'ici).
@HiveType(typeId: 7)
class Recitation extends Equatable {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String studentId;

  @HiveField(2)
  final String markazId;

  @HiveField(3)
  final DateTime date;

  @HiveField(4)
  final String surah;

  @HiveField(5)
  final RecitationStatus status;

  @HiveField(6)
  final int? ayahFrom;

  @HiveField(7)
  final int? ayahTo;

  @HiveField(8)
  final String? note;

  const Recitation({
    required this.id,
    required this.studentId,
    required this.markazId,
    required this.date,
    required this.surah,
    required this.status,
    this.ayahFrom,
    this.ayahTo,
    this.note,
  });

  Recitation copyWith({
    String? id,
    String? studentId,
    String? markazId,
    DateTime? date,
    String? surah,
    RecitationStatus? status,
    int? ayahFrom,
    int? ayahTo,
    String? note,
  }) {
    return Recitation(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      markazId: markazId ?? this.markazId,
      date: date ?? this.date,
      surah: surah ?? this.surah,
      status: status ?? this.status,
      ayahFrom: ayahFrom ?? this.ayahFrom,
      ayahTo: ayahTo ?? this.ayahTo,
      note: note ?? this.note,
    );
  }

  @override
  List<Object?> get props => [id, studentId, markazId, date, surah, status, ayahFrom, ayahTo, note];

  @override
  String toString() => 'Recitation(id: $id, studentId: $studentId, surah: $surah, status: $status)';
}
