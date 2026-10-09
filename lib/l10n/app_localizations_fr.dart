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

  @override
  String get navActivityLog => 'Journal d\'activité';

  @override
  String get actionRetry => 'Réessayer';

  @override
  String get activityFilterAll => 'Tout';

  @override
  String get activityCategoryStudent => 'Élèves';

  @override
  String get activityCategoryClass => 'Groupes';

  @override
  String get activityCategoryGuardian => 'Tuteurs';

  @override
  String get activityCategoryAttendance => 'Présences';

  @override
  String get activityCategoryRecitation => 'Récitations';

  @override
  String get activityCategoryPayment => 'Paiements';

  @override
  String get activityCategoryMarkaz => 'Markaz';

  @override
  String get activityCategoryUser => 'Compte';

  @override
  String get activityCategorySync => 'Conflits';

  @override
  String get activityPeriodAll => 'Toutes les dates';

  @override
  String get activityPeriod7 => '7 derniers jours';

  @override
  String get activityPeriod30 => '30 derniers jours';

  @override
  String get activityToday => 'Aujourd\'hui';

  @override
  String get activityYesterday => 'Hier';

  @override
  String get activityEmpty => 'Aucune activité pour ce filtre.';

  @override
  String get activityLoadError =>
      'Impossible de charger le journal. Vérifiez votre connexion.';

  @override
  String get activityOfflineBadge => 'Saisi hors ligne';

  @override
  String activityByUser(String name) {
    return 'par $name';
  }

  @override
  String get activityConflictTitle => 'Conflit de synchronisation';

  @override
  String activityConflictExplanation(
      String performedAt, String serverUpdatedAt) {
    return 'Cette action a été faite hors ligne le $performedAt, mais la donnée avait été modifiée entre-temps sur le serveur (le $serverUpdatedAt). La version hors ligne a été appliquée. Version serveur remplacée :';
  }

  @override
  String get activityConflictHint => 'Touchez pour voir la version remplacée';

  @override
  String get receiptPendingSync =>
      'Paiement enregistré hors ligne. Le reçu sera disponible après synchronisation (son numéro est attribué par le serveur).';

  @override
  String get navSync => 'Synchronisation';

  @override
  String get syncOnline => 'Connecté au serveur';

  @override
  String get syncOffline => 'Hors ligne';

  @override
  String get syncOfflineBanner =>
      'Hors ligne — vos saisies sont enregistrées sur l\'appareil et seront envoyées automatiquement.';

  @override
  String syncPendingBanner(String count) {
    return '$count action(s) en attente de synchronisation';
  }

  @override
  String syncFailedBanner(String count) {
    return '$count action(s) refusée(s) par le serveur — à vérifier';
  }

  @override
  String get syncNow => 'Synchroniser maintenant';

  @override
  String get syncInProgress => 'Synchronisation en cours…';

  @override
  String get syncAllDone => 'Tout est synchronisé.';

  @override
  String syncResult(String synced, String failed) {
    return '$synced action(s) envoyée(s), $failed refusée(s).';
  }

  @override
  String get syncStillOffline =>
      'Serveur toujours injoignable. Nouvel essai automatique dès le retour de la connexion.';

  @override
  String get syncEmpty =>
      'Aucune action en attente. Toutes vos saisies sont sur le serveur.';

  @override
  String get syncPendingTitle => 'Actions en attente';

  @override
  String get syncOpCreate => 'Création';

  @override
  String get syncOpUpdate => 'Modification';

  @override
  String get syncOpDelete => 'Suppression';

  @override
  String get syncEntityPayment => 'Paiement';

  @override
  String get syncEntityAttendance => 'Présence';

  @override
  String get syncEntityGuardian => 'Tuteur';

  @override
  String get syncEntityRecitation => 'Récitation';

  @override
  String get syncEntityClass => 'Groupe';

  @override
  String get syncEntityStudentClass => 'Affectation à un groupe';

  @override
  String syncDoneAt(String date) {
    return 'Saisi le $date';
  }

  @override
  String syncRejected(String message) {
    return 'Refusé par le serveur : $message';
  }

  @override
  String get syncDiscard => 'Abandonner cette action';

  @override
  String get syncDiscardConfirmTitle => 'Abandonner cette action ?';

  @override
  String get syncDiscardConfirmBody =>
      'Elle ne sera jamais envoyée au serveur. Une création sera retirée de l\'appareil ; une modification sera remplacée par la version du serveur à la prochaine synchronisation.';

  @override
  String get syncConflictsHint =>
      'Les conflits éventuels (donnée modifiée entre-temps sur le serveur) sont consultables dans le journal d\'activité.';
}
