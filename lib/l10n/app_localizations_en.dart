// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get navOverview => 'Overview';

  @override
  String get navStudents => 'Students';

  @override
  String get navGroups => 'Groups';

  @override
  String get navPayments => 'Payments';

  @override
  String get navAttendance => 'Attendance';

  @override
  String get navReports => 'Reports';

  @override
  String get navMyMarkaz => 'My Markaz';

  @override
  String get navGuardians => 'Guardians / Parents';

  @override
  String get navRecitations => 'Recitations';

  @override
  String get navLogout => 'Log out';

  @override
  String get navDarkMode => 'Dark mode';

  @override
  String get actionSave => 'Save';

  @override
  String get actionSaving => 'Saving...';

  @override
  String get actionCancel => 'Cancel';

  @override
  String get actionAdd => 'Add';

  @override
  String get actionEdit => 'Edit';

  @override
  String get actionDelete => 'Delete';

  @override
  String get actionClose => 'Close';

  @override
  String get actionConfirm => 'Confirm';

  @override
  String get actionShare => 'Share';

  @override
  String get actionDownload => 'Download';

  @override
  String get markazSettingsTitle => 'My Markaz';

  @override
  String get markazHeaderSubtitle =>
      'This information is used throughout the app.';

  @override
  String get markazSectionIdentity => 'Identity';

  @override
  String get markazSectionIdentitySubtitle =>
      'Shown on generated receipts and reports.';

  @override
  String get markazSectionContact => 'Contact details';

  @override
  String get markazSectionFinance => 'Finance';

  @override
  String get markazSectionFinanceSubtitle =>
      'Currency used for all amounts in the app.';

  @override
  String get markazSectionSchedule => 'School days';

  @override
  String get markazSectionScheduleSubtitle =>
      'Used to calculate students\' attendance rate.';

  @override
  String get markazSectionAppearance => 'Appearance';

  @override
  String get markazSectionAppearanceSubtitle =>
      'Choose how the app looks on this device.';

  @override
  String get markazSectionLanguage => 'Language';

  @override
  String get markazSectionLanguageSubtitle => 'Choose the app\'s language.';

  @override
  String get fieldMarkazName => 'Markaz name';

  @override
  String get fieldSlogan => 'Slogan';

  @override
  String get fieldAddress => 'Address';

  @override
  String get fieldCity => 'City';

  @override
  String get fieldCountry => 'Country';

  @override
  String get fieldCurrency => 'Currency (e.g. GNF, XOF, EUR)';

  @override
  String get fieldPhone => 'Phone';

  @override
  String get fieldEmail => 'Email';

  @override
  String get appearanceSystem => 'System';

  @override
  String get appearanceLight => 'Light';

  @override
  String get appearanceDark => 'Dark';

  @override
  String get languageFrench => 'Français';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageArabic => 'العربية';

  @override
  String get markazNameRequired => 'The Markaz name is required';

  @override
  String get markazUpdated => 'Markaz profile updated';

  @override
  String get genericError => 'Error';
}
