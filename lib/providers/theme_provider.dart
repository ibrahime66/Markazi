import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../utils/app_colors.dart';

/// Gère le mode d'affichage clair/sombre de l'app (doc/audit.md K7).
///
/// Persisté dans une box Hive brute (`settings`, pas de `TypeAdapter`
/// nécessaire pour un simple `bool`) — indépendante des box métier
/// (élèves, paiements, ...) pour ne jamais être vidée par
/// `Repository.clearAll()`/`syncFromMarkaz()`.
///
/// Beaucoup d'écrans de l'app utilisent directement les couleurs statiques
/// `AppColors.xxx` plutôt que `Theme.of(context)`. Pour que le choix de
/// thème s'applique partout sans réécrire chaque écran, ce provider met à
/// jour le mode global de `AppColors` (`AppColors.applyBrightness`) *avant*
/// de notifier ses écouteurs : tout écran qui dépend de ce provider (via
/// `context.watch<ThemeProvider>()`) se reconstruit alors avec les bonnes
/// couleurs déjà en place.
class ThemeProvider extends ChangeNotifier {
  static const _boxName = 'settings';
  static const _key = 'theme_mode';

  ThemeMode _themeMode = ThemeMode.system;
  ThemeMode get themeMode => _themeMode;

  bool get isDark => _resolvedIsDark;
  bool _resolvedIsDark = false;

  Future<void> load() async {
    final box = await Hive.openBox(_boxName);
    final stored = box.get(_key) as String?;
    _themeMode = switch (stored) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
    _applyResolvedBrightness();
  }

  /// Doit être appelé une fois au démarrage avec la luminosité système
  /// actuelle (`MediaQuery.platformBrightnessOf`), pour que le mode
  /// "Système" soit correctement résolu dès le premier affichage.
  void syncWithPlatformBrightness(Brightness platformBrightness) {
    _applyResolvedBrightness(platformBrightness: platformBrightness);
  }

  Future<void> setThemeMode(ThemeMode mode, {Brightness? platformBrightness}) async {
    _themeMode = mode;
    _applyResolvedBrightness(platformBrightness: platformBrightness);
    final box = await Hive.openBox(_boxName);
    await box.put(_key, switch (mode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
    });
  }

  void _applyResolvedBrightness({Brightness? platformBrightness}) {
    _resolvedIsDark = switch (_themeMode) {
      ThemeMode.light => false,
      ThemeMode.dark => true,
      ThemeMode.system => (platformBrightness ?? _lastPlatformBrightness) == Brightness.dark,
    };
    _lastPlatformBrightness = platformBrightness ?? _lastPlatformBrightness;
    AppColors.applyBrightness(_resolvedIsDark);
    notifyListeners();
  }

  Brightness _lastPlatformBrightness = Brightness.light;
}
