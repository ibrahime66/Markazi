import 'package:flutter_test/flutter_test.dart';
import 'package:markazi/models/activity_log_entry.dart';

/// doc/audit.md, point F4 — lecture d'une page du journal au format exact
/// renvoyé par `ActivityLogController::index` (pagination Laravel).
void main() {
  test('ActivityLogPage lit une page Laravel paginée', () {
    final page = ActivityLogPage.fromJson({
      'current_page': 1,
      'last_page': 3,
      'per_page': 30,
      'total': 61,
      'data': [
        {
          'id': 12,
          'markaz_id': 1,
          'user_id': 4,
          'action': 'payment.recorded',
          'entity_type': r'App\Models\Payment',
          'entity_id': 7,
          'description': 'Paiement enregistré',
          'meta': {'amount': 5000},
          'created_at': '2026-10-09T12:30:00.000000Z',
          'user': {'id': 4, 'name': 'Oustaz Barry'},
        },
        {
          'id': 11,
          'action': 'user.logged_in',
          'entity_type': null,
          'description': null,
          'created_at': null,
          'user': null,
        },
      ],
    });

    expect(page.hasMore, isTrue);
    expect(page.entries, hasLength(2));

    final first = page.entries.first;
    expect(first.id, '12');
    expect(first.domain, 'payment');
    expect(first.entityType, r'App\Models\Payment');
    expect(first.userName, 'Oustaz Barry');
    expect(first.createdAt!.toUtc(), DateTime.utc(2026, 10, 9, 12, 30));

    final second = page.entries.last;
    expect(second.domain, 'user');
    expect(second.userName, isNull);
    expect(second.createdAt, isNull);
  });

  test('Dernière page : plus rien à charger', () {
    final page = ActivityLogPage.fromJson({'current_page': 3, 'last_page': 3, 'data': []});
    expect(page.hasMore, isFalse);
    expect(page.entries, isEmpty);
  });
}
