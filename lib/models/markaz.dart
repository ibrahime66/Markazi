import 'package:equatable/equatable.dart';

/// Fiche du Markaz courant (CDC section 8.2). Récupérée depuis l'API
/// (GET /markaz) — pas de cache Hive : c'est une donnée unique par
/// utilisateur, peu volumineuse, rechargée à chaque connexion.
class Markaz extends Equatable {
  final String id;
  final String name;
  final String? slogan;
  final String? logoPath;
  final String? address;
  final String? city;
  final String? country;
  // Devise affichée avec chaque montant dans toute l'app (CDC — doc/audit.md
  // point I4). "GNF" par défaut si le Markaz ne l'a pas encore configurée
  // (valeur par défaut côté serveur), mais reste modifiable pour un Markaz
  // situé dans un autre pays.
  final String currency;
  final String? phone;
  final String? email;
  final String? website;
  final String? primaryColorHex;
  final String? secondaryColorHex;
  final List<String> workingDays;

  const Markaz({
    required this.id,
    required this.name,
    this.slogan,
    this.logoPath,
    this.address,
    this.city,
    this.country,
    this.currency = 'GNF',
    this.phone,
    this.email,
    this.website,
    this.primaryColorHex,
    this.secondaryColorHex,
    this.workingDays = const [],
  });

  factory Markaz.fromJson(Map<String, dynamic> json) {
    return Markaz(
      id: json['id'].toString(),
      name: json['name'] as String? ?? '',
      slogan: json['slogan'] as String?,
      logoPath: json['logo_path'] as String?,
      address: json['address'] as String?,
      city: json['city'] as String?,
      country: json['country'] as String?,
      currency: json['currency'] as String? ?? 'GNF',
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      website: json['website'] as String?,
      primaryColorHex: json['primary_color'] as String?,
      secondaryColorHex: json['secondary_color'] as String?,
      workingDays: (json['working_days'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
    );
  }

  @override
  List<Object?> get props => [
        id, name, slogan, logoPath, address, city, country, currency,
        phone, email, website, primaryColorHex, secondaryColorHex, workingDays,
      ];
}
