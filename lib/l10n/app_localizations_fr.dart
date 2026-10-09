// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get navOverview => 'Vue d\'ensemble';

  @override
  String get navStudents => 'Élèves';

  @override
  String get navGroups => 'Groupes';

  @override
  String get navPayments => 'Paiements';

  @override
  String get navAttendance => 'Présences';

  @override
  String get navReports => 'Rapports';

  @override
  String get navMyMarkaz => 'Mon Markaz';

  @override
  String get navGuardians => 'Tuteurs / Parents';

  @override
  String get navRecitations => 'Récitations';

  @override
  String get navActivityLog => 'Journal d\'activité';

  @override
  String get navLogout => 'Déconnexion';

  @override
  String get navDarkMode => 'Mode sombre';

  @override
  String get actionSave => 'Enregistrer';

  @override
  String get actionSaving => 'Enregistrement...';

  @override
  String get actionCancel => 'Annuler';

  @override
  String get actionAdd => 'Ajouter';

  @override
  String get actionEdit => 'Modifier';

  @override
  String get actionDelete => 'Supprimer';

  @override
  String get actionClose => 'Fermer';

  @override
  String get actionConfirm => 'Confirmer';

  @override
  String get actionShare => 'Partager';

  @override
  String get actionDownload => 'Télécharger';

  @override
  String get markazSettingsTitle => 'Mon Markaz';

  @override
  String get markazHeaderSubtitle =>
      'Ces informations sont utilisées dans toute l\'application.';

  @override
  String get markazSectionIdentity => 'Identité';

  @override
  String get markazSectionIdentitySubtitle =>
      'Apparaît sur les reçus et rapports générés.';

  @override
  String get markazSectionContact => 'Coordonnées';

  @override
  String get markazSectionFinance => 'Finance';

  @override
  String get markazSectionFinanceSubtitle =>
      'Devise utilisée pour tous les montants de l\'app.';

  @override
  String get markazSectionSchedule => 'Jours de cours';

  @override
  String get markazSectionScheduleSubtitle =>
      'Utilisés pour calculer le taux de présence des élèves.';

  @override
  String get markazSectionAppearance => 'Apparence';

  @override
  String get markazSectionAppearanceSubtitle =>
      'Choisissez l\'apparence de l\'application sur cet appareil.';

  @override
  String get markazSectionLanguage => 'Langue';

  @override
  String get markazSectionLanguageSubtitle =>
      'Choisissez la langue de l\'application.';

  @override
  String get fieldMarkazName => 'Nom du Markaz';

  @override
  String get fieldSlogan => 'Slogan';

  @override
  String get fieldAddress => 'Adresse';

  @override
  String get fieldCity => 'Ville';

  @override
  String get fieldCountry => 'Pays';

  @override
  String get fieldCurrency => 'Devise (ex: GNF, XOF, EUR)';

  @override
  String get fieldPhone => 'Téléphone';

  @override
  String get fieldEmail => 'Email';

  @override
  String get appearanceSystem => 'Système';

  @override
  String get appearanceLight => 'Clair';

  @override
  String get appearanceDark => 'Sombre';

  @override
  String get languageFrench => 'Français';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageArabic => 'العربية';

  @override
  String get markazNameRequired => 'Le nom du Markaz est obligatoire';

  @override
  String get markazUpdated => 'Fiche Markaz mise à jour';

  @override
  String get genericError => 'Erreur';
}
