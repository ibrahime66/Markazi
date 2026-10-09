import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/guardian.dart';
import '../providers/guardian_provider.dart';
import '../providers/student_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/locale_provider.dart';
import '../l10n/app_localizations.dart';
import '../utils/app_colors.dart';
import '../widgets/common_widgets.dart';

/// Écran de gestion des tuteurs/parents (CDC section 8.3) — module ajouté
/// pour combler doc/audit.md, point B2.
class GuardianScreen extends StatefulWidget {
  const GuardianScreen({super.key});

  @override
  State<GuardianScreen> createState() => _GuardianScreenState();
}

class _GuardianScreenState extends State<GuardianScreen> {
  /// Textes traduits (doc/audit.md K8).
  AppLocalizations get _l10n => AppLocalizations.of(context);

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      context.read<GuardianProvider>().loadGuardians();
      // Nécessaire pour proposer la liste des élèves à rattacher
      // (doc/audit.md, point I5).
      context.read<StudentProvider>().loadStudents();
    });
  }

  void _openForm({Guardian? guardian}) {
    showDialog(
      context: context,
      builder: (_) => _GuardianFormDialog(guardian: guardian),
    );
  }

  Future<void> _confirmDelete(Guardian guardian) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(_l10n.guardianDeleteTitle),
        content: Text(_l10n.guardianDeleteBody(guardian.name)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(_l10n.actionCancel)),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(_l10n.actionDelete, style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    try {
      await context.read<GuardianProvider>().removeGuardian(guardian.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_l10n.guardianDeleted), backgroundColor: Colors.green),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_l10n.commonErrorWithDetail(e)), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeProvider>();
    context.watch<LocaleProvider>();
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: MarkaziAppBar(title: l10n.navGuardians),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () => _openForm(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Consumer<GuardianProvider>(
        builder: (context, provider, _) {
          if (provider.guardians.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.family_restroom, size: 56, color: AppColors.textMedium.withValues(alpha: 0.4)),
                    const SizedBox(height: 16),
                    Text(
                      _l10n.guardianEmptyTitle,
                      style: GoogleFonts.cairo(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textDark),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _l10n.guardianEmptyBody,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.cairo(fontSize: 13, color: AppColors.textMedium),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: provider.guardians.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final guardian = provider.guardians[index];
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
                  children: [
                    CircleAvatar(
                      backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                      child: Text(
                        guardian.name.isNotEmpty ? guardian.name[0].toUpperCase() : '?',
                        style: GoogleFonts.cairo(color: AppColors.primary, fontWeight: FontWeight.w700),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(guardian.name, style: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                          const SizedBox(height: 2),
                          Text(guardian.phone, style: GoogleFonts.cairo(fontSize: 12, color: AppColors.textMedium)),
                          if (guardian.email != null && guardian.email!.isNotEmpty)
                            Text(guardian.email!, style: GoogleFonts.cairo(fontSize: 12, color: AppColors.textMedium)),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, size: 20),
                      color: AppColors.textMedium,
                      onPressed: () => _openForm(guardian: guardian),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 20),
                      color: Colors.red,
                      onPressed: () => _confirmDelete(guardian),
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

class _GuardianFormDialog extends StatefulWidget {
  final Guardian? guardian;

  const _GuardianFormDialog({this.guardian});

  @override
  State<_GuardianFormDialog> createState() => _GuardianFormDialogState();
}

class _GuardianFormDialogState extends State<_GuardianFormDialog> {
  /// Textes traduits (doc/audit.md K8).
  AppLocalizations get _l10n => AppLocalizations.of(context);

  late final _nameController = TextEditingController(text: widget.guardian?.name);
  late final _phoneController = TextEditingController(text: widget.guardian?.phone);
  late final _emailController = TextEditingController(text: widget.guardian?.email);
  late final _addressController = TextEditingController(text: widget.guardian?.address);
  bool _isSaving = false;

  // Élèves à rattacher à ce tuteur (doc/audit.md, point I5) : un tuteur
  // peut avoir plusieurs élèves (fratrie), d'où la sélection à cocher
  // plutôt qu'un simple champ unique.
  late Set<String> _selectedStudentIds;
  late final Set<String> _initiallySelectedStudentIds;

  @override
  void initState() {
    super.initState();
    final students = context.read<StudentProvider>().students;
    _initiallySelectedStudentIds = widget.guardian == null
        ? const {}
        : students
            .where((s) => s.guardianId == widget.guardian!.id)
            .map((s) => s.id)
            .toSet();
    _selectedStudentIds = {..._initiallySelectedStudentIds};
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_nameController.text.trim().isEmpty || _phoneController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_l10n.guardianNamePhoneRequired)),
      );
      return;
    }

    setState(() => _isSaving = true);
    final guardianProvider = context.read<GuardianProvider>();
    final studentProvider = context.read<StudentProvider>();

    try {
      String guardianId;
      if (widget.guardian == null) {
        final created = await guardianProvider.addGuardian(
          name: _nameController.text,
          phone: _phoneController.text,
          email: _emailController.text,
          address: _addressController.text,
        );
        guardianId = created.id;
      } else {
        guardianId = widget.guardian!.id;
        await guardianProvider.updateGuardian(
          guardianId: guardianId,
          name: _nameController.text,
          phone: _phoneController.text,
          email: _emailController.text,
          address: _addressController.text,
        );
      }

      // Applique les changements de rattachement élève ↔ tuteur : on ne
      // touche que les élèves dont la case a réellement changé.
      final added = _selectedStudentIds.difference(_initiallySelectedStudentIds);
      final removed = _initiallySelectedStudentIds.difference(_selectedStudentIds);
      for (final studentId in added) {
        await studentProvider.setGuardian(studentId, guardianId);
      }
      for (final studentId in removed) {
        await studentProvider.setGuardian(studentId, null);
      }

      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_l10n.commonErrorWithDetail(e)), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.guardian != null;
    final students = context.watch<StudentProvider>().students;
    return AlertDialog(
      title: Text(isEdit ? _l10n.guardianEditTitle : _l10n.guardianAddTitle),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: _l10n.fieldNameRequired, prefixIcon: Icon(Icons.person_outline)),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(labelText: _l10n.fieldPhoneRequired, prefixIcon: Icon(Icons.phone_outlined)),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(labelText: _l10n.fieldEmail, prefixIcon: Icon(Icons.email_outlined)),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _addressController,
              decoration: InputDecoration(labelText: _l10n.fieldAddress, prefixIcon: Icon(Icons.location_on_outlined)),
            ),
            if (students.isNotEmpty) ...[
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  _l10n.guardianLinkedStudents,
                  style: GoogleFonts.cairo(fontWeight: FontWeight.w700, fontSize: 13),
                ),
              ),
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 220),
                child: ListView(
                  shrinkWrap: true,
                  children: students.map((student) {
                    return CheckboxListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      title: Text(student.name),
                      value: _selectedStudentIds.contains(student.id),
                      onChanged: (checked) {
                        setState(() {
                          if (checked == true) {
                            _selectedStudentIds.add(student.id);
                          } else {
                            _selectedStudentIds.remove(student.id);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: _isSaving ? null : () => Navigator.pop(context), child: Text(_l10n.actionCancel)),
        TextButton(onPressed: _isSaving ? null : _save, child: Text(_isSaving ? _l10n.actionSaving : _l10n.actionSave)),
      ],
    );
  }
}
