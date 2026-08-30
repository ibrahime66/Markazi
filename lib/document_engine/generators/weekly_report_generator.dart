import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../models/document_metadata.dart';
import '../models/document_theme.dart';
import '../utils/pdf_helpers.dart';

/// Génère le rapport hebdomadaire de présence/récitation d'un élève
/// (CDC section 8.8).
class WeeklyReportGenerator {
  static Future<pw.Document> generate(WeeklyReportMetadata metadata) async {
    final theme = DocumentTheme(
      primaryColor: metadata.markaz.primaryColor ?? const DocumentTheme().primaryColor,
    );
    final doc = pw.Document();
    final dateFormat = DateFormat('dd/MM/yyyy');

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (context) => context.pageNumber == 1
            ? PdfHelpers.header(metadata.markaz, 'RAPPORT HEBDOMADAIRE', theme)
            : pw.SizedBox(),
        footer: (context) => PdfHelpers.footer(context, theme),
        build: (context) => [
          PdfHelpers.labeledRow('Élève', metadata.studentName, theme),
          if (metadata.className != null)
            PdfHelpers.labeledRow('Classe', metadata.className!, theme),
          PdfHelpers.labeledRow(
            'Période',
            '${dateFormat.format(metadata.weekStart)} - ${dateFormat.format(metadata.weekEnd)}',
            theme,
          ),
          PdfHelpers.labeledRow(
            'Taux de présence',
            '${metadata.attendanceRate.toStringAsFixed(1)} %',
            theme,
          ),
          pw.SizedBox(height: 16),
          pw.Table(
            border: pw.TableBorder.all(color: theme.borderColor, width: 0.5),
            columnWidths: const {
              0: pw.FlexColumnWidth(2),
              1: pw.FlexColumnWidth(2),
              2: pw.FlexColumnWidth(3),
              3: pw.FlexColumnWidth(3),
            },
            children: [
              pw.TableRow(
                decoration: pw.BoxDecoration(color: theme.primaryColor),
                children: [
                  _headerCell('Date'),
                  _headerCell('Statut'),
                  _headerCell('Leçon / Sourate'),
                  _headerCell('Observation'),
                ],
              ),
              ...metadata.entries.map(
                (entry) => pw.TableRow(
                  children: [
                    _cell(dateFormat.format(entry.date), theme),
                    _cell(entry.status, theme),
                    _cell(entry.lesson, theme),
                    _cell(entry.observation ?? '-', theme),
                  ],
                ),
              ),
              if (metadata.entries.isEmpty)
                pw.TableRow(
                  children: [
                    _cell('-', theme),
                    _cell('Aucun enregistrement sur cette période', theme),
                    _cell('', theme),
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

  static pw.Widget _headerCell(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: DocumentTheme.bodySize,
          fontWeight: pw.FontWeight.bold,
          color: PdfColors.white,
        ),
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
