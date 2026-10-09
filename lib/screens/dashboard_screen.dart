import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
    final userName = authService.currentUser?.name ?? 'Utilisateur';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bienvenue, $userName',
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
                  child: const Icon(Icons.sync, color: Colors.white),
                ),
                onPressed: _syncFromApi,
                tooltip: pending > 0
                    ? '$pending action(s) en attente de synchronisation'
                    : 'Synchroniser avec le serveur',
              );
            },
          ),
        ],
      ),
      drawer: _buildNavigationDrawer(context, userName),
      body: _buildTabContent(),
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
            'Statistiques générales',
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
                    'Élèves',
                    studentProvider.students.length.toString(),
                    Icons.people,
                    AppColors.primary,
                  ),
                  _buildStatCard(
                    'Paiements',
                    validPayments.length.toString(),
                    Icons.payments,
                    Colors.blue,
                  ),
                  _buildStatCard(
                    'Présences',
                    validAttendances.length.toString(),
                    Icons.calendar_today,
                    Colors.orange,
                  ),
                  _buildStatCard(
                    'Récitations',
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
            'Actions rapides',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildActionButton('Ajouter', Icons.person_add)),
              const SizedBox(width: 12),
              Expanded(child: _buildActionButton('Paiement', Icons.add_card)),
              const SizedBox(width: 12),
              Expanded(child: _buildActionButton('Présence', Icons.check_circle)),
            ],
          ),
          const SizedBox(height: 32),
          Text(
            'Mes groupes',
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
                'Paiements récents',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              TextButton(
                onPressed: () => setState(() => _selectedTabIndex = 3),
                child: Text(
                  'Tout voir',
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
                'Aucun groupe créé pour l\'instant',
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
                  '$activeCount groupe${activeCount > 1 ? 's' : ''} actif${activeCount > 1 ? 's' : ''}',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$occupied / $capacity places occupées',
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
                'Aucun paiement enregistré pour l\'instant',
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
              student?.name ?? 'Élève supprimé',
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
  Widget _buildActionButton(String label, IconData icon) {
    VoidCallback onTap;
    switch (label) {
      case 'Ajouter':
        onTap = _showAddStudentDialog;
        break;
      case 'Paiement':
        onTap = _showAddPaymentDialog;
        break;
      default:
        onTap = _showMarkAttendanceDialog;
    }

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
            label: const Text('Ajouter'),
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
              'Élèves',
              '${studentProvider.students.length} élève(s)',
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
                            'Aucun élève enregistré',
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
                                Text('Tél: ${_formatGuineanPhone(student.parentPhone)}'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.edit, color: Colors.blue, size: 20),
                                  onPressed: () => _showEditStudentDialog(student),
                                  tooltip: 'Modifier l\'élève',
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red, size: 20),
                                  onPressed: () => _showDeleteStudentDialog(student),
                                  tooltip: 'Supprimer l\'élève',
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
              'Paiements',
              '${validPayments.length} paiement(s)',
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
                  ? 'Aucun paiement enregistré'
                  : 'Aucun paiement valide (élèves supprimés)',
              style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey),
            ),
            if (paymentProvider.payments.isNotEmpty && validPayments.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  '${paymentProvider.payments.length} paiement(s) lié(s) à des élèves supprimés',
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
              'Présences',
              '${validAttendances.length} présence(s)',
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
                      ? 'Aucune présence enregistrée'
                      : 'Aucune présence valide (élèves supprimés)',
                  style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey),
                ),
                if (attendanceProvider.attendances.isNotEmpty && validAttendances.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      '${attendanceProvider.attendances.length} présence(s) liée(s) à des élèves supprimés',
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
            final isPresent = attendance.status == AttendanceStatus.present;
            final isAbsent = attendance.status == AttendanceStatus.absent;

            Color statusColor;
            IconData statusIcon;
            String statusText;

            if (isPresent) {
              statusColor = Colors.green;
              statusIcon = Icons.check_circle;
              statusText = 'Présent';
            } else if (isAbsent) {
              statusColor = Colors.red;
              statusIcon = Icons.cancel;
              statusText = 'Absent';
            } else {
              statusColor = Colors.orange;
              statusIcon = Icons.schedule;
              statusText = 'Tardif';
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
            'Générer des rapports',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          _buildReportButton('Rapport hebdomadaire', Icons.date_range,
              () => _showWeeklyReport()),
          const SizedBox(height: 12),
          _buildReportButton('Rapport mensuel', Icons.calendar_month,
              () => _showMonthlyReport()),
          const SizedBox(height: 12),
          _buildReportButton(
              'Rapport des paiements', Icons.money, () => _showPaymentReport()),
          const SizedBox(height: 12),
          _buildReportButton('Rapport de performance', Icons.trending_up,
              () => _showPerformanceReport()),
          const SizedBox(height: 12),
          _buildReportButton('Taux présence par élève', Icons.person_outline,
              () => _showAttendanceRateReport()),
          const SizedBox(height: 32),
          Text(
            'Export',
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
              label: const Text('Exporter en PDF'),
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
          title: const Text('Ajouter un nouvel élève'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Nom de l\'élève',
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
                    labelText: 'Téléphone du parent',
                    hintText: 'Ex: 622180933',
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
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isEmpty ||
                    phoneController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Veuillez remplir tous les champs'),
                    ),
                  );
                  return;
                }

                // Valider le numéro de téléphone
                if (!_isValidGuineanPhone(phoneController.text)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                          'Numéro de téléphone invalide'),
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
                      const SnackBar(
                        content: Text('Élève ajouté avec succès!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                    Navigator.pop(context);
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Erreur: ${e.toString()}'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              child: const Text('Ajouter'),
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
          title: const Text('Modifier l\'élève'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Nom de l\'élève',
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
                    labelText: 'Téléphone du parent',
                    hintText: 'Ex: 622180933',
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
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isEmpty ||
                    phoneController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Veuillez remplir tous les champs'),
                    ),
                  );
                  return;
                }

                // Valider le numéro de téléphone
                if (!_isValidGuineanPhone(phoneController.text)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                          'Numéro de téléphone invalide'),
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
                      const SnackBar(
                        content: Text('Élève modifié avec succès!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                    Navigator.pop(context);
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Erreur: ${e.toString()}'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              child: const Text('Modifier'),
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
        title: const Text('Archiver cet élève ?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Êtes-vous sûr de vouloir retirer cet élève de la liste ?'),
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
                    'Nom: ${student.name}',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Text('Tél: ${_formatGuineanPhone(student.parentPhone)}'),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "L'élève sera archivé : il n'apparaîtra plus dans les listes, mais son historique (paiements, présences, récitations) est conservé et reste compté dans les totaux financiers.",
              style: TextStyle(color: Colors.red[700], fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                final studentProvider = context.read<StudentProvider>();
                await studentProvider.removeStudent(student.id);

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Élève archivé avec succès'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  Navigator.pop(context);
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Erreur: ${e.toString()}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Archiver'),
          ),
        ],
      ),
    );
  }

  // ─── Add Payment Dialog ────────────────────
  // ─── Payment Dialog ───────────────────────
  static const List<String> _monthNames = [
    'Janvier',
    'Février',
    'Mars',
    'Avril',
    'Mai',
    'Juin',
    'Juillet',
    'Août',
    'Septembre',
    'Octobre',
    'Novembre',
    'Décembre'
  ];

  /// Libellé affiché pour un mois (ex. "Août 2026").
  String _formatMonthLabel(DateTime month) =>
      '${_monthNames[month.month - 1]} ${month.year}';

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
                title: const Text('Ajouter un paiement'),
                content: const Text(
                    'Aucun élève enregistré. Veuillez d\'abord ajouter des élèves.'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Fermer'),
                  ),
                ],
              );
            }

            return AlertDialog(
              title: const Text('Enregistrer un paiement'),
              contentPadding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      initialValue: selectedStudentId,
                      hint: const Text('Sélectionner un élève'),
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
                        labelText: 'Montant ($_currency)',
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
                        labelText: 'Mois',
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
                        labelText: 'Statut',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: const Icon(Icons.check_circle),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'paid', child: Text('Payé')),
                        DropdownMenuItem(
                            value: 'unpaid', child: Text('Non payé')),
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
                            labelText: 'Jour du paiement',
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
                  child: const Text('Annuler'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (selectedStudentId == null ||
                        amountController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Veuillez remplir tous les champs'),
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
                        const SnackBar(
                          content: Text('Montant invalide'),
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
                  child: const Text('Enregistrer'),
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
          content: Text('Paiement pour ${_formatMonthLabel(month)} enregistré!'),
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
          title: const Text('Paiement déjà enregistré'),
          content: Text(e.message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              child: const Text('Confirmer quand même'),
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
          content: Text('Erreur: ${e.toString()}'),
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
                title: const Text('Marquer présence'),
                content: const Text(
                    'Aucun élève enregistré. Veuillez d\'abord ajouter des élèves.'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Fermer'),
                  ),
                ],
              );
            }

            return AlertDialog(
              title: const Text('Marquer présence'),
              contentPadding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      initialValue: selectedStudentId,
                      hint: const Text('Sélectionner un élève'),
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
                        labelText: 'Leçon/Cours',
                        hintText: 'Ex: Coran, Hadith',
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
                        labelText: 'Statut',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: const Icon(Icons.check_circle),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'present',
                          child: Row(
                            children: [
                              Icon(Icons.check_circle,
                                  color: Colors.green, size: 20),
                              SizedBox(width: 8),
                              Text('Présent'),
                            ],
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'absent',
                          child: Row(
                            children: [
                              Icon(Icons.close, color: Colors.red, size: 20),
                              SizedBox(width: 8),
                              Text('Absent'),
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
                              Text('Tardif'),
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
                  child: const Text('Annuler'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (selectedStudentId == null || selectedStatus == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                              'Veuillez sélectionner un élève et un statut'),
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
                          : 'Absence de cours';

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
                      }

                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Présence enregistrée avec succès!'),
                            backgroundColor: Colors.green,
                          ),
                        );
                        Navigator.pop(context);
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Erreur: ${e.toString()}'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                  ),
                  child: const Text('Enregistrer'),
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
              .where((a) => a.status == AttendanceStatus.absent)
              .length;
          final late = weeklyAttendances
              .where((a) => a.status == AttendanceStatus.late)
              .length;

          return AlertDialog(
            title: const Text('Rapport hebdomadaire'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                      'Semaine du ${startOfWeek.day}/${startOfWeek.month} au ${endOfWeek.day}/${endOfWeek.month}',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 24),
                  _buildReportStat('Présents', '$present', Colors.green),
                  const SizedBox(height: 12),
                  _buildReportStat('Absents', '$absent', Colors.red),
                  const SizedBox(height: 12),
                  _buildReportStat('Tardifs', '$late', Colors.orange),
                  const SizedBox(height: 24),
                  Text('Total sessions: ${weeklyAttendances.length}',
                      style: GoogleFonts.poppins(fontSize: 14)),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Fermer'),
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
              .where((a) => a.status == AttendanceStatus.absent)
              .length;
          final late = monthlyAttendances
              .where((a) => a.status == AttendanceStatus.late)
              .length;

          return AlertDialog(
            title: const Text('Rapport mensuel'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Mois: ${startOfMonth.month}/${startOfMonth.year}',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 24),
                  _buildReportStat('Présents', '$present', Colors.green),
                  const SizedBox(height: 12),
                  _buildReportStat('Absents', '$absent', Colors.red),
                  const SizedBox(height: 12),
                  _buildReportStat('Tardifs', '$late', Colors.orange),
                  const SizedBox(height: 24),
                  Text('Total sessions: ${monthlyAttendances.length}',
                      style: GoogleFonts.poppins(fontSize: 14)),
                  const SizedBox(height: 16),
                  Text(
                    'Taux de présence: ${monthlyAttendances.isNotEmpty ? ((present / monthlyAttendances.length) * 100).toStringAsFixed(1) : 0}%',
                    style: GoogleFonts.poppins(
                        fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Fermer'),
              ),
            ],
          );
        },
      ),
    );
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
            title: const Text('Rapport des paiements'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildReportStat('Total payé',
                      '${totalPaid.toStringAsFixed(2)} $_currency', Colors.green),
                  const SizedBox(height: 12),
                  _buildReportStat('Total en attente',
                      '${totalUnpaid.toStringAsFixed(2)} $_currency', Colors.orange),
                  const SizedBox(height: 12),
                  _buildReportStat(
                      'Total général',
                      '${(totalPaid + totalUnpaid).toStringAsFixed(2)} $_currency',
                      AppColors.primary),
                  const SizedBox(height: 24),
                  Text(
                      'Nombre de paiements: ${paymentProvider.payments.length}',
                      style: GoogleFonts.poppins(fontSize: 14)),
                  const SizedBox(height: 12),
                  Text('Élèves actifs: ${studentProvider.students.length}',
                      style: GoogleFonts.poppins(fontSize: 14)),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Fermer'),
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
            title: const Text('Rapport de performance'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Métriques de gestion:',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  _buildPerformanceBar(
                      'Taux de présence', attendanceRate, Colors.green),
                  const SizedBox(height: 16),
                  _buildPerformanceBar(
                      'Taux de paiement', paymentRate, Colors.blue),
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
                        Text('Résumé:',
                            style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        Text('• Total élèves: $totalStudents'),
                        Text('• Sessions enregistrées: $totalAttendance'),
                        Text(
                            '• Paiements registrés: ${paymentProvider.payments.length}'),
                        Text('• Paiements complétés: $paidCount'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Fermer'),
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
    final studentPhone = student?.parentPhone ?? 'Non disponible';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Détails du paiement'),
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
                      'Élève',
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
                'Montant',
                '${payment.amount} $_currency',
                Colors.green,
              ),
              const SizedBox(height: 12),

              // Statut
              _buildPaymentDetailRow(
                'Statut',
                isPaid ? 'Payé' : 'En attente',
                isPaid ? Colors.green : Colors.orange,
              ),
              const SizedBox(height: 12),

              // Date
              _buildPaymentDetailRow(
                'Date du paiement',
                formattedDate,
                Colors.purple,
              ),
              const SizedBox(height: 12),

              // Téléphone de l'élève/parent
              _buildPaymentDetailRow(
                'Téléphone du parent',
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
                      'ID Paiement',
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
                    const SnackBar(
                      content: Text('Paiement marqué comme payé'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  Navigator.pop(context);
                  _offerPaymentReceipt(updated);
                } catch (e) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Erreur: ${e.toString()}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
              child: const Text('Marquer comme payé'),
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
              label: const Text('Reçu'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
            ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  void _showAttendanceDetails(dynamic attendance, String studentName,
      dynamic student, String statusText, Color statusColor) {
    final studentPhone = student?.parentPhone ?? 'Non disponible';
    final formattedDate = attendance.date.toString().split(' ')[0];
    final lesson = attendance.lesson ?? 'Non spécifié';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Détails de la présence'),
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
                      'Élève',
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
                'Leçon',
                lesson,
                Colors.purple,
              ),
              const SizedBox(height: 12),

              // Statut
              _buildAttendanceDetailRow(
                'Statut',
                statusText,
                statusColor,
              ),
              const SizedBox(height: 12),

              // Date
              _buildAttendanceDetailRow(
                'Date',
                formattedDate,
                Colors.green,
              ),
              const SizedBox(height: 12),

              // Téléphone du parent
              _buildAttendanceDetailRow(
                'Téléphone du parent',
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
                      'ID Présence',
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
            child: const Text('Fermer'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _showEditAttendanceDialog(attendance as Attendance, studentName);
            },
            icon: const Icon(Icons.edit_outlined, size: 18),
            label: const Text('Modifier'),
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
          title: const Text('Modifier la présence'),
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
                  decoration: const InputDecoration(
                    labelText: 'Statut',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: AttendanceStatus.present, child: Text('Présent')),
                    DropdownMenuItem(value: AttendanceStatus.absent, child: Text('Absent')),
                    DropdownMenuItem(value: AttendanceStatus.late, child: Text('Tardif')),
                  ],
                  onChanged: (value) {
                    if (value != null) setState(() => selectedStatus = value);
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: lessonController,
                  decoration: const InputDecoration(
                    labelText: 'Leçon',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Annuler'),
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
                      const SnackBar(
                        content: Text('Présence corrigée'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (dialogContext.mounted) {
                    ScaffoldMessenger.of(dialogContext).showSnackBar(
                      SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              child: const Text('Enregistrer'),
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
              .where((a) => a.status == AttendanceStatus.absent)
              .length;

          final lateCount = studentAttendances
              .where((a) => a.status == AttendanceStatus.late)
              .length;

          final attendanceRate = studentAttendances.isNotEmpty
              ? ((presentCount / studentAttendances.length) * 100)
              : 0.0;

          return AlertDialog(
            title: const Text('Profil de l\'élève'),
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
                          'Nom de l\'élève',
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
                    'Contact',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildStudentDetailRow(
                    'Téléphone',
                    _formatGuineanPhone(student.parentPhone),
                    Colors.blue,
                  ),
                  const SizedBox(height: 16),

                  // Statistiques des paiements
                  Text(
                    'Paiements',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildStudentDetailRow(
                    'Total payé',
                    '$paidAmount $_currency',
                    Colors.green,
                  ),
                  const SizedBox(height: 8),
                  _buildStudentDetailRow(
                    'Total en attente',
                    '${totalPayments - paidAmount} $_currency',
                    Colors.orange,
                  ),
                  const SizedBox(height: 8),
                  _buildStudentDetailRow(
                    'Paiements payés',
                    '$paidPayments/${studentPayments.length}',
                    Colors.purple,
                  ),
                  const SizedBox(height: 16),

                  // Statistiques de présence
                  Text(
                    'Présence',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildStudentDetailRow(
                    'Taux de présence',
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
                          'Présent',
                          '$presentCount',
                          Colors.green,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildAttendanceStatBadge(
                          'Absent',
                          '$absentCount',
                          Colors.red,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildAttendanceStatBadge(
                          'Tardif',
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
                          'ID Élève',
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
                child: const Text('Fermer'),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _showEditStudentDialog(student);
                },
                icon: const Icon(Icons.edit, size: 18),
                label: const Text('Modifier'),
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
                label: const Text('Supprimer'),
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
            title: const Text('Taux de présence par élève'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (students.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text('Aucun élève enregistré'),
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
                          .where((a) => a.status == AttendanceStatus.absent)
                          .length;

                      final monthLate = monthAttendances
                          .where((a) => a.status == AttendanceStatus.late)
                          .length;

                      // Calculer les taux pour la semaine
                      final weekAbsent = weekAttendances
                          .where((a) => a.status == AttendanceStatus.absent)
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
                                'Cette semaine (${weekAttendances.length} sessions)',
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
                                    'Présent',
                                    '${weekPresentRate.toStringAsFixed(1)}%',
                                    Colors.green,
                                  ),
                                  _buildAttendanceStatBadge(
                                    'Absent',
                                    '${weekAbsentRate.toStringAsFixed(1)}%',
                                    Colors.red,
                                  ),
                                  _buildAttendanceStatBadge(
                                    'Tardif',
                                    '${weekLateRate.toStringAsFixed(1)}%',
                                    Colors.orange,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              // Ce mois
                              Text(
                                'Ce mois (${monthAttendances.length} sessions)',
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
                                    'Présent',
                                    '${monthPresentRate.toStringAsFixed(1)}%',
                                    Colors.green,
                                  ),
                                  _buildAttendanceStatBadge(
                                    'Absent',
                                    '${monthAbsentRate.toStringAsFixed(1)}%',
                                    Colors.red,
                                  ),
                                  _buildAttendanceStatBadge(
                                    'Tardif',
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
                child: const Text('Fermer'),
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
                          'Groupes',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${classProvider.classes.length} groupes',
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
                      label: const Text('Ajouter'),
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
            'Aucun groupe',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Commencez par créer votre premier groupe',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _showAddClassDialog,
            icon: const Icon(Icons.add),
            label: const Text('Créer un groupe'),
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
      statusText = 'Complet';
    } else if (occupancyRate > 75) {
      statusColor = Colors.orange;
      statusText = 'Presque complet';
    } else {
      statusColor = Colors.green;
      statusText = 'Disponible';
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
                      const PopupMenuItem(
                        value: 'add_student',
                        child: ListTile(
                          leading: Icon(Icons.person_add, size: 20),
                          title: Text('Ajouter un élève'),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                      if (classModel.studentIds.isNotEmpty)
                        const PopupMenuItem(
                          value: 'remove_student',
                          child: ListTile(
                            leading: Icon(Icons.person_remove, size: 20, color: Colors.orange),
                            title: Text('Retirer un élève'),
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      const PopupMenuItem(
                        value: 'edit',
                        child: ListTile(
                          leading: Icon(Icons.edit, size: 20),
                          title: Text('Modifier le groupe'),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: ListTile(
                          leading: Icon(Icons.delete, size: 20, color: Colors.red),
                          title: Text('Supprimer le groupe'),
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
                        'Occupation',
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
      status: 'Payé',
      recordedByName: teacherName,
    );

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Reçu de paiement'),
        content: const Text('Le reçu a été généré. Que voulez-vous en faire ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Plus tard'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              final bytes = await DocumentService().generatePaymentReceipt(metadata);
              await DocumentService().sharePdf(bytes, 'recu_${payment.receiptNumber ?? payment.id}.pdf');
            },
            child: const Text('Partager'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              final bytes = await DocumentService().generatePaymentReceipt(metadata);
              await DocumentService().previewPdf(bytes);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Aperçu / Imprimer'),
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
        const SnackBar(content: Text('Ajoutez d\'abord un élève')),
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
      builder: (_) => const AlertDialog(
        content: Row(children: [
          CircularProgressIndicator(),
          SizedBox(width: 16),
          Expanded(child: Text('Génération du rapport...')),
        ]),
      ),
    );

    try {
      final attendances = context
          .read<AttendanceProvider>()
          .attendances
          .where((a) =>
              a.studentId == student.id &&
              !a.date.isBefore(weekStart) &&
              !a.date.isAfter(weekEnd))
          .toList()
        ..sort((a, b) => a.date.compareTo(b.date));

      final entries = attendances
          .map((a) => DailyEntry(
                date: a.date,
                status: _attendanceStatusLabel(a.status),
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
        SnackBar(content: Text('Erreur lors de la génération : $e'), backgroundColor: Colors.red),
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
      builder: (_) => const AlertDialog(
        content: Row(children: [
          CircularProgressIndicator(),
          SizedBox(width: 16),
          Expanded(child: Text('Génération du rapport...')),
        ]),
      ),
    );

    try {
      final attendances = context
          .read<AttendanceProvider>()
          .attendances
          .where((a) =>
              a.studentId == student.id &&
              !a.date.isBefore(monthStart) &&
              !a.date.isAfter(monthEnd))
          .toList();
      final presentDays = attendances.where((a) => a.status == AttendanceStatus.present).length;
      final absentDays = attendances.where((a) => a.status == AttendanceStatus.absent).length;

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
        presentDays: presentDays,
        absentDays: absentDays,
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
        SnackBar(content: Text('Erreur lors de la génération : $e'), backgroundColor: Colors.red),
      );
    }
  }

  String _attendanceStatusLabel(AttendanceStatus status) {
    switch (status) {
      case AttendanceStatus.present:
        return 'Présent';
      case AttendanceStatus.absent:
        return 'Absent';
      case AttendanceStatus.late:
        return 'Retard';
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
        title: const Text('Rapport généré'),
        content: const Text('Que voulez-vous faire de ce rapport ?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Plus tard')),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              await DocumentService().sharePdf(bytes, fileName);
            },
            child: const Text('Partager'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              await DocumentService().previewPdf(bytes);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Aperçu / Imprimer'),
          ),
        ],
      ),
    );
  }

  // ─── API Sync Handler ───────────────────
  Future<void> _syncFromApi() async {
    try {
      // Afficher un indicateur de chargement
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              // Expanded pour que le texte passe à la ligne au lieu de
              // déborder horizontalement — la Row d'un AlertDialog n'a
              // qu'une largeur de contenu restreinte par défaut.
              Expanded(child: Text('Synchronisation avec le serveur...')),
            ],
          ),
        ),
      );

      final studentService = context.read<StudentService>();
      await studentService.syncFromApi();
      if (!mounted) return;

      // Recharger les données
      final studentProvider = context.read<StudentProvider>();
      await studentProvider.loadStudents();

      // Rejoue les actions hors ligne en attente (CDC section 20).
      if (!mounted) return;
      await context.read<SyncQueueProvider>().replayPending();

      if (mounted) {
        Navigator.pop(context); // Fermer le dialogue de chargement
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Données synchronisées avec succès!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Fermer le dialogue de chargement
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur de synchronisation: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // ─── Logout Handler ────────────────────────
  Future<void> _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Déconnexion'),
        content: const Text('Êtes-vous sûr de vouloir vous déconnecter?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child:
                const Text('Déconnecter', style: TextStyle(color: Colors.red)),
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
            SnackBar(content: Text('Erreur déconnexion: $e')),
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
          title: const Text('Ajouter un groupe'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nom du groupe',
                    hintText: 'Ex: Groupe Nouroul Bayan',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: levelController,
                  decoration: const InputDecoration(
                    labelText: 'Niveau du groupe',
                    hintText: 'Ex: Djouzou Amma, Nouroul Bayan, etc.',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    hintText: 'Description du groupe',
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: teacherController,
                  decoration: const InputDecoration(
                    labelText: 'Nom de l\'enseignant',
                    hintText: 'Ex: Cheikh Ibrahim',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: maxStudentsController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre maximum d\'élèves',
                    hintText: 'Ex: 30 (modifiable, jusqu\'à 500)',
                    helperText: 'Vous pouvez augmenter ce nombre à tout moment.',
                  ),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
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
                      const SnackBar(
                        content: Text('Classe ajoutée avec succès!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Erreur: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              child: const Text('Ajouter'),
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
          title: Text('Modifier: ${classModel.name}'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nom du groupe',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: levelController,
                  decoration: const InputDecoration(
                    labelText: 'Niveau du groupe',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: teacherController,
                  decoration: const InputDecoration(
                    labelText: 'Nom de l\'enseignant',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: maxStudentsController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre maximum d\'élèves',
                    hintText: 'Ex: 30 (modifiable, jusqu\'à 500)',
                    helperText: 'Vous pouvez augmenter ce nombre à tout moment.',
                  ),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
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
                      const SnackBar(
                        content: Text('Classe modifiée avec succès!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Erreur: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              child: const Text('Modifier'),
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
        title: Text('Supprimer: ${classModel.name}'),
        content: Text('Êtes-vous sûr de vouloir supprimer ce groupe? Cette action est irréversible et retirera tous les élèves du groupe.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await classProvider.deleteClass(classModel.id);
                
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Classe supprimée avec succès!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Erreur: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Supprimer'),
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
          title: const Text('Ajouter un élève'),
          content: const Text('Tous les élèves sont déjà dans ce groupe.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Fermer'),
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
        title: Text('Ajouter un élève à ${groupModel.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Sélectionnez un élève à ajouter:'),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: selectedStudentId,
              decoration: const InputDecoration(
                labelText: 'Élève',
                hintText: 'Choisissez un élève',
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
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (selectedStudentId != null) {
                try {
                  await classProvider.addStudentToClass(groupModel.id, selectedStudentId!);
                  
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Élève ajouté au groupe avec succès!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Erreur: $e'),
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
            child: const Text('Ajouter'),
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
          title: const Text('Retirer un élève'),
          content: const Text('Ce groupe ne contient aucun élève.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Fermer'),
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
        title: Text('Retirer un élève de ${groupModel.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Sélectionnez un élève à retirer:'),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: selectedStudentId,
              decoration: const InputDecoration(
                labelText: 'Élève',
                hintText: 'Choisissez un élève',
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
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (selectedStudentId != null) {
                try {
                  await classProvider.removeStudentFromClass(groupModel.id, selectedStudentId!);
                  
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Élève retiré du groupe avec succès!'),
                        backgroundColor: Colors.orange,
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Erreur: $e'),
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
            child: const Text('Retirer'),
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
  late String _studentId = widget.students.first.id;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Générer un rapport'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DropdownButtonFormField<String>(
            initialValue: _studentId,
            decoration: const InputDecoration(labelText: 'Élève'),
            items: widget.students
                .map((s) => DropdownMenuItem(value: s.id, child: Text(s.name)))
                .toList(),
            onChanged: (value) => setState(() => _studentId = value ?? _studentId),
          ),
          const SizedBox(height: 16),
          Text(
            'Choisissez la période du rapport :',
            style: GoogleFonts.cairo(fontSize: 13, color: AppColors.textMedium),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
        TextButton(
          onPressed: () => widget.onWeekly(widget.students.firstWhere((s) => s.id == _studentId)),
          child: const Text('Hebdomadaire'),
        ),
        ElevatedButton(
          onPressed: () => widget.onMonthly(widget.students.firstWhere((s) => s.id == _studentId)),
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
          child: const Text('Mensuel'),
        ),
      ],
    );
  }
}
