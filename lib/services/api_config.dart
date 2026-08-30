/// Configuration de l'API Markazi (backend Laravel — voir doc/CDC.md section 13/14).
///
/// L'URL de base est pilotée via `--dart-define=API_BASE_URL=...` plutôt que
/// codée en dur (doc/audit.md, point D1 : une IP figée dans le code cassait
/// l'app à chaque changement de réseau Wi-Fi, et ne fonctionnait ni hors du
/// réseau local ni en production).
///
/// ⚠️ En développement, un téléphone physique ne peut pas joindre
/// "localhost"/"127.0.0.1" (ça pointerait vers le téléphone lui-même) : il
/// faut l'adresse IP locale de la machine qui fait tourner `php artisan
/// serve`, sur le même réseau Wi-Fi (`hostname -I` sous Linux pour la
/// retrouver), démarré avec `php artisan serve --host=0.0.0.0 --port=8321`
/// pour qu'il écoute au-delà de localhost. Exemple de lancement :
///
/// ```
/// flutter run --dart-define=API_BASE_URL=http://192.168.1.185:8321/api
/// ```
///
/// Sans `--dart-define`, [baseUrl] retombe sur [_devFallback] ci-dessous —
/// pratique pour un lancement rapide depuis VSCode (voir .vscode/launch.json),
/// mais à garder synchronisé avec l'IP réelle de la machine de dev.
///
/// Avant la mise en production, passer l'URL réelle de l'API déployée en
/// HTTPS (obligatoire — CDC section 19) via ce même `--dart-define`, sans
/// toucher au code.
class ApiConfig {
  ApiConfig._();

  static const String _devFallback = 'http://192.168.1.185:8321/api';

  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: _devFallback,
  );
}
