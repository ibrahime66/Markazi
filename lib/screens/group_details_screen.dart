import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../utils/app_colors.dart';
import '../providers/class_provider.dart';
import '../providers/student_provider.dart';
import '../providers/payment_provider.dart';
import '../providers/attendance_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/markaz_provider.dart';
import '../models/class_model.dart';
import '../models/student.dart';
import '../models/payment.dart';
import '../models/attendance.dart';
import '../l10n/app_localizations.dart';

class GroupDetailsScreen extends StatefulWidget {
  final ClassModel group;

  const GroupDetailsScreen({super.key, required this.group});

  @override
  State<GroupDetailsScreen> createState() => _GroupDetailsScreenState();
}

class _GroupDetailsScreenState extends State<GroupDetailsScreen> {
  /// Textes traduits (doc/audit.md K8).
  AppLocalizations get _l10n => AppLocalizations.of(context);

  /// Devise configurée pour ce Markaz (doc/audit.md, point I4).
  String get _currency => context.read<MarkazProvider>().markaz?.currency ?? 'GNF';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    Future.microtask(() {
      if (!mounted) return;
      final studentProvider = context.read<StudentProvider>();
      final paymentProvider = context.read<PaymentProvider>();
      final attendanceProvider = context.read<AttendanceProvider>();
      
      studentProvider.loadStudents();
      paymentProvider.loadPayments();
      attendanceProvider.loadAttendances();
    });
  }

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeProvider>();
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: Text(
          widget.group.name,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer4<ClassProvider, StudentProvider, PaymentProvider, AttendanceProvider>(
        builder: (context, classProvider, studentProvider, paymentProvider, attendanceProvider, _) {
          // Récupérer les élèves du groupe (uniquement les élèves existants)
          final groupStudents = widget.group.studentIds
              .map((studentId) {
                final student = studentProvider.students
                    .where((s) => s.id == studentId)
                    .firstOrNull;
                return student;
              })
              .where((student) => student != null)
              .cast<Student>()
              .toList();

          // Calculer les statistiques
          final stats = _calculateGroupStats(groupStudents, paymentProvider.payments, attendanceProvider.attendances);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Informations du groupe
                _buildGroupInfo(),
                const SizedBox(height: 20),

                // Statistiques du groupe
                _buildGroupStats(stats),
                const SizedBox(height: 20),

                // Liste des élèves
                _buildStudentsList(groupStudents, paymentProvider.payments, attendanceProvider.attendances),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildGroupInfo() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _l10n.groupInfoTitle,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            _buildInfoRow(_l10n.fieldLevel, widget.group.level),
            _buildInfoRow(_l10n.fieldTeacher, widget.group.teacherName),
            _buildInfoRow(_l10n.fieldCapacity, _l10n.groupCapacityValue(widget.group.studentIds.length, widget.group.maxStudents)),
            if (widget.group.description.isNotEmpty)
              _buildInfoRow(_l10n.fieldDescription, widget.group.description),
            if (widget.group.schedule != null)
              _buildInfoRow(_l10n.fieldSchedule, widget.group.schedule!),
            if (widget.group.room != null)
              _buildInfoRow(_l10n.fieldRoom, widget.group.room!),
            _buildInfoRow(_l10n.fieldStatus, widget.group.isActive ? _l10n.commonActive : _l10n.commonInactive),
            _buildInfoRow(_l10n.fieldCreatedOn,
                '${widget.group.createdAt.day}/${widget.group.createdAt.month}/${widget.group.createdAt.year}'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                color: Colors.black87,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupStats(Map<String, dynamic> stats) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _l10n.groupStatsTitle,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _buildStatCard(_l10n.navStudents, '${stats['totalStudents']}', Icons.people, AppColors.primary),
                _buildStatCard(_l10n.statAttendanceRate, '${stats['attendanceRate']}%', Icons.calendar_today, Colors.green),
                _buildStatCard(_l10n.statPaymentRate, '${stats['paymentRate']}%', Icons.payments, Colors.blue),
                _buildStatCard(_l10n.statTotalPaid, '${stats['totalPaid']} $_currency', Icons.account_balance, Colors.orange),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      width: 140,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentsList(List<Student> students, List<Payment> payments, List<Attendance> attendances) {
    if (students.isEmpty) {
      return Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Center(
            child: Column(
              children: [
                Icon(Icons.people_outline, size: 48, color: Colors.grey[400]),
                const SizedBox(height: 12),
                Text(
                  _l10n.groupNoStudents,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Card(
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête du tableau
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: Text(
              _l10n.groupStudentsTitle,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
          // En-têtes des colonnes
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    _l10n.fieldStudentName,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    _l10n.syncEntityPayment,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    _l10n.syncEntityAttendance,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    _l10n.fieldAmount,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
          // Lignes des élèves
          ...students.asMap().entries.map((entry) {
            final index = entry.key;
            final student = entry.value;
            return _buildStudentTableRow(student, payments, attendances, index.isEven);
          }),
        ],
      ),
    );
  }

  Widget _buildStudentTableRow(Student student, List<Payment> payments, List<Attendance> attendances, bool isEven) {
    final studentPayments = payments.where((p) => p.studentId == student.id).toList();
    final studentAttendances = attendances.where((a) => a.studentId == student.id).toList();
    
    final paidAmount = studentPayments.where((p) => p.status == PaymentStatus.paid).fold(0.0, (sum, p) => sum + p.amount);
    final totalAmount = studentPayments.fold(0.0, (sum, p) => sum + p.amount);
    final attendanceRate = studentAttendances.isEmpty ? 0.0 :
        (studentAttendances.where((a) => a.status == AttendanceStatus.present).length / studentAttendances.length * 100);
    final paymentRate = totalAmount == 0 ? 0.0 : (paidAmount / totalAmount * 100);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isEven ? AppColors.surface : AppColors.background,
        border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Row(
        children: [
          // Nom de l'élève
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  student.name,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(Icons.phone, size: 12, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        student.parentPhone,
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: Colors.grey[600],
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Paiement en pourcentage
          Expanded(
            flex: 2,
            child: _buildPercentageCell(paymentRate, isPayment: true),
          ),
          // Présence en pourcentage
          Expanded(
            flex: 2,
            child: _buildPercentageCell(attendanceRate, isPayment: false),
          ),
          // Montant payé
          Expanded(
            flex: 2,
            child: Column(
              children: [
                Text(
                  '${paidAmount.toInt()}',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue,
                  ),
                  textAlign: TextAlign.center,
                ),
                Text(
                  _currency,
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPercentageCell(double percentage, {required bool isPayment}) {
    Color color;
    IconData icon;
    
    if (isPayment) {
      if (percentage >= 80) {
        color = Colors.green;
        icon = Icons.check_circle;
      } else if (percentage >= 50) {
        color = Colors.orange;
        icon = Icons.schedule;
      } else {
        color = Colors.red;
        icon = Icons.error;
      }
    } else {
      if (percentage >= 80) {
        color = Colors.green;
        icon = Icons.check_circle;
      } else if (percentage >= 50) {
        color = Colors.orange;
        icon = Icons.warning;
      } else {
        color = Colors.red;
        icon = Icons.error;
      }
    }

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 4),
            Text(
              '${percentage.toStringAsFixed(0)}%',
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
        // Barre de progression
        Container(
          height: 4,
          margin: const EdgeInsets.only(top: 4),
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(2),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: percentage / 100,
            child: Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Map<String, dynamic> _calculateGroupStats(List<Student> students, List<Payment> payments, List<Attendance> attendances) {
    if (students.isEmpty) {
      return {
        'totalStudents': 0,
        'attendanceRate': 0.0,
        'paymentRate': 0.0,
        'totalPaid': 0,
      };
    }

    double totalAttendanceRate = 0;
    double totalPaymentRate = 0;
    double totalPaid = 0;

    for (final student in students) {
      final studentPayments = payments.where((p) => p.studentId == student.id).toList();
      final studentAttendances = attendances.where((a) => a.studentId == student.id).toList();
      
      final paidAmount = studentPayments.where((p) => p.status == PaymentStatus.paid).fold(0.0, (sum, p) => sum + p.amount);
      final totalAmount = studentPayments.fold(0.0, (sum, p) => sum + p.amount);

      final attendanceRate = studentAttendances.isEmpty ? 0.0 :
          (studentAttendances.where((a) => a.status == AttendanceStatus.present).length / studentAttendances.length * 100);
      final paymentRate = totalAmount == 0 ? 0.0 : (paidAmount / totalAmount * 100);
      
      totalAttendanceRate += attendanceRate;
      totalPaymentRate += paymentRate;
      totalPaid += paidAmount;
    }

    return {
      'totalStudents': students.length,
      'attendanceRate': students.isEmpty ? 0.0 : (totalAttendanceRate / students.length),
      'paymentRate': students.isEmpty ? 0.0 : (totalPaymentRate / students.length),
      'totalPaid': totalPaid.toInt(),
    };
  }
}
