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

  /// No description provided for @navActivityLog.
  ///
  /// In fr, this message translates to:
  /// **'Journal d\'activité'**
  String get navActivityLog;

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
