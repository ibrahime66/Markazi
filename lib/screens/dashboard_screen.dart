import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../utils/app_colors.dart';
import '../providers/student_provider.dart';
import '../providers/payment_provider.dart';
import '../providers/attendance_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/locale_provider.dart';
import '../l10n/app_localizations.dart';
import '../providers/class_provider.dart';
import '../providers/markaz_provider.dart';
import '../providers/sync_queue_provider.dart';
import '../providers/guardian_provider.dart';
import '../providers/recitation_provider.dart';
import '../widgets/sync_status_banner.dart';
import '../services/auth_service.dart';
import '../services/student_service.dart';
import '../services/payment_service.dart';
import '../services/attendance_service.dart';
import '../services/class_service.dart';
import '../services/api_client.dart';
import '../datasources/api_payment_datasource.dart' show PaymentDuplicateException;
import '../models/payment.dart';
import '../models/class_model.dart';
import '../models/student.dart';
import '../models/attendance.dart';
import '../document_engine/document_service.dart';
import '../document_engine/models/document_metadata.dart';
import '../document_engine/models/markaz_branding.dart';
import 'group_details_screen.dart';

/// Dashboard principal pour l'utilisateur connecté
/// Gestion des élèves, paiements, présences et statistiques
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  /// Textes traduits (doc/audit.md K8).
  AppLocalizations get _l10n => AppLocalizations.of(context);

  int _selectedTabIndex = 0;

  /// Devise configurée pour ce Markaz, utilisée partout où un montant est
  /// affiché (doc/audit.md, point I4 : auparavant "FGN" codé en dur dans
  /// toute l'app, incompatible avec un déploiement dans d'autres pays).
  String get _currency => context.read<MarkazProvider>().markaz?.currency ?? 'GNF';

  @override
  void initState() {
    super.initState();
    // Charger les données au démarrage du dashboard
    Future.microtask(() async {
      // Tous les lookups Provider sont faits ici, avant tout `await` (donc
      // avant tout "gap" async) : on capture des objets Dart classiques
      // (services/providers), pas le BuildContext lui-même, donc leur usage
      // plus bas dans ce microtask reste valide même une fois l'écran démonté.
      if (!mounted) return;
      final studentProvider = context.read<StudentProvider>();
      final paymentProvider = context.read<PaymentProvider>();
      final attendanceProvider = context.read<AttendanceProvider>();
      final classProvider = context.read<ClassProvider>();
      final studentService = context.read<StudentService>();
      final paymentService = context.read<PaymentService>();
      final attendanceService = context.read<AttendanceService>();
      final classService = context.read<ClassService>();
      final markazProvider = context.read<MarkazProvider>();

      // Synchroniser depuis l'API avant de charger les données locales
      try {
        await studentService.syncFromApi();
        await paymentService.syncFromApi();
        await attendanceService.syncFromApi();
        await classService.syncFromApi();
        await markazProvider.load();

        debugPrint('✅ Synchronisation API terminée');
      } catch (e) {
        debugPrint('Erreur sync automatique: $e');
      }

      // Puis charger les données locales
      studentProvider.loadStudents();
      paymentProvider.loadPayments();
      attendanceProvider.loadAttendances();
      classProvider.loadClasses();
      
      // Écouter les changements dans les élèves pour rafraîchir les groupes
      studentProvider.addListener(() {
        // Quand un élève est supprimé, recharger les groupes pour mettre à jour les occupations
        classProvider.loadClasses();
        
        // Correction manuelle des occupations incorrectes
        _fixGroupOccupations(classProvider, studentProvider);
      });
      
      // Correction initiale des occupations
      _fixGroupOccupations(classProvider, studentProvider);
    });
  }

  // ─── Utility Methods ───────────────────────
  /// Valide un numéro de téléphone. Auparavant limité à exactement 9
  /// chiffres (format guinéen) — bloquant pour un déploiement Play Store
  /// où les utilisateurs peuvent être dans n'importe quel pays. On se
  /// contente désormais d'une longueur plausible pour un numéro réel.
  bool _isValidGuineanPhone(String phone) {
    final digits = phone.replaceAll(RegExp(r'[^0-9]'), '');
    return digits.length >= 6 && digits.length <= 15;
  }

  /// Formate un numéro de téléphone pour l'affichage. Le groupement par
  /// paires façon "622 18 09 33" ne reste appliqué qu'aux numéros à 9
  /// chiffres (format guinéen) ; les autres longueurs sont affichées
  /// telles quelles plutôt que tronquées ou mal découpées.
  String _formatGuineanPhone(String phone) {
    final digits = phone.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length != 9) return digits;
    return '${digits.substring(0, 3)} ${digits.substring(3, 5)} ${digits.substring(5, 7)} ${digits.substring(7, 9)}';
  }

  /// Nettoie le numéro (garde seulement les 9 chiffres)
  String _cleanPhoneNumber(String phone) {
    return phone.replaceAll(RegExp(r'[^0-9]'), '');
  }

  @override
  Widget build(BuildContext context) {
    // Reconstruit l'écran (donc relit AppColors.xxx) quand le mode clair/
    // sombre change — doc/audit.md K7. Idem pour la langue — K8.
    context.watch<ThemeProvider>();
    context.watch<LocaleProvider>();
    final l10n = AppLocalizations.of(context);
    final authService = context.read<AuthService>();
    final userName = authService.currentUser?.name ?? _l10n.dashUserFallback;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _l10n.dashWelcome(userName),
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.white70,
              ),
            ),
            Text(
              _tabTitles(l10n)[_selectedTabIndex],
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
        ),
        actions: [
          Consumer<SyncQueueProvider>(
            builder: (context, syncQueueProvider, _) {
              final pending = syncQueueProvider.pendingCount;
              return IconButton(
                icon: Badge(
                  isLabelVisible: pending > 0,
                  label: Text('$pending'),
                  child: Icon(
                    syncQueueProvider.isOnline ? Icons.sync : Icons.cloud_off_rounded,
                    color: Colors.white,
                  ),
                ),
                onPressed: syncQueueProvider.isSyncing ? null : _syncFromApi,
                tooltip: pending > 0
                    ? l10n.syncPendingBanner('$pending')
                    : l10n.syncNow,
              );
            },
          ),
        ],
      ),
      drawer: _buildNavigationDrawer(context, userName),
      body: Column(
        children: [
          // Indicateur hors ligne / actions en attente (CDC §20).
          const SyncStatusBanner(),
          Expanded(child: _buildTabContent()),
        ],
      ),
    );
  }

  // Titres pleins affichés dans l'AppBar (les onglets ont migré dans le
  // tiroir de navigation ci-dessous, avec icônes et libellés complets —
  // plus d'abréviations tronquées ni de menu masqué derrière un bouton
  // "⋮" flottant).
  List<String> _tabTitles(AppLocalizations l10n) => [
        l10n.navOverview,
        l10n.navStudents,
        l10n.navGroups,
        l10n.navPayments,
        l10n.navAttendance,
        l10n.navReports,
      ];

  /// Tiroir de navigation principal : réunit les onglets internes du
  /// tableau de bord et les destinations autrefois cachées derrière le
  /// menu "⋮" (Mon Markaz, Tuteurs/Parents, Récitations), toutes avec de
  /// vraies icônes vectorielles et un libellé complet.
  Widget _buildNavigationDrawer(BuildContext context, String userName) {
    final l10n = AppLocalizations.of(context);
    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
              decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.mosque_rounded,
                        color: Colors.white, size: 26),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Markazi',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  _buildDrawerTab(Icons.dashboard_rounded, l10n.navOverview, 0),
                  _buildDrawerTab(Icons.people_rounded, l10n.navStudents, 1),
                  _buildDrawerTab(Icons.groups_rounded, l10n.navGroups, 2),
                  _buildDrawerTab(Icons.payments_rounded, l10n.navPayments, 3),
                  _buildDrawerTab(Icons.event_available_rounded, l10n.navAttendance, 4),
                  _buildDrawerTab(Icons.bar_chart_rounded, l10n.navReports, 5),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Divider(height: 24),
                  ),
                  _buildDrawerRoute(Icons.mosque_outlined, l10n.navMyMarkaz, '/markaz-settings'),
                  _buildDrawerRoute(Icons.family_restroom_rounded, l10n.navGuardians, '/guardians'),
                  _buildDrawerRoute(Icons.menu_book_rounded, l10n.navRecitations, '/recitations'),
                  _buildDrawerRoute(Icons.history_rounded, l10n.navActivityLog, '/activity-log'),
                  _buildDrawerRoute(Icons.cloud_sync_rounded, l10n.navSync, '/sync'),
                ],
              ),
            ),
            // Bascule rapide du mode sombre, accessible en un clic direct
            // depuis le tiroir — le réglage fin (Système/Clair/Sombre) reste
            // disponible dans "Mon Markaz" pour qui le cherche, mais l'usage
            // courant ne doit pas nécessiter d'y naviguer (retour
            // utilisateur : "c'est à l'utilisateur de cliquer pour
            // l'activer dans l'application").
            const Divider(height: 1),
            SwitchListTile(
              secondary: Icon(
                AppColors.isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                color: AppColors.primary,
              ),
              title: Text(
                l10n.navDarkMode,
                style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              value: AppColors.isDark,
              activeThumbColor: AppColors.primary,
              onChanged: (value) {
                context.read<ThemeProvider>().setThemeMode(
                      value ? ThemeMode.dark : ThemeMode.light,
                    );
              },
            ),
            // Déconnexion : séparée en bas du tiroir, loin des actions
            // courantes de l'AppBar où elle n'avait pas sa place.
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.logout_rounded, color: Colors.red),
              title: Text(
                l10n.navLogout,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.red,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                _handleLogout();
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  /// Item de tiroir pour un onglet interne du tableau de bord.
  Widget _buildDrawerTab(IconData icon, String label, int index) {
    final isActive = _selectedTabIndex == index;
    return ListTile(
      leading: Icon(icon, color: isActive ? AppColors.primary : Colors.grey[600]),
      title: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
          color: isActive ? AppColors.primary : AppColors.textDark,
        ),
      ),
      selected: isActive,
      selectedTileColor: AppColors.primary.withValues(alpha: 0.08),
      onTap: () {
        setState(() => _selectedTabIndex = index);
        Navigator.pop(context);
      },
    );
  }

  /// Item de tiroir qui navigue vers un écran séparé (route nommée).
  Widget _buildDrawerRoute(IconData icon, String label, String route) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey[600]),
      title: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.textDark,
        ),
      ),
      onTap: () {
        Navigator.pop(context);
        Navigator.pushNamed(context, route);
      },
    );
  }

  Widget _buildTabContent() {
    switch (_selectedTabIndex) {
      case 0:
        return _buildOverview();
      case 1:
        return _buildStudentsTab();
      case 2:
        return _buildGroupsTab();
      case 3:
        return _buildPaymentsTab();
      case 4:
        return _buildAttendanceTab();
      case 5:
        return _buildReportsTab();
      default:
        return const SizedBox.shrink();
    }
  }

  // ─── OVERVIEW ──────────────────────────────
  Widget _buildOverview() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _l10n.dashGeneralStats,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          Consumer3<StudentProvider, PaymentProvider, AttendanceProvider>(
            builder: (context, studentProvider, paymentProvider, attendanceProvider, _) {
              // Filtrer pour n'afficher que les données valides
              final existingStudentIds = studentProvider.students.map((s) => s.id).toSet();
              final validPayments = paymentProvider.payments
                  .where((payment) => existingStudentIds.contains(payment.studentId))
                  .toList();
              final validAttendances = attendanceProvider.attendances
                  .where((attendance) => existingStudentIds.contains(attendance.studentId))
                  .toList();
              
              return GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                // 1.5 débordait de 31px sur certains téléphones (icône +
                // 2 lignes de texte ne tenaient pas dans la hauteur allouée
                // — vérifié sur un TECNO CK6 réel). 1.15 laisse assez de
                // marge verticale.
                childAspectRatio: 1.15,
                children: [
                  _buildStatCard(
                    _l10n.navStudents,
                    studentProvider.students.length.toString(),
                    Icons.people,
                    AppColors.primary,
                  ),
                  _buildStatCard(
                    _l10n.navPayments,
                    validPayments.length.toString(),
                    Icons.payments,
                    Colors.blue,
                  ),
                  _buildStatCard(
                    _l10n.navAttendance,
                    validAttendances.length.toString(),
                    Icons.calendar_today,
                    Colors.orange,
                  ),
                  _buildStatCard(
                    _l10n.navRecitations,
                    '${validAttendances.length}',
                    Icons.menu_book,
                    Colors.purple,
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 32),
          Text(
            _l10n.dashQuickActions,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildActionButton(_l10n.actionAdd, Icons.person_add, _showAddStudentDialog)),
              const SizedBox(width: 12),
              Expanded(child: _buildActionButton(_l10n.syncEntityPayment, Icons.add_card, _showAddPaymentDialog)),
              const SizedBox(width: 12),
              Expanded(child: _buildActionButton(_l10n.syncEntityAttendance, Icons.check_circle, _showMarkAttendanceDialog)),
            ],
          ),
          const SizedBox(height: 32),
          Text(
            _l10n.dashMyGroups,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          Consumer<ClassProvider>(
            builder: (context, classProvider, _) {
              return _buildGroupsSummaryCard(classProvider);
            },
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _l10n.dashRecentPayments,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              TextButton(
                onPressed: () => setState(() => _selectedTabIndex = 3),
                child: Text(
                  _l10n.dashSeeAll,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Consumer2<StudentProvider, PaymentProvider>(
            builder: (context, studentProvider, paymentProvider, _) {
              final recent = [...paymentProvider.payments]
                ..sort((a, b) => b.date.compareTo(a.date));
              return _buildRecentPaymentsCard(
                  recent.take(4).toList(), studentProvider);
            },
          ),
        ],
      ),
    );
  }

  /// Carte de résumé des groupes : nombre de groupes actifs et taux
  /// d'occupation global, pour combler l'espace vide de la vue d'ensemble
  /// avec une information utile plutôt qu'un simple remplissage visuel.
  Widget _buildGroupsSummaryCard(ClassProvider classProvider) {
    final activeCount = classProvider.activeClassesCount;
    final occupied = classProvider.totalStudentsInClasses;
    final capacity = classProvider.totalCapacity;
    final occupancyRate = capacity > 0 ? (occupied / capacity * 100) : 0.0;

    if (activeCount == 0) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Row(
          children: [
            Icon(Icons.groups_outlined, color: Colors.grey[400], size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                AppLocalizations.of(context).dashNoGroupYet,
                style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[600]),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.groups_rounded, color: AppColors.primary, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context).dashActiveGroups(activeCount),
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  AppLocalizations.of(context).dashSeatsOccupied(occupied, capacity),
                  style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Text(
            '${occupancyRate.toStringAsFixed(0)}%',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  /// Carte listant les derniers paiements enregistrés, avec le nom de
  /// l'élève, le montant et le statut.
  Widget _buildRecentPaymentsCard(
      List<Payment> recentPayments, StudentProvider studentProvider) {
    if (recentPayments.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Row(
          children: [
            Icon(Icons.receipt_long_outlined, color: Colors.grey[400], size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                AppLocalizations.of(context).dashNoPaymentYet,
                style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[600]),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          for (var i = 0; i < recentPayments.length; i++) ...[
            if (i > 0) const Divider(height: 1),
            _buildRecentPaymentRow(recentPayments[i], studentProvider),
          ],
        ],
      ),
    );
  }

  Widget _buildRecentPaymentRow(Payment payment, StudentProvider studentProvider) {
    final student = studentProvider.students
        .where((s) => s.id == payment.studentId)
        .firstOrNull;
    final isPaid = payment.status == PaymentStatus.paid;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(
            isPaid ? Icons.check_circle_rounded : Icons.hourglass_top_rounded,
            color: isPaid ? Colors.green : Colors.orange,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              student?.name ?? AppLocalizations.of(context).commonStudentDeleted,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
          ),
          Text(
            '${payment.amount.toStringAsFixed(0)} $_currency',
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: isPaid ? Colors.green : Colors.orange,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Bouton d'action rapide : occupe toute la largeur que lui donne son
  // Expanded parent (au lieu d'une taille fixe de 70px) pour que les 3
  // boutons restent parfaitement alignés entre eux quelle que soit la
  // largeur de l'écran, plutôt que de dépendre du calcul intrinsèque
  // d'un Wrap.
  //
  // L'action est passée explicitement : elle était auparavant déduite du
  // libellé ('Ajouter', 'Paiement'), ce qui cassait les boutons une fois
  // l'interface traduite (doc/audit.md K8).
  Widget _buildActionButton(String label, IconData icon, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: AppColors.primary, size: 26),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── STUDENTS TAB ──────────────────────────
  /// En-tête commun à un onglet liste : titre, compteur et bouton
  /// "Ajouter" toujours visible (liste vide ou non) — Paiements et
  /// Présences n'avaient aucun moyen d'ajouter un élément directement
  /// depuis leur onglet (seulement via "Actions rapides" sur la vue
  /// d'ensemble), contrairement aux Groupes qui avaient déjà ce bouton.
  Widget _buildTabHeader(String title, String count, VoidCallback onAdd) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: AppColors.surface,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                count,
                style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
          ElevatedButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add, size: 18),
            label: Text(AppLocalizations.of(context).actionAdd),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentsTab() {
    return Consumer<StudentProvider>(
      builder: (context, studentProvider, _) {
        return Column(
          children: [
            _buildTabHeader(
              AppLocalizations.of(context).navStudents,
              AppLocalizations.of(context).dashStudentsCount(studentProvider.students.length),
              _showAddStudentDialog,
            ),
            Expanded(
              child: studentProvider.students.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.people_outline, size: 64, color: Colors.grey[300]),
                          const SizedBox(height: 16),
                          Text(
                            AppLocalizations.of(context).dashNoStudent,
                            style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: studentProvider.students.length,
                      itemBuilder: (context, index) {
                        final student = studentProvider.students[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            onTap: () => _showStudentDetails(student),
                            leading: CircleAvatar(
                              backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                              child: Text(
                                student.name.isNotEmpty
                                    ? student.name[0].toUpperCase()
                                    : '?',
                                style: TextStyle(
                                    color: AppColors.primary, fontWeight: FontWeight.w700),
                              ),
                            ),
                            title: Text(student.name),
                            subtitle:
                                Text(AppLocalizations.of(context).dashPhoneShort(_formatGuineanPhone(student.parentPhone))),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.edit, color: Colors.blue, size: 20),
                                  onPressed: () => _showEditStudentDialog(student),
                                  tooltip: AppLocalizations.of(context).dashEditStudent,
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red, size: 20),
                                  onPressed: () => _showDeleteStudentDialog(student),
                                  tooltip: AppLocalizations.of(context).dashDeleteStudent,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  // ─── PAYMENTS TAB ──────────────────────────
  Widget _buildPaymentsTab() {
    return Consumer2<PaymentProvider, StudentProvider>(
      builder: (context, paymentProvider, studentProvider, _) {
        // Filtrer les paiements pour n'afficher que ceux des élèves existants
        final existingStudentIds = studentProvider.students.map((s) => s.id).toSet();
        final validPayments = paymentProvider.payments
            .where((payment) => existingStudentIds.contains(payment.studentId))
            .toList();

        return Column(
          children: [
            _buildTabHeader(
              AppLocalizations.of(context).navPayments,
              AppLocalizations.of(context).dashPaymentsCount(validPayments.length),
              _showAddPaymentDialog,
            ),
            Expanded(child: _buildPaymentsList(paymentProvider, studentProvider, validPayments)),
          ],
        );
      },
    );
  }

  Widget _buildPaymentsList(PaymentProvider paymentProvider, StudentProvider studentProvider,
      List<Payment> validPayments) {
    if (validPayments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.payments_outlined, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              paymentProvider.payments.isEmpty
                  ? AppLocalizations.of(context).dashNoPayment
                  : AppLocalizations.of(context).dashNoValidPayment,
              style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey),
            ),
            if (paymentProvider.payments.isNotEmpty && validPayments.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  AppLocalizations.of(context).dashPaymentsOfRemoved(paymentProvider.payments.length),
                  style: GoogleFonts.poppins(fontSize: 12, color: Colors.orange),
                ),
              ),
          ],
        ),
      );
    }

    return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: validPayments.length,
          itemBuilder: (context, index) {
            final payment = validPayments[index];
            // Trouver le nom de l'élève (maintenant garanti d'exister)
            final student = studentProvider.students.firstWhere(
                (s) => s.id == payment.studentId);
            final studentName = student.name;

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                onTap: () => _showPaymentDetails(payment, studentName, student),
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: payment.status == PaymentStatus.paid
                        ? Colors.green.withValues(alpha: 0.2)
                        : Colors.orange.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    payment.status == PaymentStatus.paid
                        ? Icons.check_circle
                        : Icons.hourglass_empty,
                    color: payment.status == PaymentStatus.paid
                        ? Colors.green
                        : Colors.orange,
                  ),
                ),
                title: Text(studentName),
                subtitle: Text(payment.date.toString().split(' ')[0]),
                trailing: Text(
                  '${payment.amount} $_currency',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Colors.blue,
                  ),
                ),
              ),
            );
          },
        );
  }

  // ─── ATTENDANCE TAB ────────────────────────
  Widget _buildAttendanceTab() {
    return Consumer2<AttendanceProvider, StudentProvider>(
      builder: (context, attendanceProvider, studentProvider, _) {
        // Filtrer les présences pour n'afficher que celles des élèves existants
        final existingStudentIds = studentProvider.students.map((s) => s.id).toSet();
        final validAttendances = attendanceProvider.attendances
            .where((attendance) => existingStudentIds.contains(attendance.studentId))
            .toList();

        return Column(
          children: [
            _buildTabHeader(
              AppLocalizations.of(context).navAttendance,
              AppLocalizations.of(context).dashAttendancesCount(validAttendances.length),
              _showMarkAttendanceDialog,
            ),
            Expanded(
              child: _buildAttendanceList(attendanceProvider, studentProvider, validAttendances),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAttendanceList(AttendanceProvider attendanceProvider,
      StudentProvider studentProvider, List<Attendance> validAttendances) {
        if (validAttendances.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.calendar_today_outlined,
                    size: 64, color: Colors.grey[300]),
                const SizedBox(height: 16),
                Text(
                  attendanceProvider.attendances.isEmpty 
                      ? AppLocalizations.of(context).dashNoAttendance
                      : AppLocalizations.of(context).dashNoValidAttendance,
                  style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey),
                ),
                if (attendanceProvider.attendances.isNotEmpty && validAttendances.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      AppLocalizations.of(context).dashAttendancesOfRemoved(attendanceProvider.attendances.length),
                      style: GoogleFonts.poppins(fontSize: 12, color: Colors.orange),
                    ),
                  ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: validAttendances.length,
          itemBuilder: (context, index) {
            final attendance = validAttendances[index];
            // Trouver le nom de l'élève (maintenant garanti d'exister)
            final student = studentProvider.students.firstWhere(
                (s) => s.id == attendance.studentId);
            final studentName = student.name;

            // Déterminer le statut et la couleur
            Color statusColor;
            IconData statusIcon;
            String statusText;

            switch (attendance.status) {
              case AttendanceStatus.present:
                statusColor = Colors.green;
                statusIcon = Icons.check_circle;
                statusText = AppLocalizations.of(context).attendancePresent;
              case AttendanceStatus.absent:
                statusColor = Colors.red;
                statusIcon = Icons.cancel;
                statusText = AppLocalizations.of(context).attendanceAbsent;
              case AttendanceStatus.justified:
                statusColor = Colors.blue;
                statusIcon = Icons.event_busy;
                statusText = AppLocalizations.of(context).attendanceJustified;
              case AttendanceStatus.late:
                statusColor = Colors.orange;
                statusIcon = Icons.schedule;
                statusText = AppLocalizations.of(context).attendanceLate;
            }

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                onTap: () => _showAttendanceDetails(
                    attendance, studentName, student, statusText, statusColor),
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    statusIcon,
                    color: statusColor,
                  ),
                ),
                title: Text(studentName),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                        '${attendance.lesson} • ${attendance.date.toString().split(' ')[0]}'),
                    const SizedBox(height: 4),
                    Text(
                      statusText,
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                trailing: Icon(Icons.chevron_right, color: Colors.grey[400]),
              ),
            );
          },
        );
  }

  // ─── REPORTS TAB ───────────────────────────
  Widget _buildReportsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context).dashGenerateReports,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          _buildReportButton(AppLocalizations.of(context).dashWeeklyReport, Icons.date_range,
              () => _showWeeklyReport()),
          const SizedBox(height: 12),
          _buildReportButton(AppLocalizations.of(context).dashMonthlyReport, Icons.calendar_month,
              () => _showMonthlyReport()),
          const SizedBox(height: 12),
          _buildReportButton(
              AppLocalizations.of(context).dashPaymentReport, Icons.money, () => _showPaymentReport()),
          const SizedBox(height: 12),
          _buildReportButton(AppLocalizations.of(context).dashPerformanceReport, Icons.trending_up,
              () => _showPerformanceReport()),
          const SizedBox(height: 12),
          _buildReportButton(AppLocalizations.of(context).dashAttendanceByStudentShort, Icons.person_outline,
              () => _showAttendanceRateReport()),
          const SizedBox(height: 32),
          Text(
            AppLocalizations.of(context).dashExport,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _generateStudentReport,
              icon: const Icon(Icons.download),
              label: Text(AppLocalizations.of(context).dashExportPdf),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportButton(String label, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary, size: 24),
            const SizedBox(width: 12),
            // Expanded (plutôt que Spacer après un Text non contraint) :
            // certains libellés de rapports sont longs ("Taux présence
            // par élève") et débordaient sur les écrans étroits sans
            // cette contrainte.
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  // ─── Add Student Dialog ────────────────────
  void _showAddStudentDialog() {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(AppLocalizations.of(context).dashAddNewStudent),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context).fieldStudentName,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon: const Icon(Icons.person),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: phoneController,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context).fieldParentPhone,
                    hintText: AppLocalizations.of(context).dashPhoneHint,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon: const Icon(Icons.phone),
                  ),
                  keyboardType: TextInputType.phone,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppLocalizations.of(context).actionCancel),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isEmpty ||
                    phoneController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(AppLocalizations.of(context).commonFillAllFields),
                    ),
                  );
                  return;
                }

                // Valider le numéro de téléphone
                if (!_isValidGuineanPhone(phoneController.text)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          AppLocalizations.of(context).commonInvalidPhone),
                      backgroundColor: Colors.orange,
                    ),
                  );
                  return;
                }

                try {
                  final studentProvider = context.read<StudentProvider>();
                  await studentProvider.addStudent(
                    name: nameController.text.trim(),
                    parentPhone: _cleanPhoneNumber(phoneController.text),
                  );

                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(AppLocalizations.of(context).dashStudentAdded),
                        backgroundColor: Colors.green,
                      ),
                    );
                    Navigator.pop(context);
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(AppLocalizations.of(context).commonErrorColon(e.toString())),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              child: Text(AppLocalizations.of(context).actionAdd),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Edit Student Dialog ────────────────────
  void _showEditStudentDialog(dynamic student) {
    final nameController = TextEditingController(text: student.name);
    final phoneController = TextEditingController(text: student.parentPhone);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(AppLocalizations.of(context).dashEditStudent),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context).fieldStudentName,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon: const Icon(Icons.person),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: phoneController,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context).fieldParentPhone,
                    hintText: AppLocalizations.of(context).dashPhoneHint,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon: const Icon(Icons.phone),
                  ),
                  keyboardType: TextInputType.phone,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppLocalizations.of(context).actionCancel),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isEmpty ||
                    phoneController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(AppLocalizations.of(context).commonFillAllFields),
                    ),
                  );
                  return;
                }

                // Valider le numéro de téléphone
                if (!_isValidGuineanPhone(phoneController.text)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          AppLocalizations.of(context).commonInvalidPhone),
                      backgroundColor: Colors.orange,
                    ),
                  );
                  return;
                }

                try {
                  final studentProvider = context.read<StudentProvider>();
                  await studentProvider.updateStudent(
                    studentId: student.id,
                    name: nameController.text.trim(),
                    parentPhone: _cleanPhoneNumber(phoneController.text),
                  );

                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(AppLocalizations.of(context).dashStudentUpdated),
                        backgroundColor: Colors.green,
                      ),
                    );
                    Navigator.pop(context);
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(AppLocalizations.of(context).commonErrorColon(e.toString())),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              child: Text(AppLocalizations.of(context).actionEdit),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Delete Student Dialog ────────────────────
  void _showDeleteStudentDialog(dynamic student) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context).dashArchiveStudentTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppLocalizations.of(context).dashArchiveStudentQuestion),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context).dashNameLine(student.name),
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Text(AppLocalizations.of(context).dashPhoneShort(_formatGuineanPhone(student.parentPhone))),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              AppLocalizations.of(context).dashArchiveStudentBody,
              style: TextStyle(color: Colors.red[700], fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context).actionCancel),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                final studentProvider = context.read<StudentProvider>();
                await studentProvider.removeStudent(student.id);

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(AppLocalizations.of(context).dashStudentArchived),
                      backgroundColor: Colors.green,
                    ),
                  );
                  Navigator.pop(context);
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(AppLocalizations.of(context).commonErrorColon(e.toString())),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: Text(AppLocalizations.of(context).actionArchive),
          ),
        ],
      ),
    );
  }

  // ─── Add Payment Dialog ────────────────────
  // ─── Payment Dialog ───────────────────────
  /// Libellé affiché pour un mois (ex. "Août 2026"), dans la langue de
  /// l'interface (doc/audit.md K8).
  String _formatMonthLabel(DateTime month) {
    final label =
        DateFormat.yMMMM(Localizations.localeOf(context).toString()).format(month);
    return label.isEmpty ? label : label[0].toUpperCase() + label.substring(1);
  }

  /// Les 12 derniers mois (dont le mois en cours), premier jour de chaque
  /// mois. Renvoie de vraies dates — et non de simples libellés — pour que
  /// le mois choisi dans le formulaire de paiement soit réellement celui
  /// envoyé au serveur (voir _submitPayment : auparavant le paiement était
  /// toujours daté d'aujourd'hui quel que soit le mois sélectionné, rendant
  /// impossible l'enregistrement d'un paiement pour un autre mois que le
  /// mois en cours).
  List<DateTime> _getMonthsList() {
    final now = DateTime.now();
    return List.generate(12, (i) => DateTime(now.year, now.month - i, 1));
  }

  void _showAddPaymentDialog() {
    String? selectedStudentId;
    final amountController = TextEditingController();
    String selectedStatus = 'paid';
    final now = DateTime.now();
    DateTime selectedMonth = DateTime(now.year, now.month, 1);
    DateTime selectedPaidDay = now;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Consumer<StudentProvider>(
          builder: (context, studentProvider, _) {
            if (studentProvider.students.isEmpty) {
              return AlertDialog(
                title: Text(AppLocalizations.of(context).dashAddPayment),
                content: Text(
                    AppLocalizations.of(context).dashNoStudentAddFirst),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(AppLocalizations.of(context).actionClose),
                  ),
                ],
              );
            }

            return AlertDialog(
              title: Text(AppLocalizations.of(context).dashRecordPayment),
              contentPadding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      initialValue: selectedStudentId,
                      hint: Text(AppLocalizations.of(context).dashSelectStudent),
                      isExpanded: true,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: const Icon(Icons.person),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      items: studentProvider.students.map((student) {
                        return DropdownMenuItem<String>(
                          value: student.id,
                          child: Text(student.name),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() => selectedStudentId = value);
                      },
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: amountController,
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context).dashAmountWithCurrency(_currency),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: const Icon(Icons.attach_money),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<DateTime>(
                      initialValue: selectedMonth,
                      isExpanded: true,
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context).fieldMonth,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: const Icon(Icons.calendar_month),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      items: _getMonthsList().map((month) {
                        return DropdownMenuItem<DateTime>(
                          value: month,
                          child: Text(_formatMonthLabel(month)),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => selectedMonth = value);
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: selectedStatus,
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context).fieldStatus,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: const Icon(Icons.check_circle),
                      ),
                      items: [
                        DropdownMenuItem(value: 'paid', child: Text(AppLocalizations.of(context).paymentPaid)),
                        DropdownMenuItem(
                            value: 'unpaid', child: Text(AppLocalizations.of(context).paymentUnpaid)),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => selectedStatus = value);
                        }
                      },
                    ),
                    if (selectedStatus == 'paid') ...[
                      const SizedBox(height: 16),
                      InkWell(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: selectedPaidDay,
                            firstDate: DateTime(2020),
                            lastDate: DateTime(now.year + 1),
                          );
                          if (picked != null) {
                            setState(() => selectedPaidDay = picked);
                          }
                        },
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: AppLocalizations.of(context).dashPaymentDay,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            prefixIcon: const Icon(Icons.event_available_outlined),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                          ),
                          child: Text(
                            '${selectedPaidDay.day.toString().padLeft(2, '0')}/'
                            '${selectedPaidDay.month.toString().padLeft(2, '0')}/'
                            '${selectedPaidDay.year}',
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(AppLocalizations.of(context).actionCancel),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (selectedStudentId == null ||
                        amountController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(AppLocalizations.of(context).commonFillAllFields),
                        ),
                      );
                      return;
                    }

                    // Le clavier numérique en français affiche souvent une
                    // virgule plutôt qu'un point pour les décimales.
                    final amount = double.tryParse(
                        amountController.text.replaceAll(',', '.'));
                    if (amount == null || amount <= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(AppLocalizations.of(context).dashInvalidAmount),
                        ),
                      );
                      return;
                    }

                    await _submitPayment(
                      dialogContext: context,
                      studentId: selectedStudentId!,
                      amount: amount,
                      status: selectedStatus == 'paid'
                          ? PaymentStatus.paid
                          : PaymentStatus.unpaid,
                      month: selectedMonth,
                      paidAt: selectedStatus == 'paid' ? selectedPaidDay : null,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                  ),
                  child: Text(AppLocalizations.of(context).actionSave),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  /// Enregistre un paiement, avec confirmation explicite si le serveur
  /// détecte qu'un paiement payé existe déjà pour cet élève ce mois-ci
  /// (CDC 8.7). Sans ce circuit, ce refus légitime du serveur remontait
  /// comme une erreur brute sans aucun moyen de la résoudre — l'utilisateur
  /// ne pouvait tout simplement pas enregistrer le paiement.
  Future<void> _submitPayment({
    required BuildContext dialogContext,
    required String studentId,
    required double amount,
    required PaymentStatus status,
    required DateTime month,
    DateTime? paidAt,
    bool confirmDuplicate = false,
  }) async {
    try {
      final paymentProvider = dialogContext.read<PaymentProvider>();
      final savedPayment = await paymentProvider.addPayment(
        studentId: studentId,
        amount: amount,
        status: status,
        date: month,
        paidAt: paidAt,
        confirmDuplicate: confirmDuplicate,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).dashPaymentRecorded(_formatMonthLabel(month))),
          backgroundColor: Colors.green,
        ),
      );
      if (dialogContext.mounted) {
        Navigator.pop(dialogContext); // Ferme le formulaire de paiement
      }

      // Reçu PDF disponible seulement pour un paiement marqué payé
      // (CDC section 8.7 / 21).
      if (savedPayment.status == PaymentStatus.paid) {
        _offerPaymentReceipt(savedPayment);
      }
    } on PaymentDuplicateException catch (e) {
      if (!mounted) return;
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: Text(AppLocalizations.of(context).dashPaymentAlreadyRecorded),
          content: Text(e.message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(AppLocalizations.of(context).actionCancel),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              child: Text(AppLocalizations.of(context).dashConfirmAnyway),
            ),
          ],
        ),
      );

      if (confirmed == true && dialogContext.mounted) {
        await _submitPayment(
          dialogContext: dialogContext,
          studentId: studentId,
          amount: amount,
          status: status,
          month: month,
          paidAt: paidAt,
          confirmDuplicate: true,
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).commonErrorColon(e.toString())),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ─── Mark Attendance Dialog ────────────────
  void _showMarkAttendanceDialog() {
    String? selectedStudentId;
    String? selectedStatus = 'present';
    final lessonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Consumer<StudentProvider>(
          builder: (context, studentProvider, _) {
            if (studentProvider.students.isEmpty) {
              return AlertDialog(
                title: Text(AppLocalizations.of(context).dashMarkAttendance),
                content: Text(
                    AppLocalizations.of(context).dashNoStudentAddFirst),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(AppLocalizations.of(context).actionClose),
                  ),
                ],
              );
            }

            return AlertDialog(
              title: Text(AppLocalizations.of(context).dashMarkAttendance),
              contentPadding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      initialValue: selectedStudentId,
                      hint: Text(AppLocalizations.of(context).dashSelectStudent),
                      isExpanded: true,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: const Icon(Icons.person),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      items: studentProvider.students.map((student) {
                        return DropdownMenuItem<String>(
                          value: student.id,
                          child: Text(student.name),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() => selectedStudentId = value);
                      },
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: lessonController,
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context).dashLessonField,
                        hintText: AppLocalizations.of(context).dashLessonHint,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: const Icon(Icons.book),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: selectedStatus,
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context).fieldStatus,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: const Icon(Icons.check_circle),
                      ),
                      items: [
                        DropdownMenuItem(
                          value: 'present',
                          child: Row(
                            children: [
                              Icon(Icons.check_circle,
                                  color: Colors.green, size: 20),
                              SizedBox(width: 8),
                              Text(AppLocalizations.of(context).attendancePresent),
                            ],
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'absent',
                          child: Row(
                            children: [
                              Icon(Icons.close, color: Colors.red, size: 20),
                              SizedBox(width: 8),
                              Text(AppLocalizations.of(context).attendanceAbsent),
                            ],
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'late',
                          child: Row(
                            children: [
                              Icon(Icons.schedule,
                                  color: Colors.orange, size: 20),
                              SizedBox(width: 8),
                              Text(AppLocalizations.of(context).attendanceLate),
                            ],
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'justified',
                          child: Row(
                            children: [
                              Icon(Icons.event_busy,
                                  color: Colors.blue, size: 20),
                              SizedBox(width: 8),
                              Text(AppLocalizations.of(context).attendanceJustified),
                            ],
                          ),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => selectedStatus = value);
                        }
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(AppLocalizations.of(context).actionCancel),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (selectedStudentId == null || selectedStatus == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              AppLocalizations.of(context).dashSelectStudentAndStatus),
                        ),
                      );
                      return;
                    }

                    try {
                      final authService = context.read<AuthService>();
                      final attendanceProvider =
                          context.read<AttendanceProvider>();
                      final markazId = authService.currentMarkazId ?? '';
                      final lesson = lessonController.text.isNotEmpty
                          ? lessonController.text.trim()
                          : AppLocalizations.of(context).dashNoLessonDefault;

                      if (selectedStatus == 'present') {
                        await attendanceProvider.markPresent(
                          studentId: selectedStudentId!,
                          markazId: markazId,
                          lesson: lesson,
                        );
                      } else if (selectedStatus == 'absent') {
                        await attendanceProvider.markAbsent(
                          studentId: selectedStudentId!,
                          markazId: markazId,
                          lesson: lesson,
                        );
                      } else if (selectedStatus == 'late') {
                        await attendanceProvider.markLate(
                          studentId: selectedStudentId!,
                          markazId: markazId,
                          lesson: lesson,
                        );
                      } else if (selectedStatus == 'justified') {
                        await attendanceProvider.markJustified(
                          studentId: selectedStudentId!,
                          markazId: markazId,
                          lesson: lesson,
                        );
                      }

                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(AppLocalizations.of(context).dashAttendanceRecorded),
                            backgroundColor: Colors.green,
                          ),
                        );
                        Navigator.pop(context);
                      }
                    } on AttendanceAlreadyRecordedException catch (e) {
                      // H7 : une seule présence par élève et par jour côté
                      // serveur — on propose de corriger l'existante.
                      if (!context.mounted) return;
                      final lesson = lessonController.text.isNotEmpty
                          ? lessonController.text.trim()
                          : AppLocalizations.of(context).dashNoLessonDefault;
                      final replaced = await _confirmReplaceAttendance(
                        context,
                        e.existing,
                        _attendanceStatusFromKey(selectedStatus!),
                        lesson,
                      );
                      if (replaced && context.mounted) {
                        Navigator.pop(context);
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(AppLocalizations.of(context).commonErrorColon(e.toString())),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                  ),
                  child: Text(AppLocalizations.of(context).actionSave),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // ─── Weekly Report ────────────────────────
  void _showWeeklyReport() {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));

    showDialog(
      context: context,
      builder: (context) => Consumer<AttendanceProvider>(
        builder: (context, attendanceProvider, _) {
          final weeklyAttendances = attendanceProvider.attendances
              .where((a) =>
                  a.date.isAfter(startOfWeek) &&
                  a.date.isBefore(endOfWeek.add(const Duration(days: 1))))
              .toList();

          final present = weeklyAttendances
              .where((a) => a.status == AttendanceStatus.present)
              .length;
          final absent = weeklyAttendances
              .where((a) => a.status.isAbsence)
              .length;
          final late = weeklyAttendances
              .where((a) => a.status == AttendanceStatus.late)
              .length;

          return AlertDialog(
            title: Text(AppLocalizations.of(context).dashWeeklyReport),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                      AppLocalizations.of(context).dashWeekRange(startOfWeek.day, startOfWeek.month, endOfWeek.day, endOfWeek.month),
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 24),
                  _buildReportStat(AppLocalizations.of(context).dashPresentPlural, '$present', Colors.green),
                  const SizedBox(height: 12),
                  _buildReportStat(AppLocalizations.of(context).dashAbsentPlural, '$absent', Colors.red),
                  const SizedBox(height: 12),
                  _buildReportStat(AppLocalizations.of(context).dashLatePlural, '$late', Colors.orange),
                  const SizedBox(height: 24),
                  Text(AppLocalizations.of(context).dashTotalSessionsWeek(weeklyAttendances.length),
                      style: GoogleFonts.poppins(fontSize: 14)),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(AppLocalizations.of(context).actionClose),
              ),
            ],
          );
        },
      ),
    );
  }

  // ─── Monthly Report ───────────────────────
  void _showMonthlyReport() {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);

    showDialog(
      context: context,
      builder: (context) => Consumer<AttendanceProvider>(
        builder: (context, attendanceProvider, _) {
          final monthlyAttendances = attendanceProvider.attendances
              .where((a) =>
                  a.date.isAfter(startOfMonth) &&
                  a.date.isBefore(endOfMonth.add(const Duration(days: 1))))
              .toList();

          final present = monthlyAttendances
              .where((a) => a.status == AttendanceStatus.present)
              .length;
          final absent = monthlyAttendances
              .where((a) => a.status.isAbsence)
              .length;
          final late = monthlyAttendances
              .where((a) => a.status == AttendanceStatus.late)
              .length;

          return AlertDialog(
            title: Text(AppLocalizations.of(context).dashMonthlyReport),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(AppLocalizations.of(context).dashMonthLine(startOfMonth.month, startOfMonth.year),
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 24),
                  _buildReportStat(AppLocalizations.of(context).dashPresentPlural, '$present', Colors.green),
                  const SizedBox(height: 12),
                  _buildReportStat(AppLocalizations.of(context).dashAbsentPlural, '$absent', Colors.red),
                  const SizedBox(height: 12),
                  _buildReportStat(AppLocalizations.of(context).dashLatePlural, '$late', Colors.orange),
                  const SizedBox(height: 24),
                  Text(AppLocalizations.of(context).dashTotalSessionsMonth(monthlyAttendances.length),
                      style: GoogleFonts.poppins(fontSize: 14)),
                  const SizedBox(height: 16),
                  Text(
                    AppLocalizations.of(context).dashAttendanceRateLine(monthlyAttendances.isNotEmpty ? ((present / monthlyAttendances.length) * 100).toStringAsFixed(1) : 0),
                    style: GoogleFonts.poppins(
                        fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(AppLocalizations.of(context).actionClose),
              ),
            ],
          );
        },
      ),
    );
  }

  AttendanceStatus _attendanceStatusFromKey(String key) {
    switch (key) {
      case 'absent':
        return AttendanceStatus.absent;
      case 'late':
        return AttendanceStatus.late;
      case 'justified':
        return AttendanceStatus.justified;
      default:
        return AttendanceStatus.present;
    }
  }

  /// H7 : l'élève a déjà une présence aujourd'hui. Le serveur n'en garde
  /// qu'une par jour ; plutôt que de l'écraser sans prévenir, on montre
  /// l'existante et on propose de la remplacer (PUT sur le même
  /// enregistrement). Retourne true si le remplacement a eu lieu.
  Future<bool> _confirmReplaceAttendance(
    BuildContext context,
    Attendance existing,
    AttendanceStatus newStatus,
    String newLesson,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(AppLocalizations.of(context).dashAttendanceAlreadyRecorded),
        content: Text(
          AppLocalizations.of(context).dashReplaceAttendanceBody(_attendanceStatusLabel(existing.status), existing.lesson, _attendanceStatusLabel(newStatus), newLesson),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(AppLocalizations.of(context).actionCancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(AppLocalizations.of(context).actionReplace),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return false;

    try {
      await context.read<AttendanceProvider>().updateAttendance(
            attendanceId: existing.id,
            status: newStatus,
            lesson: newLesson,
          );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).dashAttendanceReplaced),
            backgroundColor: Colors.green,
          ),
        );
      }
      return true;
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).commonErrorColon(e.toString())),
            backgroundColor: Colors.red,
          ),
        );
      }
      return false;
    }
  }

  // ─── Payment Report ───────────────────────
  void _showPaymentReport() {
    showDialog(
      context: context,
      builder: (context) => Consumer2<StudentProvider, PaymentProvider>(
        builder: (context, studentProvider, paymentProvider, _) {
          double totalPaid = 0;
          double totalUnpaid = 0;

          for (var payment in paymentProvider.payments) {
            if (payment.status == PaymentStatus.paid) {
              totalPaid += payment.amount;
            } else {
              totalUnpaid += payment.amount;
            }
          }

          return AlertDialog(
            title: Text(AppLocalizations.of(context).dashPaymentReport),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildReportStat(AppLocalizations.of(context).statTotalPaid,
                      '${totalPaid.toStringAsFixed(2)} $_currency', Colors.green),
                  const SizedBox(height: 12),
                  _buildReportStat(AppLocalizations.of(context).dashTotalPending,
                      '${totalUnpaid.toStringAsFixed(2)} $_currency', Colors.orange),
                  const SizedBox(height: 12),
                  _buildReportStat(
                      AppLocalizations.of(context).dashGrandTotal,
                      '${(totalPaid + totalUnpaid).toStringAsFixed(2)} $_currency',
                      AppColors.primary),
                  const SizedBox(height: 24),
                  Text(
                      AppLocalizations.of(context).dashPaymentsNumber(paymentProvider.payments.length),
                      style: GoogleFonts.poppins(fontSize: 14)),
                  const SizedBox(height: 12),
                  Text(AppLocalizations.of(context).dashActiveStudents(studentProvider.students.length),
                      style: GoogleFonts.poppins(fontSize: 14)),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(AppLocalizations.of(context).actionClose),
              ),
            ],
          );
        },
      ),
    );
  }

  // ─── Performance Report ────────────────────
  void _showPerformanceReport() {
    showDialog(
      context: context,
      builder: (context) =>
          Consumer3<StudentProvider, AttendanceProvider, PaymentProvider>(
        builder:
            (context, studentProvider, attendanceProvider, paymentProvider, _) {
          final totalStudents = studentProvider.students.length;
          final totalAttendance = attendanceProvider.attendances.length;
          final presentCount = attendanceProvider.attendances
              .where((a) => a.status == AttendanceStatus.present)
              .length;
          final paidCount = paymentProvider.payments
              .where((p) => p.status == PaymentStatus.paid)
              .length;

          final attendanceRate = totalAttendance > 0
              ? ((presentCount / totalAttendance) * 100)
              : 0.0;
          final paymentRate =
              totalStudents > 0 ? ((paidCount / totalStudents) * 100) : 0.0;

          return AlertDialog(
            title: Text(AppLocalizations.of(context).dashPerformanceReport),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(AppLocalizations.of(context).dashManagementMetrics,
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  _buildPerformanceBar(
                      AppLocalizations.of(context).statAttendanceRateFull, attendanceRate, Colors.green),
                  const SizedBox(height: 16),
                  _buildPerformanceBar(
                      AppLocalizations.of(context).statPaymentRateFull, paymentRate, Colors.blue),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(AppLocalizations.of(context).dashSummary,
                            style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        Text(AppLocalizations.of(context).dashSummaryStudents(totalStudents)),
                        Text(AppLocalizations.of(context).dashSummarySessions(totalAttendance)),
                        Text(
                            AppLocalizations.of(context).dashSummaryPayments(paymentProvider.payments.length)),
                        Text(AppLocalizations.of(context).dashSummaryPaid(paidCount)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(AppLocalizations.of(context).actionClose),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showPaymentDetails(
      dynamic payment, String studentName, dynamic student) {
    final isPaid = payment.status == PaymentStatus.paid;
    final formattedDate = payment.date.toString().split(' ')[0];
    final studentPhone = student?.parentPhone ?? AppLocalizations.of(context).commonNotAvailable;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context).dashPaymentDetails),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // En-tête avec nom de l'élève
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context).fieldStudent,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      studentName,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Montant
              _buildPaymentDetailRow(
                AppLocalizations.of(context).fieldAmount,
                '${payment.amount} $_currency',
                Colors.green,
              ),
              const SizedBox(height: 12),

              // Statut
              _buildPaymentDetailRow(
                AppLocalizations.of(context).fieldStatus,
                isPaid
                    ? AppLocalizations.of(context).paymentPaid
                    : AppLocalizations.of(context).paymentPending,
                isPaid ? Colors.green : Colors.orange,
              ),
              const SizedBox(height: 12),

              // Date
              _buildPaymentDetailRow(
                AppLocalizations.of(context).dashPaymentDate,
                formattedDate,
                Colors.purple,
              ),
              const SizedBox(height: 12),

              // Téléphone de l'élève/parent
              _buildPaymentDetailRow(
                AppLocalizations.of(context).fieldParentPhone,
                studentPhone,
                Colors.grey[700]!,
              ),
              const SizedBox(height: 16),

              // Identifiant du paiement
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context).dashPaymentId,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    SelectableText(
                      payment.id,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          if (!isPaid)
            ElevatedButton(
              onPressed: () async {
                // Bouton auparavant factice : il affichait un message de
                // succès sans rien enregistrer nulle part (ni API, ni
                // cache local) — le paiement restait "en attente" partout
                // dans l'app malgré le message affiché.
                final paymentProvider = context.read<PaymentProvider>();
                try {
                  final updated = await paymentProvider.markAsPaid(payment.id);
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(AppLocalizations.of(context).dashPaymentMarkedPaid),
                      backgroundColor: Colors.green,
                    ),
                  );
                  Navigator.pop(context);
                  _offerPaymentReceipt(updated);
                } catch (e) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(AppLocalizations.of(context).commonErrorColon(e.toString())),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
              child: Text(AppLocalizations.of(context).dashMarkAsPaid),
            ),
          // Auparavant, le reçu n'était proposé qu'une seule fois, juste
          // après l'enregistrement du paiement — si on fermait cette
          // fenêtre sans télécharger/partager, il n'y avait plus aucun
          // moyen d'y accéder à nouveau depuis l'onglet Paiements.
          if (isPaid)
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                _offerPaymentReceipt(payment);
              },
              icon: const Icon(Icons.receipt_long, size: 18),
              label: Text(AppLocalizations.of(context).dashReceipt),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
            ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context).actionClose),
          ),
        ],
      ),
    );
  }

  void _showAttendanceDetails(dynamic attendance, String studentName,
      dynamic student, String statusText, Color statusColor) {
    final studentPhone = student?.parentPhone ?? AppLocalizations.of(context).commonNotAvailable;
    final formattedDate = attendance.date.toString().split(' ')[0];
    final lesson = attendance.lesson ?? AppLocalizations.of(context).commonNotSpecified;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context).dashAttendanceDetails),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // En-tête avec nom de l'élève
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context).fieldStudent,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      studentName,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Leçon/Cours
              _buildAttendanceDetailRow(
                AppLocalizations.of(context).fieldLesson,
                lesson,
                Colors.purple,
              ),
              const SizedBox(height: 12),

              // Statut
              _buildAttendanceDetailRow(
                AppLocalizations.of(context).fieldStatus,
                statusText,
                statusColor,
              ),
              const SizedBox(height: 12),

              // Date
              _buildAttendanceDetailRow(
                AppLocalizations.of(context).fieldDate,
                formattedDate,
                Colors.green,
              ),
              const SizedBox(height: 12),

              // Téléphone du parent
              _buildAttendanceDetailRow(
                AppLocalizations.of(context).fieldParentPhone,
                _formatGuineanPhone(studentPhone),
                Colors.grey[700]!,
              ),
              const SizedBox(height: 16),

              // ID de la présence
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context).dashAttendanceId,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    SelectableText(
                      attendance.id,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context).actionClose),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _showEditAttendanceDialog(attendance as Attendance, studentName);
            },
            icon: const Icon(Icons.edit_outlined, size: 18),
            label: Text(AppLocalizations.of(context).actionEdit),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
          ),
        ],
      ),
    );
  }

  /// Corrige le statut/la leçon d'une présence déjà enregistrée (demande
  /// utilisateur — jusqu'ici, seule la création était possible, aucun moyen
  /// de rectifier une erreur de saisie).
  void _showEditAttendanceDialog(Attendance attendance, String studentName) {
    AttendanceStatus selectedStatus = attendance.status;
    final lessonController = TextEditingController(text: attendance.lesson);

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setState) => AlertDialog(
          title: Text(AppLocalizations.of(context).dashEditAttendance),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  studentName,
                  style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<AttendanceStatus>(
                  initialValue: selectedStatus,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context).fieldStatus,
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    DropdownMenuItem(value: AttendanceStatus.present, child: Text(AppLocalizations.of(context).attendancePresent)),
                    DropdownMenuItem(value: AttendanceStatus.absent, child: Text(AppLocalizations.of(context).attendanceAbsent)),
                    DropdownMenuItem(value: AttendanceStatus.late, child: Text(AppLocalizations.of(context).attendanceLate)),
                    DropdownMenuItem(value: AttendanceStatus.justified, child: Text(AppLocalizations.of(context).attendanceJustified)),
                  ],
                  onChanged: (value) {
                    if (value != null) setState(() => selectedStatus = value);
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: lessonController,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context).fieldLesson,
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(AppLocalizations.of(context).actionCancel),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  await context.read<AttendanceProvider>().updateAttendance(
                        attendanceId: attendance.id,
                        status: selectedStatus,
                        lesson: lessonController.text,
                      );
                  if (dialogContext.mounted) Navigator.pop(dialogContext);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(AppLocalizations.of(context).dashAttendanceCorrected),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (dialogContext.mounted) {
                    ScaffoldMessenger.of(dialogContext).showSnackBar(
                      SnackBar(content: Text(AppLocalizations.of(dialogContext).commonErrorColon(e)), backgroundColor: Colors.red),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              child: Text(AppLocalizations.of(context).actionSave),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceDetailRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: Colors.grey[600],
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            value,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ),
      ],
    );
  }

  void _showStudentDetails(dynamic student) {
    showDialog(
      context: context,
      builder: (context) => Consumer2<PaymentProvider, AttendanceProvider>(
        builder: (context, paymentProvider, attendanceProvider, _) {
          // Récupérer les paiements de cet élève
          final studentPayments = paymentProvider.payments
              .where((p) => p.studentId == student.id)
              .toList();

          final paidPayments = studentPayments
              .where((p) => p.status == PaymentStatus.paid)
              .length;

          final totalPayments =
              studentPayments.fold<double>(0, (sum, p) => sum + p.amount);

          final paidAmount = studentPayments
              .where((p) => p.status == PaymentStatus.paid)
              .fold<double>(0, (sum, p) => sum + p.amount);

          // Récupérer les présences de cet élève
          final studentAttendances = attendanceProvider.attendances
              .where((a) => a.studentId == student.id)
              .toList();

          final presentCount = studentAttendances
              .where((a) => a.status == AttendanceStatus.present)
              .length;

          final absentCount = studentAttendances
              .where((a) => a.status.isAbsence)
              .length;

          final lateCount = studentAttendances
              .where((a) => a.status == AttendanceStatus.late)
              .length;

          final attendanceRate = studentAttendances.isNotEmpty
              ? ((presentCount / studentAttendances.length) * 100)
              : 0.0;

          return AlertDialog(
            title: Text(AppLocalizations.of(context).dashStudentProfile),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // En-tête avec le nom
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border:
                          Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalizations.of(context).fieldStudentName,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          student.name,
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Contact
                  Text(
                    AppLocalizations.of(context).fieldContact,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildStudentDetailRow(
                    AppLocalizations.of(context).fieldPhone,
                    _formatGuineanPhone(student.parentPhone),
                    Colors.blue,
                  ),
                  const SizedBox(height: 16),

                  // Statistiques des paiements
                  Text(
                    AppLocalizations.of(context).navPayments,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildStudentDetailRow(
                    AppLocalizations.of(context).statTotalPaid,
                    '$paidAmount $_currency',
                    Colors.green,
                  ),
                  const SizedBox(height: 8),
                  _buildStudentDetailRow(
                    AppLocalizations.of(context).dashTotalPending,
                    '${totalPayments - paidAmount} $_currency',
                    Colors.orange,
                  ),
                  const SizedBox(height: 8),
                  _buildStudentDetailRow(
                    AppLocalizations.of(context).dashPaidPayments,
                    '$paidPayments/${studentPayments.length}',
                    Colors.purple,
                  ),
                  const SizedBox(height: 16),

                  // Statistiques de présence
                  Text(
                    AppLocalizations.of(context).syncEntityAttendance,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildStudentDetailRow(
                    AppLocalizations.of(context).statAttendanceRateFull,
                    '${attendanceRate.toStringAsFixed(1)}%',
                    attendanceRate >= 80
                        ? Colors.green
                        : attendanceRate >= 60
                            ? Colors.orange
                            : Colors.red,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: _buildAttendanceStatBadge(
                          AppLocalizations.of(context).attendancePresent,
                          '$presentCount',
                          Colors.green,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildAttendanceStatBadge(
                          AppLocalizations.of(context).attendanceAbsent,
                          '$absentCount',
                          Colors.red,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildAttendanceStatBadge(
                          AppLocalizations.of(context).attendanceLate,
                          '$lateCount',
                          Colors.orange,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // ID de l'élève
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalizations.of(context).dashStudentId,
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 4),
                        SelectableText(
                          student.id,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(AppLocalizations.of(context).actionClose),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _showEditStudentDialog(student);
                },
                icon: const Icon(Icons.edit, size: 18),
                label: Text(AppLocalizations.of(context).actionEdit),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _showDeleteStudentDialog(student);
                },
                icon: const Icon(Icons.delete, size: 18),
                label: Text(AppLocalizations.of(context).actionDelete),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStudentDetailRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.grey[600],
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentDetailRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: Colors.grey[600],
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            value,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ),
      ],
    );
  }

  void _showAttendanceRateReport() {
    showDialog(
      context: context,
      builder: (context) => Consumer2<StudentProvider, AttendanceProvider>(
        builder: (context, studentProvider, attendanceProvider, _) {
          final students = studentProvider.students;

          return AlertDialog(
            title: Text(AppLocalizations.of(context).dashAttendanceByStudent),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (students.isEmpty)
                    Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(AppLocalizations.of(context).dashNoStudent),
                    )
                  else
                    ...students.map((student) {
                      // Récupérer toutes les présences de cet élève
                      final studentAttendances = attendanceProvider.attendances
                          .where((a) => a.studentId == student.id)
                          .toList();

                      // Calculer les stats de la semaine actuelle
                      final now = DateTime.now();
                      final weekStart =
                          now.subtract(Duration(days: now.weekday - 1));
                      final weekEnd = weekStart.add(const Duration(days: 6));

                      final weekAttendances = studentAttendances
                          .where((a) =>
                              a.date.isAfter(weekStart) &&
                              a.date.isBefore(
                                  weekEnd.add(const Duration(days: 1))))
                          .toList();

                      final weekPresent = weekAttendances
                          .where((a) => a.status == AttendanceStatus.present)
                          .length;

                      // Calculer les stats du mois actuel
                      final monthStart = DateTime(now.year, now.month, 1);
                      final monthEnd = DateTime(now.year, now.month + 1, 1)
                          .subtract(const Duration(days: 1));

                      final monthAttendances = studentAttendances
                          .where((a) =>
                              a.date.isAfter(monthStart) &&
                              a.date.isBefore(
                                  monthEnd.add(const Duration(days: 1))))
                          .toList();

                      final monthPresent = monthAttendances
                          .where((a) => a.status == AttendanceStatus.present)
                          .length;

                      final monthAbsent = monthAttendances
                          .where((a) => a.status.isAbsence)
                          .length;

                      final monthLate = monthAttendances
                          .where((a) => a.status == AttendanceStatus.late)
                          .length;

                      // Calculer les taux pour la semaine
                      final weekAbsent = weekAttendances
                          .where((a) => a.status.isAbsence)
                          .length;

                      final weekLate = weekAttendances
                          .where((a) => a.status == AttendanceStatus.late)
                          .length;

                      final weekPresentRate = weekAttendances.isNotEmpty
                          ? ((weekPresent / weekAttendances.length) * 100)
                          : 0.0;
                      final weekAbsentRate = weekAttendances.isNotEmpty
                          ? ((weekAbsent / weekAttendances.length) * 100)
                          : 0.0;
                      final weekLateRate = weekAttendances.isNotEmpty
                          ? ((weekLate / weekAttendances.length) * 100)
                          : 0.0;

                      // Calculer les taux pour le mois
                      final monthPresentRate = monthAttendances.isNotEmpty
                          ? ((monthPresent / monthAttendances.length) * 100)
                          : 0.0;
                      final monthAbsentRate = monthAttendances.isNotEmpty
                          ? ((monthAbsent / monthAttendances.length) * 100)
                          : 0.0;
                      final monthLateRate = monthAttendances.isNotEmpty
                          ? ((monthLate / monthAttendances.length) * 100)
                          : 0.0;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                student.name,
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 12),
                              // Cette semaine
                              Text(
                                AppLocalizations.of(context).dashThisWeekSessions(weekAttendances.length),
                                style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey[700]),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  _buildAttendanceStatBadge(
                                    AppLocalizations.of(context).attendancePresent,
                                    '${weekPresentRate.toStringAsFixed(1)}%',
                                    Colors.green,
                                  ),
                                  _buildAttendanceStatBadge(
                                    AppLocalizations.of(context).attendanceAbsent,
                                    '${weekAbsentRate.toStringAsFixed(1)}%',
                                    Colors.red,
                                  ),
                                  _buildAttendanceStatBadge(
                                    AppLocalizations.of(context).attendanceLate,
                                    '${weekLateRate.toStringAsFixed(1)}%',
                                    Colors.orange,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              // Ce mois
                              Text(
                                AppLocalizations.of(context).dashThisMonthSessions(monthAttendances.length),
                                style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey[700]),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  _buildAttendanceStatBadge(
                                    AppLocalizations.of(context).attendancePresent,
                                    '${monthPresentRate.toStringAsFixed(1)}%',
                                    Colors.green,
                                  ),
                                  _buildAttendanceStatBadge(
                                    AppLocalizations.of(context).attendanceAbsent,
                                    '${monthAbsentRate.toStringAsFixed(1)}%',
                                    Colors.red,
                                  ),
                                  _buildAttendanceStatBadge(
                                    AppLocalizations.of(context).attendanceLate,
                                    '${monthLateRate.toStringAsFixed(1)}%',
                                    Colors.orange,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    })
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(AppLocalizations.of(context).actionClose),
              ),
            ],
          );
        },
      ),
    );
  }

  // ─── Report Helper Widgets ────────────────
  Widget _buildReportStat(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Expanded : un montant formaté ("1 234 567,00 FGN") est bien plus
        // long qu'un simple nombre de sessions — sans contrainte, la ligne
        // débordait sur le rapport des paiements.
        Expanded(
          child: Text(label, style: GoogleFonts.poppins(fontSize: 14)),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              value,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPerformanceBar(String label, double percentage, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: GoogleFonts.poppins(fontSize: 14)),
            Text('${percentage.toStringAsFixed(1)}%',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: (percentage / 100).clamp(0, 1),
            minHeight: 8,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }

  Widget _buildAttendanceStatBadge(
      String label, String percentage, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              percentage,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── GROUPS TAB ───────────────────────────
  Widget _buildGroupsTab() {
    return Consumer<ClassProvider>(
      builder: (context, classProvider, child) {
        return RefreshIndicator(
          onRefresh: () async {
            await classProvider.loadClasses();
          },
          child: Column(
            children: [
              // En-tête avec bouton d'ajout
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                color: AppColors.surface,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalizations.of(context).navGroups,
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          AppLocalizations.of(context).dashGroupsCount(classProvider.classes.length),
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    ElevatedButton.icon(
                      onPressed: _showAddClassDialog,
                      icon: const Icon(Icons.add, size: 18),
                      label: Text(AppLocalizations.of(context).actionAdd),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Liste des classes
              Expanded(
                child: classProvider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : classProvider.classes.isEmpty
                        ? _buildEmptyClassesState()
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: classProvider.classes.length,
                            itemBuilder: (context, index) {
                              final classModel = classProvider.classes[index];
                              return _buildClassCard(classModel, classProvider);
                            },
                          ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyClassesState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.class_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context).dashNoGroup,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context).dashCreateFirstGroup,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _showAddClassDialog,
            icon: const Icon(Icons.add),
            label: Text(AppLocalizations.of(context).dashCreateGroup),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClassCard(ClassModel classModel, ClassProvider classProvider) {
    final occupancyRate = classModel.maxStudents > 0
        ? (classModel.currentStudentCount / classModel.maxStudents * 100)
        : 0.0;
    
    Color statusColor;
    String statusText;
    
    if (classModel.isFull) {
      statusColor = Colors.red;
      statusText = AppLocalizations.of(context).groupFull;
    } else if (occupancyRate > 75) {
      statusColor = Colors.orange;
      statusText = AppLocalizations.of(context).groupAlmostFull;
    } else {
      statusColor = Colors.green;
      statusText = AppLocalizations.of(context).groupAvailable;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: InkWell(
        // La carte entière ouvre maintenant directement la fiche complète
        // du groupe (déjà accessible via le bouton "Voir" ci-dessous, dans
        // l'ancienne version) — le petit résumé en boîte de dialogue
        // (`_showClassDetails`) faisait doublon et n'ajoutait rien que la
        // fiche complète ne montre déjà.
        onTap: () => _showGroupDetails(classModel),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // En-tête de la classe
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          classModel.name,
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          classModel.level,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      statusText,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: statusColor,
                      ),
                    ),
                  ),
                  // Menu d'actions secondaires : remplace la rangée de 4-5
                  // petits boutons texte en bas de carte (dont deux
                  // libellés tronqués, "Modif"/"Suppr") qui rendait la
                  // carte encombrée et peu soignée.
                  PopupMenuButton<String>(
                    icon: Icon(Icons.more_vert, color: Colors.grey[600], size: 20),
                    onSelected: (action) {
                      switch (action) {
                        case 'add_student':
                          _showAddStudentToGroupDialog(classModel);
                          break;
                        case 'remove_student':
                          _showRemoveStudentFromGroupDialog(classModel);
                          break;
                        case 'edit':
                          _showEditClassDialog(classModel);
                          break;
                        case 'delete':
                          _showDeleteClassDialog(classModel, classProvider);
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'add_student',
                        child: ListTile(
                          leading: Icon(Icons.person_add, size: 20),
                          title: Text(AppLocalizations.of(context).dashAddStudentToGroup),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                      if (classModel.studentIds.isNotEmpty)
                        PopupMenuItem(
                          value: 'remove_student',
                          child: ListTile(
                            leading: Icon(Icons.person_remove, size: 20, color: Colors.orange),
                            title: Text(AppLocalizations.of(context).dashRemoveStudentFromGroup),
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      PopupMenuItem(
                        value: 'edit',
                        child: ListTile(
                          leading: Icon(Icons.edit, size: 20),
                          title: Text(AppLocalizations.of(context).dashEditGroup),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: ListTile(
                          leading: Icon(Icons.delete, size: 20, color: Colors.red),
                          title: Text(AppLocalizations.of(context).dashDeleteGroup),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Informations détaillées
              Row(
                children: [
                  Icon(Icons.person, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  // Expanded + ellipsis : le nom d'un maître peut être long
                  // et débordait sans contrainte de largeur.
                  Expanded(
                    child: Text(
                      classModel.teacherName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                ],
              ),

              if (classModel.schedule != null) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.schedule, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    // Un horaire détaillé ("Lundi, Mercredi, Vendredi
                    // 14h-16h") dépasse facilement la largeur de la carte.
                    Expanded(
                      child: Text(
                        classModel.schedule!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                  ],
                ),
              ],

              if (classModel.room != null) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.room, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        classModel.room!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              
              const SizedBox(height: 12),
              
              // Barre de progression
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        AppLocalizations.of(context).dashOccupancy,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        '${classModel.currentStudentCount}/${classModel.maxStudents}',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: occupancyRate / 100,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Reçu de paiement (Document Engine) ────────────────
  static const _moisFr = [
    'Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin',
    'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre',
  ];

  /// Propose de prévisualiser/partager le reçu PDF juste après l'enregistrement
  /// d'un paiement payé (CDC section 21 : "prévisualisable, téléchargeable,
  /// imprimable et partageable").
  Future<void> _offerPaymentReceipt(Payment payment) async {
    // Paiement saisi hors ligne : le numéro de reçu (séquence par Markaz,
    // CDC §21) n'est attribué que par le serveur — pas de reçu "N° —".
    if (payment.receiptNumber == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).receiptPendingSync)),
      );
      return;
    }
    final studentProvider = context.read<StudentProvider>();
    final student = studentProvider.students
        .where((s) => s.id == payment.studentId)
        .firstOrNull;
    final markaz = context.read<MarkazProvider>().markaz;
    final teacherName = context.read<AuthService>().currentUser?.name ?? 'Maître';

    if (student == null || markaz == null) return;

    final metadata = PaymentReceiptMetadata(
      markaz: MarkazBranding(
        markazName: markaz.name,
        slogan: markaz.slogan,
        address: markaz.address,
        city: markaz.city,
        country: markaz.country,
        currency: markaz.currency,
        phone: markaz.phone,
        primaryColorHex: markaz.primaryColorHex,
      ),
      receiptNumber: payment.receiptNumber ?? '—',
      // Le jour EXACT du paiement (`paidAt`), pas le 1er jour du mois
      // concerné (`date`) — sinon le reçu affichait toujours "01/mois/année"
      // quelle que soit la date réelle du paiement.
      date: payment.paidAt ?? payment.date,
      studentName: student.name,
      parentPhone: student.parentPhone,
      amountPaid: payment.amount,
      month: '${_moisFr[payment.date.month - 1]} ${payment.date.year}',
      paymentMethod: 'Espèces',
      // Contenu du reçu PDF : reste en français (documents V1, CDC §21).
      status: 'Payé',
      recordedByName: teacherName,
    );

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(AppLocalizations.of(context).dashReceiptTitle),
        content: Text(AppLocalizations.of(context).dashReceiptGenerated),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(AppLocalizations.of(context).actionLater),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              final bytes = await DocumentService().generatePaymentReceipt(metadata);
              await DocumentService().sharePdf(bytes, 'recu_${payment.receiptNumber ?? payment.id}.pdf');
            },
            child: Text(AppLocalizations.of(context).actionShare),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              final bytes = await DocumentService().generatePaymentReceipt(metadata);
              await DocumentService().previewPdf(bytes);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: Text(AppLocalizations.of(context).actionPreviewPrint),
          ),
        ],
      ),
    );
  }

  // ─── Rapport PDF par élève (CDC 8.8) ────────
  // Remplace l'ancien export ad-hoc (doc/audit.md, point F2) : celui-ci ne
  // générait qu'un résumé brut de toute la Markaz, sans passer par le
  // Document Engine (pas de branding, pas de gabarit CDC §21) et sans
  // correspondre au besoin réel du CDC §8.8 : un rapport PAR ÉLÈVE.
  void _generateStudentReport() {
    final students = context.read<StudentProvider>().students;
    if (students.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).commonAddStudentFirst)),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (_) => _StudentReportPickerDialog(
        students: students,
        onWeekly: (student) => _buildAndOfferWeeklyReport(student),
        onMonthly: (student) => _buildAndOfferMonthlyReport(student),
      ),
    );
  }

  MarkazBranding _currentBranding() {
    final markaz = context.read<MarkazProvider>().markaz;
    return MarkazBranding(
      markazName: markaz?.name ?? 'Markazi',
      slogan: markaz?.slogan,
      address: markaz?.address,
      city: markaz?.city,
      country: markaz?.country,
      currency: markaz?.currency ?? 'GNF',
      phone: markaz?.phone,
      primaryColorHex: markaz?.primaryColorHex,
    );
  }

  /// Nom de la classe de l'élève, si affecté à une classe (recherché parmi
  /// les classes chargées — un élève n'appartient qu'à une seule Markaz/classe).
  String? _classNameFor(Student student) {
    final classes = context.read<ClassProvider>().classes;
    final match = classes.where((c) => c.studentIds.contains(student.id));
    return match.isEmpty ? null : match.first.name;
  }

  Future<void> _buildAndOfferWeeklyReport(Student student) async {
    Navigator.pop(context); // Fermer le sélecteur

    final now = DateTime.now();
    final weekStart = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: now.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 6));

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        content: Row(children: [
          CircularProgressIndicator(),
          SizedBox(width: 16),
          Expanded(child: Text(AppLocalizations.of(context).dashGeneratingReport)),
        ]),
      ),
    );

    try {
      // Toutes les présences de la semaine (cache local complet) : le
      // provider ne contient que la journée en cours, le rapport n'affichait
      // donc que le jour même.
      final attendances = context
          .read<AttendanceService>()
          .getAttendancesForCurrentMarkaz()
          .where((a) =>
              a.studentId == student.id &&
              !a.date.isBefore(weekStart) &&
              !a.date.isAfter(weekEnd))
          .toList()
        ..sort((a, b) => a.date.compareTo(b.date));

      final entries = attendances
          .map((a) => DailyEntry(
                date: a.date,
                status: _pdfAttendanceStatusLabel(a.status),
                lesson: a.lesson,
                observation: null,
              ))
          .toList();

      // Taux calculé côté serveur (jours de cours réels du Markaz — CDC 8.6,
      // doc/audit.md point F6) plutôt que recalculé ici, pour rester exact.
      final attendanceRate = await _fetchAttendanceRate(student.id, weekStart, weekEnd);

      final metadata = WeeklyReportMetadata(
        markaz: _currentBranding(),
        studentName: student.name,
        className: _classNameFor(student),
        weekStart: weekStart,
        weekEnd: weekEnd,
        entries: entries,
        attendanceRate: attendanceRate,
      );

      final bytes = await DocumentService().generateWeeklyReport(metadata);
      if (!mounted) return;
      Navigator.pop(context); // Fermer le chargement
      await _offerGeneratedReport(bytes, 'rapport_hebdo_${student.name}_${weekStart.day}${weekStart.month}.pdf');
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).dashGenerationError(e)), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _buildAndOfferMonthlyReport(Student student) async {
    Navigator.pop(context); // Fermer le sélecteur

    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);
    final monthEnd = DateTime(now.year, now.month + 1, 0);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        content: Row(children: [
          CircularProgressIndicator(),
          SizedBox(width: 16),
          Expanded(child: Text(AppLocalizations.of(context).dashGeneratingReport)),
        ]),
      ),
    );

    try {
      // Toutes les présences du mois (cache local complet — le provider ne
      // contient que la journée en cours).
      final attendances = context
          .read<AttendanceService>()
          .getAttendancesForCurrentMarkaz()
          .where((a) =>
              a.studentId == student.id &&
              !a.date.isBefore(monthStart) &&
              !a.date.isAfter(monthEnd))
          .toList();

      final payments = context
          .read<PaymentProvider>()
          .payments
          .where((p) =>
              p.studentId == student.id &&
              p.date.year == now.year &&
              p.date.month == now.month)
          .map((p) => MonthlyPaymentEntry(
                date: p.date,
                amount: p.amount,
                // Contenu du rapport PDF : reste en français (CDC §21).
                status: p.status == PaymentStatus.paid ? 'Payé' : 'Non payé',
              ))
          .toList();

      // Jours de cours réels + taux calculés côté serveur (CDC 8.6, F6).
      final stats = await _fetchAttendanceStats(student.id, monthStart, monthEnd);

      final metadata = MonthlyReportMetadata(
        markaz: _currentBranding(),
        studentName: student.name,
        className: _classNameFor(student),
        month: now.month,
        year: now.year,
        totalDays: stats['total_days'] as int? ?? attendances.length,
        // Comptes du serveur (référence), à défaut ceux du cache local.
        presentDays: stats['present'] as int? ??
            attendances.where((a) => a.status == AttendanceStatus.present).length,
        absentDays: stats['absent'] as int? ??
            attendances.where((a) => a.status.isAbsence).length,
        attendanceRate: (stats['attendance_rate'] as num?)?.toDouble() ?? 0,
        payments: payments,
      );

      final bytes = await DocumentService().generateMonthlyReport(metadata);
      if (!mounted) return;
      Navigator.pop(context);
      await _offerGeneratedReport(bytes, 'rapport_mensuel_${student.name}_${now.month}${now.year}.pdf');
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).dashGenerationError(e)), backgroundColor: Colors.red),
      );
    }
  }

  /// Libellé d'un statut dans les documents PDF — restent en français
  /// (documents de la V1, CDC §7.2/§21), quelle que soit la langue de l'app.
  String _pdfAttendanceStatusLabel(AttendanceStatus status) {
    switch (status) {
      case AttendanceStatus.present:
        return 'Présent';
      case AttendanceStatus.absent:
        return 'Absent';
      case AttendanceStatus.late:
        return 'Retard';
      case AttendanceStatus.justified:
        return 'Absence justifiée';
    }
  }

  /// Libellé d'un statut à l'écran (traduit — doc/audit.md K8).
  String _attendanceStatusLabel(AttendanceStatus status) {
    switch (status) {
      case AttendanceStatus.present:
        return AppLocalizations.of(context).attendancePresent;
      case AttendanceStatus.absent:
        return AppLocalizations.of(context).attendanceAbsent;
      case AttendanceStatus.late:
        return AppLocalizations.of(context).attendanceLate;
      case AttendanceStatus.justified:
        return AppLocalizations.of(context).attendanceJustified;
    }
  }

  /// Appelle directement GET /students/{id}/attendance-stats (l'endpoint
  /// existe déjà côté API, voir AttendanceController::statsForStudent) —
  /// évite de dupliquer côté client le calcul du taux basé sur les jours
  /// de cours réels du Markaz (CDC 8.6, doc/audit.md point F6).
  Future<Map<String, dynamic>> _fetchAttendanceStats(String studentId, DateTime from, DateTime to) async {
    final response = await ApiClient.instance.dio.get(
      '/students/$studentId/attendance-stats',
      queryParameters: {
        'date_from': from.toIso8601String().split('T').first,
        'date_to': to.toIso8601String().split('T').first,
      },
    );
    return response.data as Map<String, dynamic>;
  }

  Future<double> _fetchAttendanceRate(String studentId, DateTime from, DateTime to) async {
    final stats = await _fetchAttendanceStats(studentId, from, to);
    return (stats['attendance_rate'] as num?)?.toDouble() ?? 0;
  }

  Future<void> _offerGeneratedReport(Uint8List bytes, String fileName) async {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(AppLocalizations.of(context).dashReportGenerated),
        content: Text(AppLocalizations.of(context).dashReportWhatToDo),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: Text(AppLocalizations.of(context).actionLater)),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              await DocumentService().sharePdf(bytes, fileName);
            },
            child: Text(AppLocalizations.of(context).actionShare),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              await DocumentService().previewPdf(bytes);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: Text(AppLocalizations.of(context).actionPreviewPrint),
          ),
        ],
      ),
    );
  }

  // ─── API Sync Handler ───────────────────
  /// Synchronisation complète demandée par l'utilisateur (CDC §20) : rejeu
  /// des actions hors ligne PUIS rechargement de toutes les données depuis
  /// le serveur — auparavant seuls les élèves étaient rechargés, et avant
  /// le rejeu (ce qui écrasait les saisies en attente).
  Future<void> _syncFromApi() async {
    final l10n = AppLocalizations.of(context);
    final markazId = context.read<AuthService>().currentMarkazId;
    if (markazId == null) return;

    final syncProvider = context.read<SyncQueueProvider>();
    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(SnackBar(content: Text(l10n.syncInProgress)));

    final report = await syncProvider.syncAll(markazId);
    if (!mounted) return;

    // Recharger l'affichage depuis les caches à jour.
    await Future.wait([
      context.read<StudentProvider>().loadStudents(),
      context.read<ClassProvider>().loadClasses(),
      context.read<PaymentProvider>().loadPayments(),
      context.read<AttendanceProvider>().loadAttendances(),
      context.read<GuardianProvider>().loadGuardians(),
      context.read<RecitationProvider>().loadRecitations(),
    ]);
    if (!mounted) return;

    messenger.hideCurrentSnackBar();
    final String message;
    final Color color;
    if (report.offline) {
      message = l10n.syncStillOffline;
      color = Colors.blueGrey;
    } else if (report.failed > 0) {
      message = l10n.syncResult('${report.synced}', '${report.failed}');
      color = Colors.red;
    } else {
      message = report.synced > 0
          ? l10n.syncResult('${report.synced}', '0')
          : l10n.syncAllDone;
      color = Colors.green;
    }
    messenger.showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
  }

  // ─── Logout Handler ────────────────────────
  Future<void> _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context).navLogout),
        content: Text(AppLocalizations.of(context).dashLogoutConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppLocalizations.of(context).actionCancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child:
                Text(AppLocalizations.of(context).actionLogout, style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        final authService = context.read<AuthService>();
        await authService.logout();
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/splash');
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppLocalizations.of(context).dashLogoutError(e))),
          );
        }
      }
    }
  }

  // ─── CLASS MANAGEMENT DIALOGS ─────────────────────
  void _showAddClassDialog() {
    final nameController = TextEditingController();
    final levelController = TextEditingController();
    final descriptionController = TextEditingController();
    final teacherController = TextEditingController();
    final maxStudentsController = TextEditingController(text: '30');

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(AppLocalizations.of(context).dashAddGroup),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context).fieldGroupName,
                    hintText: AppLocalizations.of(context).dashGroupNameHint,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: levelController,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context).fieldGroupLevel,
                    hintText: AppLocalizations.of(context).dashGroupLevelHint,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descriptionController,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context).fieldDescription,
                    hintText: AppLocalizations.of(context).fieldGroupDescription,
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: teacherController,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context).fieldTeacherName,
                    hintText: AppLocalizations.of(context).dashTeacherHint,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: maxStudentsController,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context).fieldMaxStudents,
                    hintText: AppLocalizations.of(context).dashMaxStudentsHint,
                    helperText: AppLocalizations.of(context).dashMaxStudentsHelp,
                  ),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppLocalizations.of(context).actionCancel),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  final classProvider = context.read<ClassProvider>();
                  await classProvider.addClass(
                    name: nameController.text,
                    level: levelController.text,
                    description: descriptionController.text,
                    teacherName: teacherController.text,
                    maxStudents: int.tryParse(maxStudentsController.text) ?? 20,
                  );
                  
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(AppLocalizations.of(context).dashGroupAdded),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(AppLocalizations.of(context).commonErrorColon(e)),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              child: Text(AppLocalizations.of(context).actionAdd),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditClassDialog(ClassModel classModel) {
    final nameController = TextEditingController(text: classModel.name);
    final levelController = TextEditingController(text: classModel.level);
    final descriptionController = TextEditingController(text: classModel.description);
    final teacherController = TextEditingController(text: classModel.teacherName);
    final maxStudentsController = TextEditingController(text: classModel.maxStudents.toString());

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(AppLocalizations.of(context).dashEditNamed(classModel.name)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context).fieldGroupName,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: levelController,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context).fieldGroupLevel,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descriptionController,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context).fieldDescription,
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: teacherController,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context).fieldTeacherName,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: maxStudentsController,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context).fieldMaxStudents,
                    hintText: AppLocalizations.of(context).dashMaxStudentsHint,
                    helperText: AppLocalizations.of(context).dashMaxStudentsHelp,
                  ),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppLocalizations.of(context).actionCancel),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  final classProvider = context.read<ClassProvider>();
                  await classProvider.updateClass(
                    classId: classModel.id,
                    name: nameController.text,
                    level: levelController.text,
                    description: descriptionController.text,
                    teacherName: teacherController.text,
                    maxStudents: int.tryParse(maxStudentsController.text) ?? 20,
                  );
                  
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(AppLocalizations.of(context).dashGroupUpdated),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(AppLocalizations.of(context).commonErrorColon(e)),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              child: Text(AppLocalizations.of(context).actionEdit),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteClassDialog(ClassModel classModel, ClassProvider classProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context).dashDeleteNamed(classModel.name)),
        content: Text(AppLocalizations.of(context).dashDeleteGroupConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context).actionCancel),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await classProvider.deleteClass(classModel.id);
                
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(AppLocalizations.of(context).dashGroupDeleted),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(AppLocalizations.of(context).commonErrorColon(e)),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: Text(AppLocalizations.of(context).actionDelete),
          ),
        ],
      ),
    );
  }

  void _showGroupDetails(ClassModel groupModel) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GroupDetailsScreen(group: groupModel),
      ),
    );
  }

  void _showAddStudentToGroupDialog(ClassModel groupModel) {
    final studentProvider = context.read<StudentProvider>();
    final classProvider = context.read<ClassProvider>();
    final students = studentProvider.students;
    
    // Filtrer les élèves qui ne sont pas déjà dans ce groupe
    final availableStudents = students.where((student) => 
        !groupModel.studentIds.contains(student.id)
    ).toList();

    if (availableStudents.isEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(AppLocalizations.of(context).dashAddStudentToGroup),
          content: Text(AppLocalizations.of(context).dashAllStudentsInGroup),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppLocalizations.of(context).actionClose),
            ),
          ],
        ),
      );
      return;
    }

    String? selectedStudentId;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context).dashAddStudentTo(groupModel.name)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(AppLocalizations.of(context).dashSelectStudentToAdd),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: selectedStudentId,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context).fieldStudent,
                hintText: AppLocalizations.of(context).dashChooseStudent,
              ),
              items: availableStudents.map((student) {
                return DropdownMenuItem(
                  value: student.id,
                  child: Text('${student.name} - ${student.parentPhone}'),
                );
              }).toList(),
              onChanged: (value) {
                selectedStudentId = value;
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context).actionCancel),
          ),
          ElevatedButton(
            onPressed: () async {
              if (selectedStudentId != null) {
                try {
                  await classProvider.addStudentToClass(groupModel.id, selectedStudentId!);
                  
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(AppLocalizations.of(context).dashStudentAddedToGroup),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(AppLocalizations.of(context).commonErrorColon(e)),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
            child: Text(AppLocalizations.of(context).actionAdd),
          ),
        ],
      ),
    );
  }

  void _showRemoveStudentFromGroupDialog(ClassModel groupModel) {
    final studentProvider = context.read<StudentProvider>();
    final classProvider = context.read<ClassProvider>();
    final students = studentProvider.students;
    
    // Filtrer les élèves qui sont dans ce groupe
    final groupStudents = students.where((student) => 
        groupModel.studentIds.contains(student.id)
    ).toList();

    if (groupStudents.isEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(AppLocalizations.of(context).dashRemoveStudentFromGroup),
          content: Text(AppLocalizations.of(context).dashGroupEmpty),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppLocalizations.of(context).actionClose),
            ),
          ],
        ),
      );
      return;
    }

    String? selectedStudentId;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context).dashRemoveStudentFrom(groupModel.name)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(AppLocalizations.of(context).dashSelectStudentToRemove),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: selectedStudentId,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context).fieldStudent,
                hintText: AppLocalizations.of(context).dashChooseStudent,
              ),
              items: groupStudents.map((student) {
                return DropdownMenuItem(
                  value: student.id,
                  child: Text('${student.name} - ${student.parentPhone}'),
                );
              }).toList(),
              onChanged: (value) {
                selectedStudentId = value;
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context).actionCancel),
          ),
          ElevatedButton(
            onPressed: () async {
              if (selectedStudentId != null) {
                try {
                  await classProvider.removeStudentFromClass(groupModel.id, selectedStudentId!);
                  
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(AppLocalizations.of(context).dashStudentRemovedFromGroup),
                        backgroundColor: Colors.orange,
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(AppLocalizations.of(context).commonErrorColon(e)),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
            ),
            child: Text(AppLocalizations.of(context).actionRemove),
          ),
        ],
      ),
    );
  }

  // ─── Group Occupation Fix ───────────────────────
  void _fixGroupOccupations(ClassProvider classProvider, StudentProvider studentProvider) {
    try {
      // Pour l'instant, on ne fait rien pour éviter les erreurs
      // TODO: Implémenter une solution plus robuste plus tard
      debugPrint('Correction des occupations désactivée temporairement');
    } catch (e) {
      debugPrint('Erreur lors de la correction des occupations: $e');
    }
  }
}

/// Sélecteur d'élève + type de rapport, pour le Document Engine (CDC §8.8).
class _StudentReportPickerDialog extends StatefulWidget {
  final List<Student> students;
  final void Function(Student student) onWeekly;
  final void Function(Student student) onMonthly;

  const _StudentReportPickerDialog({
    required this.students,
    required this.onWeekly,
    required this.onMonthly,
  });

  @override
  State<_StudentReportPickerDialog> createState() => _StudentReportPickerDialogState();
}

class _StudentReportPickerDialogState extends State<_StudentReportPickerDialog> {
  /// Textes traduits (doc/audit.md K8).
  AppLocalizations get _l10n => AppLocalizations.of(context);

  late String _studentId = widget.students.first.id;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_l10n.dashGenerateReport),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DropdownButtonFormField<String>(
            initialValue: _studentId,
            decoration: InputDecoration(labelText: _l10n.fieldStudent),
            items: widget.students
                .map((s) => DropdownMenuItem(value: s.id, child: Text(s.name)))
                .toList(),
            onChanged: (value) => setState(() => _studentId = value ?? _studentId),
          ),
          const SizedBox(height: 16),
          Text(
            _l10n.dashChooseReportPeriod,
            style: GoogleFonts.cairo(fontSize: 13, color: AppColors.textMedium),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(_l10n.actionCancel)),
        TextButton(
          onPressed: () => widget.onWeekly(widget.students.firstWhere((s) => s.id == _studentId)),
          child: Text(_l10n.dashWeekly),
        ),
        ElevatedButton(
          onPressed: () => widget.onMonthly(widget.students.firstWhere((s) => s.id == _studentId)),
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
          child: Text(_l10n.dashMonthly),
        ),
      ],
    );
  }
}
