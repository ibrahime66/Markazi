import 'package:hive_flutter/hive_flutter.dart';
import '../models/guardian.dart';

/// Cache local Hive pour les tuteurs (mode hors ligne partiel).
class HiveGuardianDataSource {
  static const String _boxName = 'guardians';
  late Box<Guardian> _box;

  Future<void> init() async {
    _box = await Hive.openBox<Guardian>(_boxName);
  }

  Future<void> addGuardian(Guardian guardian) async {
    await _box.put(guardian.id, guardian);
  }

  Future<void> updateGuardian(Guardian guardian) async {
    await _box.put(guardian.id, guardian);
  }

  Future<void> deleteGuardian(String id) async {
    await _box.delete(id);
  }

  Guardian? getGuardianById(String id) {
    return _box.get(id);
  }

  List<Guardian> getAllGuardians() {
    return _box.values.toList();
  }

  List<Guardian> getGuardiansByMarkaz(String markazId) {
    return _box.values.where((g) => g.markazId == markazId).toList();
  }

  Future<void> clearAll() async {
    await _box.clear();
  }

  Future<void> close() async {
    await _box.close();
  }
}
