import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/markaz.dart';
import '../services/markaz_service.dart';

/// Expose la fiche du Markaz courant à l'UI (écran de réglages, Document Engine).
class MarkazProvider extends ChangeNotifier {
  final MarkazService _service;

  MarkazProvider(this._service);

  /// Copie locale du logo (CDC §8.2 / §21) : les documents PDF sont générés
  /// sur l'appareil, y compris hors ligne (CDC §20), ils ne peuvent donc
  /// pas dépendre d'un téléchargement au moment de la génération.
  static const _logoBoxName = 'markaz_logo';

  Markaz? _markaz;
  Uint8List? _logoBytes;
  bool _isLoading = false;
  String? _errorMessage;

  Markaz? get markaz => _markaz;

  /// Logo du Markaz, ou null s'il n'en a pas (ou pas encore téléchargé).
  Uint8List? get logoBytes => _logoBytes;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> load() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _markaz = await _service.getMarkaz();
      await _refreshLogoCache();
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      // Hors ligne : le logo déjà en cache reste utilisable.
      _logoBytes ??= await _readCachedLogo();
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

  /// Envoie un nouveau logo puis le garde en cache local.
  Future<bool> setLogo(Uint8List bytes, String fileName) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _markaz = await _service.uploadLogo(bytes, fileName);
      await _writeCachedLogo(_markaz?.logoPath, bytes);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Retire le logo (serveur et cache local).
  Future<bool> removeLogo() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _markaz = await _service.deleteLogo();
      await _writeCachedLogo(null, null);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Met le cache en accord avec le serveur : téléchargement seulement si
  /// le logo a changé (chemin différent de celui en cache).
  Future<void> _refreshLogoCache() async {
    final path = _markaz?.logoPath;
    final box = await Hive.openBox(_logoBoxName);
    if (path == null) {
      await _writeCachedLogo(null, null);
      return;
    }
    final cachedBytes = box.get('bytes');
    if (box.get('path') == path && cachedBytes is Uint8List) {
      _logoBytes = cachedBytes;
      return;
    }
    try {
      final bytes = await _service.downloadLogo();
      await _writeCachedLogo(path, bytes);
    } catch (e) {
      debugPrint('Téléchargement du logo impossible : $e');
      _logoBytes = cachedBytes is Uint8List ? cachedBytes : null;
    }
  }

  Future<Uint8List?> _readCachedLogo() async {
    final bytes = (await Hive.openBox(_logoBoxName)).get('bytes');
    return bytes is Uint8List ? bytes : null;
  }

  Future<void> _writeCachedLogo(String? path, Uint8List? bytes) async {
    final box = await Hive.openBox(_logoBoxName);
    if (path == null || bytes == null) {
      await box.clear();
      _logoBytes = null;
    } else {
      await box.putAll({'path': path, 'bytes': bytes});
      _logoBytes = bytes;
    }
  }
}
