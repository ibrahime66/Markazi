import 'package:pdf/pdf.dart';

/// Thème visuel appliqué à tous les documents générés (CDC section 21 :
/// "injection automatique du logo, des couleurs et des coordonnées du
/// Markaz"). Les couleurs par défaut sont utilisées quand le Markaz n'a
/// pas personnalisé les siennes.
class DocumentTheme {
  final PdfColor primaryColor;
  final PdfColor secondaryColor;
  final PdfColor textColor;
  final PdfColor mutedTextColor;
  final PdfColor borderColor;

  const DocumentTheme({
    this.primaryColor = const PdfColor.fromInt(0xFF1A7F55),
    this.secondaryColor = const PdfColor.fromInt(0xFF2EAA73),
    this.textColor = const PdfColor.fromInt(0xFF1A1A1A),
    this.mutedTextColor = const PdfColor.fromInt(0xFF6B7280),
    this.borderColor = const PdfColor.fromInt(0xFFE5E7EB),
  });

  static const double titleSize = 20;
  static const double headingSize = 14;
  static const double bodySize = 10;
  static const double captionSize = 8;
}
