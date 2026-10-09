import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
    Locale('fr')
  ];

  /// No description provided for @navOverview.
  ///
  /// In fr, this message translates to:
  /// **'Vue d\'ensemble'**
  String get navOverview;

  /// No description provided for @navStudents.
  ///
  /// In fr, this message translates to:
  /// **'Élèves'**
  String get navStudents;

  /// No description provided for @navGroups.
  ///
  /// In fr, this message translates to:
  /// **'Groupes'**
  String get navGroups;

  /// No description provided for @navPayments.
  ///
  /// In fr, this message translates to:
  /// **'Paiements'**
  String get navPayments;

  /// No description provided for @navAttendance.
  ///
  /// In fr, this message translates to:
  /// **'Présences'**
  String get navAttendance;

  /// No description provided for @navReports.
  ///
  /// In fr, this message translates to:
  /// **'Rapports'**
  String get navReports;

  /// No description provided for @navMyMarkaz.
  ///
  /// In fr, this message translates to:
  /// **'Mon Markaz'**
  String get navMyMarkaz;

  /// No description provided for @navGuardians.
  ///
  /// In fr, this message translates to:
  /// **'Tuteurs / Parents'**
  String get navGuardians;

  /// No description provided for @navRecitations.
  ///
  /// In fr, this message translates to:
  /// **'Récitations'**
  String get navRecitations;

  /// No description provided for @navLogout.
  ///
  /// In fr, this message translates to:
  /// **'Déconnexion'**
  String get navLogout;

  /// No description provided for @navDarkMode.
  ///
  /// In fr, this message translates to:
  /// **'Mode sombre'**
  String get navDarkMode;

  /// No description provided for @actionSave.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer'**
  String get actionSave;

  /// No description provided for @actionSaving.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrement...'**
  String get actionSaving;

  /// No description provided for @actionCancel.
  ///
  /// In fr, this message translates to:
  /// **'Annuler'**
  String get actionCancel;

  /// No description provided for @actionAdd.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter'**
  String get actionAdd;

  /// No description provided for @actionEdit.
  ///
  /// In fr, this message translates to:
  /// **'Modifier'**
  String get actionEdit;

  /// No description provided for @actionDelete.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer'**
  String get actionDelete;

  /// No description provided for @actionClose.
  ///
  /// In fr, this message translates to:
  /// **'Fermer'**
  String get actionClose;

  /// No description provided for @actionConfirm.
  ///
  /// In fr, this message translates to:
  /// **'Confirmer'**
  String get actionConfirm;

  /// No description provided for @actionShare.
  ///
  /// In fr, this message translates to:
  /// **'Partager'**
  String get actionShare;

  /// No description provided for @actionDownload.
  ///
  /// In fr, this message translates to:
  /// **'Télécharger'**
  String get actionDownload;

  /// No description provided for @markazSettingsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Mon Markaz'**
  String get markazSettingsTitle;

  /// No description provided for @markazHeaderSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Ces informations sont utilisées dans toute l\'application.'**
  String get markazHeaderSubtitle;

  /// No description provided for @markazSectionIdentity.
  ///
  /// In fr, this message translates to:
  /// **'Identité'**
  String get markazSectionIdentity;

  /// No description provided for @markazSectionIdentitySubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Apparaît sur les reçus et rapports générés.'**
  String get markazSectionIdentitySubtitle;

  /// No description provided for @markazSectionContact.
  ///
  /// In fr, this message translates to:
  /// **'Coordonnées'**
  String get markazSectionContact;

  /// No description provided for @markazSectionFinance.
  ///
  /// In fr, this message translates to:
  /// **'Finance'**
  String get markazSectionFinance;

  /// No description provided for @markazSectionFinanceSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Devise utilisée pour tous les montants de l\'app.'**
  String get markazSectionFinanceSubtitle;

  /// No description provided for @markazSectionSchedule.
  ///
  /// In fr, this message translates to:
  /// **'Jours de cours'**
  String get markazSectionSchedule;

  /// No description provided for @markazSectionScheduleSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Utilisés pour calculer le taux de présence des élèves.'**
  String get markazSectionScheduleSubtitle;

  /// No description provided for @markazSectionAppearance.
  ///
  /// In fr, this message translates to:
  /// **'Apparence'**
  String get markazSectionAppearance;

  /// No description provided for @markazSectionAppearanceSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Choisissez l\'apparence de l\'application sur cet appareil.'**
  String get markazSectionAppearanceSubtitle;

  /// No description provided for @markazSectionLanguage.
  ///
  /// In fr, this message translates to:
  /// **'Langue'**
  String get markazSectionLanguage;

  /// No description provided for @markazSectionLanguageSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Choisissez la langue de l\'application.'**
  String get markazSectionLanguageSubtitle;

  /// No description provided for @fieldMarkazName.
  ///
  /// In fr, this message translates to:
  /// **'Nom du Markaz'**
  String get fieldMarkazName;

  /// No description provided for @fieldSlogan.
  ///
  /// In fr, this message translates to:
  /// **'Slogan'**
  String get fieldSlogan;

  /// No description provided for @fieldAddress.
  ///
  /// In fr, this message translates to:
  /// **'Adresse'**
  String get fieldAddress;

  /// No description provided for @fieldCity.
  ///
  /// In fr, this message translates to:
  /// **'Ville'**
  String get fieldCity;

  /// No description provided for @fieldCountry.
  ///
  /// In fr, this message translates to:
  /// **'Pays'**
  String get fieldCountry;

  /// No description provided for @fieldCurrency.
  ///
  /// In fr, this message translates to:
  /// **'Devise (ex: GNF, XOF, EUR)'**
  String get fieldCurrency;

  /// No description provided for @fieldPhone.
  ///
  /// In fr, this message translates to:
  /// **'Téléphone'**
  String get fieldPhone;

  /// No description provided for @fieldEmail.
  ///
  /// In fr, this message translates to:
  /// **'Email'**
  String get fieldEmail;

  /// No description provided for @appearanceSystem.
  ///
  /// In fr, this message translates to:
  /// **'Système'**
  String get appearanceSystem;

  /// No description provided for @appearanceLight.
  ///
  /// In fr, this message translates to:
  /// **'Clair'**
  String get appearanceLight;

  /// No description provided for @appearanceDark.
  ///
  /// In fr, this message translates to:
  /// **'Sombre'**
  String get appearanceDark;

  /// No description provided for @languageFrench.
  ///
  /// In fr, this message translates to:
  /// **'Français'**
  String get languageFrench;

  /// No description provided for @languageEnglish.
  ///
  /// In fr, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageArabic.
  ///
  /// In fr, this message translates to:
  /// **'العربية'**
  String get languageArabic;

  /// No description provided for @markazNameRequired.
  ///
  /// In fr, this message translates to:
  /// **'Le nom du Markaz est obligatoire'**
  String get markazNameRequired;

  /// No description provided for @markazUpdated.
  ///
  /// In fr, this message translates to:
  /// **'Fiche Markaz mise à jour'**
  String get markazUpdated;

  /// No description provided for @genericError.
  ///
  /// In fr, this message translates to:
  /// **'Erreur'**
  String get genericError;

  /// No description provided for @navActivityLog.
  ///
  /// In fr, this message translates to:
  /// **'Journal d\'activité'**
  String get navActivityLog;

  /// No description provided for @actionRetry.
  ///
  /// In fr, this message translates to:
  /// **'Réessayer'**
  String get actionRetry;

  /// No description provided for @activityFilterAll.
  ///
  /// In fr, this message translates to:
  /// **'Tout'**
  String get activityFilterAll;

  /// No description provided for @activityCategoryStudent.
  ///
  /// In fr, this message translates to:
  /// **'Élèves'**
  String get activityCategoryStudent;

  /// No description provided for @activityCategoryClass.
  ///
  /// In fr, this message translates to:
  /// **'Groupes'**
  String get activityCategoryClass;

  /// No description provided for @activityCategoryGuardian.
  ///
  /// In fr, this message translates to:
  /// **'Tuteurs'**
  String get activityCategoryGuardian;

  /// No description provided for @activityCategoryAttendance.
  ///
  /// In fr, this message translates to:
  /// **'Présences'**
  String get activityCategoryAttendance;

  /// No description provided for @activityCategoryRecitation.
  ///
  /// In fr, this message translates to:
  /// **'Récitations'**
  String get activityCategoryRecitation;

  /// No description provided for @activityCategoryPayment.
  ///
  /// In fr, this message translates to:
  /// **'Paiements'**
  String get activityCategoryPayment;

  /// No description provided for @activityCategoryMarkaz.
  ///
  /// In fr, this message translates to:
  /// **'Markaz'**
  String get activityCategoryMarkaz;

  /// No description provided for @activityCategoryUser.
  ///
  /// In fr, this message translates to:
  /// **'Compte'**
  String get activityCategoryUser;

  /// No description provided for @activityCategorySync.
  ///
  /// In fr, this message translates to:
  /// **'Conflits'**
  String get activityCategorySync;

  /// No description provided for @activityPeriodAll.
  ///
  /// In fr, this message translates to:
  /// **'Toutes les dates'**
  String get activityPeriodAll;

  /// No description provided for @activityPeriod7.
  ///
  /// In fr, this message translates to:
  /// **'7 derniers jours'**
  String get activityPeriod7;

  /// No description provided for @activityPeriod30.
  ///
  /// In fr, this message translates to:
  /// **'30 derniers jours'**
  String get activityPeriod30;

  /// No description provided for @activityToday.
  ///
  /// In fr, this message translates to:
  /// **'Aujourd\'hui'**
  String get activityToday;

  /// No description provided for @activityYesterday.
  ///
  /// In fr, this message translates to:
  /// **'Hier'**
  String get activityYesterday;

  /// No description provided for @activityEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Aucune activité pour ce filtre.'**
  String get activityEmpty;

  /// No description provided for @activityLoadError.
  ///
  /// In fr, this message translates to:
  /// **'Impossible de charger le journal. Vérifiez votre connexion.'**
  String get activityLoadError;

  /// No description provided for @activityOfflineBadge.
  ///
  /// In fr, this message translates to:
  /// **'Saisi hors ligne'**
  String get activityOfflineBadge;

  /// No description provided for @activityByUser.
  ///
  /// In fr, this message translates to:
  /// **'par {name}'**
  String activityByUser(String name);

  /// No description provided for @activityConflictTitle.
  ///
  /// In fr, this message translates to:
  /// **'Conflit de synchronisation'**
  String get activityConflictTitle;

  /// No description provided for @activityConflictExplanation.
  ///
  /// In fr, this message translates to:
  /// **'Cette action a été faite hors ligne le {performedAt}, mais la donnée avait été modifiée entre-temps sur le serveur (le {serverUpdatedAt}). La version hors ligne a été appliquée. Version serveur remplacée :'**
  String activityConflictExplanation(
      String performedAt, String serverUpdatedAt);

  /// No description provided for @activityConflictHint.
  ///
  /// In fr, this message translates to:
  /// **'Touchez pour voir la version remplacée'**
  String get activityConflictHint;

  /// No description provided for @receiptPendingSync.
  ///
  /// In fr, this message translates to:
  /// **'Paiement enregistré hors ligne. Le reçu sera disponible après synchronisation (son numéro est attribué par le serveur).'**
  String get receiptPendingSync;

  /// No description provided for @navSync.
  ///
  /// In fr, this message translates to:
  /// **'Synchronisation'**
  String get navSync;

  /// No description provided for @syncOnline.
  ///
  /// In fr, this message translates to:
  /// **'Connecté au serveur'**
  String get syncOnline;

  /// No description provided for @syncOffline.
  ///
  /// In fr, this message translates to:
  /// **'Hors ligne'**
  String get syncOffline;

  /// No description provided for @syncOfflineBanner.
  ///
  /// In fr, this message translates to:
  /// **'Hors ligne — vos saisies sont enregistrées sur l\'appareil et seront envoyées automatiquement.'**
  String get syncOfflineBanner;

  /// No description provided for @syncPendingBanner.
  ///
  /// In fr, this message translates to:
  /// **'{count} action(s) en attente de synchronisation'**
  String syncPendingBanner(String count);

  /// No description provided for @syncFailedBanner.
  ///
  /// In fr, this message translates to:
  /// **'{count} action(s) refusée(s) par le serveur — à vérifier'**
  String syncFailedBanner(String count);

  /// No description provided for @syncNow.
  ///
  /// In fr, this message translates to:
  /// **'Synchroniser maintenant'**
  String get syncNow;

  /// No description provided for @syncInProgress.
  ///
  /// In fr, this message translates to:
  /// **'Synchronisation en cours…'**
  String get syncInProgress;

  /// No description provided for @syncAllDone.
  ///
  /// In fr, this message translates to:
  /// **'Tout est synchronisé.'**
  String get syncAllDone;

  /// No description provided for @syncResult.
  ///
  /// In fr, this message translates to:
  /// **'{synced} action(s) envoyée(s), {failed} refusée(s).'**
  String syncResult(String synced, String failed);

  /// No description provided for @syncStillOffline.
  ///
  /// In fr, this message translates to:
  /// **'Serveur toujours injoignable. Nouvel essai automatique dès le retour de la connexion.'**
  String get syncStillOffline;

  /// No description provided for @syncEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Aucune action en attente. Toutes vos saisies sont sur le serveur.'**
  String get syncEmpty;

  /// No description provided for @syncPendingTitle.
  ///
  /// In fr, this message translates to:
  /// **'Actions en attente'**
  String get syncPendingTitle;

  /// No description provided for @syncOpCreate.
  ///
  /// In fr, this message translates to:
  /// **'Création'**
  String get syncOpCreate;

  /// No description provided for @syncOpUpdate.
  ///
  /// In fr, this message translates to:
  /// **'Modification'**
  String get syncOpUpdate;

  /// No description provided for @syncOpDelete.
  ///
  /// In fr, this message translates to:
  /// **'Suppression'**
  String get syncOpDelete;

  /// No description provided for @syncEntityPayment.
  ///
  /// In fr, this message translates to:
  /// **'Paiement'**
  String get syncEntityPayment;

  /// No description provided for @syncEntityAttendance.
  ///
  /// In fr, this message translates to:
  /// **'Présence'**
  String get syncEntityAttendance;

  /// No description provided for @syncEntityGuardian.
  ///
  /// In fr, this message translates to:
  /// **'Tuteur'**
  String get syncEntityGuardian;

  /// No description provided for @syncEntityRecitation.
  ///
  /// In fr, this message translates to:
  /// **'Récitation'**
  String get syncEntityRecitation;

  /// No description provided for @syncEntityClass.
  ///
  /// In fr, this message translates to:
  /// **'Groupe'**
  String get syncEntityClass;

  /// No description provided for @syncEntityStudentClass.
  ///
  /// In fr, this message translates to:
  /// **'Affectation à un groupe'**
  String get syncEntityStudentClass;

  /// No description provided for @syncDoneAt.
  ///
  /// In fr, this message translates to:
  /// **'Saisi le {date}'**
  String syncDoneAt(String date);

  /// No description provided for @syncRejected.
  ///
  /// In fr, this message translates to:
  /// **'Refusé par le serveur : {message}'**
  String syncRejected(String message);

  /// No description provided for @syncDiscard.
  ///
  /// In fr, this message translates to:
  /// **'Abandonner cette action'**
  String get syncDiscard;

  /// No description provided for @syncDiscardConfirmTitle.
  ///
  /// In fr, this message translates to:
  /// **'Abandonner cette action ?'**
  String get syncDiscardConfirmTitle;

  /// No description provided for @syncDiscardConfirmBody.
  ///
  /// In fr, this message translates to:
  /// **'Elle ne sera jamais envoyée au serveur. Une création sera retirée de l\'appareil ; une modification sera remplacée par la version du serveur à la prochaine synchronisation.'**
  String get syncDiscardConfirmBody;

  /// No description provided for @syncConflictsHint.
  ///
  /// In fr, this message translates to:
  /// **'Les conflits éventuels (donnée modifiée entre-temps sur le serveur) sont consultables dans le journal d\'activité.'**
  String get syncConflictsHint;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
