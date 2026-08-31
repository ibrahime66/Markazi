import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part 'student.g.dart';

/// Modèle représentant un élève de la Markaz
@HiveType(typeId: 0)
class Student extends Equatable {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String parentPhone;

  @HiveField(3)
  final String markazId;

  @HiveField(4)
  final DateTime createdAt;

  /// Tuteur/parent rattaché à cet élève (doc/audit.md, point I5). Null si
  /// aucun tuteur enregistré n'est encore lié. Un même tuteur peut être
  /// rattaché à plusieurs élèves (fratrie) ; l'inverse n'est pas vrai.
  @HiveField(5)
  final String? guardianId;

  const Student({
    required this.id,
    required this.name,
    required this.parentPhone,
    required this.markazId,
    required this.createdAt,
    this.guardianId,
  });

  /// Crée une nouvelle instance avec les modifications
  Student copyWith({
    String? id,
    String? name,
    String? parentPhone,
    String? markazId,
    DateTime? createdAt,
    String? guardianId,
    bool clearGuardianId = false,
  }) {
    return Student(
      id: id ?? this.id,
      name: name ?? this.name,
      parentPhone: parentPhone ?? this.parentPhone,
      markazId: markazId ?? this.markazId,
      createdAt: createdAt ?? this.createdAt,
      guardianId: clearGuardianId ? null : (guardianId ?? this.guardianId),
    );
  }

  /// Convertit un Student en JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'parentPhone': parentPhone,
      'markazId': markazId,
      'createdAt': createdAt.toIso8601String(),
      'guardianId': guardianId,
    };
  }

  /// Crée un Student à partir de JSON
  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      parentPhone: json['parentPhone'] as String? ?? '',
      markazId: json['markazId'] as String? ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      guardianId: json['guardianId'] as String?,
    );
  }

  @override
  List<Object?> get props =>
      [id, name, parentPhone, markazId, createdAt, guardianId];

  @override
  String toString() =>
      'Student(id: $id, name: $name, parentPhone: $parentPhone, markazId: $markazId, createdAt: $createdAt, guardianId: $guardianId)';
}
