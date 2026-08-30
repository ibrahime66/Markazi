import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/guardian.dart';
import '../repositories/guardian_repository.dart';
import 'auth_service.dart';

/// Service métier pour la gestion des tuteurs/parents (CDC section 8.3).
class GuardianService {
  final GuardianRepository _repository;
  final AuthService _authService;

  GuardianService(this._repository, this._authService);

  Future<Guardian> createGuardian({
    required String name,
    required String phone,
    String? email,
    String? address,
  }) async {
    if (name.trim().isEmpty) {
      throw Exception('Le nom du tuteur est obligatoire');
    }
    if (phone.trim().isEmpty) {
      throw Exception('Le téléphone du tuteur est obligatoire');
    }

    final markazId = _authService.currentMarkazId;
    if (markazId == null) {
      throw Exception('Utilisateur non authentifié');
    }

    const uuid = Uuid();
    final guardian = Guardian(
      id: uuid.v4(),
      name: name.trim(),
      phone: phone.trim(),
      markazId: markazId,
      email: email?.trim().isEmpty ?? true ? null : email!.trim(),
      address: address?.trim().isEmpty ?? true ? null : address!.trim(),
    );

    return await _repository.addGuardian(guardian);
  }

  Future<Guardian> updateGuardian({
    required String guardianId,
    required String name,
    required String phone,
    String? email,
    String? address,
  }) async {
    final existing = _repository.getGuardianById(guardianId);
    if (existing == null) {
      throw Exception('Tuteur non trouvé');
    }
    if (!_authService.hasAccessToMarkaz(existing.markazId)) {
      throw Exception('Accès refusé à ce tuteur');
    }
    if (name.trim().isEmpty) {
      throw Exception('Le nom du tuteur est obligatoire');
    }
    if (phone.trim().isEmpty) {
      throw Exception('Le téléphone du tuteur est obligatoire');
    }

    final updated = existing.copyWith(
      name: name.trim(),
      phone: phone.trim(),
      email: email?.trim().isEmpty ?? true ? null : email!.trim(),
      address: address?.trim().isEmpty ?? true ? null : address!.trim(),
    );

    await _repository.updateGuardian(updated);
    return updated;
  }

  Future<void> deleteGuardian(String guardianId) async {
    final existing = _repository.getGuardianById(guardianId);
    if (existing == null) {
      throw Exception('Tuteur non trouvé');
    }
    if (!_authService.hasAccessToMarkaz(existing.markazId)) {
      throw Exception('Accès refusé à ce tuteur');
    }
    await _repository.removeGuardian(guardianId);
  }

  List<Guardian> getGuardiansForCurrentMarkaz() {
    final markazId = _authService.currentMarkazId;
    if (markazId == null) {
      throw Exception('Utilisateur non authentifié');
    }
    return _repository.getGuardiansByMarkaz(markazId);
  }

  Future<void> syncFromApi() async {
    final markazId = _authService.currentMarkazId;
    if (markazId != null) {
      await _repository.syncFromMarkaz(markazId);
    } else {
      debugPrint('Impossible de sync tuteurs: markazId null');
    }
  }
}
