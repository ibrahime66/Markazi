import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part 'guardian.g.dart';

/// Modèle représentant un parent/tuteur (CDC section 8.3) — module ajouté
/// pour combler doc/audit.md, point B2 (backend complet, aucune intégration
/// Flutter jusqu'ici).
@HiveType(typeId: 6)
class Guardian extends Equatable {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String phone;

  @HiveField(3)
  final String markazId;

  @HiveField(4)
  final String? email;

  @HiveField(5)
  final String? address;

  const Guardian({
    required this.id,
    required this.name,
    required this.phone,
    required this.markazId,
    this.email,
    this.address,
  });

  Guardian copyWith({
    String? id,
    String? name,
    String? phone,
    String? markazId,
    String? email,
    String? address,
  }) {
    return Guardian(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      markazId: markazId ?? this.markazId,
      email: email ?? this.email,
      address: address ?? this.address,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'markazId': markazId,
      'email': email,
      'address': address,
    };
  }

  factory Guardian.fromJson(Map<String, dynamic> json) {
    return Guardian(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      markazId: json['markazId'] as String? ?? '',
      email: json['email'] as String?,
      address: json['address'] as String?,
    );
  }

  @override
  List<Object?> get props => [id, name, phone, markazId, email, address];

  @override
  String toString() => 'Guardian(id: $id, name: $name, phone: $phone)';
}
