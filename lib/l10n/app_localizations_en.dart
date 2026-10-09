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

  @override
  String get navActivityLog => 'Activity log';

  @override
  String get actionRetry => 'Retry';

  @override
  String get activityFilterAll => 'All';

  @override
  String get activityCategoryStudent => 'Students';

  @override
  String get activityCategoryClass => 'Groups';

  @override
  String get activityCategoryGuardian => 'Guardians';

  @override
  String get activityCategoryAttendance => 'Attendance';

  @override
  String get activityCategoryRecitation => 'Recitations';

  @override
  String get activityCategoryPayment => 'Payments';

  @override
  String get activityCategoryMarkaz => 'Markaz';

  @override
  String get activityCategoryUser => 'Account';

  @override
  String get activityCategorySync => 'Conflicts';

  @override
  String get activityPeriodAll => 'All dates';

  @override
  String get activityPeriod7 => 'Last 7 days';

  @override
  String get activityPeriod30 => 'Last 30 days';

  @override
  String get activityToday => 'Today';

  @override
  String get activityYesterday => 'Yesterday';

  @override
  String get activityEmpty => 'No activity for this filter.';

  @override
  String get activityLoadError =>
      'Could not load the activity log. Check your connection.';

  @override
  String get activityOfflineBadge => 'Entered offline';

  @override
  String activityByUser(String name) {
    return 'by $name';
  }

  @override
  String get activityConflictTitle => 'Sync conflict';

  @override
  String activityConflictExplanation(
      String performedAt, String serverUpdatedAt) {
    return 'This action was made offline on $performedAt, but the data had been changed on the server in the meantime (on $serverUpdatedAt). The offline version was applied. Replaced server version:';
  }

  @override
  String get activityConflictHint => 'Tap to see the replaced version';

  @override
  String get receiptPendingSync =>
      'Payment saved offline. The receipt will be available after synchronization (its number is assigned by the server).';

  @override
  String get navSync => 'Synchronization';

  @override
  String get syncOnline => 'Connected to the server';

  @override
  String get syncOffline => 'Offline';

  @override
  String get syncOfflineBanner =>
      'Offline — your entries are saved on the device and will be sent automatically.';

  @override
  String syncPendingBanner(String count) {
    return '$count action(s) waiting to be synchronized';
  }

  @override
  String syncFailedBanner(String count) {
    return '$count action(s) rejected by the server — please check';
  }

  @override
  String get syncNow => 'Synchronize now';

  @override
  String get syncInProgress => 'Synchronizing…';

  @override
  String get syncAllDone => 'Everything is synchronized.';

  @override
  String syncResult(String synced, String failed) {
    return '$synced action(s) sent, $failed rejected.';
  }

  @override
  String get syncStillOffline =>
      'Server still unreachable. Automatic retry as soon as the connection is back.';

  @override
  String get syncEmpty =>
      'No pending actions. All your entries are on the server.';

  @override
  String get syncPendingTitle => 'Pending actions';

  @override
  String get syncOpCreate => 'Creation';

  @override
  String get syncOpUpdate => 'Change';

  @override
  String get syncOpDelete => 'Deletion';

  @override
  String get syncEntityPayment => 'Payment';

  @override
  String get syncEntityAttendance => 'Attendance';

  @override
  String get syncEntityGuardian => 'Guardian';

  @override
  String get syncEntityRecitation => 'Recitation';

  @override
  String get syncEntityClass => 'Group';

  @override
  String get syncEntityStudentClass => 'Group assignment';

  @override
  String syncDoneAt(String date) {
    return 'Entered on $date';
  }

  @override
  String syncRejected(String message) {
    return 'Rejected by the server: $message';
  }

  @override
  String get syncDiscard => 'Discard this action';

  @override
  String get syncDiscardConfirmTitle => 'Discard this action?';

  @override
  String get syncDiscardConfirmBody =>
      'It will never be sent to the server. A creation will be removed from the device; a change will be replaced by the server version at the next synchronization.';

  @override
  String get syncConflictsHint =>
      'Possible conflicts (data changed on the server in the meantime) can be reviewed in the activity log.';
}
