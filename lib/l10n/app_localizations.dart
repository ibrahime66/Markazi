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

  /// No description provided for @guardianDeleteTitle.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer ce tuteur ?'**
  String get guardianDeleteTitle;

  /// No description provided for @guardianDeleteBody.
  ///
  /// In fr, this message translates to:
  /// **'« {guardian} » sera définitivement supprimé.'**
  String guardianDeleteBody(Object guardian);

  /// No description provided for @guardianDeleted.
  ///
  /// In fr, this message translates to:
  /// **'Tuteur supprimé'**
  String get guardianDeleted;

  /// No description provided for @commonErrorWithDetail.
  ///
  /// In fr, this message translates to:
  /// **'Erreur : {error}'**
  String commonErrorWithDetail(Object error);

  /// No description provided for @guardianEmptyTitle.
  ///
  /// In fr, this message translates to:
  /// **'Aucun tuteur enregistré'**
  String get guardianEmptyTitle;

  /// No description provided for @guardianEmptyBody.
  ///
  /// In fr, this message translates to:
  /// **'Ajoutez les parents/tuteurs pour les rattacher aux élèves.'**
  String get guardianEmptyBody;

  /// No description provided for @guardianNamePhoneRequired.
  ///
  /// In fr, this message translates to:
  /// **'Nom et téléphone sont obligatoires'**
  String get guardianNamePhoneRequired;

  /// No description provided for @guardianEditTitle.
  ///
  /// In fr, this message translates to:
  /// **'Modifier le tuteur'**
  String get guardianEditTitle;

  /// No description provided for @guardianAddTitle.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter un tuteur'**
  String get guardianAddTitle;

  /// No description provided for @fieldNameRequired.
  ///
  /// In fr, this message translates to:
  /// **'Nom *'**
  String get fieldNameRequired;

  /// No description provided for @fieldPhoneRequired.
  ///
  /// In fr, this message translates to:
  /// **'Téléphone *'**
  String get fieldPhoneRequired;

  /// No description provided for @guardianLinkedStudents.
  ///
  /// In fr, this message translates to:
  /// **'Élèves rattachés'**
  String get guardianLinkedStudents;

  /// No description provided for @commonAddStudentFirst.
  ///
  /// In fr, this message translates to:
  /// **'Ajoutez d\'abord un élève'**
  String get commonAddStudentFirst;

  /// No description provided for @recitationDeleteTitle.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer cette séance ?'**
  String get recitationDeleteTitle;

  /// No description provided for @recitationDeleteBody.
  ///
  /// In fr, this message translates to:
  /// **'Cette récitation sera définitivement supprimée.'**
  String get recitationDeleteBody;

  /// No description provided for @recitationDeleted.
  ///
  /// In fr, this message translates to:
  /// **'Récitation supprimée'**
  String get recitationDeleted;

  /// No description provided for @recitationStatusRecited.
  ///
  /// In fr, this message translates to:
  /// **'Récité'**
  String get recitationStatusRecited;

  /// No description provided for @recitationStatusPartial.
  ///
  /// In fr, this message translates to:
  /// **'Partiel'**
  String get recitationStatusPartial;

  /// No description provided for @recitationStatusNotRecited.
  ///
  /// In fr, this message translates to:
  /// **'Non récité'**
  String get recitationStatusNotRecited;

  /// No description provided for @recitationEmptyTitle.
  ///
  /// In fr, this message translates to:
  /// **'Aucune récitation enregistrée'**
  String get recitationEmptyTitle;

  /// No description provided for @recitationEmptyBody.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrez la sourate étudiée par chaque élève après chaque séance.'**
  String get recitationEmptyBody;

  /// No description provided for @commonStudentDeleted.
  ///
  /// In fr, this message translates to:
  /// **'Élève supprimé'**
  String get commonStudentDeleted;

  /// No description provided for @recitationVerseRange.
  ///
  /// In fr, this message translates to:
  /// **' (versets {ayahFrom}-{ayahTo})'**
  String recitationVerseRange(Object ayahFrom, Object ayahTo);

  /// No description provided for @recitationSurahRequired.
  ///
  /// In fr, this message translates to:
  /// **'La sourate est obligatoire'**
  String get recitationSurahRequired;

  /// No description provided for @recitationEditTitle.
  ///
  /// In fr, this message translates to:
  /// **'Modifier la récitation'**
  String get recitationEditTitle;

  /// No description provided for @recitationAddTitle.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer une récitation'**
  String get recitationAddTitle;

  /// No description provided for @fieldStudentRequired.
  ///
  /// In fr, this message translates to:
  /// **'Élève *'**
  String get fieldStudentRequired;

  /// No description provided for @commonDateDmy.
  ///
  /// In fr, this message translates to:
  /// **'Date : {day}/{month}/{year}'**
  String commonDateDmy(Object day, Object month, Object year);

  /// No description provided for @fieldSurahRequired.
  ///
  /// In fr, this message translates to:
  /// **'Sourate *'**
  String get fieldSurahRequired;

  /// No description provided for @fieldAyahFrom.
  ///
  /// In fr, this message translates to:
  /// **'Verset début'**
  String get fieldAyahFrom;

  /// No description provided for @fieldAyahTo.
  ///
  /// In fr, this message translates to:
  /// **'Verset fin'**
  String get fieldAyahTo;

  /// No description provided for @fieldStatus.
  ///
  /// In fr, this message translates to:
  /// **'Statut'**
  String get fieldStatus;

  /// No description provided for @fieldNoteOptional.
  ///
  /// In fr, this message translates to:
  /// **'Note (optionnel)'**
  String get fieldNoteOptional;

  /// No description provided for @groupInfoTitle.
  ///
  /// In fr, this message translates to:
  /// **'Informations du groupe'**
  String get groupInfoTitle;

  /// No description provided for @fieldLevel.
  ///
  /// In fr, this message translates to:
  /// **'Niveau'**
  String get fieldLevel;

  /// No description provided for @fieldTeacher.
  ///
  /// In fr, this message translates to:
  /// **'Enseignant'**
  String get fieldTeacher;

  /// No description provided for @fieldCapacity.
  ///
  /// In fr, this message translates to:
  /// **'Capacité'**
  String get fieldCapacity;

  /// No description provided for @groupCapacityValue.
  ///
  /// In fr, this message translates to:
  /// **'{studentIdsCount}/{maxStudents} élèves'**
  String groupCapacityValue(Object studentIdsCount, Object maxStudents);

  /// No description provided for @fieldDescription.
  ///
  /// In fr, this message translates to:
  /// **'Description'**
  String get fieldDescription;

  /// No description provided for @fieldSchedule.
  ///
  /// In fr, this message translates to:
  /// **'Emploi du temps'**
  String get fieldSchedule;

  /// No description provided for @fieldRoom.
  ///
  /// In fr, this message translates to:
  /// **'Salle'**
  String get fieldRoom;

  /// No description provided for @commonInactive.
  ///
  /// In fr, this message translates to:
  /// **'Inactif'**
  String get commonInactive;

  /// No description provided for @fieldCreatedOn.
  ///
  /// In fr, this message translates to:
  /// **'Créé le'**
  String get fieldCreatedOn;

  /// No description provided for @groupStatsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Statistiques du groupe'**
  String get groupStatsTitle;

  /// No description provided for @statAttendanceRate.
  ///
  /// In fr, this message translates to:
  /// **'Taux présence'**
  String get statAttendanceRate;

  /// No description provided for @statPaymentRate.
  ///
  /// In fr, this message translates to:
  /// **'Taux paiement'**
  String get statPaymentRate;

  /// No description provided for @statTotalPaid.
  ///
  /// In fr, this message translates to:
  /// **'Total payé'**
  String get statTotalPaid;

  /// No description provided for @groupNoStudents.
  ///
  /// In fr, this message translates to:
  /// **'Aucun élève dans ce groupe'**
  String get groupNoStudents;

  /// No description provided for @groupStudentsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Élèves du groupe'**
  String get groupStudentsTitle;

  /// No description provided for @fieldStudentName.
  ///
  /// In fr, this message translates to:
  /// **'Nom de l\'élève'**
  String get fieldStudentName;

  /// No description provided for @fieldAmount.
  ///
  /// In fr, this message translates to:
  /// **'Montant'**
  String get fieldAmount;

  /// No description provided for @authEnterValidEmail.
  ///
  /// In fr, this message translates to:
  /// **'Entrez un email valide'**
  String get authEnterValidEmail;

  /// No description provided for @forgotCodeSent.
  ///
  /// In fr, this message translates to:
  /// **'Code envoyé par email. Vérifiez aussi vos spams.'**
  String get forgotCodeSent;

  /// No description provided for @authAllFieldsRequired.
  ///
  /// In fr, this message translates to:
  /// **'Tous les champs doivent être remplis'**
  String get authAllFieldsRequired;

  /// No description provided for @authPasswordsDoNotMatch.
  ///
  /// In fr, this message translates to:
  /// **'Les mots de passe ne correspondent pas'**
  String get authPasswordsDoNotMatch;

  /// No description provided for @forgotPasswordReset.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe réinitialisé. Connectez-vous.'**
  String get forgotPasswordReset;

  /// No description provided for @forgotTitle.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe oublié'**
  String get forgotTitle;

  /// No description provided for @forgotStepCode.
  ///
  /// In fr, this message translates to:
  /// **'Entrez le code reçu par email et votre nouveau mot de passe.'**
  String get forgotStepCode;

  /// No description provided for @forgotStepEmail.
  ///
  /// In fr, this message translates to:
  /// **'Entrez votre email, un code de réinitialisation vous sera envoyé.'**
  String get forgotStepEmail;

  /// No description provided for @authEmailHint.
  ///
  /// In fr, this message translates to:
  /// **'votre.email@exemple.com'**
  String get authEmailHint;

  /// No description provided for @forgotSendCode.
  ///
  /// In fr, this message translates to:
  /// **'Envoyer le code'**
  String get forgotSendCode;

  /// No description provided for @forgotCodeLabel.
  ///
  /// In fr, this message translates to:
  /// **'Code reçu par email'**
  String get forgotCodeLabel;

  /// No description provided for @forgotCodeHint.
  ///
  /// In fr, this message translates to:
  /// **'Collez le code ici'**
  String get forgotCodeHint;

  /// No description provided for @forgotNewPassword.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau mot de passe'**
  String get forgotNewPassword;

  /// No description provided for @authPasswordHint.
  ///
  /// In fr, this message translates to:
  /// **'Au moins 6 caractères'**
  String get authPasswordHint;

  /// No description provided for @forgotConfirmPassword.
  ///
  /// In fr, this message translates to:
  /// **'Confirmer le mot de passe'**
  String get forgotConfirmPassword;

  /// No description provided for @forgotResetButton.
  ///
  /// In fr, this message translates to:
  /// **'Réinitialiser le mot de passe'**
  String get forgotResetButton;

  /// No description provided for @forgotRestart.
  ///
  /// In fr, this message translates to:
  /// **'Je n\'ai pas reçu de code, recommencer'**
  String get forgotRestart;

  /// No description provided for @authInvalidEmail.
  ///
  /// In fr, this message translates to:
  /// **'Email invalide'**
  String get authInvalidEmail;

  /// No description provided for @loginUnknownError.
  ///
  /// In fr, this message translates to:
  /// **'Erreur inconnue lors de la connexion'**
  String get loginUnknownError;

  /// No description provided for @loginError.
  ///
  /// In fr, this message translates to:
  /// **'Erreur de connexion. Veuillez réessayer.'**
  String get loginError;

  /// No description provided for @registerUnknownError.
  ///
  /// In fr, this message translates to:
  /// **'Erreur inconnue lors de la création du compte'**
  String get registerUnknownError;

  /// No description provided for @registerError.
  ///
  /// In fr, this message translates to:
  /// **'Erreur lors de la création du compte. Veuillez réessayer.'**
  String get registerError;

  /// No description provided for @authLogin.
  ///
  /// In fr, this message translates to:
  /// **'Se connecter'**
  String get authLogin;

  /// No description provided for @loginSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Accédez à votre compte markaz'**
  String get loginSubtitle;

  /// No description provided for @authPassword.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe'**
  String get authPassword;

  /// No description provided for @loginForgotPassword.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe oublié ?'**
  String get loginForgotPassword;

  /// No description provided for @loginNoAccount.
  ///
  /// In fr, this message translates to:
  /// **'Pas encore de compte ? '**
  String get loginNoAccount;

  /// No description provided for @authCreateAccount.
  ///
  /// In fr, this message translates to:
  /// **'Créer un compte'**
  String get authCreateAccount;

  /// No description provided for @registerSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Rejoignez Markazi en quelques secondes'**
  String get registerSubtitle;

  /// No description provided for @fieldFullName.
  ///
  /// In fr, this message translates to:
  /// **'Nom complet'**
  String get fieldFullName;

  /// No description provided for @registerNameHint.
  ///
  /// In fr, this message translates to:
  /// **'Ex: Ahmed Ben Ali'**
  String get registerNameHint;

  /// No description provided for @registerMarkazHint.
  ///
  /// In fr, this message translates to:
  /// **'Ex: Markaz Al-Nour'**
  String get registerMarkazHint;

  /// No description provided for @registerHaveAccount.
  ///
  /// In fr, this message translates to:
  /// **'Vous avez déjà un compte ? '**
  String get registerHaveAccount;

  /// No description provided for @splashTagline.
  ///
  /// In fr, this message translates to:
  /// **'Gérez votre markaz\nsimplement et efficacement'**
  String get splashTagline;

  /// No description provided for @commonLoading.
  ///
  /// In fr, this message translates to:
  /// **'Chargement...'**
  String get commonLoading;

  /// No description provided for @dayShortMon.
  ///
  /// In fr, this message translates to:
  /// **'Lun'**
  String get dayShortMon;

  /// No description provided for @dayShortTue.
  ///
  /// In fr, this message translates to:
  /// **'Mar'**
  String get dayShortTue;

  /// No description provided for @dayShortWed.
  ///
  /// In fr, this message translates to:
  /// **'Mer'**
  String get dayShortWed;

  /// No description provided for @dayShortThu.
  ///
  /// In fr, this message translates to:
  /// **'Jeu'**
  String get dayShortThu;

  /// No description provided for @dayShortFri.
  ///
  /// In fr, this message translates to:
  /// **'Ven'**
  String get dayShortFri;

  /// No description provided for @dayShortSat.
  ///
  /// In fr, this message translates to:
  /// **'Sam'**
  String get dayShortSat;

  /// No description provided for @dayShortSun.
  ///
  /// In fr, this message translates to:
  /// **'Dim'**
  String get dayShortSun;

  /// No description provided for @onboardingTitle1.
  ///
  /// In fr, this message translates to:
  /// **'Gérez vos élèves\nfacilement'**
  String get onboardingTitle1;

  /// No description provided for @onboardingBody1.
  ///
  /// In fr, this message translates to:
  /// **'Ajoutez vos élèves et leurs informations complètes en quelques secondes. Retrouvez-les facilement à tout moment.'**
  String get onboardingBody1;

  /// No description provided for @onboardingTitle2.
  ///
  /// In fr, this message translates to:
  /// **'Suivez les\npaiements'**
  String get onboardingTitle2;

  /// No description provided for @onboardingBody2.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrez les paiements et générez automatiquement des reçus. Plus de confusion dans la gestion financière.'**
  String get onboardingBody2;

  /// No description provided for @onboardingTitle3.
  ///
  /// In fr, this message translates to:
  /// **'Suivi journalier\ndes cours'**
  String get onboardingTitle3;

  /// No description provided for @onboardingBody3.
  ///
  /// In fr, this message translates to:
  /// **'Notez chaque jour la progression des élèves et leur récitation. Un suivi précis et structuré pour chaque séance.'**
  String get onboardingBody3;

  /// No description provided for @onboardingTitle4.
  ///
  /// In fr, this message translates to:
  /// **'Rapports\nautomatiques'**
  String get onboardingTitle4;

  /// No description provided for @onboardingBody4.
  ///
  /// In fr, this message translates to:
  /// **'Obtenez des statistiques hebdomadaires et mensuelles exportables en PDF. Partagez facilement avec les parents.'**
  String get onboardingBody4;

  /// No description provided for @onboardingSkip.
  ///
  /// In fr, this message translates to:
  /// **'Passer'**
  String get onboardingSkip;

  /// No description provided for @homeMainFeatures.
  ///
  /// In fr, this message translates to:
  /// **'Fonctionnalités principales'**
  String get homeMainFeatures;

  /// No description provided for @homeMainFeaturesSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Tout ce dont vous avez besoin pour gérer votre markaz'**
  String get homeMainFeaturesSubtitle;

  /// No description provided for @homeWhyTitle.
  ///
  /// In fr, this message translates to:
  /// **'Pourquoi choisir Markazi ?'**
  String get homeWhyTitle;

  /// No description provided for @homeWhySubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Les avantages qui font la différence'**
  String get homeWhySubtitle;

  /// No description provided for @navFeatures.
  ///
  /// In fr, this message translates to:
  /// **'Fonctionnalités'**
  String get navFeatures;

  /// No description provided for @navAbout.
  ///
  /// In fr, this message translates to:
  /// **'À propos'**
  String get navAbout;

  /// No description provided for @homeBadge.
  ///
  /// In fr, this message translates to:
  /// **'Solution pour maîtres de markaz'**
  String get homeBadge;

  /// No description provided for @homeHeroTitle.
  ///
  /// In fr, this message translates to:
  /// **'Gérez votre markaz\nde façon moderne'**
  String get homeHeroTitle;

  /// No description provided for @homeHeroBody.
  ///
  /// In fr, this message translates to:
  /// **'Élèves, paiements, présences, récitation — tout centralisé dans une seule application simple et efficace.'**
  String get homeHeroBody;

  /// No description provided for @homeStatFree.
  ///
  /// In fr, this message translates to:
  /// **'Gratuit'**
  String get homeStatFree;

  /// No description provided for @homeStatFiveMin.
  ///
  /// In fr, this message translates to:
  /// **'5 min'**
  String get homeStatFiveMin;

  /// No description provided for @homeStatToStart.
  ///
  /// In fr, this message translates to:
  /// **'Pour démarrer'**
  String get homeStatToStart;

  /// No description provided for @homeStatMulti.
  ///
  /// In fr, this message translates to:
  /// **'Multi'**
  String get homeStatMulti;

  /// No description provided for @homeFeatureStudents.
  ///
  /// In fr, this message translates to:
  /// **'Gestion élèves'**
  String get homeFeatureStudents;

  /// No description provided for @homeFeatureStats.
  ///
  /// In fr, this message translates to:
  /// **'Statistiques'**
  String get homeFeatureStats;

  /// No description provided for @homeFeatureReports.
  ///
  /// In fr, this message translates to:
  /// **'Rapports PDF'**
  String get homeFeatureReports;

  /// No description provided for @homeAdvTimeTitle.
  ///
  /// In fr, this message translates to:
  /// **'Gain de temps'**
  String get homeAdvTimeTitle;

  /// No description provided for @homeAdvTimeBody.
  ///
  /// In fr, this message translates to:
  /// **'Réduisez le temps administratif de 80%. Concentrez-vous sur ce qui compte : l\'enseignement.'**
  String get homeAdvTimeBody;

  /// No description provided for @homeAdvOrgTitle.
  ///
  /// In fr, this message translates to:
  /// **'Mieux organisé'**
  String get homeAdvOrgTitle;

  /// No description provided for @homeAdvOrgBody.
  ///
  /// In fr, this message translates to:
  /// **'Toutes vos données centralisées, accessibles partout et à tout moment depuis votre téléphone.'**
  String get homeAdvOrgBody;

  /// No description provided for @homeAdvParentsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Communication parents'**
  String get homeAdvParentsTitle;

  /// No description provided for @homeAdvParentsBody.
  ///
  /// In fr, this message translates to:
  /// **'Partagez reçus et rapports PDF avec les familles de vos élèves en un geste.'**
  String get homeAdvParentsBody;

  /// No description provided for @homeCtaTitle.
  ///
  /// In fr, this message translates to:
  /// **'Prêt à digitaliser votre markaz ?'**
  String get homeCtaTitle;

  /// No description provided for @homeCtaBody.
  ///
  /// In fr, this message translates to:
  /// **'Rejoignez les maîtres qui gèrent leur markaz avec Markazi.'**
  String get homeCtaBody;

  /// No description provided for @homeStart.
  ///
  /// In fr, this message translates to:
  /// **'Commencer'**
  String get homeStart;

  /// No description provided for @homeLearnMore.
  ///
  /// In fr, this message translates to:
  /// **'En savoir plus'**
  String get homeLearnMore;

  /// No description provided for @appTagline.
  ///
  /// In fr, this message translates to:
  /// **'La solution digitale pour les markaz islamiques'**
  String get appTagline;

  /// No description provided for @aboutBadgeIslamic.
  ///
  /// In fr, this message translates to:
  /// **'Islamique'**
  String get aboutBadgeIslamic;

  /// No description provided for @aboutBadgeMobile.
  ///
  /// In fr, this message translates to:
  /// **'Mobile First'**
  String get aboutBadgeMobile;

  /// No description provided for @aboutBadgeAfrica.
  ///
  /// In fr, this message translates to:
  /// **'Afrique'**
  String get aboutBadgeAfrica;

  /// No description provided for @aboutGoalTitle.
  ///
  /// In fr, this message translates to:
  /// **'Notre objectif'**
  String get aboutGoalTitle;

  /// No description provided for @aboutGoalSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Digitaliser les markaz'**
  String get aboutGoalSubtitle;

  /// No description provided for @aboutGoalBody1.
  ///
  /// In fr, this message translates to:
  /// **'Markazi est né d\'un constat simple : les maîtres de markaz gèrent encore leur école avec des cahiers, des notes manuscrites et de la mémoire.'**
  String get aboutGoalBody1;

  /// No description provided for @aboutGoalBody2.
  ///
  /// In fr, this message translates to:
  /// **'Notre objectif est de leur offrir un outil numérique moderne, simple et adapté à leurs besoins, pour qu\'ils puissent se concentrer sur l\'essentiel : transmettre le savoir islamique.'**
  String get aboutGoalBody2;

  /// No description provided for @aboutVisionTitle.
  ///
  /// In fr, this message translates to:
  /// **'Notre vision'**
  String get aboutVisionTitle;

  /// No description provided for @aboutVisionModernTitle.
  ///
  /// In fr, this message translates to:
  /// **'Solution moderne'**
  String get aboutVisionModernTitle;

  /// No description provided for @aboutVisionModernBody.
  ///
  /// In fr, this message translates to:
  /// **'Une application pensée pour les réalités des maîtres africains : simple, rapide et fonctionnant même avec une connexion limitée.'**
  String get aboutVisionModernBody;

  /// No description provided for @aboutVisionEcosystemTitle.
  ///
  /// In fr, this message translates to:
  /// **'Écosystème connecté'**
  String get aboutVisionEcosystemTitle;

  /// No description provided for @aboutVisionEcosystemBody.
  ///
  /// In fr, this message translates to:
  /// **'À terme, relier les maîtres, les élèves et les parents dans un seul écosystème pour une meilleure communication et suivi.'**
  String get aboutVisionEcosystemBody;

  /// No description provided for @aboutVisionImpactTitle.
  ///
  /// In fr, this message translates to:
  /// **'Impact continental'**
  String get aboutVisionImpactTitle;

  /// No description provided for @aboutVisionImpactBody.
  ///
  /// In fr, this message translates to:
  /// **'Devenir la référence en gestion de markaz à travers l\'Afrique francophone et au-delà.'**
  String get aboutVisionImpactBody;

  /// No description provided for @aboutApproachTitle.
  ///
  /// In fr, this message translates to:
  /// **'Notre approche'**
  String get aboutApproachTitle;

  /// No description provided for @aboutApproachUserTitle.
  ///
  /// In fr, this message translates to:
  /// **'Centré utilisateur'**
  String get aboutApproachUserTitle;

  /// No description provided for @aboutApproachUserBody.
  ///
  /// In fr, this message translates to:
  /// **'Conçu avec et pour les maîtres de markaz'**
  String get aboutApproachUserBody;

  /// No description provided for @aboutApproachOfflineBody.
  ///
  /// In fr, this message translates to:
  /// **'Fonctionne sans connexion internet permanente'**
  String get aboutApproachOfflineBody;

  /// No description provided for @aboutApproachSecureTitle.
  ///
  /// In fr, this message translates to:
  /// **'Sécurisé'**
  String get aboutApproachSecureTitle;

  /// No description provided for @aboutApproachSecureBody.
  ///
  /// In fr, this message translates to:
  /// **'Vos données protégées et confidentielles'**
  String get aboutApproachSecureBody;

  /// No description provided for @aboutApproachLangTitle.
  ///
  /// In fr, this message translates to:
  /// **'Multilingue'**
  String get aboutApproachLangTitle;

  /// No description provided for @aboutApproachLangBody.
  ///
  /// In fr, this message translates to:
  /// **'Français, anglais et arabe'**
  String get aboutApproachLangBody;

  /// No description provided for @aboutValuesTitle.
  ///
  /// In fr, this message translates to:
  /// **'Nos valeurs'**
  String get aboutValuesTitle;

  /// No description provided for @aboutValueSimplicityTitle.
  ///
  /// In fr, this message translates to:
  /// **'Simplicité'**
  String get aboutValueSimplicityTitle;

  /// No description provided for @aboutValueSimplicityBody.
  ///
  /// In fr, this message translates to:
  /// **'Un outil qui ne demande pas de formation. Intuitif dès le premier jour.'**
  String get aboutValueSimplicityBody;

  /// No description provided for @aboutValueRespectTitle.
  ///
  /// In fr, this message translates to:
  /// **'Respect'**
  String get aboutValueRespectTitle;

  /// No description provided for @aboutValueRespectBody.
  ///
  /// In fr, this message translates to:
  /// **'Respectueux des valeurs islamiques et des pratiques des communautés.'**
  String get aboutValueRespectBody;

  /// No description provided for @aboutValueImpactTitle.
  ///
  /// In fr, this message translates to:
  /// **'Impact'**
  String get aboutValueImpactTitle;

  /// No description provided for @aboutValueImpactBody.
  ///
  /// In fr, this message translates to:
  /// **'Chaque fonctionnalité est conçue pour avoir un impact réel sur le quotidien du maître.'**
  String get aboutValueImpactBody;

  /// No description provided for @aboutContactTitle.
  ///
  /// In fr, this message translates to:
  /// **'Contactez-nous'**
  String get aboutContactTitle;

  /// No description provided for @aboutContactBody.
  ///
  /// In fr, this message translates to:
  /// **'Une question, une suggestion ou un partenariat ?\nNous sommes à votre écoute.'**
  String get aboutContactBody;

  /// No description provided for @aboutContactButton.
  ///
  /// In fr, this message translates to:
  /// **'Nous contacter'**
  String get aboutContactButton;

  /// No description provided for @featStudentsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Gestion des élèves'**
  String get featStudentsTitle;

  /// No description provided for @featStudentsBody.
  ///
  /// In fr, this message translates to:
  /// **'Créez une fiche complète pour chaque élève : nom, prénom, date de naissance, informations des parents, niveau en Coran, date d\'inscription. Recherchez, filtrez et gérez facilement tous vos élèves depuis une seule page.'**
  String get featStudentsBody;

  /// No description provided for @featStudentsH1.
  ///
  /// In fr, this message translates to:
  /// **'Fiche individuelle complète'**
  String get featStudentsH1;

  /// No description provided for @featStudentsH2.
  ///
  /// In fr, this message translates to:
  /// **'Informations des parents'**
  String get featStudentsH2;

  /// No description provided for @featStudentsH3.
  ///
  /// In fr, this message translates to:
  /// **'Historique de progression'**
  String get featStudentsH3;

  /// No description provided for @featStudentsH4.
  ///
  /// In fr, this message translates to:
  /// **'Recherche et filtrage rapides'**
  String get featStudentsH4;

  /// No description provided for @featPaymentsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Paiements & Reçus'**
  String get featPaymentsTitle;

  /// No description provided for @featPaymentsBody.
  ///
  /// In fr, this message translates to:
  /// **'Gérez les mensualités de chaque élève. Enregistrez les paiements reçus et générez automatiquement des reçus PDF professionnels. Consultez l\'historique des paiements et identifiez facilement les retards.'**
  String get featPaymentsBody;

  /// No description provided for @featPaymentsH1.
  ///
  /// In fr, this message translates to:
  /// **'Suivi des mensualités'**
  String get featPaymentsH1;

  /// No description provided for @featPaymentsH2.
  ///
  /// In fr, this message translates to:
  /// **'Génération de reçus PDF'**
  String get featPaymentsH2;

  /// No description provided for @featPaymentsH3.
  ///
  /// In fr, this message translates to:
  /// **'Historique des paiements'**
  String get featPaymentsH3;

  /// No description provided for @featPaymentsH4.
  ///
  /// In fr, this message translates to:
  /// **'Alertes de retard'**
  String get featPaymentsH4;

  /// No description provided for @featAttendanceTitle.
  ///
  /// In fr, this message translates to:
  /// **'Présence & Récitation'**
  String get featAttendanceTitle;

  /// No description provided for @featAttendanceBody.
  ///
  /// In fr, this message translates to:
  /// **'Pointez les présences et les absences chaque jour en quelques secondes. Évaluez la récitation de chaque élève à chaque séance. Un historique complet pour suivre l\'assiduité et la progression.'**
  String get featAttendanceBody;

  /// No description provided for @featAttendanceH1.
  ///
  /// In fr, this message translates to:
  /// **'Pointage quotidien rapide'**
  String get featAttendanceH1;

  /// No description provided for @featAttendanceH2.
  ///
  /// In fr, this message translates to:
  /// **'Évaluation de récitation'**
  String get featAttendanceH2;

  /// No description provided for @featAttendanceH3.
  ///
  /// In fr, this message translates to:
  /// **'Historique de présence'**
  String get featAttendanceH3;

  /// No description provided for @featAttendanceH4.
  ///
  /// In fr, this message translates to:
  /// **'Notes personnalisées'**
  String get featAttendanceH4;

  /// No description provided for @featStatsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Statistiques hebdomadaires'**
  String get featStatsTitle;

  /// No description provided for @featStatsBody.
  ///
  /// In fr, this message translates to:
  /// **'Obtenez une vue d\'ensemble de votre classe chaque semaine. Taux d\'assiduité, progression en récitation, paiements reçus — toutes les métriques importantes visualisées clairement.'**
  String get featStatsBody;

  /// No description provided for @featStatsH1.
  ///
  /// In fr, this message translates to:
  /// **'Tableau de bord hebdomadaire'**
  String get featStatsH1;

  /// No description provided for @featStatsH2.
  ///
  /// In fr, this message translates to:
  /// **'Graphiques de progression'**
  String get featStatsH2;

  /// No description provided for @featStatsH3.
  ///
  /// In fr, this message translates to:
  /// **'Taux d\'assiduité'**
  String get featStatsH3;

  /// No description provided for @featStatsH4.
  ///
  /// In fr, this message translates to:
  /// **'Comparaison des élèves'**
  String get featStatsH4;

  /// No description provided for @featReportTitle.
  ///
  /// In fr, this message translates to:
  /// **'Rapport mensuel PDF'**
  String get featReportTitle;

  /// No description provided for @featReportBody.
  ///
  /// In fr, this message translates to:
  /// **'Générez un rapport mensuel complet pour chaque élève ou pour toute la classe. Partagez-le avec les parents par WhatsApp, e-mail ou toute application de votre téléphone. Rapport professionnel avec toutes les informations importantes.'**
  String get featReportBody;

  /// No description provided for @featReportH1.
  ///
  /// In fr, this message translates to:
  /// **'Rapport élève individuel'**
  String get featReportH1;

  /// No description provided for @featReportH2.
  ///
  /// In fr, this message translates to:
  /// **'Rapport de classe complet'**
  String get featReportH2;

  /// No description provided for @featReportH3.
  ///
  /// In fr, this message translates to:
  /// **'Partage WhatsApp, e-mail…'**
  String get featReportH3;

  /// No description provided for @featReportH4.
  ///
  /// In fr, this message translates to:
  /// **'Format PDF professionnel'**
  String get featReportH4;

  /// No description provided for @featAbsenceTitle.
  ///
  /// In fr, this message translates to:
  /// **'Gestion des absences'**
  String get featAbsenceTitle;

  /// No description provided for @featAbsenceBody.
  ///
  /// In fr, this message translates to:
  /// **'Suivez le taux d\'absentéisme de chaque élève sur les jours de cours réels du markaz. Distinguez les absences justifiées et partagez les rapports d\'assiduité avec les parents.'**
  String get featAbsenceBody;

  /// No description provided for @featAbsenceH1.
  ///
  /// In fr, this message translates to:
  /// **'Taux d\'absentéisme par élève'**
  String get featAbsenceH1;

  /// No description provided for @featAbsenceH2.
  ///
  /// In fr, this message translates to:
  /// **'Jours de cours configurables'**
  String get featAbsenceH2;

  /// No description provided for @featAbsenceH3.
  ///
  /// In fr, this message translates to:
  /// **'Rapports d\'assiduité à partager'**
  String get featAbsenceH3;

  /// No description provided for @featAbsenceH4.
  ///
  /// In fr, this message translates to:
  /// **'Justifications d\'absence'**
  String get featAbsenceH4;

  /// No description provided for @featHeaderBadge.
  ///
  /// In fr, this message translates to:
  /// **'6 fonctionnalités essentielles'**
  String get featHeaderBadge;

  /// No description provided for @featHeaderTitle.
  ///
  /// In fr, this message translates to:
  /// **'Tout ce qu\'il vous faut\npour gérer votre markaz'**
  String get featHeaderTitle;

  /// No description provided for @featHeaderBody.
  ///
  /// In fr, this message translates to:
  /// **'Markazi regroupe tous les outils nécessaires à la gestion quotidienne de votre markaz dans une application simple et intuitive.'**
  String get featHeaderBody;

  /// No description provided for @featCtaTitle.
  ///
  /// In fr, this message translates to:
  /// **'Essayez Markazi gratuitement'**
  String get featCtaTitle;

  /// No description provided for @featCtaBody.
  ///
  /// In fr, this message translates to:
  /// **'Créez votre compte et démarrez en moins de 5 minutes.'**
  String get featCtaBody;

  /// No description provided for @featCtaButton.
  ///
  /// In fr, this message translates to:
  /// **'Créer mon compte'**
  String get featCtaButton;
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
