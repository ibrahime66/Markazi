import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../models/sync_queue_item.dart';
import '../providers/attendance_provider.dart';
import '../providers/class_provider.dart';
import '../providers/guardian_provider.dart';
import '../providers/locale_provider.dart';
import '../providers/payment_provider.dart';
import '../providers/recitation_provider.dart';
import '../providers/student_provider.dart';
import '../providers/sync_queue_provider.dart';
import '../providers/theme_provider.dart';
import '../services/auth_service.dart';
import '../utils/app_colors.dart';
import '../widgets/common_widgets.dart';

/// Écran "Synchronisation" (CDC §20, doc/audit.md points D2/F5) : état de
/// connexion, actions saisies hors ligne en attente d'envoi (avec leur date
/// réelle), refus éventuels du serveur, et possibilité de relancer ou
/// d'abandonner une action.
class SyncStatusScreen extends StatelessWidget {
  const SyncStatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeProvider>();
    context.watch<LocaleProvider>();
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: MarkaziAppBar(title: l10n.navSync),
      body: Consumer<SyncQueueProvider>(
        builder: (context, sync, _) {
          final items = sync.pendingItems;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _StatusCard(sync: sync),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: sync.isSyncing ? null : () => _syncNow(context),
                  icon: sync.isSyncing
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.sync),
                  label: Text(sync.isSyncing ? l10n.syncInProgress : l10n.syncNow),
                ),
              ),
              const SizedBox(height: 20),
              if (items.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  child: Column(
                    children: [
                      Icon(
                        Icons.cloud_done_rounded,
                        size: 56,
                        color: AppColors.primary.withValues(alpha: 0.6),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        l10n.syncEmpty,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.cairo(color: AppColors.textMedium),
                      ),
                    ],
                  ),
                )
              else ...[
                Text(
                  l10n.syncPendingTitle,
                  style: GoogleFonts.cairo(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 8),
                for (final item in items) _PendingItemTile(item: item),
              ],
              const SizedBox(height: 16),
              Text(
                l10n.syncConflictsHint,
                style: GoogleFonts.cairo(fontSize: 12, color: AppColors.textMedium),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _syncNow(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final markazId = context.read<AuthService>().currentMarkazId;
    if (markazId == null) return;
    final messenger = ScaffoldMessenger.of(context);
    final report = await context.read<SyncQueueProvider>().syncAll(markazId);
    if (!context.mounted) return;

    await _reloadProviders(context);
    if (!context.mounted) return;

    messenger.showSnackBar(SnackBar(
      content: Text(report.offline
          ? l10n.syncStillOffline
          : report.synced == 0 && report.failed == 0
              ? l10n.syncAllDone
              : l10n.syncResult('${report.synced}', '${report.failed}')),
      backgroundColor: report.offline
          ? Colors.blueGrey
          : report.failed > 0
              ? Colors.red
              : Colors.green,
    ));
  }
}

/// Recharge l'affichage de chaque module depuis les caches locaux à jour.
Future<void> _reloadProviders(BuildContext context) {
  return Future.wait([
    context.read<StudentProvider>().loadStudents(),
    context.read<ClassProvider>().loadClasses(),
    context.read<PaymentProvider>().loadPayments(),
    context.read<AttendanceProvider>().loadAttendances(),
    context.read<GuardianProvider>().loadGuardians(),
    context.read<RecitationProvider>().loadRecitations(),
  ]);
}

class _StatusCard extends StatelessWidget {
  final SyncQueueProvider sync;

  const _StatusCard({required this.sync});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final online = sync.isOnline;
    final color = online ? AppColors.primary : Colors.blueGrey;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color.withValues(alpha: 0.12),
            child: Icon(
              online ? Icons.cloud_done_rounded : Icons.cloud_off_rounded,
              color: color,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  online ? l10n.syncOnline : l10n.syncOffline,
                  style: GoogleFonts.cairo(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
                Text(
                  sync.pendingCount == 0
                      ? l10n.syncAllDone
                      : l10n.syncPendingBanner('${sync.pendingCount}'),
                  style: GoogleFonts.cairo(fontSize: 13, color: AppColors.textMedium),
                ),
                if (!online)
                  Text(
                    l10n.syncOfflineBanner,
                    style: GoogleFonts.cairo(fontSize: 12, color: AppColors.textMedium),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PendingItemTile extends StatelessWidget {
  final SyncQueueItem item;

  const _PendingItemTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final sync = context.read<SyncQueueProvider>();
    final locale = Localizations.localeOf(context).toString();
    final summary = sync.describe(item);
    final failed = item.lastError != null;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: AppColors.surface,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: failed
                ? Colors.red.withValues(alpha: 0.5)
                : AppColors.textLight.withValues(alpha: 0.2),
          ),
        ),
        child: ListTile(
          leading: Icon(
            failed ? Icons.error_outline_rounded : _entityIcon(item.entityType),
            color: failed ? Colors.red.shade700 : AppColors.primary,
          ),
          title: Text(
            '${_entityLabel(l10n, item.entityType)} · ${_operationLabel(l10n, item.operation)}',
            style: GoogleFonts.cairo(
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (summary != null && summary.isNotEmpty)
                Text(summary, style: GoogleFonts.cairo(color: AppColors.textDark)),
              Text(
                l10n.syncDoneAt(
                  DateFormat.yMMMd(locale).add_Hm().format(item.actionDate),
                ),
                style: GoogleFonts.cairo(fontSize: 12, color: AppColors.textMedium),
              ),
              if (failed)
                Text(
                  l10n.syncRejected(item.lastError!),
                  style: GoogleFonts.cairo(fontSize: 12, color: Colors.red.shade700),
                ),
            ],
          ),
          trailing: PopupMenuButton<String>(
            onSelected: (_) => _confirmDiscard(context),
            itemBuilder: (_) => [
              PopupMenuItem(value: 'discard', child: Text(l10n.syncDiscard)),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDiscard(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final sync = context.read<SyncQueueProvider>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.syncDiscardConfirmTitle),
        content: Text(l10n.syncDiscardConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(l10n.actionCancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(
              l10n.syncDiscard,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await sync.discard(item);
    if (!context.mounted) return;
    await _reloadProviders(context);
  }

  static IconData _entityIcon(SyncEntityType type) {
    switch (type) {
      case SyncEntityType.payment:
        return Icons.payments_rounded;
      case SyncEntityType.attendance:
        return Icons.event_available_rounded;
      case SyncEntityType.guardian:
        return Icons.family_restroom_rounded;
      case SyncEntityType.recitation:
        return Icons.menu_book_rounded;
      case SyncEntityType.classModel:
        return Icons.groups_rounded;
      case SyncEntityType.studentClass:
        return Icons.group_add_rounded;
    }
  }

  static String _entityLabel(AppLocalizations l10n, SyncEntityType type) {
    switch (type) {
      case SyncEntityType.payment:
        return l10n.syncEntityPayment;
      case SyncEntityType.attendance:
        return l10n.syncEntityAttendance;
      case SyncEntityType.guardian:
        return l10n.syncEntityGuardian;
      case SyncEntityType.recitation:
        return l10n.syncEntityRecitation;
      case SyncEntityType.classModel:
        return l10n.syncEntityClass;
      case SyncEntityType.studentClass:
        return l10n.syncEntityStudentClass;
    }
  }

  static String _operationLabel(AppLocalizations l10n, SyncOperation op) {
    switch (op) {
      case SyncOperation.create:
        return l10n.syncOpCreate;
      case SyncOperation.update:
        return l10n.syncOpUpdate;
      case SyncOperation.delete:
        return l10n.syncOpDelete;
    }
  }
}
