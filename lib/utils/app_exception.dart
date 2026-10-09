import 'package:flutter/widgets.dart';
import '../l10n/app_localizations.dart';

/// Langue active de l'interface, connue hors de l'arbre de widgets (services,
/// client HTTP) : mise à jour par `MaterialApp.builder` dans main.dart à
/// chaque reconstruction (doc/audit.md K8).
class AppLocale {
  AppLocale._();

  static Locale current = const Locale('fr');

  /// Textes traduits dans la langue active.
  static AppLocalizations get l10n => lookupAppLocalizations(current);
}

/// Erreur métier présentée à l'utilisateur, traduite dans la langue active
/// au moment de l'affichage (doc/audit.md K8). `toString()` renvoie
/// directement le message, sans le préfixe technique « Exception: ».
class AppException implements Exception {
  final String Function(AppLocalizations l10n) _message;

  AppException(this._message);

  String get message => _message(AppLocale.l10n);

  @override
  String toString() => message;
}
