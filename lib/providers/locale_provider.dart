import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

/// Gère la langue de l'application (doc/audit.md K8).
///
/// Persisté dans la même box Hive brute `settings` que `ThemeProvider`
/// (voir ce fichier pour le raisonnement : indépendante des box métier).
/// `null` = suivre la langue du système (résolue par `localeResolutionCallback`
/// dans `main.dart` parmi les langues supportées, avec repli sur le français).
class LocaleProvider extends ChangeNotifier {
  static const _boxName = 'settings';
  static const _key = 'locale';

  static const supportedLocales = [Locale('fr'), Locale('en'), Locale('ar')];

  Locale? _locale;
  Locale? get locale => _locale;

  Future<void> load() async {
    final box = await Hive.openBox(_boxName);
    final stored = box.get(_key) as String?;
    _locale = stored == null ? null : Locale(stored);
    notifyListeners();
  }

  Future<void> setLocale(Locale? locale) async {
    _locale = locale;
    notifyListeners();
    final box = await Hive.openBox(_boxName);
    if (locale == null) {
      await box.delete(_key);
    } else {
      await box.put(_key, locale.languageCode);
    }
  }
}
