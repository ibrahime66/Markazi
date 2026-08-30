import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/markaz_provider.dart';
import '../utils/app_colors.dart';
import '../widgets/common_widgets.dart';

/// Écran de gestion de la fiche Markaz (CDC section 8.2 / 11 : "configurer
/// les informations du Markaz"). Ces informations sont réutilisées
/// automatiquement dans tous les documents générés (reçus, rapports).
class MarkazSettingsScreen extends StatefulWidget {
  const MarkazSettingsScreen({super.key});

  @override
  State<MarkazSettingsScreen> createState() => _MarkazSettingsScreenState();
}

class _MarkazSettingsScreenState extends State<MarkazSettingsScreen> {
  final _nameController = TextEditingController();
  final _sloganController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _countryController = TextEditingController();
  final _currencyController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();

  bool _initialized = false;
  bool _isSaving = false;

  /// Jours de cours du Markaz (CDC 8.6 : "samedi/dimanche non travaillés par
  /// défaut"). Utilisé par le calcul du taux de présence côté serveur.
  static const _dayLabels = {
    'mon': 'Lun', 'tue': 'Mar', 'wed': 'Mer', 'thu': 'Jeu',
    'fri': 'Ven', 'sat': 'Sam', 'sun': 'Dim',
  };
  static const _defaultWorkingDays = ['mon', 'tue', 'wed', 'thu', 'fri'];
  Set<String> _workingDays = _defaultWorkingDays.toSet();

  @override
  void dispose() {
    _nameController.dispose();
    _sloganController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _countryController.dispose();
    _currencyController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _fillFromMarkaz(MarkazProvider provider) {
    if (_initialized || provider.markaz == null) return;
    final markaz = provider.markaz!;
    _nameController.text = markaz.name;
    _sloganController.text = markaz.slogan ?? '';
    _addressController.text = markaz.address ?? '';
    _cityController.text = markaz.city ?? '';
    _countryController.text = markaz.country ?? '';
    _currencyController.text = markaz.currency;
    _phoneController.text = markaz.phone ?? '';
    _emailController.text = markaz.email ?? '';
    _workingDays = markaz.workingDays.isNotEmpty
        ? markaz.workingDays.toSet()
        : _defaultWorkingDays.toSet();
    _initialized = true;
  }

  Future<void> _save() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Le nom du Markaz est obligatoire')),
      );
      return;
    }

    setState(() => _isSaving = true);

    final provider = context.read<MarkazProvider>();
    final success = await provider.update({
      'name': _nameController.text.trim(),
      'slogan': _sloganController.text.trim(),
      'address': _addressController.text.trim(),
      'city': _cityController.text.trim(),
      'country': _countryController.text.trim(),
      'currency': _currencyController.text.trim(),
      'phone': _phoneController.text.trim(),
      'email': _emailController.text.trim(),
      // Ordre stable (lun→dim) plutôt que l'ordre d'insertion du Set.
      'working_days': _dayLabels.keys.where(_workingDays.contains).toList(),
    });

    if (!mounted) return;
    setState(() => _isSaving = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? 'Fiche Markaz mise à jour' : (provider.errorMessage ?? 'Erreur')),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const MarkaziAppBar(title: 'Mon Markaz'),
      body: Consumer<MarkazProvider>(
        builder: (context, provider, _) {
          _fillFromMarkaz(provider);

          if (provider.isLoading && provider.markaz == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Informations du Markaz',
                  style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textDark),
                ),
                const SizedBox(height: 4),
                Text(
                  'Ces informations apparaissent sur les reçus et rapports générés.',
                  style: GoogleFonts.cairo(fontSize: 13, color: AppColors.textDark.withValues(alpha: 0.6)),
                ),
                const SizedBox(height: 24),
                _field(_nameController, 'Nom du Markaz', Icons.mosque_outlined, required: true),
                const SizedBox(height: 14),
                _field(_sloganController, 'Slogan', Icons.short_text),
                const SizedBox(height: 14),
                _field(_addressController, 'Adresse', Icons.location_on_outlined),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(child: _field(_cityController, 'Ville', Icons.location_city_outlined)),
                    const SizedBox(width: 12),
                    Expanded(child: _field(_countryController, 'Pays', Icons.public)),
                  ],
                ),
                const SizedBox(height: 14),
                // Devise utilisée pour tous les montants affichés dans
                // l'app (paiements, rapports, reçus) — doc/audit.md I4 :
                // auparavant codée en dur ("FGN"), bloquant pour un Markaz
                // situé dans un autre pays.
                _field(_currencyController, 'Devise (ex: GNF, XOF, EUR)', Icons.payments_outlined),
                const SizedBox(height: 14),
                _field(_phoneController, 'Téléphone', Icons.phone_outlined),
                const SizedBox(height: 14),
                _field(_emailController, 'Email', Icons.email_outlined),
                const SizedBox(height: 24),
                Text(
                  'Jours de cours',
                  style: GoogleFonts.cairo(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textDark),
                ),
                const SizedBox(height: 4),
                Text(
                  'Utilisés pour calculer le taux de présence des élèves.',
                  style: GoogleFonts.cairo(fontSize: 13, color: AppColors.textDark.withValues(alpha: 0.6)),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _dayLabels.entries.map((entry) {
                    final selected = _workingDays.contains(entry.key);
                    return FilterChip(
                      label: Text(entry.value, style: GoogleFonts.cairo(fontSize: 13)),
                      selected: selected,
                      selectedColor: AppColors.primary.withValues(alpha: 0.15),
                      checkmarkColor: AppColors.primary,
                      onSelected: (value) {
                        setState(() {
                          if (value) {
                            _workingDays.add(entry.key);
                          } else {
                            _workingDays.remove(entry.key);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 28),
                PrimaryButton(
                  text: _isSaving ? 'Enregistrement...' : 'Enregistrer',
                  onPressed: _isSaving ? () {} : _save,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _field(TextEditingController controller, String label, IconData icon, {bool required = false}) {
    return TextField(
      controller: controller,
      style: GoogleFonts.cairo(fontSize: 14),
      decoration: InputDecoration(
        labelText: required ? '$label *' : label,
        prefixIcon: Icon(icon, size: 20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }
}
