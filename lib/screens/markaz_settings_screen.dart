import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/locale_provider.dart';
import '../providers/markaz_provider.dart';
import '../providers/theme_provider.dart';
import '../utils/app_colors.dart';
import '../widgets/common_widgets.dart';
import '../l10n/app_localizations.dart';

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
    final l10n = AppLocalizations.of(context);
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.markazNameRequired)),
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
        content: Text(success ? l10n.markazUpdated : (provider.errorMessage ?? l10n.genericError)),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeProvider>();
    context.watch<LocaleProvider>();
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: MarkaziAppBar(title: l10n.markazSettingsTitle),
      body: Consumer<MarkazProvider>(
        builder: (context, provider, _) {
          _fillFromMarkaz(provider);

          if (provider.isLoading && provider.markaz == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _markazHeader(l10n),
                const SizedBox(height: 20),
                _section(
                  icon: Icons.mosque_outlined,
                  title: l10n.markazSectionIdentity,
                  subtitle: l10n.markazSectionIdentitySubtitle,
                  children: [
                    _field(_nameController, l10n.fieldMarkazName, Icons.badge_outlined, required: true),
                    const SizedBox(height: 14),
                    _field(_sloganController, l10n.fieldSlogan, Icons.short_text),
                  ],
                ),
                const SizedBox(height: 16),
                _section(
                  icon: Icons.location_on_outlined,
                  title: l10n.markazSectionContact,
                  children: [
                    _field(_addressController, l10n.fieldAddress, Icons.location_on_outlined),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(child: _field(_cityController, l10n.fieldCity, Icons.location_city_outlined)),
                        const SizedBox(width: 12),
                        Expanded(child: _field(_countryController, l10n.fieldCountry, Icons.public)),
                      ],
                    ),
                    const SizedBox(height: 14),
                    _field(_phoneController, l10n.fieldPhone, Icons.phone_outlined),
                    const SizedBox(height: 14),
                    _field(_emailController, l10n.fieldEmail, Icons.email_outlined),
                  ],
                ),
                const SizedBox(height: 16),
                _section(
                  icon: Icons.payments_outlined,
                  title: l10n.markazSectionFinance,
                  // Devise utilisée pour tous les montants affichés dans
                  // l'app (paiements, rapports, reçus) — doc/audit.md I4 :
                  // auparavant codée en dur ("FGN"), bloquant pour un Markaz
                  // situé dans un autre pays.
                  subtitle: l10n.markazSectionFinanceSubtitle,
                  children: [
                    _field(_currencyController, l10n.fieldCurrency, Icons.payments_outlined),
                  ],
                ),
                const SizedBox(height: 16),
                _section(
                  icon: Icons.calendar_month_outlined,
                  title: l10n.markazSectionSchedule,
                  subtitle: l10n.markazSectionScheduleSubtitle,
                  children: [
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
                  ],
                ),
                const SizedBox(height: 16),
                _appearanceSection(l10n),
                const SizedBox(height: 16),
                _languageSection(l10n),
                const SizedBox(height: 28),
                PrimaryButton(
                  text: _isSaving ? l10n.actionSaving : l10n.actionSave,
                  onPressed: _isSaving ? () {} : _save,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Bandeau d'en-tête avec l'aperçu du nom du Markaz — donne un repère
  /// visuel immédiat au lieu d'un simple titre de section.
  Widget _markazHeader(AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0.75)],
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.mosque, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _nameController.text.trim().isEmpty ? l10n.markazSettingsTitle : _nameController.text.trim(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white),
                ),
                const SizedBox(height: 2),
                Text(
                  l10n.markazHeaderSubtitle,
                  style: GoogleFonts.cairo(fontSize: 12.5, color: Colors.white.withValues(alpha: 0.85)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Regroupe un ensemble de champs liés dans une carte avec un en-tête
  /// (icône + titre), au lieu de la longue liste de champs à plat d'avant.
  Widget _section({
    required IconData icon,
    required String title,
    String? subtitle,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.cairo(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textDark),
              ),
            ],
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 3),
            Text(
              subtitle,
              style: GoogleFonts.cairo(fontSize: 12.5, color: AppColors.textDark.withValues(alpha: 0.6)),
            ),
          ],
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }

  /// Sélecteur de mode clair/sombre (doc/audit.md K7). Placé ici (et pas
  /// dans un menu séparé) : c'est déjà l'endroit où l'utilisateur configure
  /// les préférences globales de l'app (devise, jours de cours). Une
  /// bascule rapide équivalente est aussi dans le tiroir de navigation
  /// (retour utilisateur : le réglage seul ici n'était pas assez visible).
  Widget _appearanceSection(AppLocalizations l10n) {
    final themeProvider = context.watch<ThemeProvider>();
    return _section(
      icon: Icons.dark_mode_outlined,
      title: l10n.markazSectionAppearance,
      subtitle: l10n.markazSectionAppearanceSubtitle,
      children: [
        SegmentedButton<ThemeMode>(
          segments: [
            ButtonSegment(
              value: ThemeMode.system,
              label: Text(l10n.appearanceSystem),
              icon: const Icon(Icons.brightness_auto_outlined, size: 18),
            ),
            ButtonSegment(
              value: ThemeMode.light,
              label: Text(l10n.appearanceLight),
              icon: const Icon(Icons.light_mode_outlined, size: 18),
            ),
            ButtonSegment(
              value: ThemeMode.dark,
              label: Text(l10n.appearanceDark),
              icon: const Icon(Icons.dark_mode_outlined, size: 18),
            ),
          ],
          selected: {themeProvider.themeMode},
          onSelectionChanged: (selection) {
            themeProvider.setThemeMode(
              selection.first,
              platformBrightness: MediaQuery.platformBrightnessOf(context),
            );
          },
          style: ButtonStyle(
            textStyle: WidgetStateProperty.all(GoogleFonts.cairo(fontSize: 12.5)),
          ),
        ),
      ],
    );
  }

  /// Sélecteur de langue de l'app (doc/audit.md K8). `null` = suit la
  /// langue du système.
  Widget _languageSection(AppLocalizations l10n) {
    final localeProvider = context.watch<LocaleProvider>();
    final current = localeProvider.locale?.languageCode;
    return _section(
      icon: Icons.language_outlined,
      title: l10n.markazSectionLanguage,
      subtitle: l10n.markazSectionLanguageSubtitle,
      children: [
        SegmentedButton<String?>(
          segments: [
            ButtonSegment(value: null, label: Text(l10n.appearanceSystem)),
            ButtonSegment(value: 'fr', label: Text(l10n.languageFrench)),
            ButtonSegment(value: 'en', label: Text(l10n.languageEnglish)),
            ButtonSegment(value: 'ar', label: Text(l10n.languageArabic)),
          ],
          selected: {current},
          onSelectionChanged: (selection) {
            final code = selection.first;
            localeProvider.setLocale(code == null ? null : Locale(code));
          },
          style: ButtonStyle(
            textStyle: WidgetStateProperty.all(GoogleFonts.cairo(fontSize: 12.5)),
          ),
        ),
      ],
    );
  }

  Widget _field(TextEditingController controller, String label, IconData icon, {bool required = false}) {
    return TextField(
      controller: controller,
      style: GoogleFonts.cairo(fontSize: 14),
      decoration: InputDecoration(
        labelText: required ? '$label *' : label,
        prefixIcon: Icon(icon, size: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppColors.textDark.withValues(alpha: 0.08)),
        ),
        filled: true,
        fillColor: AppColors.background,
      ),
    );
  }
}
