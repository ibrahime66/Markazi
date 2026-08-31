import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

import 'generators/monthly_report_generator.dart';
import 'generators/payment_receipt_generator.dart';
import 'generators/weekly_report_generator.dart';
import 'models/document_metadata.dart';

/// Point d'entrée unique du moteur de documents (CDC section 21). Toute
/// génération de PDF de l'application passe par ce service.
class DocumentService {
  DocumentService._internal();
  static final DocumentService _instance = DocumentService._internal();
  factory DocumentService() => _instance;

  Future<Uint8List> generatePaymentReceipt(PaymentReceiptMetadata metadata) async {
    final doc = await PaymentReceiptGenerator.generate(metadata);
    return doc.save();
  }

  Future<Uint8List> generateWeeklyReport(WeeklyReportMetadata metadata) async {
    final doc = await WeeklyReportGenerator.generate(metadata);
    return doc.save();
  }

  Future<Uint8List> generateMonthlyReport(MonthlyReportMetadata metadata) async {
    final doc = await MonthlyReportGenerator.generate(metadata);
    return doc.save();
  }

  /// Ouvre l'aperçu natif (prévisualisation, impression) — CDC section 21 :
  /// "prévisualisé, téléchargé, enregistré et imprimé".
  Future<void> previewPdf(Uint8List bytes) async {
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => bytes,
    );
  }

  /// Partage le document via le share sheet natif (Android/iOS/Web) — CDC
  /// section 21 : aucune intégration propriétaire, on laisse l'utilisateur
  /// choisir l'application de destination.
  Future<void> sharePdf(Uint8List bytes, String fileName) async {
    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/$fileName');
    await file.writeAsBytes(bytes, flush: true);
    await SharePlus.instance.share(
      ShareParams(files: [XFile(file.path)], text: 'Document partagé depuis Markazi'),
    );
  }
}
