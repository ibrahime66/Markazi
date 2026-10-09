import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../models/activity_log_entry.dart';
import '../providers/activity_log_provider.dart';
import '../providers/locale_provider.dart';
import '../providers/theme_provider.dart';
import '../utils/app_colors.dart';
import '../widgets/common_widgets.dart';

/// Écran "Journal d'activité" (CDC §8.9 : "journal d'activité horodaté par
/// utilisateur et par entité") — comble doc/audit.md, point F4 : les actions
/// étaient journalisées côté serveur mais aucun écran ne les montrait.
///
/// Les actions saisies hors ligne apparaissent à leur date réelle avec un
/// badge, et les conflits de synchronisation (CDC §20) sont mis en évidence
/// avec la version serveur remplacée, pour arbitrage manuel.
class ActivityLogScreen extends StatefulWidget {
  const ActivityLogScreen({super.key});

  @override
  State<ActivityLogScreen> createState() => _ActivityLogScreenState();
}

class _ActivityLogScreenState extends State<ActivityLogScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    Future.microtask(() {
      if (!mounted) return;
      context.read<ActivityLogProvider>().refresh();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 300) {
      context.read<ActivityLogProvider>().loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeProvider>();
    context.watch<LocaleProvider>();
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: MarkaziAppBar(title: l10n.navActivityLog),
      body: Consumer<ActivityLogProvider>(
        builder: (context, provider, _) {
          return Column(
            children: [
              _Filters(provider: provider),
              Expanded(child: _buildBody(context, provider, l10n)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    ActivityLogProvider provider,
    AppLocalizations l10n,
  ) {
    if (provider.isLoading && provider.entries.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.hasError && provider.entries.isEmpty) {
      return _Message(
        icon: Icons.cloud_off_rounded,
        text: l10n.activityLoadError,
        action: TextButton.icon(
          onPressed: provider.refresh,
          icon: const Icon(Icons.refresh),
          label: Text(l10n.actionRetry),
        ),
      );
    }

    if (provider.entries.isEmpty) {
      return RefreshIndicator(
        onRefresh: provider.refresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            const SizedBox(height: 80),
            _Message(icon: Icons.history_rounded, text: l10n.activityEmpty),
          ],
        ),
      );
    }

    final rows = _groupByDay(provider.entries, l10n, context);
    return RefreshIndicator(
      onRefresh: provider.refresh,
      child: ListView.builder(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        itemCount: rows.length + (provider.isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= rows.length) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          final row = rows[index];
          if (row is String) return _DayHeader(label: row);
          return _EntryTile(entry: row as ActivityLogEntry);
        },
      ),
    );
  }

  /// Intercale un en-tête de jour ("Aujourd'hui", "Hier", date complète)
  /// entre les entrées, déjà triées de la plus récente à la plus ancienne.
  List<Object> _groupByDay(
    List<ActivityLogEntry> entries,
    AppLocalizations l10n,
    BuildContext context,
  ) {
    final locale = Localizations.localeOf(context).toString();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final rows = <Object>[];
    DateTime? currentDay;

    for (final entry in entries) {
      final d = entry.performedAt;
      final day = DateTime(d.year, d.month, d.day);
      if (currentDay != day) {
        currentDay = day;
        final diff = today.difference(day).inDays;
        rows.add(diff == 0
            ? l10n.activityToday
            : diff == 1
                ? l10n.activityYesterday
                : DateFormat.yMMMMEEEEd(locale).format(day));
      }
      rows.add(entry);
    }
    return rows;
  }
}

class _Filters extends StatelessWidget {
  final ActivityLogProvider provider;

  const _Filters({required this.provider});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final periods = <int?, String>{
      null: l10n.activityPeriodAll,
      7: l10n.activityPeriod7,
      30: l10n.activityPeriod30,
    };

    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.only(top: 8, bottom: 8),
      child: Column(
        children: [
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                _chip(
                  label: l10n.activityFilterAll,
                  selected: provider.category == null,
                  onTap: () => provider.setCategory(null),
                ),
                for (final category in ActivityLogProvider.categories)
                  _chip(
                    label: categoryLabel(l10n, category),
                    selected: provider.category == category,
                    onTap: () => provider.setCategory(category),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                for (final entry in periods.entries)
                  _chip(
                    label: entry.value,
                    selected: provider.periodDays == entry.key,
                    onTap: () => provider.setPeriodDays(entry.key),
                    icon: Icons.calendar_today_rounded,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
    IconData? icon,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: ChoiceChip(
        avatar: icon != null && selected ? Icon(icon, size: 14) : null,
        label: Text(label, style: GoogleFonts.cairo(fontSize: 13)),
        selected: selected,
        onSelected: (_) => onTap(),
        selectedColor: AppColors.primary.withValues(alpha: 0.15),
        showCheckmark: false,
      ),
    );
  }
}

/// Libellé traduit d'une catégorie d'action.
String categoryLabel(AppLocalizations l10n, String category) {
  switch (category) {
    case 'student':
      return l10n.activityCategoryStudent;
    case 'class':
      return l10n.activityCategoryClass;
    case 'guardian':
      return l10n.activityCategoryGuardian;
    case 'attendance':
      return l10n.activityCategoryAttendance;
    case 'recitation':
      return l10n.activityCategoryRecitation;
    case 'payment':
      return l10n.activityCategoryPayment;
    case 'markaz':
      return l10n.activityCategoryMarkaz;
    case 'user':
      return l10n.activityCategoryUser;
    case 'sync':
      return l10n.activityCategorySync;
    default:
      return category;
  }
}

IconData _categoryIcon(String category) {
  switch (category) {
    case 'student':
      return Icons.person_rounded;
    case 'class':
      return Icons.groups_rounded;
    case 'guardian':
      return Icons.family_restroom_rounded;
    case 'attendance':
      return Icons.event_available_rounded;
    case 'recitation':
      return Icons.menu_book_rounded;
    case 'payment':
      return Icons.payments_rounded;
    case 'markaz':
      return Icons.mosque_outlined;
    case 'user':
      return Icons.account_circle_rounded;
    case 'sync':
      return Icons.sync_problem_rounded;
    default:
      return Icons.history_rounded;
  }
}

class _DayHeader extends StatelessWidget {
  final String label;

  const _DayHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Text(
        label,
        style: GoogleFonts.cairo(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: AppColors.textMedium,
        ),
      ),
    );
  }
}

class _EntryTile extends StatelessWidget {
  final ActivityLogEntry entry;

  const _EntryTile({required this.entry});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final color = entry.isConflict ? Colors.orange.shade800 : AppColors.primary;

    // Material (et non Container décoré) : l'effet de toucher du ListTile
    // doit rester visible sur une entrée de conflit cliquable.
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: AppColors.surface,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: entry.isConflict
                ? Colors.orange.withValues(alpha: 0.6)
                : AppColors.textLight.withValues(alpha: 0.2),
          ),
        ),
        child: ListTile(
          onTap: entry.isConflict ? () => _showConflict(context, entry) : null,
          leading: CircleAvatar(
            backgroundColor: color.withValues(alpha: 0.12),
            child: Icon(_categoryIcon(entry.category), color: color, size: 20),
          ),
          title: Text(
            entry.description.isNotEmpty ? entry.description : entry.action,
            style: GoogleFonts.cairo(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                [
                  DateFormat.Hm(locale).format(entry.performedAt),
                  if (entry.userName != null)
                    l10n.activityByUser(entry.userName!),
                ].join(' · '),
                style: GoogleFonts.cairo(
                    fontSize: 12, color: AppColors.textMedium),
              ),
              if (entry.syncedOffline || entry.isConflict)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Wrap(
                    spacing: 6,
                    children: [
                      if (entry.syncedOffline)
                        _Badge(
                          icon: Icons.cloud_off_rounded,
                          label: l10n.activityOfflineBadge,
                          color: Colors.blueGrey,
                        ),
                      if (entry.isConflict)
                        _Badge(
                          icon: Icons.touch_app_rounded,
                          label: l10n.activityConflictHint,
                          color: Colors.orange.shade800,
                        ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showConflict(BuildContext context, ActivityLogEntry entry) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final format = DateFormat.yMMMd(locale).add_Hm();

    String formatDate(dynamic value) {
      if (value is! String) return '—';
      final parsed = DateTime.tryParse(value);
      return parsed == null ? value : format.format(parsed.toLocal());
    }

    final version = entry.meta['overwritten_server_version'];
    final fields = version is Map<String, dynamic>
        ? version.entries
            .where((e) => !const ['id', 'updated_at'].contains(e.key))
            .toList()
        : const <MapEntry<String, dynamic>>[];

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.activityConflictTitle),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.activityConflictExplanation(
                formatDate(entry.meta['performed_at']),
                formatDate(entry.meta['server_updated_at']),
              )),
              const SizedBox(height: 12),
              for (final field in fields)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    '${field.key} : ${field.value ?? '—'}',
                    style:
                        const TextStyle(fontFamily: 'monospace', fontSize: 12),
                  ),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.actionClose),
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _Badge({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(label, style: GoogleFonts.cairo(fontSize: 11, color: color)),
        ],
      ),
    );
  }
}

class _Message extends StatelessWidget {
  final IconData icon;
  final String text;
  final Widget? action;

  const _Message({required this.icon, required this.text, this.action});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                size: 56, color: AppColors.textMedium.withValues(alpha: 0.4)),
            const SizedBox(height: 16),
            Text(
              text,
              textAlign: TextAlign.center,
              style:
                  GoogleFonts.cairo(fontSize: 14, color: AppColors.textMedium),
            ),
            if (action != null) ...[const SizedBox(height: 12), action!],
          ],
        ),
      ),
    );
  }
}
