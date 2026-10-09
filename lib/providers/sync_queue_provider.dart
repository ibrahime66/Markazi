import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/sync_queue_item.dart';
import '../services/api_client.dart';
import '../services/sync_orchestrator.dart';

/// État du mode hors ligne pour l'interface (CDC section 20 : "indicateur
/// visuel clair dans l'interface signalant l'état de connexion et le nombre
/// d'actions en attente de synchronisation"). Voir doc/audit.md, D2 et F5.
///
/// - Compteur en direct : abonné à la boîte Hive de la file, il se met à
///   jour même quand un repository y ajoute une action en arrière-plan.
/// - État de connexion : déduit du résultat des requêtes API
///   ([ApiClient.isOnline]).
/// - Rejeu automatique "à la reconnexion" (CDC §20) : dès qu'une requête
///   réussit à nouveau, et par une tentative périodique tant que des
///   actions attendent (sinon rien ne détecterait le retour du réseau si
///   l'utilisateur ne fait aucune action).
class SyncQueueProvider extends ChangeNotifier {
  final SyncOrchestrator _orchestrator;
  final ValueNotifier<bool> _isOnline;
  final Duration _retryInterval;
  bool _isSyncing = false;
  SyncReport? _lastReport;
  DateTime? _lastSyncAt;
  Timer? _timer;

  SyncQueueProvider(
    this._orchestrator, {
    ValueNotifier<bool>? isOnline,
    Duration retryInterval = const Duration(seconds: 45),
  })  : _isOnline = isOnline ?? ApiClient.instance.isOnline,
        _retryInterval = retryInterval {
    _orchestrator.queueListenable.addListener(_onQueueChanged);
    _isOnline.addListener(_onConnectivityChanged);
    _updateTimer();
  }

  int get pendingCount => _orchestrator.pendingCount;

  int get failedCount => _orchestrator.failedCount;

  List<SyncQueueItem> get pendingItems => _orchestrator.pendingItems;

  bool get isOnline => _isOnline.value;

  bool get isSyncing => _isSyncing;

  SyncReport? get lastReport => _lastReport;

  DateTime? get lastSyncAt => _lastSyncAt;

  String? describe(SyncQueueItem item) => _orchestrator.describe(item);

  /// Actions que l'automatisme peut retenter : celles jamais refusées par
  /// le serveur. Une action refusée (validation, doublon…) échouerait à
  /// nouveau à l'identique : elle attend une décision de l'utilisateur
  /// ("Synchroniser maintenant" ou "Abandonner").
  bool get _hasRetryable => pendingItems.any((i) => i.lastError == null);

  void _onQueueChanged() {
    _updateTimer();
    notifyListeners();
  }

  void _onConnectivityChanged() {
    notifyListeners();
    // Retour de la connexion : rejeu automatique des actions en attente.
    if (_isOnline.value && _hasRetryable) {
      replayPending();
    }
  }

  /// Tentative périodique uniquement tant qu'il reste des actions à envoyer.
  void _updateTimer() {
    if (!_hasRetryable) {
      _timer?.cancel();
      _timer = null;
    } else {
      _timer ??= Timer.periodic(_retryInterval, (_) {
        if (_hasRetryable && !_isSyncing) replayPending();
      });
    }
  }

  /// Rejoue les actions en attente. Sûr à appeler même hors ligne.
  Future<SyncReport> replayPending() {
    return _run(_orchestrator.replayPending);
  }

  /// Synchronisation complète demandée par l'utilisateur : rejeu, puis
  /// rechargement des données depuis le serveur.
  Future<SyncReport> syncAll(String markazId) {
    return _run(() => _orchestrator.syncAll(markazId));
  }

  Future<SyncReport> _run(Future<SyncReport> Function() action) async {
    _isSyncing = true;
    notifyListeners();
    try {
      final report = await action();
      _lastReport = report;
      if (!report.offline) _lastSyncAt = DateTime.now();
      return report;
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  /// Abandonne une action en attente (choix de l'utilisateur).
  Future<void> discard(SyncQueueItem item) => _orchestrator.discard(item);

  @override
  void dispose() {
    _timer?.cancel();
    _orchestrator.queueListenable.removeListener(_onQueueChanged);
    _isOnline.removeListener(_onConnectivityChanged);
    super.dispose();
  }
}
