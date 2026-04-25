import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import '../utils/app_colors.dart';
import '../providers/student_provider.dart';
import '../providers/payment_provider.dart';
import '../providers/attendance_provider.dart';
import '../providers/class_provider.dart';
import '../services/auth_service.dart';
import '../services/student_service.dart';
import '../services/payment_service.dart';
import '../services/attendance_service.dart';
import '../services/class_service.dart';
import '../widgets/common_widgets.dart';
import '../models/payment.dart';
import '../models/class_model.dart';

/// Dashboard principal pour l'utilisateur connecté
/// Gestion des élèves, paiements, présences et statistiques
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedTabIndex = 0;

  @override
  void initState() {
    super.initState();
    // Charger les données au démarrage du dashboard
    Future.microtask(() async {
      final studentProvider = context.read<StudentProvider>();
      final paymentProvider = context.read<PaymentProvider>();
      final attendanceProvider = context.read<AttendanceProvider>();
      final classProvider = context.read<ClassProvider>();

      // Synchroniser depuis Firebase d'abord (désactivé temporairement)
      try {
        // Désactivation temporaire pour débloquer l'application
        print('⏸️ Sync Firebase désactivée temporairement');
        
        // final studentService = context.read<StudentService>();
        // await studentService.syncFromFirebase();
        
        // final paymentService = context.read<PaymentService>();
        // await paymentService.syncFromFirebase();
        
        // final attendanceService = context.read<AttendanceService>();
        // await attendanceService.syncFromFirebase();
        
        // final classService = context.read<ClassService>();
        // await classService.syncFromFirebase();
        
        print('✅ Chargement local terminé');
      } catch (e) {
        print('Erreur sync automatique: $e');
      }

      // Puis charger les données locales
      studentProvider.loadStudents();
      paymentProvider.loadPayments();
      attendanceProvider.loadAttendances();
      classProvider.loadClasses();
    });
  }

  // ─── Utility Methods ───────────────────────
  /// Valide qu'un numéro de téléphone guinéen a exactement 9 chiffres
  bool _isValidGuineanPhone(String phone) {
    final digits = phone.replaceAll(RegExp(r'[^0-9]'), '');
    return digits.length == 9;
  }

  /// Formate un numéro de téléphone guinéen (ex: 622 18 09 33)
  String _formatGuineanPhone(String phone) {
    final digits = phone.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length < 9) return digits;
    return '${digits.substring(0, 3)} ${digits.substring(3, 5)} ${digits.substring(5, 7)} ${digits.substring(7, 9)}';
  }

  /// Nettoie le numéro (garde seulement les 9 chiffres)
  String _cleanPhoneNumber(String phone) {
    return phone.replaceAll(RegExp(r'[^0-9]'), '');
  }

  @override
  Widget build(BuildContext context) {
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
              'Tableau de bord Markazi',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.sync, color: Colors.white),
            onPressed: _syncFromFirebase,
            tooltip: 'Synchroniser avec Firebase',
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: _handleLogout,
            tooltip: 'Déconnexion',
          ),
        ],
      ),
      body: Column(
        children: [
          // Onglets
          Container(
            color: Colors.white,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildTabButton('Vue d\'ensemble', 0),
                  _buildTabButton('Élèves', 1),
                  _buildTabButton('Groupes', 2),
                  _buildTabButton('Paiements', 3),
                  _buildTabButton('Présences', 4),
                  _buildTabButton('Rapports', 5),
                ],
              ),
            ),
          ),
          // Contenu des onglets
          Expanded(
            child: _buildTabContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(String label, int index) {
    final isActive = _selectedTabIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTabIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isActive ? AppColors.primary : Colors.transparent,
              width: 3,
            ),
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
            color: isActive ? AppColors.primary : Colors.grey,
          ),
        ),
      ),
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
            builder: (context, studentProvider, paymentProvider,
                attendanceProvider, _) {
              return GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                children: [
                  _buildStatCard(
                    'Élèves',
                    studentProvider.students.length.toString(),
                    Icons.people,
                    AppColors.primary,
                  ),
                  _buildStatCard(
                    'Paiements',
                    paymentProvider.payments.length.toString(),
                    Icons.payments,
                    Colors.blue,
                  ),
                  _buildStatCard(
                    'Présences',
                    attendanceProvider.attendances.length.toString(),
                    Icons.calendar_today,
                    Colors.orange,
                  ),
                  _buildStatCard(
                    'Récitations',
                    '${attendanceProvider.attendances.length}',
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
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildActionButton('Ajouter', Icons.person_add),
              _buildActionButton('Paiement', Icons.add_card),
              _buildActionButton('Présence', Icons.check_circle),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 24,
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

  Widget _buildActionButton(String label, IconData icon) {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            if (label.contains('Ajouter')) {
              _showAddStudentDialog();
            } else if (label.contains('Paiement')) {
              _showAddPaymentDialog();
            } else if (label.contains('Présence')) {
              _showMarkAttendanceDialog();
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Feature: $label - Coming soon!')),
              );
            }
          },
          child: Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primary, size: 28),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // ─── STUDENTS TAB ──────────────────────────
  Widget _buildStudentsTab() {
    return Consumer<StudentProvider>(
      builder: (context, studentProvider, _) {
        if (studentProvider.students.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.people_outline, size: 64, color: Colors.grey[300]),
                const SizedBox(height: 16),
                Text(
                  'Aucun élève enregistré',
                  style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: _showAddStudentDialog,
                  icon: const Icon(Icons.add),
                  label: const Text('Ajouter un élève'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: studentProvider.students.length,
          itemBuilder: (context, index) {
            final student = studentProvider.students[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                onTap: () => _showStudentDetails(student),
                leading: CircleAvatar(
                  backgroundColor: AppColors.primary.withOpacity(0.2),
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
        );
      },
    );
  }

  // ─── PAYMENTS TAB ──────────────────────────
  Widget _buildPaymentsTab() {
    return Consumer2<PaymentProvider, StudentProvider>(
      builder: (context, paymentProvider, studentProvider, _) {
        if (paymentProvider.payments.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.payments_outlined,
                    size: 64, color: Colors.grey[300]),
                const SizedBox(height: 16),
                Text(
                  'Aucun paiement enregistré',
                  style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: paymentProvider.payments.length,
          itemBuilder: (context, index) {
            final payment = paymentProvider.payments[index];
            // Trouver le nom de l'élève
            final student = studentProvider.students.firstWhere(
                (s) => s.id == payment.studentId,
                orElse: () => null as dynamic);
            final studentName = student?.name ?? 'Élève inconnu';

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                onTap: () => _showPaymentDetails(payment, studentName, student),
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: payment.status.toString().contains('paid')
                        ? Colors.green.withOpacity(0.2)
                        : Colors.orange.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    payment.status.toString().contains('paid')
                        ? Icons.check_circle
                        : Icons.hourglass_empty,
                    color: payment.status.toString().contains('paid')
                        ? Colors.green
                        : Colors.orange,
                  ),
                ),
                title: Text(studentName),
                subtitle: Text(payment.date.toString().split(' ')[0]),
                trailing: Text(
                  '${payment.amount} FGN',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Colors.blue,
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ─── ATTENDANCE TAB ────────────────────────
  Widget _buildAttendanceTab() {
    return Consumer2<AttendanceProvider, StudentProvider>(
      builder: (context, attendanceProvider, studentProvider, _) {
        if (attendanceProvider.attendances.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.calendar_today_outlined,
                    size: 64, color: Colors.grey[300]),
                const SizedBox(height: 16),
                Text(
                  'Aucune présence enregistrée',
                  style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: attendanceProvider.attendances.length,
          itemBuilder: (context, index) {
            final attendance = attendanceProvider.attendances[index];
            // Trouver le nom de l'élève
            final student = studentProvider.students.firstWhere(
                (s) => s.id == attendance.studentId,
                orElse: () => null as dynamic);
            final studentName = student?.name ?? 'Élève inconnu';

            // Déterminer le statut et la couleur
            final isPresent = attendance.status.toString().contains('present');
            final isAbsent = attendance.status.toString().contains('absent');
            final isLate = attendance.status.toString().contains('late');

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
                    color: statusColor.withOpacity(0.2),
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
              onPressed: _generatePdfReport,
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
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.primary.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary, size: 24),
            const SizedBox(width: 12),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
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
                    hintText: '622180933',
                    helperText: 'Format: 9 chiffres (ex: 622180933)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon: const Icon(Icons.phone),
                  ),
                  keyboardType: TextInputType.phone,
                  onChanged: (value) {
                    // Affiche le numéro formaté au fur et à mesure
                    if (value.isNotEmpty) {
                      final formatted = _formatGuineanPhone(value);
                      // Optionnel: afficher la preview formatée
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
                          'Numéro invalide! Utilisez 9 chiffres (ex: 622180933)'),
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

                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Élève ajouté avec succès!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                    Navigator.pop(context);
                  }
                } catch (e) {
                  if (mounted) {
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
                    hintText: '622180933',
                    helperText: 'Format: 9 chiffres (ex: 622180933)',
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
                          'Numéro invalide! Utilisez 9 chiffres (ex: 622180933)'),
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

                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Élève modifié avec succès!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                    Navigator.pop(context);
                  }
                } catch (e) {
                  if (mounted) {
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
        title: const Text('Confirmer la suppression'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Êtes-vous sûr de vouloir supprimer cet élève?'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.withOpacity(0.3)),
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
              'Cette action est irréversible et supprimera également toutes les données associées (paiements, présences).',
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

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Élève supprimé avec succès!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  Navigator.pop(context);
                }
              } catch (e) {
                if (mounted) {
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
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  // ─── Add Payment Dialog ────────────────────
  // ─── Payment Dialog ───────────────────────
  String _getCurrentMonth() {
    final now = DateTime.now();
    final months = [
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
    return '${months[now.month - 1]} ${now.year}';
  }

  List<String> _getMonthsList() {
    final months = [
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
    final now = DateTime.now();
    final monthsList = <String>[];

    // Afficher les 12 derniers mois
    for (int i = 0; i < 12; i++) {
      final date = DateTime(now.year, now.month - i, 1);
      monthsList.add('${months[date.month - 1]} ${date.year}');
    }
    return monthsList;
  }

  void _showAddPaymentDialog() {
    String? selectedStudentId;
    final amountController = TextEditingController();
    String selectedStatus = 'paid';
    String selectedMonth = _getCurrentMonth();

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
                      value: selectedStudentId,
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
                        labelText: 'Montant (FGN)',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: const Icon(Icons.attach_money),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: selectedMonth,
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
                        return DropdownMenuItem<String>(
                          value: month,
                          child: Text(month),
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
                      value: selectedStatus,
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

                    try {
                      final amount = double.parse(amountController.text);
                      final paymentProvider = context.read<PaymentProvider>();
                      await paymentProvider.addPayment(
                        studentId: selectedStudentId!,
                        amount: amount,
                        status: selectedStatus == 'paid'
                            ? PaymentStatus.paid
                            : PaymentStatus.unpaid,
                      );

                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                'Paiement pour $selectedMonth enregistré!'),
                            backgroundColor: Colors.green,
                          ),
                        );
                        Navigator.pop(context);
                      }
                    } catch (e) {
                      if (mounted) {
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
                      value: selectedStudentId,
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
                      value: selectedStatus,
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

                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Présence enregistrée avec succès!'),
                            backgroundColor: Colors.green,
                          ),
                        );
                        Navigator.pop(context);
                      }
                    } catch (e) {
                      if (mounted) {
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
              .where((a) => a.status.toString().contains('present'))
              .length;
          final absent = weeklyAttendances
              .where((a) => a.status.toString().contains('absent'))
              .length;
          final late = weeklyAttendances
              .where((a) => a.status.toString().contains('late'))
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
              .where((a) => a.status.toString().contains('present'))
              .length;
          final absent = monthlyAttendances
              .where((a) => a.status.toString().contains('absent'))
              .length;
          final late = monthlyAttendances
              .where((a) => a.status.toString().contains('late'))
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
            if (payment.status.toString().contains('paid')) {
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
                      '${totalPaid.toStringAsFixed(2)} FGN', Colors.green),
                  const SizedBox(height: 12),
                  _buildReportStat('Total en attente',
                      '${totalUnpaid.toStringAsFixed(2)} FGN', Colors.orange),
                  const SizedBox(height: 12),
                  _buildReportStat(
                      'Total général',
                      '${(totalPaid + totalUnpaid).toStringAsFixed(2)} FGN',
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
              .where((a) => a.status.toString().contains('present'))
              .length;
          final paidCount = paymentProvider.payments
              .where((p) => p.status.toString().contains('paid'))
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
    final isPaid = payment.status.toString().contains('paid');
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
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.withOpacity(0.3)),
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
                '${payment.amount} FGN',
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
              onPressed: () {
                // Marquer comme payé
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Paiement marqué comme payé'),
                    backgroundColor: Colors.green,
                  ),
                );
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
              child: const Text('Marquer comme payé'),
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
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.withOpacity(0.3)),
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
        ],
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
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              value,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
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
              .where((p) => p.status.toString().contains('paid'))
              .length;

          final totalPayments =
              studentPayments.fold<double>(0, (sum, p) => sum + p.amount);

          final paidAmount = studentPayments
              .where((p) => p.status.toString().contains('paid'))
              .fold<double>(0, (sum, p) => sum + p.amount);

          // Récupérer les présences de cet élève
          final studentAttendances = attendanceProvider.attendances
              .where((a) => a.studentId == student.id)
              .toList();

          final presentCount = studentAttendances
              .where((a) => a.status.toString().contains('present'))
              .length;

          final absentCount = studentAttendances
              .where((a) => a.status.toString().contains('absent'))
              .length;

          final lateCount = studentAttendances
              .where((a) => a.status.toString().contains('late'))
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
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border:
                          Border.all(color: AppColors.primary.withOpacity(0.3)),
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
                    '$paidAmount FGN',
                    Colors.green,
                  ),
                  const SizedBox(height: 8),
                  _buildStudentDetailRow(
                    'Total en attente',
                    '${totalPayments - paidAmount} FGN',
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
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 13,
            color: Colors.grey[600],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 13,
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
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              value,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
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
                          .where((a) => a.status.toString().contains('present'))
                          .length;

                      final weekRate = weekAttendances.isNotEmpty
                          ? ((weekPresent / weekAttendances.length) * 100)
                          : 0.0;

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
                          .where((a) => a.status.toString().contains('present'))
                          .length;

                      final monthAbsent = monthAttendances
                          .where((a) => a.status.toString().contains('absent'))
                          .length;

                      final monthLate = monthAttendances
                          .where((a) => a.status.toString().contains('late'))
                          .length;

                      // Calculer les taux pour la semaine
                      final weekAbsent = weekAttendances
                          .where((a) => a.status.toString().contains('absent'))
                          .length;

                      final weekLate = weekAttendances
                          .where((a) => a.status.toString().contains('late'))
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
                    }).toList()
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
        Text(label, style: GoogleFonts.poppins(fontSize: 14)),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: color,
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
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
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
                padding: const EdgeInsets.all(20),
                color: Colors.white,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Gestion des Groupes',
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${classProvider.classes.length} groupes au total',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
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
                          horizontal: 16,
                          vertical: 8,
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
        onTap: () => _showClassDetails(classModel),
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
                      color: statusColor.withOpacity(0.1),
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
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Informations détaillées
              Row(
                children: [
                  Icon(Icons.person, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    classModel.teacherName,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Colors.grey[700],
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
                    Text(
                      classModel.schedule!,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: Colors.grey[700],
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
                    Text(
                      classModel.room!,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: Colors.grey[700],
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
              
              const SizedBox(height: 12),
              
              // Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () => _showAddStudentToGroupDialog(classModel),
                    icon: const Icon(Icons.person_add, size: 16),
                    label: const Text('Ajouter élève'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  TextButton.icon(
                    onPressed: () => _showEditClassDialog(classModel),
                    icon: const Icon(Icons.edit, size: 16),
                    label: const Text('Modifier'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primary,
                    ),
                  ),
                  if (classModel.studentIds.isEmpty)
                    TextButton.icon(
                      onPressed: () => _showDeleteClassDialog(classModel, classProvider),
                      icon: const Icon(Icons.delete, size: 16),
                      label: const Text('Supprimer'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.red,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── PDF Export ────────────────────────────
  Future<void> _generatePdfReport() async {
    try {
      // Afficher le dialogue de chargement
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Génération du PDF en cours...'),
            ],
          ),
        ),
      );

      // Récupérer les données
      final studentProvider = context.read<StudentProvider>();
      final paymentProvider = context.read<PaymentProvider>();
      final attendanceProvider = context.read<AttendanceProvider>();
      final authService = context.read<AuthService>();

      final students = studentProvider.students;
      final payments = paymentProvider.payments;
      final attendances = attendanceProvider.attendances;

      // Créer le document PDF
      final pdf = pw.Document();
      final dateNow = DateTime.now();
      final dateStr = '${dateNow.day.toString().padLeft(2, '0')}/${dateNow.month.toString().padLeft(2, '0')}/${dateNow.year}';

      // Ajouter la page principale
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // En-tête
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'RAPPORT MARKAZI',
                          style: pw.TextStyle(
                            fontSize: 24,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColor.fromHex(AppColors.primary.value.toRadixString(16).padLeft(8, '0')),
                          ),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          'Markaz: ${authService.currentMarkazId ?? 'N/A'}',
                          style: const pw.TextStyle(fontSize: 14),
                        ),
                        pw.Text(
                          'Date: $dateStr',
                          style: const pw.TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ],
                ),
                pw.SizedBox(height: 20),
                
                // Statistiques élèves
                _buildPdfSection('STATISTIQUES ÉLÈVES', [
                  'Nombre total d\'élèves: ${students.length}',
                  'Élèves actifs: ${students.where((s) => true).length}',
                ]),
                
                pw.SizedBox(height: 16),
                
                // Statistiques paiements
                _buildPdfSection('STATISTIQUES PAIEMENTS', [
                  'Total des paiements: ${payments.length}',
                  'Montant total: ${payments.fold(0.0, (sum, p) => sum + p.amount).toStringAsFixed(2)} MAD',
                  'Paiements en attente: ${payments.where((p) => p.status.name == 'unpaid').length}',
                ]),
                
                pw.SizedBox(height: 16),
                
                // Statistiques présences
                _buildPdfSection('STATISTIQUES PRÉSENCES', [
                  'Total des présences: ${attendances.length}',
                  'Présents aujourd\'hui: ${attendances.where((a) => 
                    a.status.name == 'present' && 
                    a.date.day == dateNow.day && 
                    a.date.month == dateNow.month && 
                    a.date.year == dateNow.year
                  ).length}',
                  'Absents aujourd\'hui: ${attendances.where((a) => 
                    a.status.name == 'absent' && 
                    a.date.day == dateNow.day && 
                    a.date.month == dateNow.month && 
                    a.date.year == dateNow.year
                  ).length}',
                ]),
                
                pw.SizedBox(height: 20),
                
                // Tableau des élèves
                pw.Text(
                  'LISTE DES ÉLÈVES',
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 8),
                
                // Tableau
                pw.Table.fromTextArray(
                  context: context,
                  data: [
                    ['Nom', 'Téléphone', 'Statut'],
                    ...students.map((student) => [
                      student.name,
                      student.parentPhone,
                      'Actif',
                    ]),
                  ],
                  border: pw.TableBorder.all(color: PdfColors.grey300),
                  headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  headerDecoration: const pw.BoxDecoration(color: PdfColors.grey100),
                  cellAlignments: {
                    0: pw.Alignment.centerLeft,
                    1: pw.Alignment.center,
                    2: pw.Alignment.center,
                  },
                ),
              ],
            );
          },
        ),
      );

      // Sauvegarder et imprimer
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
        name: 'rapport_markazi_${dateNow.day}${dateNow.month}${dateNow.year}.pdf',
      );

      if (mounted) {
        Navigator.pop(context); // Fermer le dialogue de chargement
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('PDF généré avec succès!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Fermer le dialogue de chargement
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la génération du PDF: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Helper pour construire une section PDF
  pw.Widget _buildPdfSection(String title, List<String> items) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            title,
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 8),
          ...items.map((item) => pw.Text(
            item,
            style: const pw.TextStyle(fontSize: 12),
          )),
        ],
      ),
    );
  }

  // ─── Firebase Sync Handler ───────────────────
  Future<void> _syncFromFirebase() async {
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
              Text('Synchronisation avec Firebase...'),
            ],
          ),
        ),
      );

      final studentService = context.read<StudentService>();
      await studentService.syncFromFirebase();

      // Recharger les données
      final studentProvider = context.read<StudentProvider>();
      await studentProvider.loadStudents();

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
    final maxStudentsController = TextEditingController(text: '20');
    final scheduleController = TextEditingController();
    final roomController = TextEditingController();

    String selectedLevel = 'Débutant';
    String selectedSchedule = '';
    String selectedRoom = '';

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
                    labelText: 'Nom de la classe',
                    hintText: 'Ex: Classe A',
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selectedLevel,
                  decoration: const InputDecoration(
                    labelText: 'Niveau',
                  ),
                  items: ClassService.predefinedLevels.map((level) {
                    return DropdownMenuItem(
                      value: level,
                      child: Text(level),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedLevel = value!;
                    });
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    hintText: 'Description de la classe',
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
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selectedSchedule.isEmpty ? null : selectedSchedule,
                  decoration: const InputDecoration(
                    labelText: 'Emploi du temps (optionnel)',
                  ),
                  items: ClassService.predefinedSchedules.map((schedule) {
                    return DropdownMenuItem(
                      value: schedule,
                      child: Text(schedule),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedSchedule = value!;
                    });
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selectedRoom.isEmpty ? null : selectedRoom,
                  decoration: const InputDecoration(
                    labelText: 'Salle (optionnel)',
                  ),
                  items: ClassService.predefinedRooms.map((room) {
                    return DropdownMenuItem(
                      value: room,
                      child: Text(room),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedRoom = value!;
                    });
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
                try {
                  final classProvider = context.read<ClassProvider>();
                  await classProvider.addClass(
                    name: nameController.text,
                    level: selectedLevel,
                    description: descriptionController.text,
                    teacherName: teacherController.text,
                    maxStudents: int.tryParse(maxStudentsController.text) ?? 20,
                    schedule: selectedSchedule.isEmpty ? null : selectedSchedule,
                    room: selectedRoom.isEmpty ? null : selectedRoom,
                  );
                  
                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Classe ajoutée avec succès!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
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
    final scheduleController = TextEditingController(text: classModel.schedule ?? '');
    final roomController = TextEditingController(text: classModel.room ?? '');

    String selectedLevel = classModel.level;
    String selectedSchedule = classModel.schedule ?? '';
    String selectedRoom = classModel.room ?? '';

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
                    labelText: 'Nom de la classe',
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selectedLevel,
                  decoration: const InputDecoration(
                    labelText: 'Niveau',
                  ),
                  items: ClassService.predefinedLevels.map((level) {
                    return DropdownMenuItem(
                      value: level,
                      child: Text(level),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedLevel = value!;
                    });
                  },
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
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selectedSchedule.isEmpty ? null : selectedSchedule,
                  decoration: const InputDecoration(
                    labelText: 'Emploi du temps (optionnel)',
                  ),
                  items: ClassService.predefinedSchedules.map((schedule) {
                    return DropdownMenuItem(
                      value: schedule,
                      child: Text(schedule),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedSchedule = value!;
                    });
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selectedRoom.isEmpty ? null : selectedRoom,
                  decoration: const InputDecoration(
                    labelText: 'Salle (optionnel)',
                  ),
                  items: ClassService.predefinedRooms.map((room) {
                    return DropdownMenuItem(
                      value: room,
                      child: Text(room),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedRoom = value!;
                    });
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
                try {
                  final classProvider = context.read<ClassProvider>();
                  await classProvider.updateClass(
                    classId: classModel.id,
                    name: nameController.text,
                    level: selectedLevel,
                    description: descriptionController.text,
                    teacherName: teacherController.text,
                    maxStudents: int.tryParse(maxStudentsController.text) ?? 20,
                    schedule: selectedSchedule.isEmpty ? null : selectedSchedule,
                    room: selectedRoom.isEmpty ? null : selectedRoom,
                  );
                  
                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Classe modifiée avec succès!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
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
        content: Text('Êtes-vous sûr de vouloir supprimer cette classe? Cette action est irréversible.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await classProvider.deleteClass(classModel.id);
                
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Classe supprimée avec succès!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
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

  void _showClassDetails(ClassModel classModel) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(classModel.name),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Niveau', classModel.level),
              _buildDetailRow('Description', classModel.description),
              _buildDetailRow('Enseignant', classModel.teacherName),
              _buildDetailRow('Capacité', '${classModel.currentStudentCount}/${classModel.maxStudents} élèves'),
              if (classModel.schedule != null)
                _buildDetailRow('Emploi du temps', classModel.schedule!),
              if (classModel.room != null)
                _buildDetailRow('Salle', classModel.room!),
              _buildDetailRow('Statut', classModel.isActive ? 'Active' : 'Inactive'),
              _buildDetailRow('Date de création', '${classModel.createdAt.day}/${classModel.createdAt.month}/${classModel.createdAt.year}'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                color: Colors.black87,
              ),
            ),
          ),
        ],
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
              value: selectedStudentId,
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
                  
                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Élève ajouté au groupe avec succès!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
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
}
