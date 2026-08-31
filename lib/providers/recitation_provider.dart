import 'package:flutter/foundation.dart';
import '../models/recitation.dart';
import '../services/recitation_service.dart';

/// Provider pour gérer les séances de récitation (CDC section 8.5).
class RecitationProvider extends ChangeNotifier {
  final RecitationService _service;
  List<Recitation> _recitations = [];
  String? _errorMessage;

  RecitationProvider(this._service);

  List<Recitation> get recitations => _recitations;

  String? get errorMessage => _errorMessage;

  Future<void> loadRecitations() async {
    try {
      _errorMessage = null;
      _recitations = _service.getRecitationsForCurrentMarkaz();
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  List<Recitation> recitationsForStudent(String studentId) {
    return _recitations.where((r) => r.studentId == studentId).toList();
  }

  Future<void> addRecitation({
    required String studentId,
    required DateTime date,
    required String surah,
    required RecitationStatus status,
    int? ayahFrom,
    int? ayahTo,
    String? note,
  }) async {
    try {
      _errorMessage = null;
      final created = await _service.recordRecitation(
        studentId: studentId,
        date: date,
        surah: surah,
        status: status,
        ayahFrom: ayahFrom,
        ayahTo: ayahTo,
        note: note,
      );
      _recitations = [..._recitations, created];
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateRecitation({
    required String recitationId,
    required String studentId,
    required DateTime date,
    required String surah,
    required RecitationStatus status,
    int? ayahFrom,
    int? ayahTo,
    String? note,
  }) async {
    try {
      _errorMessage = null;
      final updated = await _service.updateRecitation(
        recitationId: recitationId,
        studentId: studentId,
        date: date,
        surah: surah,
        status: status,
        ayahFrom: ayahFrom,
        ayahTo: ayahTo,
        note: note,
      );
      _recitations = _recitations.map((r) => r.id == updated.id ? updated : r).toList();
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> removeRecitation(String recitationId) async {
    try {
      _errorMessage = null;
      await _service.deleteRecitation(recitationId);
      _recitations = _recitations.where((r) => r.id != recitationId).toList();
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
