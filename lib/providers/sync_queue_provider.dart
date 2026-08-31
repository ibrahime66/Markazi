import 'package:flutter/foundation.dart';
import '../services/sync_orchestrator.dart';

/// Expose le nombre d'actions hors ligne en attente de synchronisation, pour
/// l'indicateur visuel exigé par le CDC section 20 ("indicateur visuel
/// clair dans l'interface signalant [...] le nombre d'actions en attente de
/// synchronisation"). Voir doc/audit.md, point D2.
///
/// S'abonne directement à la boîte Hive de la file d'attente : le compteur
/// se met donc à jour en direct même quand un repository y ajoute une
/// action en arrière-plan (échec silencieux d'une synchronisation), sans
/// attendre un appel explicite à [replayPending].
class SyncQueueProvider extends ChangeNotifier {
  final SyncOrchestrator _orchestrator;
  bool _isSyncing = false;

  SyncQueueProvider(this._orchestrator) {
    _orchestrator.queueListenable.addListener(_onQueueChanged);
  }

  void _onQueueChanged() => notifyListeners();

  int get pendingCount => _orchestrator.pendingCount;

  bool get isSyncing => _isSyncing;

  /// Rejoue les actions en attente. Sûr à appeler même hors ligne (les
  /// échecs restent silencieusement en file, le compteur se met à jour
  /// automatiquement via [_onQueueChanged]).
  Future<void> replayPending() async {
    if (_isSyncing) return;
    _isSyncing = true;
    notifyListeners();
    try {
      await _orchestrator.replayPending();
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _orchestrator.queueListenable.removeListener(_onQueueChanged);
    super.dispose();
  }
}
