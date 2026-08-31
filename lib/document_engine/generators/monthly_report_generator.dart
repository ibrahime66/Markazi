import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../models/document_metadata.dart';
import '../models/document_theme.dart';
import '../utils/pdf_helpers.dart';

const _moisFr = [
  'Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin',
  'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre',
];

/// Génère le rapport mensuel d'un élève : statistiques de présence et
/// historique des paiements (CDC section 8.8).
class MonthlyReportGenerator {
  static Future<pw.Document> generate(MonthlyReportMetadata metadata) async {
    final theme = DocumentTheme(
      primaryColor: metadata.markaz.primaryColor ?? const DocumentTheme().primaryColor,
    );
    final doc = pw.Document(theme: await PdfHelpers.buildTheme());
    final dateFormat = DateFormat('dd/MM/yyyy');
    final amountFormat = NumberFormat.decimalPattern('fr_FR');
    final monthLabel = '${_moisFr[metadata.month - 1]} ${metadata.year}';

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (context) => context.pageNumber == 1
            ? PdfHelpers.header(metadata.markaz, 'RAPPORT MENSUEL', theme)
            : pw.SizedBox(),
        footer: (context) => PdfHelpers.footer(context, theme),
        build: (context) => [
          PdfHelpers.labeledRow('Élève', metadata.studentName, theme),
          if (metadata.className != null)
            PdfHelpers.labeledRow('Classe', metadata.className!, theme),
          PdfHelpers.labeledRow('Mois', monthLabel, theme),
          pw.SizedBox(height: 16),
          pw.Text(
            'Assiduité',
            style: pw.TextStyle(
              fontSize: DocumentTheme.headingSize,
              fontWeight: pw.FontWeight.bold,
              color: theme.primaryColor,
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Row(
            children: [
              _statTile('Jours de cours', '${metadata.totalDays}', theme),
              _statTile('Présences', '${metadata.presentDays}', theme),
              _statTile('Absences', '${metadata.absentDays}', theme),
              _statTile('Taux', '${metadata.attendanceRate.toStringAsFixed(1)} %', theme),
            ],
          ),
          pw.SizedBox(height: 20),
          pw.Text(
            'Paiements',
            style: pw.TextStyle(
              fontSize: DocumentTheme.headingSize,
              fontWeight: pw.FontWeight.bold,
              color: theme.primaryColor,
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Table(
            border: pw.TableBorder.all(color: theme.borderColor, width: 0.5),
            children: [
              pw.TableRow(
                decoration: pw.BoxDecoration(color: theme.primaryColor),
                children: [
                  _headerCell('Date'),
                  _headerCell('Montant'),
                  _headerCell('Statut'),
                ],
              ),
              ...metadata.payments.map(
                (p) => pw.TableRow(
                  children: [
                    _cell(dateFormat.format(p.date), theme),
                    _cell('${amountFormat.format(p.amount)} ${metadata.markaz.currency}', theme),
                    _cell(p.status, theme),
                  ],
                ),
              ),
              if (metadata.payments.isEmpty)
                pw.TableRow(
                  children: [
                    _cell('-', theme),
                    _cell('Aucun paiement ce mois-ci', theme),
                    _cell('', theme),
                  ],
                ),
            ],
          ),
        ],
      ),
    );

    return doc;
  }

  static pw.Widget _statTile(String label, String value, DocumentTheme theme) {
    return pw.Expanded(
      child: pw.Container(
        margin: const pw.EdgeInsets.only(right: 8),
        padding: const pw.EdgeInsets.all(10),
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: theme.borderColor),
          borderRadius: pw.BorderRadius.circular(4),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(label, style: pw.TextStyle(fontSize: DocumentTheme.captionSize, color: theme.mutedTextColor)),
            pw.SizedBox(height: 4),
            pw.Text(
              value,
              style: pw.TextStyle(fontSize: DocumentTheme.headingSize, fontWeight: pw.FontWeight.bold, color: theme.textColor),
            ),
          ],
        ),
      ),
    );
  }

  static pw.Widget _headerCell(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(
        text,
        style: pw.TextStyle(fontSize: DocumentTheme.bodySize, fontWeight: pw.FontWeight.bold, color: PdfColors.white),
      ),
    );
  }

  static pw.Widget _cell(String text, DocumentTheme theme) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(text, style: pw.TextStyle(fontSize: DocumentTheme.bodySize, color: theme.textColor)),
    );
  }
}
