/// Entrée du journal d'activité (CDC section 8.9), telle que renvoyée par
/// `GET /api/activity-logs` — doc/audit.md, point F4.
///
/// Lecture seule et sans cache Hive : le journal est consulté en ligne,
/// jamais modifié depuis l'app (CDC section 19 : journal non modifiable).
class ActivityLogEntry {
  final String id;

  /// Code technique de l'action, ex. `payment.recorded`, `student.archived`.
  final String action;

  /// Classe Laravel de l'entité concernée, ex. `App\Models\Payment`
  /// (peut être nulle si l'action ne concerne aucune entité).
  final String? entityType;

  final String? description;
  final DateTime? createdAt;

  /// Nom de l'utilisateur ayant réalisé l'action (null si compte supprimé).
  final String? userName;

  const ActivityLogEntry({
    required this.id,
    required this.action,
    this.entityType,
    this.description,
    this.createdAt,
    this.userName,
  });

  factory ActivityLogEntry.fromJson(Map<String, dynamic> json) {
    final user = json['user'];
    final rawDate = json['created_at'] as String?;
    return ActivityLogEntry(
      id: json['id'].toString(),
      action: json['action'] as String? ?? '',
      entityType: json['entity_type'] as String?,
      description: json['description'] as String?,
      createdAt: rawDate != null ? DateTime.tryParse(rawDate)?.toLocal() : null,
      userName: user is Map ? user['name'] as String? : null,
    );
  }

  /// Domaine fonctionnel de l'action (préfixe avant le point :
  /// `payment.recorded` → `payment`).
  String get domain {
    final dot = action.indexOf('.');
    return dot > 0 ? action.substring(0, dot) : action;
  }
}

/// Une page du journal (pagination Laravel : `data`, `current_page`,
/// `last_page`).
class ActivityLogPage {
  final List<ActivityLogEntry> entries;
  final int currentPage;
  final int lastPage;

  const ActivityLogPage({
    required this.entries,
    required this.currentPage,
    required this.lastPage,
  });

  bool get hasMore => currentPage < lastPage;

  factory ActivityLogPage.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as List<dynamic>? ?? const [];
    return ActivityLogPage(
      entries: data
          .map((e) => ActivityLogEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
      currentPage: (json['current_page'] as num?)?.toInt() ?? 1,
      lastPage: (json['last_page'] as num?)?.toInt() ?? 1,
    );
  }
}
