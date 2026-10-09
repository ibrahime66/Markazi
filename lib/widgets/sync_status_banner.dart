import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../providers/sync_queue_provider.dart';

/// Bandeau d'état du mode hors ligne (CDC §20 : "indicateur visuel clair
/// dans l'interface signalant l'état de connexion et le nombre d'actions en
/// attente de synchronisation"). Invisible quand tout est synchronisé ;
/// un toucher ouvre l'écran "Synchronisation".
class SyncStatusBanner extends StatelessWidget {
  const SyncStatusBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Consumer<SyncQueueProvider>(
      builder: (context, sync, _) {
        final pending = sync.pendingCount;
        final failed = sync.failedCount;
        if (sync.isOnline && pending == 0) return const SizedBox.shrink();

        final Color color;
        final IconData icon;
        final String text;
        if (failed > 0) {
          color = Colors.red.shade700;
          icon = Icons.error_outline_rounded;
          text = l10n.syncFailedBanner('$failed');
        } else if (!sync.isOnline) {
          color = Colors.blueGrey.shade700;
          icon = Icons.cloud_off_rounded;
          text = pending > 0
              ? '${l10n.syncOffline} · ${l10n.syncPendingBanner('$pending')}'
              : l10n.syncOfflineBanner;
        } else {
          color = Colors.orange.shade800;
          icon = Icons.cloud_upload_rounded;
          text = l10n.syncPendingBanner('$pending');
        }

        return Material(
          color: color,
          child: InkWell(
            onTap: () => Navigator.pushNamed(context, '/sync'),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  if (sync.isSyncing)
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  else
                    Icon(icon, color: Colors.white, size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      text,
                      style: GoogleFonts.cairo(color: Colors.white, fontSize: 13),
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded, color: Colors.white),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
