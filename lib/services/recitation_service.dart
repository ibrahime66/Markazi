import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/recitation.dart';
import '../repositories/recitation_repository.dart';
import 'auth_service.dart';
import '../utils/app_exception.dart';

/// Service métier pour le suivi des récitations coraniques (CDC section 8.5).
class RecitationService {
  final RecitationRepository _repository;
  final AuthService _authService;

  RecitationService(this._repository, this._authService);

  Future<Recitation> recordRecitation({
    required String studentId,
    required DateTime date,
    required String surah,
    required RecitationStatus status,
    int? ayahFrom,
    int? ayahTo,
    String? note,
  }) async {
    if (surah.trim().isEmpty) {
      throw AppException((l) => l.recitationSurahRequired);
    }

    final markazId = _authService.currentMarkazId;
    if (markazId == null) {
      throw AppException((l) => l.errNotAuthenticated);
    }

    const uuid = Uuid();
    final recitation = Recitation(
      id: uuid.v4(),
      studentId: studentId,
      markazId: markazId,
      date: date,
      surah: surah.trim(),
      status: status,
      ayahFrom: ayahFrom,
      ayahTo: ayahTo,
      note: note?.trim().isEmpty ?? true ? null : note!.trim(),
    );

    return await _repository.addRecitation(recitation);
  }

  Future<Recitation> updateRecitation({
    required String recitationId,
    required String studentId,
    required DateTime date,
    required String surah,
    required RecitationStatus status,
    int? ayahFrom,
    int? ayahTo,
    String? note,
  }) async {
    final existing = _repository.getRecitationById(recitationId);
    if (existing == null) {
      throw AppException((l) => l.errRecitationNotFound);
    }
    if (!_authService.hasAccessToMarkaz(existing.markazId)) {
      throw AppException((l) => l.errRecitationAccessDenied);
    }

    final updated = existing.copyWith(
      studentId: studentId,
      date: date,
      surah: surah.trim(),
      status: status,
      ayahFrom: ayahFrom,
      ayahTo: ayahTo,
      note: note?.trim().isEmpty ?? true ? null : note!.trim(),
    );

    await _repository.updateRecitation(updated);
    return updated;
  }

  Future<void> deleteRecitation(String recitationId) async {
    final existing = _repository.getRecitationById(recitationId);
    if (existing == null) {
      throw AppException((l) => l.errRecitationNotFound);
    }
    if (!_authService.hasAccessToMarkaz(existing.markazId)) {
      throw AppException((l) => l.errRecitationAccessDenied);
    }
    await _repository.removeRecitation(recitationId);
  }

  List<Recitation> getRecitationsForCurrentMarkaz() {
    final markazId = _authService.currentMarkazId;
    if (markazId == null) {
      throw AppException((l) => l.errNotAuthenticated);
    }
    return _repository.getRecitationsByMarkaz(markazId);
  }

  List<Recitation> getRecitationsForStudent(String studentId) {
    return _repository.getRecitationsByStudent(studentId);
  }

  Future<void> syncFromApi() async {
    final markazId = _authService.currentMarkazId;
    if (markazId != null) {
      await _repository.syncFromMarkaz(markazId);
    } else {
      debugPrint('Impossible de sync récitations: markazId null');
    }
  }
}
