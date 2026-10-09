import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../models/document_theme.dart';
import '../models/markaz_branding.dart';

/// Blocs de mise en page réutilisés par tous les générateurs de documents.
class PdfHelpers {
  PdfHelpers._();

  static pw.ThemeData? _cachedTheme;

  /// Logo Markazi (CDC §21 : "logo Markazi" sur les documents), chargé avec
  /// le thème et affiché dans le pied de page.
  static pw.MemoryImage? _markaziLogo;

  /// Thème PDF avec police Unicode (Noto Sans + repli Noto Sans Arabic).
  ///
  /// Par défaut, `pdf` utilise la police de base "Helvetica" (PDF standard),
  /// qui ne couvre que le latin de base et affiche des cases vides pour
  /// l'arabe ou tout autre script non-latin (doc/audit.md, point K4/K7) —
  /// un souci direct pour un nom de Markaz saisi en arabe, par exemple.
  /// Noto Sans Arabic est chargé en police de repli (`fontFallback`), pas en
  /// police de base, donc chaque caractère utilise la bonne police
  /// automatiquement selon le script détecté.
  ///
  /// Le chinois (Noto Sans SC) n'est volontairement pas inclus : le fichier
  /// pèse ~10 Mo contre ~190 Ko pour l'arabe, disproportionné pour ce que
  /// l'app cible réellement (Markaz d'enseignement coranique). Un nom de
  /// Markaz en chinois s'affichera correctement dans l'app mais pas sur les
  /// PDF générés tant que cette police n'est pas ajoutée séparément.
  static Future<pw.ThemeData> buildTheme() async {
    if (_cachedTheme != null) return _cachedTheme!;

    final base = pw.Font.ttf(
      await rootBundle.load('assets/fonts/NotoSans-Regular.ttf'),
    );
    final arabic = pw.Font.ttf(
      await rootBundle.load('assets/fonts/NotoSansArabic-Regular.ttf'),
    );
    // Police grasse dédiée : sans elle, tout texte en gras (titres, en-têtes
    // de tableaux) retombait sur "Helvetica-Bold", sans support Unicode
    // (avertissement dart_pdf, cases vides possibles pour les accents
    // étendus ou l'arabe). L'arabe en gras utilise la police de repli
    // (graisse normale), la bibliothèque n'ayant qu'une liste de repli
    // commune à tous les styles.
    final bold = pw.Font.ttf(
      await rootBundle.load('assets/fonts/NotoSans-Bold.ttf'),
    );

    // Pas de police italique embarquée : l'italique (slogan) utilise les
    // mêmes polices que le texte droit plutôt qu'une police PDF standard
    // sans Unicode.
    try {
      _markaziLogo = pw.MemoryImage(
        (await rootBundle.load('assets/logo/app_icon.png')).buffer.asUint8List(),
      );
    } catch (_) {
      _markaziLogo = null;
    }

    _cachedTheme = pw.ThemeData.withFont(
      base: base,
      bold: bold,
      italic: base,
      boldItalic: bold,
      fontFallback: [arabic],
    );
    return _cachedTheme!;
  }

  /// En-tête standard : nom du Markaz, coordonnées, titre du document.
  static pw.Widget header(
    MarkazBranding markaz,
    String documentTitle,
    DocumentTheme theme,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            if (_markazLogo(markaz) case final logo?) ...[
              pw.SizedBox(width: 56, height: 56, child: pw.Image(logo, fit: pw.BoxFit.contain)),
              pw.SizedBox(width: 12),
            ],
            // Expanded : un nom de Markaz long passe à la ligne au lieu de
            // pousser le titre du document hors de la page.
            pw.Expanded(
              child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  markaz.markazName,
                  style: pw.TextStyle(
                    fontSize: DocumentTheme.titleSize,
                    fontWeight: pw.FontWeight.bold,
                    color: theme.primaryColor,
                  ),
                ),
                if (markaz.slogan != null && markaz.slogan!.isNotEmpty)
                  pw.Text(
                    markaz.slogan!,
                    style: pw.TextStyle(
                      fontSize: DocumentTheme.captionSize,
                      color: theme.mutedTextColor,
                      fontStyle: pw.FontStyle.italic,
                    ),
                  ),
                if (markaz.fullAddress.isNotEmpty)
                  pw.Text(
                    markaz.fullAddress,
                    style: pw.TextStyle(fontSize: DocumentTheme.captionSize, color: theme.mutedTextColor),
                  ),
                if (markaz.phone != null)
                  pw.Text(
                    markaz.phone!,
                    style: pw.TextStyle(fontSize: DocumentTheme.captionSize, color: theme.mutedTextColor),
                  ),
              ],
              ),
            ),
            pw.SizedBox(width: 12),
            pw.Container(
              padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: pw.BoxDecoration(
                color: theme.primaryColor,
                borderRadius: pw.BorderRadius.circular(4),
              ),
              child: pw.Text(
                documentTitle,
                style: pw.TextStyle(
                  fontSize: DocumentTheme.headingSize,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.white,
                ),
              ),
            ),
          ],
        ),
        pw.SizedBox(height: 12),
        pw.Divider(color: theme.borderColor, thickness: 1),
        pw.SizedBox(height: 12),
      ],
    );
  }

  /// Pied de page : numéro de page et mention "généré automatiquement".
  static pw.Widget footer(pw.Context context, DocumentTheme theme) {
    return pw.Column(
      children: [
        pw.Divider(color: theme.borderColor, thickness: 0.5),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Row(children: [
              if (_markaziLogo != null) ...[
                pw.SizedBox(width: 14, height: 14, child: pw.Image(_markaziLogo!)),
                pw.SizedBox(width: 6),
              ],
              pw.Text(
                'Document généré automatiquement par Markazi',
                style: pw.TextStyle(fontSize: DocumentTheme.captionSize, color: theme.mutedTextColor),
              ),
            ]),
            pw.Text(
              'Page ${context.pageNumber} / ${context.pagesCount}',
              style: pw.TextStyle(fontSize: DocumentTheme.captionSize, color: theme.mutedTextColor),
            ),
          ],
        ),
      ],
    );
  }

  /// Logo du Markaz prêt pour le PDF, ou null (absent ou format illisible :
  /// le document est alors généré sans logo plutôt que d'échouer).
  static pw.MemoryImage? _markazLogo(MarkazBranding markaz) {
    final bytes = markaz.logoBytes;
    if (bytes == null || bytes.isEmpty) return null;
    try {
      return pw.MemoryImage(bytes);
    } catch (_) {
      return null;
    }
  }

  /// Une ligne "libellé : valeur" utilisée dans les blocs d'information.
  static pw.Widget labeledRow(String label, String value, DocumentTheme theme) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 3),
      child: pw.Row(
        children: [
          pw.SizedBox(
            width: 130,
            child: pw.Text(
              label,
              style: pw.TextStyle(fontSize: DocumentTheme.bodySize, color: theme.mutedTextColor),
            ),
          ),
          pw.Expanded(
            child: pw.Text(
              value,
              style: pw.TextStyle(
                fontSize: DocumentTheme.bodySize,
                fontWeight: pw.FontWeight.bold,
                color: theme.textColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Zone de signature/cachet du maître (CDC section 21).
  static pw.Widget signatureBlock(String label, DocumentTheme theme) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.SizedBox(height: 40),
        pw.Container(width: 150, height: 1, color: theme.borderColor),
        pw.SizedBox(height: 4),
        pw.Text(label, style: pw.TextStyle(fontSize: DocumentTheme.captionSize, color: theme.mutedTextColor)),
      ],
    );
  }
}
