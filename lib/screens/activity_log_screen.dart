import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/activity_log_entry.dart';
import '../services/activity_log_service.dart';
import '../services/api_client.dart';
import '../providers/theme_provider.dart';
import '../providers/locale_provider.dart';
import '../l10n/app_localizations.dart';
import '../utils/app_colors.dart';
import '../widgets/common_widgets.dart';

/// Domaine filtrable du journal : libellé, icône, couleur et classe Laravel
/// correspondante (`entity_type` côté serveur, voir `ActivityLog::record`).
class _LogDomain {
  final String label;
  final IconData icon;
  final Color color;

  /// Classe Laravel exacte envoyée en `?entity_type=` (null = tout).
  final String? entityType;

  const _LogDomain(this.label, this.icon, this.color, this.entityType);
}

/// Écran du journal d'activité (CDC section 8.9) — doc/audit.md, point F4.
/// Lecture seule, sans cache Hive : chargé en ligne page par page.
class ActivityLogScreen extends StatefulWidget {
  const ActivityLogScreen({super.key});

  @override
  State<ActivityLogScreen> createState() => _ActivityLogScreenState();
}

class _ActivityLogScreenState extends State<ActivityLogScreen> {
  static const _filters = <_LogDomain>[
    _LogDomain('Tout', Icons.history_rounded, Colors.blueGrey, null),
    _LogDomain('Élèves', Icons.people_rounded, Colors.blue, r'App\Models\Student'),
    _LogDomain('Paiements', Icons.payments_rounded, Colors.green, r'App\Models\Payment'),
    _LogDomain('Présences', Icons.event_available_rounded, Colors.orange, r'App\Models\Attendance'),
    _LogDomain('Récitations', Icons.menu_book_rounded, Colors.purple, r'App\Models\Recitation'),
    _LogDomain('Classes', Icons.groups_rounded, Colors.teal, r'App\Models\ClassModel'),
    _LogDomain('Tuteurs', Icons.family_restroom_rounded, Colors.brown, r'App\Models\Guardian'),
    _LogDomain('Compte', Icons.person_rounded, Colors.indigo, r'App\Models\User'),
    _LogDomain('Markaz', Icons.mosque_outlined, Colors.cyan, r'App\Models\Markaz'),
  ];

  /// Domaine d'une entrée d'après le préfixe de son action
  /// (`payment.recorded` → paiements).
  static const _domainByActionPrefix = <String, int>{
    'student': 1,
    'payment': 2,
    'attendance': 3,
    'recitation': 4,
    'class': 5,
    'guardian': 6,
    'user': 7,
    'markaz': 8,
  };

  static const _months = [
    'janv.', 'févr.', 'mars', 'avr.', 'mai', 'juin',
    'juil.', 'août', 'sept.', 'oct.', 'nov.', 'déc.',
  ];

  final _service = ActivityLogService();
  final _scrollController = ScrollController();
  final List<ActivityLogEntry> _entries = [];

  int _selectedFilter = 0;
  int _currentPage = 0;
  bool _hasMore = true;
  bool _isLoading = false;
  String? _error;

  /// Incrémenté à chaque rechargement complet : une réponse arrivée après un
  /// changement de filtre est ignorée au lieu de mélanger deux listes.
  int _requestGeneration = 0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _reload();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.extentAfter < 300) {
      _loadNextPage();
    }
  }

  Future<void> _reload() async {
    _requestGeneration++;
    setState(() {
      _entries.clear();
      _currentPage = 0;
      _hasMore = true;
      _isLoading = false;
      _error = null;
    });
    await _loadNextPage();
  }

  Future<void> _loadNextPage() async {
    if (_isLoading || !_hasMore) return;
    final generation = _requestGeneration;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final page = await _service.fetchPage(
        page: _currentPage + 1,
        entityType: _filters[_selectedFilter].entityType,
      );
      if (!mounted || generation != _requestGeneration) return;
      setState(() {
        _entries.addAll(page.entries);
        _currentPage = page.currentPage;
        _hasMore = page.hasMore;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted || generation != _requestGeneration) return;
      setState(() {
        _error = ApiClient.describeError(e);
        _isLoading = false;
      });
    }
  }

  _LogDomain _domainOf(ActivityLogEntry entry) {
    final index = _domainByActionPrefix[entry.domain];
    return index != null ? _filters[index] : _filters[0];
  }

  /// Date/heure lisible en français : "Aujourd'hui à 14:32",
  /// "Hier à 09:05", sinon "3 oct. 2026 à 18:10".
  String _formatDate(DateTime? date) {
    if (date == null) return '';
    final time = '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(date.year, date.month, date.day);
    final diff = today.difference(day).inDays;
    if (diff == 0) return "Aujourd'hui à $time";
    if (diff == 1) return 'Hier à $time';
    return '${date.day} ${_months[date.month - 1]} ${date.year} à $time';
  }

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeProvider>();
    context.watch<LocaleProvider>();
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: MarkaziAppBar(title: l10n.navActivityLog),
      body: Column(
        children: [
          _buildFilterBar(),
          Expanded(
            child: RefreshIndicator(
              color: AppColors.primary,
              onRefresh: _reload,
              child: _buildList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    return SizedBox(
      height: 56,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        itemCount: _filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filter = _filters[index];
          final selected = index == _selectedFilter;
          return ChoiceChip(
            avatar: Icon(filter.icon, size: 16, color: selected ? Colors.white : filter.color),
            label: Text(
              filter.label,
              style: GoogleFonts.cairo(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: selected ? Colors.white : AppColors.textDark,
              ),
            ),
            selected: selected,
            showCheckmark: false,
            selectedColor: AppColors.primary,
            backgroundColor: AppColors.surface,
            onSelected: (_) {
              if (selected) return;
              setState(() => _selectedFilter = index);
              _reload();
            },
          );
        },
      ),
    );
  }

  Widget _buildList() {
    // Premier chargement en cours.
    if (_entries.isEmpty && _isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Erreur ou liste vide : contenu défilable pour que "tirer pour
    // rafraîchir" reste possible.
    if (_entries.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.15),
          _error != null ? _buildErrorState(_error!) : _buildEmptyState(),
        ],
      );
    }

    return ListView.separated(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      itemCount: _entries.length + 1,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        if (index == _entries.length) return _buildListFooter();
        return _buildEntryCard(_entries[index]);
      },
    );
  }

  Widget _buildListFooter() {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (_error != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          children: [
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(fontSize: 12, color: Colors.red[700]),
            ),
            TextButton(onPressed: _loadNextPage, child: const Text('Réessayer')),
          ],
        ),
      );
    }
    if (!_hasMore) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Center(
          child: Text(
            'Fin du journal',
            style: GoogleFonts.cairo(fontSize: 12, color: AppColors.textLight),
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildEntryCard(ActivityLogEntry entry) {
    final domain = _domainOf(entry);
    final description = (entry.description != null && entry.description!.isNotEmpty)
        ? entry.description!
        : entry.action;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: domain.color.withValues(alpha: 0.12),
            child: Icon(domain.icon, color: domain.color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  description,
                  style: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textDark),
                ),
                const SizedBox(height: 2),
                Text(
                  _formatDate(entry.createdAt),
                  style: GoogleFonts.cairo(fontSize: 12, color: AppColors.textMedium),
                ),
                if (entry.userName != null && entry.userName!.isNotEmpty)
                  Row(
                    children: [
                      Icon(Icons.person_outline, size: 14, color: AppColors.textLight),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          entry.userName!,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.cairo(fontSize: 12, color: AppColors.textLight),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.history_rounded, size: 56, color: AppColors.textMedium.withValues(alpha: 0.4)),
          const SizedBox(height: 16),
          Text(
            'Aucune activité enregistrée',
            textAlign: TextAlign.center,
            style: GoogleFonts.cairo(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textDark),
          ),
          const SizedBox(height: 6),
          Text(
            _selectedFilter == 0
                ? 'Les actions effectuées dans le Markaz apparaîtront ici.'
                : 'Aucune action pour ce domaine pour le moment.',
            textAlign: TextAlign.center,
            style: GoogleFonts.cairo(fontSize: 13, color: AppColors.textMedium),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.cloud_off_rounded, size: 56, color: Colors.red.withValues(alpha: 0.5)),
          const SizedBox(height: 16),
          Text(
            'Impossible de charger le journal',
            textAlign: TextAlign.center,
            style: GoogleFonts.cairo(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textDark),
          ),
          const SizedBox(height: 6),
          Text(
            message,
            textAlign: TextAlign.center,
            style: GoogleFonts.cairo(fontSize: 13, color: AppColors.textMedium),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: _reload,
            icon: const Icon(Icons.refresh, color: Colors.white),
            label: const Text('Réessayer', style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
          ),
        ],
      ),
    );
  }
}
