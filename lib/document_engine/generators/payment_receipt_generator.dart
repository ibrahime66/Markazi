import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../models/document_metadata.dart';
import '../models/document_theme.dart';
import '../utils/pdf_helpers.dart';

/// Génère le reçu de paiement PDF (CDC section 21) : logo/coordonnées du
/// Markaz, numéro de reçu, élève, montant, mois, mode, maître, signature/cachet.
class PaymentReceiptGenerator {
  static Future<pw.Document> generate(PaymentReceiptMetadata metadata) async {
    final theme = DocumentTheme(
      primaryColor: metadata.markaz.primaryColor ?? const DocumentTheme().primaryColor,
    );
    final doc = pw.Document();
    final dateFormat = DateFormat('dd/MM/yyyy');
    final amountFormat = NumberFormat.decimalPattern('fr_FR');

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a5,
        margin: const pw.EdgeInsets.all(28),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              PdfHelpers.header(metadata.markaz, 'REÇU DE PAIEMENT', theme),
              pw.Text(
                'N° ${metadata.receiptNumber}',
                style: pw.TextStyle(
                  fontSize: DocumentTheme.bodySize,
                  fontWeight: pw.FontWeight.bold,
                  color: theme.mutedTextColor,
                ),
              ),
              pw.SizedBox(height: 16),
              PdfHelpers.labeledRow('Date', dateFormat.format(metadata.date), theme),
              PdfHelpers.labeledRow('Élève', metadata.studentName, theme),
              if (metadata.parentName != null)
                PdfHelpers.labeledRow('Parent', metadata.parentName!, theme),
              if (metadata.parentPhone != null)
                PdfHelpers.labeledRow('Téléphone', metadata.parentPhone!, theme),
              PdfHelpers.labeledRow('Mois concerné', metadata.month, theme),
              PdfHelpers.labeledRow('Mode de paiement', metadata.paymentMethod, theme),
              PdfHelpers.labeledRow('Statut', metadata.status, theme),
              pw.SizedBox(height: 16),
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                decoration: pw.BoxDecoration(
                  color: theme.primaryColor,
                  borderRadius: pw.BorderRadius.circular(6),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'Montant payé',
                      style: pw.TextStyle(fontSize: DocumentTheme.headingSize, color: PdfColors.white),
                    ),
                    pw.Text(
                      '${amountFormat.format(metadata.amountPaid)} ${metadata.markaz.currency}',
                      style: pw.TextStyle(
                        fontSize: DocumentTheme.headingSize,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.white,
                      ),
                    ),
                  ],
                ),
              ),
              pw.Spacer(),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  PdfHelpers.signatureBlock('Signature du parent', theme),
                  PdfHelpers.signatureBlock(
                    'Maître : ${metadata.recordedByName}\n(signature et cachet)',
                    theme,
                  ),
                ],
              ),
              pw.SizedBox(height: 8),
              PdfHelpers.footer(context, theme),
            ],
          );
        },
      ),
    );

    return doc;
  }
}
