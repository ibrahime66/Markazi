import 'package:flutter/foundation.dart';
import '../models/guardian.dart';
import '../services/guardian_service.dart';

/// Provider pour gérer la liste des tuteurs/parents (CDC section 8.3).
class GuardianProvider extends ChangeNotifier {
  final GuardianService _service;
  List<Guardian> _guardians = [];
  String? _errorMessage;

  GuardianProvider(this._service);

  List<Guardian> get guardians => _guardians;

  String? get errorMessage => _errorMessage;

  Future<void> loadGuardians() async {
    try {
      _errorMessage = null;
      _guardians = _service.getGuardiansForCurrentMarkaz();
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  /// Retourne le tuteur tel que persisté côté serveur (avec son
  /// identifiant réel), nécessaire pour pouvoir le rattacher immédiatement
  /// à un ou plusieurs élèves (doc/audit.md, point I5).
  Future<Guardian> addGuardian({
    required String name,
    required String phone,
    String? email,
    String? address,
  }) async {
    try {
      _errorMessage = null;
      final created = await _service.createGuardian(
        name: name,
        phone: phone,
        email: email,
        address: address,
      );
      _guardians = [..._guardians, created];
      notifyListeners();
      return created;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateGuardian({
    required String guardianId,
    required String name,
    required String phone,
    String? email,
    String? address,
  }) async {
    try {
      _errorMessage = null;
      final updated = await _service.updateGuardian(
        guardianId: guardianId,
        name: name,
        phone: phone,
        email: email,
        address: address,
      );
      _guardians = _guardians.map((g) => g.id == updated.id ? updated : g).toList();
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> removeGuardian(String guardianId) async {
    try {
      _errorMessage = null;
      await _service.deleteGuardian(guardianId);
      _guardians = _guardians.where((g) => g.id != guardianId).toList();
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
