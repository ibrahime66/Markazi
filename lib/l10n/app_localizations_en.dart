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

  @override
  String get guardianDeleteTitle => 'Delete this guardian?';

  @override
  String guardianDeleteBody(Object guardian) {
    return '“$guardian” will be permanently deleted.';
  }

  @override
  String get guardianDeleted => 'Guardian deleted';

  @override
  String commonErrorWithDetail(Object error) {
    return 'Error: $error';
  }

  @override
  String get guardianEmptyTitle => 'No guardian recorded';

  @override
  String get guardianEmptyBody =>
      'Add parents/guardians to link them to students.';

  @override
  String get guardianNamePhoneRequired => 'Name and phone are required';

  @override
  String get guardianEditTitle => 'Edit guardian';

  @override
  String get guardianAddTitle => 'Add a guardian';

  @override
  String get fieldNameRequired => 'Name *';

  @override
  String get fieldPhoneRequired => 'Phone *';

  @override
  String get guardianLinkedStudents => 'Linked students';

  @override
  String get commonAddStudentFirst => 'Add a student first';

  @override
  String get recitationDeleteTitle => 'Delete this session?';

  @override
  String get recitationDeleteBody =>
      'This recitation will be permanently deleted.';

  @override
  String get recitationDeleted => 'Recitation deleted';

  @override
  String get recitationStatusRecited => 'Recited';

  @override
  String get recitationStatusPartial => 'Partial';

  @override
  String get recitationStatusNotRecited => 'Not recited';

  @override
  String get recitationEmptyTitle => 'No recitation recorded';

  @override
  String get recitationEmptyBody =>
      'Record the surah studied by each student after each session.';

  @override
  String get commonStudentDeleted => 'Deleted student';

  @override
  String recitationVerseRange(Object ayahFrom, Object ayahTo) {
    return ' (verses $ayahFrom-$ayahTo)';
  }

  @override
  String get recitationSurahRequired => 'The surah is required';

  @override
  String get recitationEditTitle => 'Edit recitation';

  @override
  String get recitationAddTitle => 'Record a recitation';

  @override
  String get fieldStudentRequired => 'Student *';

  @override
  String commonDateDmy(Object day, Object month, Object year) {
    return 'Date: $day/$month/$year';
  }

  @override
  String get fieldSurahRequired => 'Surah *';

  @override
  String get fieldAyahFrom => 'First verse';

  @override
  String get fieldAyahTo => 'Last verse';

  @override
  String get fieldStatus => 'Status';

  @override
  String get fieldNoteOptional => 'Note (optional)';

  @override
  String get groupInfoTitle => 'Group information';

  @override
  String get fieldLevel => 'Level';

  @override
  String get fieldTeacher => 'Teacher';

  @override
  String get fieldCapacity => 'Capacity';

  @override
  String groupCapacityValue(Object studentIdsCount, Object maxStudents) {
    return '$studentIdsCount/$maxStudents students';
  }

  @override
  String get fieldDescription => 'Description';

  @override
  String get fieldSchedule => 'Schedule';

  @override
  String get fieldRoom => 'Room';

  @override
  String get commonInactive => 'Inactive';

  @override
  String get fieldCreatedOn => 'Created on';

  @override
  String get groupStatsTitle => 'Group statistics';

  @override
  String get statAttendanceRate => 'Attendance rate';

  @override
  String get statPaymentRate => 'Payment rate';

  @override
  String get statTotalPaid => 'Total paid';

  @override
  String get groupNoStudents => 'No students in this group';

  @override
  String get groupStudentsTitle => 'Group students';

  @override
  String get fieldStudentName => 'Student name';

  @override
  String get fieldAmount => 'Amount';

  @override
  String get authEnterValidEmail => 'Enter a valid email';

  @override
  String get forgotCodeSent =>
      'Code sent by email. Also check your spam folder.';

  @override
  String get authAllFieldsRequired => 'All fields must be filled in';

  @override
  String get authPasswordsDoNotMatch => 'Passwords do not match';

  @override
  String get forgotPasswordReset => 'Password reset. Please log in.';

  @override
  String get forgotTitle => 'Forgot password';

  @override
  String get forgotStepCode =>
      'Enter the code received by email and your new password.';

  @override
  String get forgotStepEmail =>
      'Enter your email; a reset code will be sent to you.';

  @override
  String get authEmailHint => 'your.email@example.com';

  @override
  String get forgotSendCode => 'Send code';

  @override
  String get forgotCodeLabel => 'Code received by email';

  @override
  String get forgotCodeHint => 'Paste the code here';

  @override
  String get forgotNewPassword => 'New password';

  @override
  String get authPasswordHint => 'At least 6 characters';

  @override
  String get forgotConfirmPassword => 'Confirm password';

  @override
  String get forgotResetButton => 'Reset password';

  @override
  String get forgotRestart => 'I didn\'t receive a code, start over';

  @override
  String get authInvalidEmail => 'Invalid email';

  @override
  String get loginUnknownError => 'Unknown error while logging in';

  @override
  String get loginError => 'Login error. Please try again.';

  @override
  String get registerUnknownError => 'Unknown error while creating the account';

  @override
  String get registerError =>
      'Error while creating the account. Please try again.';

  @override
  String get authLogin => 'Log in';

  @override
  String get loginSubtitle => 'Access your markaz account';

  @override
  String get authPassword => 'Password';

  @override
  String get loginForgotPassword => 'Forgot password?';

  @override
  String get loginNoAccount => 'No account yet? ';

  @override
  String get authCreateAccount => 'Create an account';

  @override
  String get registerSubtitle => 'Join Markazi in a few seconds';

  @override
  String get fieldFullName => 'Full name';

  @override
  String get registerNameHint => 'e.g. Ahmed Ben Ali';

  @override
  String get registerMarkazHint => 'e.g. Markaz Al-Nour';

  @override
  String get registerHaveAccount => 'Already have an account? ';

  @override
  String get splashTagline => 'Manage your markaz\nsimply and efficiently';

  @override
  String get commonLoading => 'Loading...';

  @override
  String get dayShortMon => 'Mon';

  @override
  String get dayShortTue => 'Tue';

  @override
  String get dayShortWed => 'Wed';

  @override
  String get dayShortThu => 'Thu';

  @override
  String get dayShortFri => 'Fri';

  @override
  String get dayShortSat => 'Sat';

  @override
  String get dayShortSun => 'Sun';

  @override
  String get onboardingTitle1 => 'Manage your students\neasily';

  @override
  String get onboardingBody1 =>
      'Add your students and their full details in seconds. Find them easily at any time.';

  @override
  String get onboardingTitle2 => 'Track\npayments';

  @override
  String get onboardingBody2 =>
      'Record payments and generate receipts automatically. No more confusion in financial management.';

  @override
  String get onboardingTitle3 => 'Daily lesson\ntracking';

  @override
  String get onboardingBody3 =>
      'Record your students\' progress and recitation every day. Precise, structured tracking for every session.';

  @override
  String get onboardingTitle4 => 'Automatic\nreports';

  @override
  String get onboardingBody4 =>
      'Get weekly and monthly statistics exportable as PDF. Share them easily with parents.';

  @override
  String get onboardingSkip => 'Skip';

  @override
  String get homeMainFeatures => 'Main features';

  @override
  String get homeMainFeaturesSubtitle =>
      'Everything you need to manage your markaz';

  @override
  String get homeWhyTitle => 'Why choose Markazi?';

  @override
  String get homeWhySubtitle => 'The advantages that make the difference';

  @override
  String get navFeatures => 'Features';

  @override
  String get navAbout => 'About';

  @override
  String get homeBadge => 'A solution for markaz teachers';

  @override
  String get homeHeroTitle => 'Manage your markaz\nthe modern way';

  @override
  String get homeHeroBody =>
      'Students, payments, attendance, recitation — all in one simple and efficient app.';

  @override
  String get homeStatFree => 'Free';

  @override
  String get homeStatFiveMin => '5 min';

  @override
  String get homeStatToStart => 'To get started';

  @override
  String get homeStatMulti => 'Multi';

  @override
  String get homeFeatureStudents => 'Student management';

  @override
  String get homeFeatureStats => 'Statistics';

  @override
  String get homeFeatureReports => 'PDF reports';

  @override
  String get homeAdvTimeTitle => 'Save time';

  @override
  String get homeAdvTimeBody =>
      'Cut administrative time by 80%. Focus on what matters: teaching.';

  @override
  String get homeAdvOrgTitle => 'Better organized';

  @override
  String get homeAdvOrgBody =>
      'All your data in one place, available anywhere, anytime from your phone.';

  @override
  String get homeAdvParentsTitle => 'Parent communication';

  @override
  String get homeAdvParentsBody =>
      'Share receipts and PDF reports with your students\' families in one tap.';

  @override
  String get homeCtaTitle => 'Ready to digitize your markaz?';

  @override
  String get homeCtaBody =>
      'Join the teachers who manage their markaz with Markazi.';

  @override
  String get homeStart => 'Get started';

  @override
  String get homeLearnMore => 'Learn more';

  @override
  String get appTagline => 'The digital solution for Islamic markaz';

  @override
  String get aboutBadgeIslamic => 'Islamic';

  @override
  String get aboutBadgeMobile => 'Mobile first';

  @override
  String get aboutBadgeAfrica => 'Africa';

  @override
  String get aboutGoalTitle => 'Our goal';

  @override
  String get aboutGoalSubtitle => 'Digitizing the markaz';

  @override
  String get aboutGoalBody1 =>
      'Markazi was born from a simple observation: markaz teachers still run their school with notebooks, handwritten notes and memory.';

  @override
  String get aboutGoalBody2 =>
      'Our goal is to give them a modern, simple digital tool suited to their needs, so they can focus on what matters: passing on Islamic knowledge.';

  @override
  String get aboutVisionTitle => 'Our vision';

  @override
  String get aboutVisionModernTitle => 'A modern solution';

  @override
  String get aboutVisionModernBody =>
      'An app designed for the realities of African teachers: simple, fast and working even with a limited connection.';

  @override
  String get aboutVisionEcosystemTitle => 'A connected ecosystem';

  @override
  String get aboutVisionEcosystemBody =>
      'Eventually, connecting teachers, students and parents in a single ecosystem for better communication and follow-up.';

  @override
  String get aboutVisionImpactTitle => 'Continental impact';

  @override
  String get aboutVisionImpactBody =>
      'To become the reference for markaz management across French-speaking Africa and beyond.';

  @override
  String get aboutApproachTitle => 'Our approach';

  @override
  String get aboutApproachUserTitle => 'User-centered';

  @override
  String get aboutApproachUserBody => 'Designed with and for markaz teachers';

  @override
  String get aboutApproachOfflineBody =>
      'Works without a permanent internet connection';

  @override
  String get aboutApproachSecureTitle => 'Secure';

  @override
  String get aboutApproachSecureBody => 'Your data protected and confidential';

  @override
  String get aboutApproachLangTitle => 'Multilingual';

  @override
  String get aboutApproachLangBody => 'French, English and Arabic';

  @override
  String get aboutValuesTitle => 'Our values';

  @override
  String get aboutValueSimplicityTitle => 'Simplicity';

  @override
  String get aboutValueSimplicityBody =>
      'A tool that needs no training. Intuitive from day one.';

  @override
  String get aboutValueRespectTitle => 'Respect';

  @override
  String get aboutValueRespectBody =>
      'Respectful of Islamic values and community practices.';

  @override
  String get aboutValueImpactTitle => 'Impact';

  @override
  String get aboutValueImpactBody =>
      'Every feature is designed to make a real difference in the teacher\'s daily life.';

  @override
  String get aboutContactTitle => 'Contact us';

  @override
  String get aboutContactBody =>
      'A question, a suggestion or a partnership?\nWe are listening.';

  @override
  String get aboutContactButton => 'Contact us';

  @override
  String get featStudentsTitle => 'Student management';

  @override
  String get featStudentsBody =>
      'Create a complete record for each student: name, date of birth, parent details, Quran level, enrollment date. Search, filter and manage all your students easily from a single page.';

  @override
  String get featStudentsH1 => 'Complete individual record';

  @override
  String get featStudentsH2 => 'Parent details';

  @override
  String get featStudentsH3 => 'Progress history';

  @override
  String get featStudentsH4 => 'Fast search and filtering';

  @override
  String get featPaymentsTitle => 'Payments & receipts';

  @override
  String get featPaymentsBody =>
      'Manage each student\'s monthly fees. Record payments received and automatically generate professional PDF receipts. Review payment history and easily spot late payments.';

  @override
  String get featPaymentsH1 => 'Monthly fee tracking';

  @override
  String get featPaymentsH2 => 'PDF receipt generation';

  @override
  String get featPaymentsH3 => 'Payment history';

  @override
  String get featPaymentsH4 => 'Late payment alerts';

  @override
  String get featAttendanceTitle => 'Attendance & recitation';

  @override
  String get featAttendanceBody =>
      'Mark attendance and absences every day in seconds. Assess each student\'s recitation at every session. A complete history to follow attendance and progress.';

  @override
  String get featAttendanceH1 => 'Fast daily check-in';

  @override
  String get featAttendanceH2 => 'Recitation assessment';

  @override
  String get featAttendanceH3 => 'Attendance history';

  @override
  String get featAttendanceH4 => 'Custom notes';

  @override
  String get featStatsTitle => 'Weekly statistics';

  @override
  String get featStatsBody =>
      'Get an overview of your class every week. Attendance rate, recitation progress, payments received — all the key metrics shown clearly.';

  @override
  String get featStatsH1 => 'Weekly dashboard';

  @override
  String get featStatsH2 => 'Progress charts';

  @override
  String get featStatsH3 => 'Attendance rate';

  @override
  String get featStatsH4 => 'Student comparison';

  @override
  String get featReportTitle => 'Monthly PDF report';

  @override
  String get featReportBody =>
      'Generate a complete monthly report for each student or for the whole class. Share it with parents via WhatsApp, email or any app on your phone. A professional report with all the key information.';

  @override
  String get featReportH1 => 'Individual student report';

  @override
  String get featReportH2 => 'Full class report';

  @override
  String get featReportH3 => 'Share via WhatsApp, email…';

  @override
  String get featReportH4 => 'Professional PDF format';

  @override
  String get featAbsenceTitle => 'Absence management';

  @override
  String get featAbsenceBody =>
      'Track each student\'s absence rate over the markaz\'s actual school days. Distinguish excused absences and share attendance reports with parents.';

  @override
  String get featAbsenceH1 => 'Absence rate per student';

  @override
  String get featAbsenceH2 => 'Configurable school days';

  @override
  String get featAbsenceH3 => 'Shareable attendance reports';

  @override
  String get featAbsenceH4 => 'Absence justifications';

  @override
  String get featHeaderBadge => '6 essential features';

  @override
  String get featHeaderTitle => 'Everything you need\nto manage your markaz';

  @override
  String get featHeaderBody =>
      'Markazi brings together all the tools you need for the daily management of your markaz in one simple, intuitive app.';

  @override
  String get featCtaTitle => 'Try Markazi for free';

  @override
  String get featCtaBody =>
      'Create your account and get started in less than 5 minutes.';

  @override
  String get featCtaButton => 'Create my account';
}
