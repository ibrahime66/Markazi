import 'package:flutter/foundation.dart';
import '../datasources/api_activity_log_datasource.dart';
import '../models/activity_log_entry.dart';

/// État de l'écran "Journal d'activité" (CDC §8.9 — doc/audit.md, point F4) :
/// filtres catégorie/période, pagination infinie (CDC §25 : "chargement
/// progressif des listes longues").
class ActivityLogProvider extends ChangeNotifier {
  final ApiActivityLogDatasource _datasource;

  ActivityLogProvider(this._datasource);

  /// Catégories proposées en filtre — mêmes valeurs que celles acceptées
  /// par l'API (`ActivityLogController::CATEGORIES`).
  static const categories = [
    'student',
    'class',
    'guardian',
    'attendance',
    'recitation',
    'payment',
    'markaz',
    'user',
    'sync',
  ];

  List<ActivityLogEntry> _entries = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasError = false;
  int _page = 0;
  bool _hasMore = false;
  String? _category;
  int? _periodDays;

  List<ActivityLogEntry> get entries => _entries;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasError => _hasError;
  bool get hasMore => _hasMore;
  String? get category => _category;
  int? get periodDays => _periodDays;

  void setCategory(String? category) {
    if (category == _category) return;
    _category = category;
    refresh();
  }

  void setPeriodDays(int? days) {
    if (days == _periodDays) return;
    _periodDays = days;
    refresh();
  }

  DateTime? get _dateFrom {
    if (_periodDays == null) return null;
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: _periodDays! - 1));
  }

  /// Recharge depuis la première page (filtre changé, tirer pour rafraîchir).
  Future<void> refresh() async {
    _isLoading = true;
    _hasError = false;
    notifyListeners();
    try {
      final page = await _datasource.fetchPage(
        page: 1,
        category: _category,
        dateFrom: _dateFrom,
      );
      _entries = page.entries;
      _page = page.currentPage;
      _hasMore = page.hasMore;
    } catch (e) {
      debugPrint('Erreur chargement journal : $e');
      _hasError = true;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Charge la page suivante (défilement en bas de liste).
  Future<void> loadMore() async {
    if (!_hasMore || _isLoading || _isLoadingMore) return;
    _isLoadingMore = true;
    notifyListeners();
    try {
      final page = await _datasource.fetchPage(
        page: _page + 1,
        category: _category,
        dateFrom: _dateFrom,
      );
      _entries = [..._entries, ...page.entries];
      _page = page.currentPage;
      _hasMore = page.hasMore;
    } catch (e) {
      debugPrint('Erreur chargement journal (page suivante) : $e');
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }
}
