import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part 'class_model.g.dart';

/// Modèle représentant une classe dans la Markaz
@HiveType(typeId: 5)
class ClassModel extends Equatable {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String level; // Ex: "Débutant", "Intermédiaire", "Avancé"

  @HiveField(3)
  final String description;

  @HiveField(4)
  final String teacherId; // ID de l'enseignant responsable

  @HiveField(5)
  final String teacherName;

  @HiveField(6)
  final int maxStudents;

  @HiveField(7)
  final List<String> studentIds; // IDs des élèves dans la classe

  @HiveField(8)
  final String markazId;

  @HiveField(9)
  final DateTime createdAt;

  @HiveField(10)
  final bool isActive;

  @HiveField(11)
  final String? schedule; // Emploi du temps (ex: "Lun, Mer, Ven - 16h-18h")

  @HiveField(12)
  final String? room; // Salle de classe

  const ClassModel({
    required this.id,
    required this.name,
    required this.level,
    required this.description,
    required this.teacherId,
    required this.teacherName,
    required this.maxStudents,
    required this.studentIds,
    required this.markazId,
    required this.createdAt,
    this.isActive = true,
    this.schedule,
    this.room,
  });

  /// Crée une nouvelle instance avec les modifications
  ClassModel copyWith({
    String? id,
    String? name,
    String? level,
    String? description,
    String? teacherId,
    String? teacherName,
    int? maxStudents,
    List<String>? studentIds,
    String? markazId,
    DateTime? createdAt,
    bool? isActive,
    String? schedule,
    String? room,
  }) {
    return ClassModel(
      id: id ?? this.id,
      name: name ?? this.name,
      level: level ?? this.level,
      description: description ?? this.description,
      teacherId: teacherId ?? this.teacherId,
      teacherName: teacherName ?? this.teacherName,
      maxStudents: maxStudents ?? this.maxStudents,
      studentIds: studentIds ?? this.studentIds,
      markazId: markazId ?? this.markazId,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
      schedule: schedule ?? this.schedule,
      room: room ?? this.room,
    );
  }

  /// Ajoute un élève à la classe
  ClassModel addStudent(String studentId) {
    if (studentIds.contains(studentId)) return this;
    if (studentIds.length >= maxStudents) return this;
    
    return copyWith(studentIds: [...studentIds, studentId]);
  }

  /// Retire un élève de la classe
  ClassModel removeStudent(String studentId) {
    return copyWith(
      studentIds: studentIds.where((id) => id != studentId).toList(),
    );
  }

  /// Nombre d'élèves actuels (IDs valides seulement)
  int get currentStudentCount => studentIds.length;
  
  /// Nombre d'élèves réels (après validation)
  int get realStudentCount => studentIds.length;
  
  /// Nettoie les IDs d'élèves qui n'existent plus
  ClassModel cleanStudentIds(List<String> existingStudentIds) {
    final validStudentIds = studentIds.where((id) => existingStudentIds.contains(id)).toList();
    if (validStudentIds.length == studentIds.length) {
      return this; // Pas de changement nécessaire
    }
    return copyWith(studentIds: validStudentIds);
  }

  /// Places disponibles
  int get availablePlaces => maxStudents - studentIds.length;

  /// La classe est pleine
  bool get isFull => studentIds.length >= maxStudents;

  /// Convertit une classe en JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'level': level,
      'description': description,
      'teacherId': teacherId,
      'teacherName': teacherName,
      'maxStudents': maxStudents,
      'studentIds': studentIds,
      'markazId': markazId,
      'createdAt': createdAt.toIso8601String(),
      'isActive': isActive,
      'schedule': schedule,
      'room': room,
    };
  }

  /// Crée une classe à partir de JSON
  factory ClassModel.fromJson(Map<String, dynamic> json) {
    return ClassModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      level: json['level'] as String? ?? '',
      description: json['description'] as String? ?? '',
      teacherId: json['teacherId'] as String? ?? '',
      teacherName: json['teacherName'] as String? ?? '',
      maxStudents: json['maxStudents'] as int? ?? 20,
      studentIds: (json['studentIds'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      markazId: json['markazId'] as String? ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      isActive: json['isActive'] as bool? ?? true,
      schedule: json['schedule'] as String?,
      room: json['room'] as String?,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        level,
        description,
        teacherId,
        teacherName,
        maxStudents,
        studentIds,
        markazId,
        createdAt,
        isActive,
        schedule,
        room,
      ];

  @override
  String toString() =>
      'ClassModel(id: $id, name: $name, level: $level, students: ${studentIds.length}/$maxStudents)';
}
