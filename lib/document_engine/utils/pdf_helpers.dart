import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../models/document_theme.dart';
import '../models/markaz_branding.dart';

/// Blocs de mise en page réutilisés par tous les générateurs de documents.
class PdfHelpers {
  PdfHelpers._();

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
            pw.Column(
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
            pw.Text(
              'Document généré automatiquement par Markazi',
              style: pw.TextStyle(fontSize: DocumentTheme.captionSize, color: theme.mutedTextColor),
            ),
            pw.Text(
              'Page ${context.pageNumber} / ${context.pagesCount}',
              style: pw.TextStyle(fontSize: DocumentTheme.captionSize, color: theme.mutedTextColor),
            ),
          ],
        ),
      ],
    );
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
