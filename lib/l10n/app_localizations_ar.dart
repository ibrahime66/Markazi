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

  @override
  String get guardianDeleteTitle => 'حذف ولي الأمر هذا؟';

  @override
  String guardianDeleteBody(Object guardian) {
    return 'سيتم حذف «$guardian» نهائيًا.';
  }

  @override
  String get guardianDeleted => 'تم حذف ولي الأمر';

  @override
  String commonErrorWithDetail(Object error) {
    return 'خطأ: $error';
  }

  @override
  String get guardianEmptyTitle => 'لا يوجد أولياء أمور مسجلون';

  @override
  String get guardianEmptyBody => 'أضف الآباء/أولياء الأمور لربطهم بالطلاب.';

  @override
  String get guardianNamePhoneRequired => 'الاسم والهاتف مطلوبان';

  @override
  String get guardianEditTitle => 'تعديل ولي الأمر';

  @override
  String get guardianAddTitle => 'إضافة ولي أمر';

  @override
  String get fieldNameRequired => 'الاسم *';

  @override
  String get fieldPhoneRequired => 'الهاتف *';

  @override
  String get guardianLinkedStudents => 'الطلاب المرتبطون';

  @override
  String get commonAddStudentFirst => 'أضف طالبًا أولًا';

  @override
  String get recitationDeleteTitle => 'حذف هذه الجلسة؟';

  @override
  String get recitationDeleteBody => 'سيتم حذف هذا التسميع نهائيًا.';

  @override
  String get recitationDeleted => 'تم حذف التسميع';

  @override
  String get recitationStatusRecited => 'تم التسميع';

  @override
  String get recitationStatusPartial => 'جزئي';

  @override
  String get recitationStatusNotRecited => 'لم يُسمَّع';

  @override
  String get recitationEmptyTitle => 'لا يوجد تسميع مسجل';

  @override
  String get recitationEmptyBody =>
      'سجّل السورة التي درسها كل طالب بعد كل جلسة.';

  @override
  String get commonStudentDeleted => 'طالب محذوف';

  @override
  String recitationVerseRange(Object ayahFrom, Object ayahTo) {
    return ' (الآيات $ayahFrom-$ayahTo)';
  }

  @override
  String get recitationSurahRequired => 'السورة مطلوبة';

  @override
  String get recitationEditTitle => 'تعديل التسميع';

  @override
  String get recitationAddTitle => 'تسجيل تسميع';

  @override
  String get fieldStudentRequired => 'الطالب *';

  @override
  String commonDateDmy(Object day, Object month, Object year) {
    return 'التاريخ: $day/$month/$year';
  }

  @override
  String get fieldSurahRequired => 'السورة *';

  @override
  String get fieldAyahFrom => 'الآية الأولى';

  @override
  String get fieldAyahTo => 'الآية الأخيرة';

  @override
  String get fieldStatus => 'الحالة';

  @override
  String get fieldNoteOptional => 'ملاحظة (اختياري)';

  @override
  String get groupInfoTitle => 'معلومات المجموعة';

  @override
  String get fieldLevel => 'المستوى';

  @override
  String get fieldTeacher => 'المعلّم';

  @override
  String get fieldCapacity => 'السعة';

  @override
  String groupCapacityValue(Object studentIdsCount, Object maxStudents) {
    return '$studentIdsCount/$maxStudents طالب';
  }

  @override
  String get fieldDescription => 'الوصف';

  @override
  String get fieldSchedule => 'الجدول الزمني';

  @override
  String get fieldRoom => 'القاعة';

  @override
  String get commonInactive => 'غير نشط';

  @override
  String get fieldCreatedOn => 'أُنشئ في';

  @override
  String get groupStatsTitle => 'إحصائيات المجموعة';

  @override
  String get statAttendanceRate => 'نسبة الحضور';

  @override
  String get statPaymentRate => 'نسبة الدفع';

  @override
  String get statTotalPaid => 'إجمالي المدفوع';

  @override
  String get groupNoStudents => 'لا يوجد طلاب في هذه المجموعة';

  @override
  String get groupStudentsTitle => 'طلاب المجموعة';

  @override
  String get fieldStudentName => 'اسم الطالب';

  @override
  String get fieldAmount => 'المبلغ';

  @override
  String get authEnterValidEmail => 'أدخل بريدًا إلكترونيًا صالحًا';

  @override
  String get forgotCodeSent =>
      'تم إرسال الرمز بالبريد الإلكتروني. تحقق أيضًا من مجلد الرسائل غير المرغوب فيها.';

  @override
  String get authAllFieldsRequired => 'يجب ملء جميع الحقول';

  @override
  String get authPasswordsDoNotMatch => 'كلمتا المرور غير متطابقتين';

  @override
  String get forgotPasswordReset => 'تمت إعادة تعيين كلمة المرور. سجّل الدخول.';

  @override
  String get forgotTitle => 'نسيت كلمة المرور';

  @override
  String get forgotStepCode =>
      'أدخل الرمز الذي وصلك بالبريد الإلكتروني وكلمة المرور الجديدة.';

  @override
  String get forgotStepEmail =>
      'أدخل بريدك الإلكتروني وسيُرسل إليك رمز إعادة التعيين.';

  @override
  String get authEmailHint => 'your.email@example.com';

  @override
  String get forgotSendCode => 'إرسال الرمز';

  @override
  String get forgotCodeLabel => 'الرمز المستلم بالبريد الإلكتروني';

  @override
  String get forgotCodeHint => 'الصق الرمز هنا';

  @override
  String get forgotNewPassword => 'كلمة المرور الجديدة';

  @override
  String get authPasswordHint => '6 أحرف على الأقل';

  @override
  String get forgotConfirmPassword => 'تأكيد كلمة المرور';

  @override
  String get forgotResetButton => 'إعادة تعيين كلمة المرور';

  @override
  String get forgotRestart => 'لم أستلم رمزًا، أعد المحاولة';

  @override
  String get authInvalidEmail => 'بريد إلكتروني غير صالح';

  @override
  String get loginUnknownError => 'خطأ غير معروف أثناء تسجيل الدخول';

  @override
  String get loginError => 'خطأ في تسجيل الدخول. يُرجى المحاولة مرة أخرى.';

  @override
  String get registerUnknownError => 'خطأ غير معروف أثناء إنشاء الحساب';

  @override
  String get registerError =>
      'خطأ أثناء إنشاء الحساب. يُرجى المحاولة مرة أخرى.';

  @override
  String get authLogin => 'تسجيل الدخول';

  @override
  String get loginSubtitle => 'ادخل إلى حساب مركزك';

  @override
  String get authPassword => 'كلمة المرور';

  @override
  String get loginForgotPassword => 'نسيت كلمة المرور؟';

  @override
  String get loginNoAccount => 'ليس لديك حساب بعد؟ ';

  @override
  String get authCreateAccount => 'إنشاء حساب';

  @override
  String get registerSubtitle => 'انضم إلى مركزي في ثوانٍ';

  @override
  String get fieldFullName => 'الاسم الكامل';

  @override
  String get registerNameHint => 'مثال: أحمد بن علي';

  @override
  String get registerMarkazHint => 'مثال: مركز النور';

  @override
  String get registerHaveAccount => 'لديك حساب بالفعل؟ ';

  @override
  String get splashTagline => 'أدِر مركزك\nببساطة وفعالية';

  @override
  String get commonLoading => 'جارٍ التحميل...';

  @override
  String get dayShortMon => 'الإثنين';

  @override
  String get dayShortTue => 'الثلاثاء';

  @override
  String get dayShortWed => 'الأربعاء';

  @override
  String get dayShortThu => 'الخميس';

  @override
  String get dayShortFri => 'الجمعة';

  @override
  String get dayShortSat => 'السبت';

  @override
  String get dayShortSun => 'الأحد';

  @override
  String get onboardingTitle1 => 'أدِر طلابك\nبسهولة';

  @override
  String get onboardingBody1 =>
      'أضف طلابك ومعلوماتهم الكاملة في ثوانٍ، وابحث عنهم بسهولة في أي وقت.';

  @override
  String get onboardingTitle2 => 'تابِع\nالمدفوعات';

  @override
  String get onboardingBody2 =>
      'سجّل المدفوعات وأنشئ الإيصالات تلقائيًا. لا مزيد من الارتباك في الإدارة المالية.';

  @override
  String get onboardingTitle3 => 'متابعة يومية\nللدروس';

  @override
  String get onboardingBody3 =>
      'سجّل يوميًا تقدّم الطلاب وتسميعهم. متابعة دقيقة ومنظمة لكل جلسة.';

  @override
  String get onboardingTitle4 => 'تقارير\nتلقائية';

  @override
  String get onboardingBody4 =>
      'احصل على إحصائيات أسبوعية وشهرية قابلة للتصدير بصيغة PDF، وشاركها بسهولة مع الأولياء.';

  @override
  String get onboardingSkip => 'تخطي';

  @override
  String get homeMainFeatures => 'الميزات الرئيسية';

  @override
  String get homeMainFeaturesSubtitle => 'كل ما تحتاجه لإدارة مركزك';

  @override
  String get homeWhyTitle => 'لماذا تختار مركزي؟';

  @override
  String get homeWhySubtitle => 'المزايا التي تصنع الفرق';

  @override
  String get navFeatures => 'الميزات';

  @override
  String get navAbout => 'حول التطبيق';

  @override
  String get homeBadge => 'حل لمعلّمي المراكز';

  @override
  String get homeHeroTitle => 'أدِر مركزك\nبطريقة عصرية';

  @override
  String get homeHeroBody =>
      'الطلاب والمدفوعات والحضور والتسميع — كل ذلك في تطبيق واحد بسيط وفعّال.';

  @override
  String get homeStatFree => 'مجاني';

  @override
  String get homeStatFiveMin => '5 دقائق';

  @override
  String get homeStatToStart => 'للبدء';

  @override
  String get homeStatMulti => 'متعدد';

  @override
  String get homeFeatureStudents => 'إدارة الطلاب';

  @override
  String get homeFeatureStats => 'الإحصائيات';

  @override
  String get homeFeatureReports => 'تقارير PDF';

  @override
  String get homeAdvTimeTitle => 'توفير الوقت';

  @override
  String get homeAdvTimeBody =>
      'قلّل الوقت الإداري بنسبة 80%. ركّز على ما يهم: التعليم.';

  @override
  String get homeAdvOrgTitle => 'تنظيم أفضل';

  @override
  String get homeAdvOrgBody =>
      'جميع بياناتك في مكان واحد، متاحة في أي مكان وزمان من هاتفك.';

  @override
  String get homeAdvParentsTitle => 'التواصل مع الأولياء';

  @override
  String get homeAdvParentsBody =>
      'شارك الإيصالات وتقارير PDF مع عائلات طلابك بلمسة واحدة.';

  @override
  String get homeCtaTitle => 'هل أنت مستعد لرقمنة مركزك؟';

  @override
  String get homeCtaBody => 'انضم إلى المعلّمين الذين يديرون مراكزهم بمركزي.';

  @override
  String get homeStart => 'ابدأ';

  @override
  String get homeLearnMore => 'اعرف المزيد';

  @override
  String get appTagline => 'الحل الرقمي للمراكز الإسلامية';

  @override
  String get aboutBadgeIslamic => 'إسلامي';

  @override
  String get aboutBadgeMobile => 'للهاتف أولًا';

  @override
  String get aboutBadgeAfrica => 'أفريقيا';

  @override
  String get aboutGoalTitle => 'هدفنا';

  @override
  String get aboutGoalSubtitle => 'رقمنة المراكز';

  @override
  String get aboutGoalBody1 =>
      'وُلد مركزي من ملاحظة بسيطة: لا يزال معلّمو المراكز يديرون مدارسهم بالدفاتر والملاحظات المكتوبة باليد والذاكرة.';

  @override
  String get aboutGoalBody2 =>
      'هدفنا أن نقدّم لهم أداة رقمية حديثة وبسيطة ومناسبة لاحتياجاتهم، ليتفرغوا للأهم: نقل العلم الشرعي.';

  @override
  String get aboutVisionTitle => 'رؤيتنا';

  @override
  String get aboutVisionModernTitle => 'حل عصري';

  @override
  String get aboutVisionModernBody =>
      'تطبيق مصمَّم لواقع المعلّمين الأفارقة: بسيط وسريع ويعمل حتى مع اتصال محدود.';

  @override
  String get aboutVisionEcosystemTitle => 'منظومة متصلة';

  @override
  String get aboutVisionEcosystemBody =>
      'على المدى البعيد، ربط المعلّمين والطلاب والأولياء في منظومة واحدة لتواصل ومتابعة أفضل.';

  @override
  String get aboutVisionImpactTitle => 'أثر على مستوى القارة';

  @override
  String get aboutVisionImpactBody =>
      'أن نصبح المرجع في إدارة المراكز في أفريقيا الناطقة بالفرنسية وخارجها.';

  @override
  String get aboutApproachTitle => 'نهجنا';

  @override
  String get aboutApproachUserTitle => 'يتمحور حول المستخدم';

  @override
  String get aboutApproachUserBody => 'مصمَّم مع معلّمي المراكز ومن أجلهم';

  @override
  String get aboutApproachOfflineBody => 'يعمل دون اتصال دائم بالإنترنت';

  @override
  String get aboutApproachSecureTitle => 'آمن';

  @override
  String get aboutApproachSecureBody => 'بياناتك محمية وسرية';

  @override
  String get aboutApproachLangTitle => 'متعدد اللغات';

  @override
  String get aboutApproachLangBody => 'الفرنسية والإنجليزية والعربية';

  @override
  String get aboutValuesTitle => 'قيمنا';

  @override
  String get aboutValueSimplicityTitle => 'البساطة';

  @override
  String get aboutValueSimplicityBody =>
      'أداة لا تتطلب تدريبًا، سهلة الاستخدام من اليوم الأول.';

  @override
  String get aboutValueRespectTitle => 'الاحترام';

  @override
  String get aboutValueRespectBody =>
      'يحترم القيم الإسلامية وممارسات المجتمعات.';

  @override
  String get aboutValueImpactTitle => 'الأثر';

  @override
  String get aboutValueImpactBody =>
      'كل ميزة مصمَّمة لتُحدث فرقًا حقيقيًا في يوم المعلّم.';

  @override
  String get aboutContactTitle => 'اتصل بنا';

  @override
  String get aboutContactBody => 'سؤال أو اقتراح أو شراكة؟\nنحن نستمع إليك.';

  @override
  String get aboutContactButton => 'تواصل معنا';

  @override
  String get featStudentsTitle => 'إدارة الطلاب';

  @override
  String get featStudentsBody =>
      'أنشئ ملفًا كاملًا لكل طالب: الاسم وتاريخ الميلاد ومعلومات الأولياء ومستوى القرآن وتاريخ التسجيل. ابحث وصفِّ وأدِر جميع طلابك بسهولة من صفحة واحدة.';

  @override
  String get featStudentsH1 => 'ملف فردي كامل';

  @override
  String get featStudentsH2 => 'معلومات الأولياء';

  @override
  String get featStudentsH3 => 'سجل التقدّم';

  @override
  String get featStudentsH4 => 'بحث وتصفية سريعان';

  @override
  String get featPaymentsTitle => 'المدفوعات والإيصالات';

  @override
  String get featPaymentsBody =>
      'أدِر الرسوم الشهرية لكل طالب. سجّل المدفوعات المستلمة وأنشئ إيصالات PDF احترافية تلقائيًا. راجع سجل المدفوعات واكتشف التأخيرات بسهولة.';

  @override
  String get featPaymentsH1 => 'متابعة الرسوم الشهرية';

  @override
  String get featPaymentsH2 => 'إنشاء إيصالات PDF';

  @override
  String get featPaymentsH3 => 'سجل المدفوعات';

  @override
  String get featPaymentsH4 => 'تنبيهات التأخير';

  @override
  String get featAttendanceTitle => 'الحضور والتسميع';

  @override
  String get featAttendanceBody =>
      'سجّل الحضور والغياب يوميًا في ثوانٍ. قيّم تسميع كل طالب في كل جلسة. سجل كامل لمتابعة المواظبة والتقدّم.';

  @override
  String get featAttendanceH1 => 'تسجيل يومي سريع';

  @override
  String get featAttendanceH2 => 'تقييم التسميع';

  @override
  String get featAttendanceH3 => 'سجل الحضور';

  @override
  String get featAttendanceH4 => 'ملاحظات مخصّصة';

  @override
  String get featStatsTitle => 'إحصائيات أسبوعية';

  @override
  String get featStatsBody =>
      'احصل على نظرة شاملة على فصلك كل أسبوع: نسبة المواظبة وتقدّم التسميع والمدفوعات المستلمة — كل المؤشرات المهمة معروضة بوضوح.';

  @override
  String get featStatsH1 => 'لوحة متابعة أسبوعية';

  @override
  String get featStatsH2 => 'رسوم بيانية للتقدّم';

  @override
  String get featStatsH3 => 'نسبة المواظبة';

  @override
  String get featStatsH4 => 'مقارنة الطلاب';

  @override
  String get featReportTitle => 'تقرير شهري PDF';

  @override
  String get featReportBody =>
      'أنشئ تقريرًا شهريًا كاملًا لكل طالب أو للفصل بأكمله، وشاركه مع الأولياء عبر واتساب أو البريد الإلكتروني أو أي تطبيق على هاتفك. تقرير احترافي بكل المعلومات المهمة.';

  @override
  String get featReportH1 => 'تقرير فردي للطالب';

  @override
  String get featReportH2 => 'تقرير كامل للفصل';

  @override
  String get featReportH3 => 'مشاركة عبر واتساب والبريد…';

  @override
  String get featReportH4 => 'صيغة PDF احترافية';

  @override
  String get featAbsenceTitle => 'إدارة الغياب';

  @override
  String get featAbsenceBody =>
      'تابِع نسبة غياب كل طالب حسب أيام الدراسة الفعلية في المركز، وميّز الغياب المبرَّر وشارك تقارير المواظبة مع الأولياء.';

  @override
  String get featAbsenceH1 => 'نسبة الغياب لكل طالب';

  @override
  String get featAbsenceH2 => 'أيام دراسة قابلة للضبط';

  @override
  String get featAbsenceH3 => 'تقارير مواظبة قابلة للمشاركة';

  @override
  String get featAbsenceH4 => 'تبرير الغياب';

  @override
  String get featHeaderBadge => '6 ميزات أساسية';

  @override
  String get featHeaderTitle => 'كل ما تحتاجه\nلإدارة مركزك';

  @override
  String get featHeaderBody =>
      'يجمع مركزي كل الأدوات اللازمة للإدارة اليومية لمركزك في تطبيق بسيط وسهل الاستخدام.';

  @override
  String get featCtaTitle => 'جرّب مركزي مجانًا';

  @override
  String get featCtaBody => 'أنشئ حسابك وابدأ في أقل من 5 دقائق.';

  @override
  String get featCtaButton => 'إنشاء حسابي';

  @override
  String get dashUserFallback => 'المستخدم';

  @override
  String dashWelcome(Object userName) {
    return 'مرحبًا، $userName';
  }

  @override
  String get dashGeneralStats => 'إحصائيات عامة';

  @override
  String get dashQuickActions => 'إجراءات سريعة';

  @override
  String get dashMyGroups => 'مجموعاتي';

  @override
  String get dashRecentPayments => 'المدفوعات الأخيرة';

  @override
  String get dashSeeAll => 'عرض الكل';

  @override
  String get dashNoGroupYet => 'لم تُنشأ أي مجموعة بعد';

  @override
  String dashActiveGroups(Object activeCount) {
    return '$activeCount مجموعة نشطة';
  }

  @override
  String dashSeatsOccupied(Object occupied, Object capacity) {
    return '$occupied / $capacity مقعد مشغول';
  }

  @override
  String get dashNoPaymentYet => 'لم تُسجَّل أي دفعة بعد';

  @override
  String dashStudentsCount(Object studentsCount) {
    return '$studentsCount طالب';
  }

  @override
  String get dashNoStudent => 'لا يوجد طلاب مسجلون';

  @override
  String dashPhoneShort(Object parentPhone) {
    return 'الهاتف: $parentPhone';
  }

  @override
  String get dashEditStudent => 'تعديل الطالب';

  @override
  String get dashDeleteStudent => 'إزالة الطالب';

  @override
  String dashPaymentsCount(Object validPaymentsCount) {
    return '$validPaymentsCount دفعة';
  }

  @override
  String get dashNoPayment => 'لا توجد مدفوعات مسجلة';

  @override
  String get dashNoValidPayment => 'لا توجد مدفوعات صالحة (طلاب محذوفون)';

  @override
  String dashPaymentsOfRemoved(Object paymentsCount) {
    return '$paymentsCount دفعة مرتبطة بطلاب محذوفين';
  }

  @override
  String dashAttendancesCount(Object validAttendancesCount) {
    return '$validAttendancesCount سجل حضور';
  }

  @override
  String get dashNoAttendance => 'لا يوجد حضور مسجل';

  @override
  String get dashNoValidAttendance => 'لا يوجد حضور صالح (طلاب محذوفون)';

  @override
  String dashAttendancesOfRemoved(Object attendancesCount) {
    return '$attendancesCount سجل حضور مرتبط بطلاب محذوفين';
  }

  @override
  String get attendancePresent => 'حاضر';

  @override
  String get attendanceAbsent => 'غائب';

  @override
  String get attendanceJustified => 'غياب مبرَّر';

  @override
  String get attendanceLate => 'متأخر';

  @override
  String get dashGenerateReports => 'إنشاء التقارير';

  @override
  String get dashWeeklyReport => 'التقرير الأسبوعي';

  @override
  String get dashMonthlyReport => 'التقرير الشهري';

  @override
  String get dashPaymentReport => 'تقرير المدفوعات';

  @override
  String get dashPerformanceReport => 'تقرير الأداء';

  @override
  String get dashAttendanceByStudentShort => 'نسبة الحضور لكل طالب';

  @override
  String get dashExport => 'تصدير';

  @override
  String get dashExportPdf => 'تصدير بصيغة PDF';

  @override
  String get dashAddNewStudent => 'إضافة طالب جديد';

  @override
  String get fieldParentPhone => 'هاتف ولي الأمر';

  @override
  String get dashPhoneHint => 'مثال: 622180933';

  @override
  String get commonFillAllFields => 'يُرجى ملء جميع الحقول';

  @override
  String get commonInvalidPhone => 'رقم هاتف غير صالح';

  @override
  String get dashStudentAdded => 'تمت إضافة الطالب بنجاح!';

  @override
  String commonErrorColon(Object error) {
    return 'خطأ: $error';
  }

  @override
  String get dashStudentUpdated => 'تم تعديل الطالب بنجاح!';

  @override
  String get dashArchiveStudentTitle => 'أرشفة هذا الطالب؟';

  @override
  String get dashArchiveStudentQuestion =>
      'هل أنت متأكد من إزالة هذا الطالب من القائمة؟';

  @override
  String dashNameLine(Object student) {
    return 'الاسم: $student';
  }

  @override
  String get dashArchiveStudentBody =>
      'سيُؤرشف الطالب: لن يظهر في القوائم بعد الآن، لكن سجله (المدفوعات والحضور والتسميع) محفوظ ويبقى محسوبًا في الإجماليات المالية.';

  @override
  String get dashStudentArchived => 'تمت أرشفة الطالب بنجاح';

  @override
  String get actionArchive => 'أرشفة';

  @override
  String get dashAddPayment => 'إضافة دفعة';

  @override
  String get dashNoStudentAddFirst =>
      'لا يوجد طلاب مسجلون. يُرجى إضافة طلاب أولًا.';

  @override
  String get dashRecordPayment => 'تسجيل دفعة';

  @override
  String get dashSelectStudent => 'اختر طالبًا';

  @override
  String dashAmountWithCurrency(Object currency) {
    return 'المبلغ ($currency)';
  }

  @override
  String get fieldMonth => 'الشهر';

  @override
  String get paymentPaid => 'مدفوع';

  @override
  String get paymentUnpaid => 'غير مدفوع';

  @override
  String get dashPaymentDay => 'يوم الدفع';

  @override
  String get dashInvalidAmount => 'مبلغ غير صالح';

  @override
  String dashPaymentRecorded(Object month) {
    return 'تم تسجيل دفعة شهر $month!';
  }

  @override
  String get dashPaymentAlreadyRecorded => 'الدفعة مسجلة مسبقًا';

  @override
  String get dashConfirmAnyway => 'التأكيد على أي حال';

  @override
  String get dashMarkAttendance => 'تسجيل الحضور';

  @override
  String get dashLessonField => 'الدرس/المادة';

  @override
  String get dashLessonHint => 'مثال: القرآن، الحديث';

  @override
  String get dashSelectStudentAndStatus => 'يُرجى اختيار طالب وحالة';

  @override
  String get dashNoLessonDefault => 'لا يوجد درس';

  @override
  String get dashAttendanceRecorded => 'تم تسجيل الحضور بنجاح!';

  @override
  String dashWeekRange(Object day, Object month, Object day2, Object month2) {
    return 'أسبوع $day/$month إلى $day2/$month2';
  }

  @override
  String get dashPresentPlural => 'الحاضرون';

  @override
  String get dashAbsentPlural => 'الغائبون';

  @override
  String get dashLatePlural => 'المتأخرون';

  @override
  String dashTotalSessionsWeek(Object weeklyAttendancesCount) {
    return 'إجمالي الجلسات: $weeklyAttendancesCount';
  }

  @override
  String dashMonthLine(Object month, Object year) {
    return 'الشهر: $month/$year';
  }

  @override
  String dashTotalSessionsMonth(Object monthlyAttendancesCount) {
    return 'إجمالي الجلسات: $monthlyAttendancesCount';
  }

  @override
  String dashAttendanceRateLine(Object length) {
    return 'نسبة الحضور: $length%';
  }

  @override
  String get dashAttendanceAlreadyRecorded => 'الحضور مسجل مسبقًا';

  @override
  String dashReplaceAttendanceBody(
      Object status, Object lesson, Object newStatus, Object newLesson) {
    return 'لدى هذا الطالب سجل حضور اليوم بالفعل:\n• الحالة: $status\n• الدرس: $lesson\n\nيُحتفظ بسجل حضور واحد فقط لكل طالب في اليوم. هل تريد استبداله بـ «$newStatus — $newLesson»؟';
  }

  @override
  String get actionReplace => 'استبدال';

  @override
  String get dashAttendanceReplaced => 'تم استبدال الحضور';

  @override
  String get dashTotalPending => 'إجمالي المعلّق';

  @override
  String get dashGrandTotal => 'الإجمالي العام';

  @override
  String dashPaymentsNumber(Object paymentsCount) {
    return 'عدد المدفوعات: $paymentsCount';
  }

  @override
  String dashActiveStudents(Object studentsCount) {
    return 'الطلاب النشطون: $studentsCount';
  }

  @override
  String get dashManagementMetrics => 'مؤشرات الإدارة:';

  @override
  String get statAttendanceRateFull => 'نسبة الحضور';

  @override
  String get statPaymentRateFull => 'نسبة الدفع';

  @override
  String get dashSummary => 'الملخص:';

  @override
  String dashSummaryStudents(Object totalStudents) {
    return '• إجمالي الطلاب: $totalStudents';
  }

  @override
  String dashSummarySessions(Object totalAttendance) {
    return '• الجلسات المسجلة: $totalAttendance';
  }

  @override
  String dashSummaryPayments(Object paymentsCount) {
    return '• المدفوعات المسجلة: $paymentsCount';
  }

  @override
  String dashSummaryPaid(Object paidCount) {
    return '• المدفوعات المكتملة: $paidCount';
  }

  @override
  String get commonNotAvailable => 'غير متاح';

  @override
  String get dashPaymentDetails => 'تفاصيل الدفعة';

  @override
  String get fieldStudent => 'الطالب';

  @override
  String get paymentPending => 'قيد الانتظار';

  @override
  String get dashPaymentDate => 'تاريخ الدفع';

  @override
  String get dashPaymentId => 'معرّف الدفعة';

  @override
  String get dashPaymentMarkedPaid => 'تم وضع علامة مدفوع على الدفعة';

  @override
  String get dashMarkAsPaid => 'وضع علامة مدفوع';

  @override
  String get dashReceipt => 'الإيصال';

  @override
  String get commonNotSpecified => 'غير محدد';

  @override
  String get dashAttendanceDetails => 'تفاصيل الحضور';

  @override
  String get fieldLesson => 'الدرس';

  @override
  String get fieldDate => 'التاريخ';

  @override
  String get dashAttendanceId => 'معرّف الحضور';

  @override
  String get dashEditAttendance => 'تعديل الحضور';

  @override
  String get dashAttendanceCorrected => 'تم تصحيح الحضور';

  @override
  String get dashStudentProfile => 'ملف الطالب';

  @override
  String get fieldContact => 'التواصل';

  @override
  String get dashPaidPayments => 'المدفوعات المسددة';

  @override
  String get dashStudentId => 'معرّف الطالب';

  @override
  String get dashAttendanceByStudent => 'نسبة الحضور لكل طالب';

  @override
  String dashThisWeekSessions(Object weekAttendancesCount) {
    return 'هذا الأسبوع ($weekAttendancesCount جلسة)';
  }

  @override
  String dashThisMonthSessions(Object monthAttendancesCount) {
    return 'هذا الشهر ($monthAttendancesCount جلسة)';
  }

  @override
  String dashGroupsCount(Object classesCount) {
    return '$classesCount مجموعة';
  }

  @override
  String get dashNoGroup => 'لا توجد مجموعات';

  @override
  String get dashCreateFirstGroup => 'ابدأ بإنشاء مجموعتك الأولى';

  @override
  String get dashCreateGroup => 'إنشاء مجموعة';

  @override
  String get groupFull => 'ممتلئة';

  @override
  String get groupAlmostFull => 'شبه ممتلئة';

  @override
  String get groupAvailable => 'متاحة';

  @override
  String get dashAddStudentToGroup => 'إضافة طالب';

  @override
  String get dashRemoveStudentFromGroup => 'إزالة طالب';

  @override
  String get dashEditGroup => 'تعديل المجموعة';

  @override
  String get dashDeleteGroup => 'حذف المجموعة';

  @override
  String get dashOccupancy => 'نسبة الإشغال';

  @override
  String get dashReceiptTitle => 'إيصال الدفع';

  @override
  String get dashReceiptGenerated => 'تم إنشاء الإيصال. ماذا تريد أن تفعل به؟';

  @override
  String get actionLater => 'لاحقًا';

  @override
  String get actionPreviewPrint => 'معاينة / طباعة';

  @override
  String get dashGeneratingReport => 'جارٍ إنشاء التقرير...';

  @override
  String dashGenerationError(Object error) {
    return 'خطأ أثناء الإنشاء: $error';
  }

  @override
  String get dashReportGenerated => 'تم إنشاء التقرير';

  @override
  String get dashReportWhatToDo => 'ماذا تريد أن تفعل بهذا التقرير؟';

  @override
  String get dashLogoutConfirm => 'هل أنت متأكد من تسجيل الخروج؟';

  @override
  String get actionLogout => 'تسجيل الخروج';

  @override
  String dashLogoutError(Object error) {
    return 'خطأ في تسجيل الخروج: $error';
  }

  @override
  String get dashAddGroup => 'إضافة مجموعة';

  @override
  String get fieldGroupName => 'اسم المجموعة';

  @override
  String get dashGroupNameHint => 'مثال: مجموعة نور البيان';

  @override
  String get fieldGroupLevel => 'مستوى المجموعة';

  @override
  String get dashGroupLevelHint => 'مثال: جزء عمّ، نور البيان، إلخ.';

  @override
  String get fieldGroupDescription => 'وصف المجموعة';

  @override
  String get fieldTeacherName => 'اسم المعلّم';

  @override
  String get dashTeacherHint => 'مثال: الشيخ إبراهيم';

  @override
  String get fieldMaxStudents => 'الحد الأقصى لعدد الطلاب';

  @override
  String get dashMaxStudentsHint => 'مثال: 30 (قابل للتعديل حتى 500)';

  @override
  String get dashMaxStudentsHelp => 'يمكنك زيادة هذا العدد في أي وقت.';

  @override
  String get dashGroupAdded => 'تمت إضافة المجموعة بنجاح!';

  @override
  String dashEditNamed(Object classModel) {
    return 'تعديل: $classModel';
  }

  @override
  String get dashGroupUpdated => 'تم تعديل المجموعة بنجاح!';

  @override
  String dashDeleteNamed(Object classModel) {
    return 'حذف: $classModel';
  }

  @override
  String get dashDeleteGroupConfirm =>
      'هل أنت متأكد من حذف هذه المجموعة؟ ستُؤرشف المجموعة ويُزال جميع طلابها منها.';

  @override
  String get dashGroupDeleted => 'تم حذف المجموعة بنجاح!';

  @override
  String get dashAllStudentsInGroup =>
      'جميع الطلاب موجودون بالفعل في هذه المجموعة.';

  @override
  String dashAddStudentTo(Object groupModel) {
    return 'إضافة طالب إلى $groupModel';
  }

  @override
  String get dashSelectStudentToAdd => 'اختر طالبًا لإضافته:';

  @override
  String get dashChooseStudent => 'اختر طالبًا';

  @override
  String get dashStudentAddedToGroup => 'تمت إضافة الطالب إلى المجموعة بنجاح!';

  @override
  String get dashGroupEmpty => 'لا تحتوي هذه المجموعة على أي طالب.';

  @override
  String dashRemoveStudentFrom(Object groupModel) {
    return 'إزالة طالب من $groupModel';
  }

  @override
  String get dashSelectStudentToRemove => 'اختر طالبًا لإزالته:';

  @override
  String get dashStudentRemovedFromGroup =>
      'تمت إزالة الطالب من المجموعة بنجاح!';

  @override
  String get actionRemove => 'إزالة';

  @override
  String get dashGenerateReport => 'إنشاء تقرير';

  @override
  String get dashChooseReportPeriod => 'اختر فترة التقرير:';

  @override
  String get dashWeekly => 'أسبوعي';

  @override
  String get dashMonthly => 'شهري';

  @override
  String get forgotResetting => 'جارٍ إعادة التعيين...';

  @override
  String get forgotSending => 'جارٍ الإرسال...';

  @override
  String get commonActive => 'نشط';

  @override
  String get errClassNotFound => 'المجموعة غير موجودة';

  @override
  String get errStudentNotFound => 'الطالب غير موجود';

  @override
  String get errMarkazAccessDenied => 'تم رفض الوصول إلى هذا المركز';

  @override
  String get errLessonRequired => 'اسم الدرس مطلوب';

  @override
  String get errAttendanceNotFound => 'سجل الحضور غير موجود';

  @override
  String get errStudentAccessDenied => 'تم رفض الوصول إلى هذا الطالب';

  @override
  String get errNotAuthenticated => 'المستخدم غير مسجّل الدخول';

  @override
  String get errEmailPasswordRequired =>
      'البريد الإلكتروني وكلمة المرور مطلوبان';

  @override
  String get errRequiredFieldsMissing => 'يجب ملء جميع الحقول المطلوبة';

  @override
  String get errPasswordTooShort => 'كلمة المرور قصيرة جدًا (6 أحرف أو أكثر)';

  @override
  String get errEmailRequired => 'البريد الإلكتروني مطلوب';

  @override
  String get errAllFieldsRequired => 'جميع الحقول مطلوبة';

  @override
  String get errGroupNameRequired => 'اسم المجموعة مطلوب';

  @override
  String get errGroupLevelRequired => 'مستوى المجموعة مطلوب';

  @override
  String get errTeacherNameRequired => 'اسم المعلّم مطلوب';

  @override
  String get errMaxStudentsRange =>
      'يجب أن يكون الحد الأقصى لعدد الطلاب بين 1 و500';

  @override
  String get errGroupNameExists => 'توجد مجموعة بهذا الاسم بالفعل';

  @override
  String get errGroupNotFound => 'المجموعة غير موجودة';

  @override
  String get errGroupAccessDenied => 'تم رفض الوصول إلى هذه المجموعة';

  @override
  String errCapacityBelowCount(Object currentStudentCount) {
    return 'لا يمكن تقليل عدد المقاعد إلى أقل من عدد الطلاب الحالي ($currentStudentCount)';
  }

  @override
  String get errGroupNotEmpty => 'لا يمكن حذف مجموعة تحتوي على طلاب';

  @override
  String errGroupFull(Object maxStudents) {
    return 'المجموعة ممتلئة بالفعل ($maxStudents طالب)';
  }

  @override
  String get errStudentAlreadyInGroup => 'الطالب موجود بالفعل في هذه المجموعة';

  @override
  String get errStudentNotInGroup => 'الطالب ليس في هذه المجموعة';

  @override
  String get errGuardianNameRequired => 'اسم ولي الأمر مطلوب';

  @override
  String get errGuardianPhoneRequired => 'هاتف ولي الأمر مطلوب';

  @override
  String get errGuardianNotFound => 'ولي الأمر غير موجود';

  @override
  String get errGuardianAccessDenied => 'تم رفض الوصول إلى ولي الأمر هذا';

  @override
  String get errAmountPositive => 'يجب أن يكون المبلغ أكبر من 0';

  @override
  String get errPaymentNotFound => 'الدفعة غير موجودة';

  @override
  String get errRecitationNotFound => 'التسميع غير موجود';

  @override
  String get errRecitationAccessDenied => 'تم رفض الوصول إلى هذا التسميع';

  @override
  String get errStudentNameRequired => 'اسم الطالب مطلوب';

  @override
  String get errNameMinLength => 'يجب أن يحتوي الاسم على 3 أحرف على الأقل';

  @override
  String get errMarkazRequired => 'لا يوجد مركز: لم يسجّل أي مستخدم الدخول';

  @override
  String get errNameInvalid => 'اسم غير صالح (3 أحرف أو أكثر)';

  @override
  String get errServerTimeout => 'الخادم لا يستجيب. تحقق من اتصالك.';

  @override
  String get errServerUnreachable =>
      'تعذّر الوصول إلى الخادم. تحقق من اتصالك بالإنترنت.';

  @override
  String get errServerCommunication => 'خطأ في الاتصال بالخادم.';

  @override
  String get activityActionPaymentRecorded => 'تم تسجيل دفعة';

  @override
  String get activityActionPaymentStatusUpdated => 'تم تحديث حالة الدفعة';

  @override
  String get activityActionAttendanceRecorded => 'تم تسجيل الحضور';

  @override
  String get activityActionAttendanceUpdated => 'تم تصحيح الحضور';

  @override
  String get activityActionAttendanceDeleted => 'تم حذف الحضور';

  @override
  String get activityActionClassCreated => 'تم إنشاء مجموعة';

  @override
  String get activityActionClassUpdated => 'تم تعديل مجموعة';

  @override
  String get activityActionClassDeleted => 'تمت أرشفة مجموعة';

  @override
  String get activityActionGuardianCreated => 'تمت إضافة ولي أمر';

  @override
  String get activityActionGuardianUpdated => 'تم تعديل ولي أمر';

  @override
  String get activityActionGuardianDeleted => 'تم حذف ولي أمر';

  @override
  String get activityActionStudentCreated => 'تمت إضافة طالب';

  @override
  String get activityActionStudentUpdated => 'تم تعديل طالب';

  @override
  String get activityActionStudentArchived => 'تمت أرشفة طالب';

  @override
  String get activityActionUserRegistered => 'التسجيل وإنشاء المركز';

  @override
  String get activityActionUserLoggedIn => 'تسجيل الدخول';

  @override
  String get activityActionRecitationRecorded => 'تم تسجيل تسميع';

  @override
  String get activityActionRecitationUpdated => 'تم تصحيح تسميع';

  @override
  String get activityActionRecitationDeleted => 'تم حذف تسميع';

  @override
  String get activityActionMarkazUpdated => 'تم تحديث بيانات المركز';

  @override
  String get activityActionSyncConflict => 'تعارض في المزامنة';

  @override
  String get groupReport => 'تقرير المجموعة';

  @override
  String get groupReportChoose => 'تقرير المجموعة بأكملها: اختر الفترة.';

  @override
  String get groupReportWeekly => 'هذا الأسبوع';

  @override
  String get groupReportMonthly => 'هذا الشهر';

  @override
  String get fieldPaymentMode => 'طريقة الدفع';

  @override
  String get paymentModeCash => 'نقدًا';

  @override
  String get paymentModeOther => 'أخرى (الدفع عبر الهاتف، تحويل…)';

  @override
  String get fieldObservationOptional => 'ملاحظة (اختياري)';

  @override
  String get fieldObservation => 'ملاحظة';

  @override
  String get groupScheduleHint => 'مثال: الإثنين، الأربعاء، الجمعة — 4-6 مساءً';

  @override
  String get studentSearchHint => 'بحث (الاسم أو الهاتف)';

  @override
  String get studentFilterAllGroups => 'كل المجموعات';

  @override
  String get studentFilterNoGroup => 'بدون مجموعة';

  @override
  String get studentSearchNoResult => 'لا يوجد طالب يطابق البحث.';
}
