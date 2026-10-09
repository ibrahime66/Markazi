import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../models/document_metadata.dart';
import '../models/document_theme.dart';
import '../utils/pdf_helpers.dart';

/// Génère le rapport hebdomadaire ou mensuel d'un groupe entier (CDC §11.3 :
/// rapport "pour un élève ou l'ensemble d'une classe") : une ligne par
/// élève avec présence, récitations et paiement du mois. Document en
/// français, comme les autres documents de la V1 (CDC §21).
class ClassReportGenerator {
  static Future<pw.Document> generate(ClassReportMetadata metadata) async {
    final theme = DocumentTheme(
      primaryColor: metadata.markaz.primaryColor ?? const DocumentTheme().primaryColor,
    );
    final doc = pw.Document(theme: await PdfHelpers.buildTheme());
    final dateFormat = DateFormat('dd/MM/yyyy');
    final currency = metadata.markaz.currency;
    final title = metadata.isMonthly ? 'RAPPORT MENSUEL' : 'RAPPORT HEBDOMADAIRE';

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (context) => context.pageNumber == 1
            ? PdfHelpers.header(metadata.markaz, title, theme)
            : pw.SizedBox(),
        footer: (context) => PdfHelpers.footer(context, theme),
        build: (context) => [
          PdfHelpers.labeledRow('Groupe', metadata.className, theme),
          if (metadata.teacherName != null && metadata.teacherName!.isNotEmpty)
            PdfHelpers.labeledRow('Enseignant', metadata.teacherName!, theme),
          PdfHelpers.labeledRow(
            'Période',
            '${dateFormat.format(metadata.periodStart)} - ${dateFormat.format(metadata.periodEnd)}',
            theme,
          ),
          PdfHelpers.labeledRow('Jours de cours', '${metadata.courseDays}', theme),
          PdfHelpers.labeledRow('Nombre d\'élèves', '${metadata.rows.length}', theme),
          PdfHelpers.labeledRow(
            'Taux de présence moyen',
            '${metadata.averageAttendanceRate.toStringAsFixed(1)} %',
            theme,
          ),
          PdfHelpers.labeledRow(
            'Total encaissé (mois)',
            '${metadata.totalPaid.toStringAsFixed(0)} $currency',
            theme,
          ),
          pw.SizedBox(height: 16),
          pw.Table(
            border: pw.TableBorder.all(color: theme.borderColor, width: 0.5),
            columnWidths: const {
              0: pw.FlexColumnWidth(4),
              1: pw.FlexColumnWidth(2),
              2: pw.FlexColumnWidth(2),
              3: pw.FlexColumnWidth(2),
              4: pw.FlexColumnWidth(2),
              5: pw.FlexColumnWidth(2),
              6: pw.FlexColumnWidth(3),
            },
            children: [
              pw.TableRow(
                decoration: pw.BoxDecoration(color: theme.primaryColor),
                children: [
                  _headerCell('Élève'),
                  _headerCell('Présents'),
                  _headerCell('Absents'),
                  _headerCell('Retards'),
                  _headerCell('Taux'),
                  _headerCell('Récitations'),
                  _headerCell('Paiement du mois'),
                ],
              ),
              ...metadata.rows.map(
                (row) => pw.TableRow(
                  children: [
                    _cell(row.studentName, theme),
                    _cell('${row.presentDays}', theme),
                    _cell('${row.absentDays}', theme),
                    _cell('${row.lateDays}', theme),
                    _cell('${row.attendanceRate.toStringAsFixed(0)} %', theme),
                    _cell('${row.recitations}', theme),
                    _cell(row.paymentStatus, theme),
                  ],
                ),
              ),
              if (metadata.rows.isEmpty)
                pw.TableRow(
                  children: [
                    _cell('Aucun élève dans ce groupe', theme),
                    for (var i = 0; i < 6; i++) _cell('', theme),
                  ],
                ),
            ],
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            'Taux = jours présents / jours de cours de la période (jours de cours configurés pour le Markaz).',
            style: pw.TextStyle(fontSize: DocumentTheme.captionSize, color: theme.mutedTextColor),
          ),
          pw.SizedBox(height: 24),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.end,
            children: [PdfHelpers.signatureBlock('Signature et cachet du maître', theme)],
          ),
        ],
      ),
    );

    return doc;
  }

  static pw.Widget _headerCell(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(5),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: DocumentTheme.captionSize + 1,
          fontWeight: pw.FontWeight.bold,
          color: PdfColors.white,
        ),
      ),
    );
  }

  static pw.Widget _cell(String text, DocumentTheme theme) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(5),
      child: pw.Text(text, style: pw.TextStyle(fontSize: DocumentTheme.bodySize - 1, color: theme.textColor)),
    );
  }
}
