import 'package:hive_flutter/hive_flutter.dart';
import '../models/recitation.dart';

/// Cache local Hive pour les récitations (mode hors ligne partiel).
class HiveRecitationDataSource {
  static const String _boxName = 'recitations';
  late Box<Recitation> _box;

  Future<void> init() async {
    _box = await Hive.openBox<Recitation>(_boxName);
  }

  Future<void> addRecitation(Recitation recitation) async {
    await _box.put(recitation.id, recitation);
  }

  Future<void> updateRecitation(Recitation recitation) async {
    await _box.put(recitation.id, recitation);
  }

  Future<void> deleteRecitation(String id) async {
    await _box.delete(id);
  }

  Recitation? getRecitationById(String id) {
    return _box.get(id);
  }

  List<Recitation> getAllRecitations() {
    return _box.values.toList();
  }

  List<Recitation> getRecitationsByMarkaz(String markazId) {
    return _box.values.where((r) => r.markazId == markazId).toList();
  }

  List<Recitation> getRecitationsByStudent(String studentId) {
    return _box.values.where((r) => r.studentId == studentId).toList();
  }

  Future<void> clearAll() async {
    await _box.clear();
  }

  Future<void> close() async {
    await _box.close();
  }
}
