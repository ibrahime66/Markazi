import 'package:flutter/foundation.dart';
import '../models/markaz.dart';
import '../services/markaz_service.dart';

/// Expose la fiche du Markaz courant à l'UI (écran de réglages, Document Engine).
class MarkazProvider extends ChangeNotifier {
  final MarkazService _service;

  MarkazProvider(this._service);

  Markaz? _markaz;
  bool _isLoading = false;
  String? _errorMessage;

  Markaz? get markaz => _markaz;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> load() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _markaz = await _service.getMarkaz();
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> update(Map<String, dynamic> data) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _markaz = await _service.updateMarkaz(data);
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
