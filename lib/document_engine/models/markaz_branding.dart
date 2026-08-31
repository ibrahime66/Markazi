import 'package:pdf/pdf.dart';

/// Informations du Markaz réutilisées dans tous les documents générés
/// (CDC section 8.2 / 21). Seul [markazName] est obligatoire.
class MarkazBranding {
  final String markazName;
  final String? logoPath; // chemin d'asset local (ex: assets/logo/app_icon.png)
  final String? address;
  final String? city;
  final String? country;
  final String? phone;
  final String? email;
  final String? slogan;
  // Devise à afficher avec chaque montant sur les documents générés
  // (reçus, rapports) — doc/audit.md point I4 : auparavant "GNF" codé en
  // dur, ne convenant qu'aux Markaz guinéens.
  final String currency;
  final String? primaryColorHex; // ex: '#1A7F55'
  final String? secondaryColorHex;

  const MarkazBranding({
    required this.markazName,
    this.logoPath,
    this.address,
    this.city,
    this.country,
    this.phone,
    this.email,
    this.slogan,
    this.currency = 'GNF',
    this.primaryColorHex,
    this.secondaryColorHex,
  });

  /// Convertit un hex "#RRGGBB" ou "#AARRGGBB" en [PdfColor].
  /// Retourne null si [hex] est absent ou mal formé (fallback silencieux
  /// vers le thème par défaut plutôt qu'un crash de génération de document).
  static PdfColor? _parseHex(String? hex) {
    if (hex == null || hex.isEmpty) return null;
    var cleaned = hex.replaceFirst('#', '');
    if (cleaned.length == 6) cleaned = 'FF$cleaned'; // ajoute l'alpha si absent
    final value = int.tryParse(cleaned, radix: 16);
    return value != null ? PdfColor.fromInt(value) : null;
  }

  PdfColor? get primaryColor => _parseHex(primaryColorHex);
  PdfColor? get secondaryColor => _parseHex(secondaryColorHex);

  /// Adresse complète formatée (ville, pays) pour affichage sur un document.
  String get fullAddress {
    final parts = [address, city, country].where((p) => p != null && p.isNotEmpty);
    return parts.join(', ');
  }
}
