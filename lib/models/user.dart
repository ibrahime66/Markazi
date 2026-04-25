import 'package:equatable/equatable.dart';

/// Énumération des rôles utilisateurs
enum UserRole {
  teacher,
  admin,
  parent,
}

/// Modèle représentant un utilisateur authentifié
class User extends Equatable {
  final String id;
  final String name;
  final String email;
  final UserRole role;
  final String markazId;
  final DateTime createdAt;

  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.markazId,
    required this.createdAt,
  });

  /// Crée une copie de l'utilisateur avec certains champs modifiés
  User copyWith({
    String? id,
    String? name,
    String? email,
    UserRole? role,
    String? markazId,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      markazId: markazId ?? this.markazId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Convertit en JSON pour l'API
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role.toString().split('.').last,
      'markazId': markazId,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Crée depuis un JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      role: UserRole.values.firstWhere(
        (role) => role.toString().split('.').last == json['role'],
        orElse: () => UserRole.teacher,
      ),
      markazId: json['markazId'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  @override
  List<Object?> get props => [id, name, email, role, markazId, createdAt];
}
