import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/recitation.dart';
import '../models/student.dart';
import '../providers/recitation_provider.dart';
import '../providers/student_provider.dart';
import '../utils/app_colors.dart';
import '../widgets/common_widgets.dart';

/// Écran de suivi des récitations coraniques (CDC section 8.5) — module
/// ajouté pour combler doc/audit.md, point B1.
class RecitationScreen extends StatefulWidget {
  const RecitationScreen({super.key});

  @override
  State<RecitationScreen> createState() => _RecitationScreenState();
}

class _RecitationScreenState extends State<RecitationScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      context.read<RecitationProvider>().loadRecitations();
      context.read<StudentProvider>().loadStudents();
    });
  }

  void _openForm({Recitation? recitation}) {
    final students = context.read<StudentProvider>().students;
    if (students.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ajoutez d\'abord un élève')),
      );
      return;
    }
    showDialog(
      context: context,
      builder: (_) => _RecitationFormDialog(recitation: recitation, students: students),
    );
  }

  Future<void> _confirmDelete(Recitation recitation) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Supprimer cette séance ?'),
        content: const Text('Cette récitation sera définitivement supprimée.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annuler')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    try {
      await context.read<RecitationProvider>().removeRecitation(recitation.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Récitation supprimée'), backgroundColor: Colors.green),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur : $e'), backgroundColor: Colors.red),
      );
    }
  }

  Color _statusColor(RecitationStatus status) {
    switch (status) {
      case RecitationStatus.recited:
        return Colors.green;
      case RecitationStatus.partial:
        return Colors.orange;
      case RecitationStatus.notRecited:
        return Colors.red;
    }
  }

  String _statusLabel(RecitationStatus status) {
    switch (status) {
      case RecitationStatus.recited:
        return 'Récité';
      case RecitationStatus.partial:
        return 'Partiel';
      case RecitationStatus.notRecited:
        return 'Non récité';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const MarkaziAppBar(title: 'Récitations'),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () => _openForm(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Consumer2<RecitationProvider, StudentProvider>(
        builder: (context, recitationProvider, studentProvider, _) {
          final recitations = recitationProvider.recitations.toList()
            ..sort((a, b) => b.date.compareTo(a.date));

          if (recitations.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.menu_book_outlined, size: 56, color: AppColors.textMedium.withValues(alpha: 0.4)),
                    const SizedBox(height: 16),
                    Text(
                      'Aucune récitation enregistrée',
                      style: GoogleFonts.cairo(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textDark),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Enregistrez la sourate étudiée par chaque élève après chaque séance.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.cairo(fontSize: 13, color: AppColors.textMedium),
                    ),
                  ],
                ),
              ),
            );
          }

          String studentName(String id) {
            final match = studentProvider.students.where((s) => s.id == id);
            return match.isEmpty ? 'Élève supprimé' : match.first.name;
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: recitations.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final recitation = recitations[index];
              final range = (recitation.ayahFrom != null && recitation.ayahTo != null)
                  ? ' (versets ${recitation.ayahFrom}-${recitation.ayahTo})'
                  : '';
              return Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2)),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 6,
                      height: 44,
                      decoration: BoxDecoration(
                        color: _statusColor(recitation.status),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(studentName(recitation.studentId),
                              style: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                          const SizedBox(height: 2),
                          Text('${recitation.surah}$range',
                              style: GoogleFonts.cairo(fontSize: 12, color: AppColors.textMedium)),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: _statusColor(recitation.status).withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(_statusLabel(recitation.status),
                                    style: GoogleFonts.cairo(fontSize: 11, fontWeight: FontWeight.w600, color: _statusColor(recitation.status))),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${recitation.date.day}/${recitation.date.month}/${recitation.date.year}',
                                style: GoogleFonts.cairo(fontSize: 11, color: AppColors.textMedium),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, size: 20),
                      color: AppColors.textMedium,
                      onPressed: () => _openForm(recitation: recitation),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 20),
                      color: Colors.red,
                      onPressed: () => _confirmDelete(recitation),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _RecitationFormDialog extends StatefulWidget {
  final Recitation? recitation;
  final List<Student> students;

  const _RecitationFormDialog({this.recitation, required this.students});

  @override
  State<_RecitationFormDialog> createState() => _RecitationFormDialogState();
}

class _RecitationFormDialogState extends State<_RecitationFormDialog> {
  late String _studentId = widget.recitation?.studentId ?? widget.students.first.id;
  late DateTime _date = widget.recitation?.date ?? DateTime.now();
  late final _surahController = TextEditingController(text: widget.recitation?.surah);
  late final _ayahFromController = TextEditingController(text: widget.recitation?.ayahFrom?.toString());
  late final _ayahToController = TextEditingController(text: widget.recitation?.ayahTo?.toString());
  late final _noteController = TextEditingController(text: widget.recitation?.note);
  late RecitationStatus _status = widget.recitation?.status ?? RecitationStatus.recited;
  bool _isSaving = false;

  @override
  void dispose() {
    _surahController.dispose();
    _ayahFromController.dispose();
    _ayahToController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _save() async {
    if (_surahController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('La sourate est obligatoire')),
      );
      return;
    }

    setState(() => _isSaving = true);
    final provider = context.read<RecitationProvider>();
    final ayahFrom = int.tryParse(_ayahFromController.text);
    final ayahTo = int.tryParse(_ayahToController.text);

    try {
      if (widget.recitation == null) {
        await provider.addRecitation(
          studentId: _studentId,
          date: _date,
          surah: _surahController.text,
          status: _status,
          ayahFrom: ayahFrom,
          ayahTo: ayahTo,
          note: _noteController.text,
        );
      } else {
        await provider.updateRecitation(
          recitationId: widget.recitation!.id,
          studentId: _studentId,
          date: _date,
          surah: _surahController.text,
          status: _status,
          ayahFrom: ayahFrom,
          ayahTo: ayahTo,
          note: _noteController.text,
        );
      }
      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur : $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.recitation != null;
    return AlertDialog(
      title: Text(isEdit ? 'Modifier la récitation' : 'Enregistrer une récitation'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              initialValue: _studentId,
              decoration: const InputDecoration(labelText: 'Élève *'),
              items: widget.students
                  .map((s) => DropdownMenuItem(value: s.id, child: Text(s.name)))
                  .toList(),
              onChanged: (value) => setState(() => _studentId = value ?? _studentId),
            ),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text('Date : ${_date.day}/${_date.month}/${_date.year}'),
              trailing: const Icon(Icons.calendar_today, size: 18),
              onTap: _pickDate,
            ),
            const SizedBox(height: 4),
            TextField(
              controller: _surahController,
              decoration: const InputDecoration(labelText: 'Sourate *', prefixIcon: Icon(Icons.menu_book_outlined)),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _ayahFromController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Verset début'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _ayahToController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Verset fin'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<RecitationStatus>(
              initialValue: _status,
              decoration: const InputDecoration(labelText: 'Statut'),
              items: const [
                DropdownMenuItem(value: RecitationStatus.recited, child: Text('Récité')),
                DropdownMenuItem(value: RecitationStatus.partial, child: Text('Partiel')),
                DropdownMenuItem(value: RecitationStatus.notRecited, child: Text('Non récité')),
              ],
              onChanged: (value) => setState(() => _status = value ?? _status),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _noteController,
              decoration: const InputDecoration(labelText: 'Note (optionnel)'),
              maxLines: 2,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: _isSaving ? null : () => Navigator.pop(context), child: const Text('Annuler')),
        TextButton(onPressed: _isSaving ? null : _save, child: Text(_isSaving ? 'Enregistrement...' : 'Enregistrer')),
      ],
    );
  }
}
