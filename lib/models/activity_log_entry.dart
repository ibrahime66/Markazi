/// Entrée du journal d'activité (CDC §8.9 — doc/audit.md, point F4), telle
/// que renvoyée par `GET /api/activity-logs`. Lecture seule, jamais mise en
/// cache local : le journal fait foi côté serveur.
class ActivityLogEntry {
  final String id;

  /// Ex. "payment.recorded", "student.archived", "sync.conflict".
  final String action;
  final String description;
  final String? userName;

  /// Date réelle de l'action (CDC §27) : pour une saisie faite hors ligne,
  /// c'est la date de réalisation, pas la date de synchronisation.
  final DateTime performedAt;
  final Map<String, dynamic> meta;

  const ActivityLogEntry({
    required this.id,
    required this.action,
    required this.description,
    required this.userName,
    required this.performedAt,
    required this.meta,
  });

  /// Famille d'action ("payment", "student"…), préfixe de [action].
  String get category => action.split('.').first;

  /// Action saisie hors ligne puis rejouée à la reconnexion.
  bool get syncedOffline => meta['synced_offline'] == true;

  /// Conflit de synchronisation : la version serveur, plus récente que
  /// l'action hors ligne, a été remplacée (CDC §20).
  bool get isConflict => action == 'sync.conflict';

  factory ActivityLogEntry.fromJson(Map<String, dynamic> json) {
    final rawMeta = json['meta'];
    final date = json['performed_at'] ?? json['created_at'];
    return ActivityLogEntry(
      id: json['id'].toString(),
      action: json['action'] as String? ?? '',
      description: json['description'] as String? ?? '',
      userName: (json['user'] as Map<String, dynamic>?)?['name'] as String?,
      performedAt:
          date is String ? DateTime.parse(date).toLocal() : DateTime.now(),
      // Laravel sérialise un tableau PHP vide en liste JSON `[]`.
      meta: rawMeta is Map<String, dynamic> ? rawMeta : const {},
    );
  }
}
