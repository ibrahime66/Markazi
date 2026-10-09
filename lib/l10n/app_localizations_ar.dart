// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get navOverview => 'نظرة عامة';

  @override
  String get navStudents => 'الطلاب';

  @override
  String get navGroups => 'المجموعات';

  @override
  String get navPayments => 'المدفوعات';

  @override
  String get navAttendance => 'الحضور';

  @override
  String get navReports => 'التقارير';

  @override
  String get navMyMarkaz => 'مركزي';

  @override
  String get navGuardians => 'الأولياء / الآباء';

  @override
  String get navRecitations => 'التسميع';

  @override
  String get navLogout => 'تسجيل الخروج';

  @override
  String get navDarkMode => 'الوضع الداكن';

  @override
  String get actionSave => 'حفظ';

  @override
  String get actionSaving => 'جارٍ الحفظ...';

  @override
  String get actionCancel => 'إلغاء';

  @override
  String get actionAdd => 'إضافة';

  @override
  String get actionEdit => 'تعديل';

  @override
  String get actionDelete => 'حذف';

  @override
  String get actionClose => 'إغلاق';

  @override
  String get actionConfirm => 'تأكيد';

  @override
  String get actionShare => 'مشاركة';

  @override
  String get actionDownload => 'تنزيل';

  @override
  String get markazSettingsTitle => 'مركزي';

  @override
  String get markazHeaderSubtitle =>
      'تُستخدم هذه المعلومات في جميع أنحاء التطبيق.';

  @override
  String get markazSectionIdentity => 'الهوية';

  @override
  String get markazSectionIdentitySubtitle =>
      'تظهر في الإيصالات والتقارير المُصدرة.';

  @override
  String get markazSectionContact => 'معلومات الاتصال';

  @override
  String get markazSectionFinance => 'المالية';

  @override
  String get markazSectionFinanceSubtitle =>
      'العملة المستخدمة لجميع المبالغ في التطبيق.';

  @override
  String get markazSectionSchedule => 'أيام الدراسة';

  @override
  String get markazSectionScheduleSubtitle => 'تُستخدم لحساب نسبة حضور الطلاب.';

  @override
  String get markazSectionAppearance => 'المظهر';

  @override
  String get markazSectionAppearanceSubtitle =>
      'اختر مظهر التطبيق على هذا الجهاز.';

  @override
  String get markazSectionLanguage => 'اللغة';

  @override
  String get markazSectionLanguageSubtitle => 'اختر لغة التطبيق.';

  @override
  String get fieldMarkazName => 'اسم المركز';

  @override
  String get fieldSlogan => 'الشعار';

  @override
  String get fieldAddress => 'العنوان';

  @override
  String get fieldCity => 'المدينة';

  @override
  String get fieldCountry => 'البلد';

  @override
  String get fieldCurrency => 'العملة (مثال: GNF, XOF, EUR)';

  @override
  String get fieldPhone => 'الهاتف';

  @override
  String get fieldEmail => 'البريد الإلكتروني';

  @override
  String get appearanceSystem => 'النظام';

  @override
  String get appearanceLight => 'فاتح';

  @override
  String get appearanceDark => 'داكن';

  @override
  String get languageFrench => 'Français';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageArabic => 'العربية';

  @override
  String get markazNameRequired => 'اسم المركز إلزامي';

  @override
  String get markazUpdated => 'تم تحديث بيانات المركز';

  @override
  String get genericError => 'خطأ';

  @override
  String get navActivityLog => 'سجل النشاط';

  @override
  String get actionRetry => 'إعادة المحاولة';

  @override
  String get activityFilterAll => 'الكل';

  @override
  String get activityCategoryStudent => 'الطلاب';

  @override
  String get activityCategoryClass => 'المجموعات';

  @override
  String get activityCategoryGuardian => 'أولياء الأمور';

  @override
  String get activityCategoryAttendance => 'الحضور';

  @override
  String get activityCategoryRecitation => 'التسميع';

  @override
  String get activityCategoryPayment => 'المدفوعات';

  @override
  String get activityCategoryMarkaz => 'المركز';

  @override
  String get activityCategoryUser => 'الحساب';

  @override
  String get activityCategorySync => 'التعارضات';

  @override
  String get activityPeriodAll => 'كل التواريخ';

  @override
  String get activityPeriod7 => 'آخر 7 أيام';

  @override
  String get activityPeriod30 => 'آخر 30 يومًا';

  @override
  String get activityToday => 'اليوم';

  @override
  String get activityYesterday => 'أمس';

  @override
  String get activityEmpty => 'لا يوجد نشاط لهذا الاختيار.';

  @override
  String get activityLoadError => 'تعذّر تحميل السجل. تحقق من اتصالك.';

  @override
  String get activityOfflineBadge => 'أُدخل دون اتصال';

  @override
  String activityByUser(String name) {
    return 'بواسطة $name';
  }

  @override
  String get activityConflictTitle => 'تعارض في المزامنة';

  @override
  String activityConflictExplanation(
      String performedAt, String serverUpdatedAt) {
    return 'تم تنفيذ هذا الإجراء دون اتصال في $performedAt، لكن البيانات كانت قد تغيّرت على الخادم في هذه الأثناء (في $serverUpdatedAt). تم تطبيق النسخة غير المتصلة. نسخة الخادم المستبدلة:';
  }

  @override
  String get activityConflictHint => 'اضغط لعرض النسخة المستبدلة';

  @override
  String get receiptPendingSync =>
      'تم حفظ الدفعة دون اتصال. سيتوفر الإيصال بعد المزامنة (يُخصَّص رقمه من الخادم).';

  @override
  String get navSync => 'المزامنة';

  @override
  String get syncOnline => 'متصل بالخادم';

  @override
  String get syncOffline => 'دون اتصال';

  @override
  String get syncOfflineBanner =>
      'دون اتصال — يتم حفظ إدخالاتك على الجهاز وسيتم إرسالها تلقائيًا.';

  @override
  String syncPendingBanner(String count) {
    return '$count إجراء(ات) بانتظار المزامنة';
  }

  @override
  String syncFailedBanner(String count) {
    return '$count إجراء(ات) رفضها الخادم — يُرجى التحقق';
  }

  @override
  String get syncNow => 'زامن الآن';

  @override
  String get syncInProgress => 'جارٍ المزامنة…';

  @override
  String get syncAllDone => 'تمت مزامنة كل شيء.';

  @override
  String syncResult(String synced, String failed) {
    return 'تم إرسال $synced إجراء(ات)، ورُفض $failed.';
  }

  @override
  String get syncStillOffline =>
      'لا يزال الخادم غير متاح. ستتم إعادة المحاولة تلقائيًا عند عودة الاتصال.';

  @override
  String get syncEmpty =>
      'لا توجد إجراءات معلّقة. جميع إدخالاتك موجودة على الخادم.';

  @override
  String get syncPendingTitle => 'الإجراءات المعلّقة';

  @override
  String get syncOpCreate => 'إنشاء';

  @override
  String get syncOpUpdate => 'تعديل';

  @override
  String get syncOpDelete => 'حذف';

  @override
  String get syncEntityPayment => 'دفعة';

  @override
  String get syncEntityAttendance => 'حضور';

  @override
  String get syncEntityGuardian => 'ولي أمر';

  @override
  String get syncEntityRecitation => 'تسميع';

  @override
  String get syncEntityClass => 'مجموعة';

  @override
  String get syncEntityStudentClass => 'تعيين في مجموعة';

  @override
  String syncDoneAt(String date) {
    return 'أُدخل في $date';
  }

  @override
  String syncRejected(String message) {
    return 'رفضه الخادم: $message';
  }

  @override
  String get syncDiscard => 'تجاهل هذا الإجراء';

  @override
  String get syncDiscardConfirmTitle => 'تجاهل هذا الإجراء؟';

  @override
  String get syncDiscardConfirmBody =>
      'لن يُرسل إلى الخادم أبدًا. سيُحذف الإنشاء من الجهاز، وسيُستبدل التعديل بنسخة الخادم في المزامنة التالية.';

  @override
  String get syncConflictsHint =>
      'يمكن مراجعة التعارضات المحتملة (بيانات تغيّرت على الخادم في هذه الأثناء) في سجل النشاط.';
}
