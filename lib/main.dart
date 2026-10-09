import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'l10n/app_localizations.dart';
import 'models/index.dart';
import 'repositories/index.dart';
import 'providers/index.dart';
import 'services/index.dart';
import 'screens/splash_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/login_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/home_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/features_screen.dart';
import 'screens/about_screen.dart';
import 'screens/markaz_settings_screen.dart';
import 'screens/guardian_screen.dart';
import 'screens/recitation_screen.dart';
import 'screens/activity_log_screen.dart';
import 'utils/app_colors.dart';
import 'datasources/hive_student_datasource.dart';
import 'datasources/hive_payment_datasource.dart';
import 'datasources/hive_attendance_datasource.dart';
import 'datasources/hive_class_datasource.dart';
import 'datasources/hive_guardian_datasource.dart';
import 'datasources/hive_recitation_datasource.dart';
import 'datasources/api_student_datasource.dart';
import 'datasources/api_payment_datasource.dart';
import 'datasources/api_attendance_datasource.dart';
import 'datasources/api_class_datasource.dart';
import 'datasources/api_guardian_datasource.dart';
import 'datasources/api_recitation_datasource.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  await Hive.initFlutter();

  // Enregistrer les adaptateurs Hive
  Hive.registerAdapter(StudentAdapter());
  Hive.registerAdapter(PaymentAdapter());
  // PaymentStatusAdapter oubliée : chaque écriture d'un Payment en cache
  // local (donc chaque enregistrement de paiement) plantait avec
  // "HiveError: Cannot write, unknown type: PaymentStatus" — le paiement
  // était bien créé côté serveur, mais l'app affichait une erreur comme si
  // l'enregistrement avait échoué.
  Hive.registerAdapter(PaymentStatusAdapter());
  Hive.registerAdapter(AttendanceAdapter());
  // Même oubli pour AttendanceStatus — mêmes symptômes potentiels pour le
  // pointage de présence.
  Hive.registerAdapter(AttendanceStatusAdapter());
  Hive.registerAdapter(ClassModelAdapter());
  Hive.registerAdapter(GuardianAdapter());
  Hive.registerAdapter(RecitationAdapter());
  Hive.registerAdapter(RecitationStatusAdapter());
  Hive.registerAdapter(SyncQueueItemAdapter());
  Hive.registerAdapter(SyncOperationAdapter());
  Hive.registerAdapter(SyncEntityTypeAdapter());

  // File d'attente hors ligne (CDC section 20) — initialisée avant les
  // repositories, qui en ont besoin pour mettre en file les échecs de sync.
  final syncQueueService = SyncQueueService();
  await syncQueueService.init();

  // Créer les data sources
  final hiveStudentDataSource = HiveStudentDataSource();
  final apiStudentDataSource = ApiStudentDatasource();
  final hivePaymentDataSource = HivePaymentDataSource();
  final apiPaymentDataSource = ApiPaymentDatasource();
  final hiveAttendanceDataSource = HiveAttendanceDataSource();
  final apiAttendanceDataSource = ApiAttendanceDatasource();
  final hiveClassDataSource = HiveClassDataSource();
  final apiClassDataSource = ApiClassDatasource();
  final hiveGuardianDataSource = HiveGuardianDataSource();
  final apiGuardianDataSource = ApiGuardianDatasource();
  final hiveRecitationDataSource = HiveRecitationDataSource();
  final apiRecitationDataSource = ApiRecitationDatasource();

  // Créer les repositories avec injection de dépendances
  final studentRepository = StudentRepository(
      hiveStudentDataSource, apiStudentDataSource);
  final paymentRepository = PaymentRepository(
      hivePaymentDataSource, apiPaymentDataSource, syncQueueService);
  final attendanceRepository = AttendanceRepository(
      hiveAttendanceDataSource, apiAttendanceDataSource, syncQueueService);
  final classRepository = ClassRepository(
      hiveClassDataSource, apiClassDataSource);
  final guardianRepository = GuardianRepository(
      hiveGuardianDataSource, apiGuardianDataSource, syncQueueService);
  final recitationRepository = RecitationRepository(
      hiveRecitationDataSource, apiRecitationDataSource, syncQueueService);

  // Initialiser les repositories
  await studentRepository.init();
  await paymentRepository.init();
  await attendanceRepository.init();
  await classRepository.init();
  await guardianRepository.init();
  await recitationRepository.init();

  // Initialiser AuthService
  final authService = AuthService();
  final markazService = MarkazService();

  // Initialiser les services (couche métier)
  final studentService = StudentService(studentRepository, authService);
  final classService = ClassService(classRepository, authService, studentService);
  final paymentService = PaymentService(paymentRepository, studentRepository, authService);
  final attendanceService = AttendanceService(
    attendanceRepository,
    studentRepository,
    authService,
  );
  final guardianService = GuardianService(guardianRepository, authService);
  final recitationService = RecitationService(recitationRepository, authService);
  final syncOrchestrator = SyncOrchestrator(
    queue: syncQueueService,
    paymentRepository: paymentRepository,
    attendanceRepository: attendanceRepository,
    guardianRepository: guardianRepository,
    recitationRepository: recitationRepository,
  );

  // Mode clair/sombre (doc/audit.md K7) — chargé avant runApp() pour éviter
  // un flash de thème incorrect au premier affichage.
  final themeProvider = ThemeProvider();
  await themeProvider.load();
  themeProvider.syncWithPlatformBrightness(
    WidgetsBinding.instance.platformDispatcher.platformBrightness,
  );

  // Langue de l'app (doc/audit.md K8) — même logique de chargement anticipé.
  final localeProvider = LocaleProvider();
  await localeProvider.load();

  // Restaure la session (token stocké) si l'utilisateur était déjà connecté
  await authService.initializeUser();

  // Recharge le cache local depuis l'API pour la Markaz de l'utilisateur restauré
  final markazProvider = MarkazProvider(markazService);
  final markazId = authService.currentMarkazId;
  if (markazId != null) {
    await Future.wait([
      studentRepository.syncFromMarkaz(markazId),
      classRepository.syncFromMarkaz(markazId),
      attendanceRepository.syncFromMarkaz(markazId),
      paymentRepository.syncFromMarkaz(markazId),
      guardianRepository.syncFromMarkaz(markazId),
      recitationRepository.syncFromMarkaz(markazId),
      markazProvider.load(),
    ]);
    // Rejoue les actions hors ligne laissées en attente lors d'une session
    // précédente (CDC section 20) avant que l'utilisateur ne commence à
    // interagir avec l'app.
    await syncOrchestrator.replayPending();
  }

  runApp(
    MultiProvider(
      providers: [
        // Service providers
        Provider<AuthService>(create: (_) => authService),
        Provider<StudentService>(create: (_) => studentService),
        Provider<PaymentService>(create: (_) => paymentService),
        Provider<AttendanceService>(create: (_) => attendanceService),
        Provider<ClassService>(create: (_) => classService),
        Provider<MarkazService>(create: (_) => markazService),
        Provider<GuardianService>(create: (_) => guardianService),
        Provider<RecitationService>(create: (_) => recitationService),

        // UI Providers
        ChangeNotifierProvider(
          create: (_) => StudentProvider(studentService),
        ),
        ChangeNotifierProvider(
          create: (_) => PaymentProvider(paymentService),
        ),
        ChangeNotifierProvider(
          create: (_) => AttendanceProvider(attendanceService),
        ),
        ChangeNotifierProvider(
          create: (_) => ClassProvider(classService),
        ),
        ChangeNotifierProvider.value(value: markazProvider),
        ChangeNotifierProvider.value(value: themeProvider),
        ChangeNotifierProvider.value(value: localeProvider),
        ChangeNotifierProvider(
          create: (_) => GuardianProvider(guardianService),
        ),
        ChangeNotifierProvider(
          create: (_) => RecitationProvider(recitationService),
        ),
        ChangeNotifierProvider(
          create: (_) => SyncQueueProvider(syncOrchestrator),
        ),
      ],
      child: const MarkaziApp(),
    ),
  );
}

class MarkaziApp extends StatelessWidget {
  const MarkaziApp({super.key});

  @override
  Widget build(BuildContext context) {
    // `Consumer` (pas juste un `context.watch` interne) : c'est ce qui fait
    // que basculer le thème (ThemeProvider.setThemeMode) ou la langue
    // (LocaleProvider.setLocale) reconstruit MaterialApp avec les bonnes
    // valeurs, propageant nativement le changement à tout ce qui lit
    // `Theme.of(context)`/`Localizations.of(context)` — voir doc/audit.md
    // K7/K8 pour l'explication complète de l'approche retenue.
    return Consumer2<ThemeProvider, LocaleProvider>(
      builder: (context, themeProvider, localeProvider, _) {
        return MaterialApp(
          title: 'Markazi',
          debugShowCheckedModeBanner: false,
          theme: _buildTheme(isDark: false),
          darkTheme: _buildTheme(isDark: true),
          themeMode: themeProvider.themeMode,
          locale: localeProvider.locale,
          supportedLocales: LocaleProvider.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          initialRoute: '/splash',
          routes: {
            '/splash': (context) => const SplashScreen(),
            '/onboarding': (context) => const OnboardingScreen(),
            '/login': (context) => LoginScreen(isLogin: true),
            '/forgot-password': (context) => const ForgotPasswordScreen(),
            '/home': (context) => const HomeScreen(),
            '/dashboard': (context) => DashboardScreen(),
            '/features': (context) => const FeaturesScreen(),
            '/about': (context) => const AboutScreen(),
            '/markaz-settings': (context) => const MarkazSettingsScreen(),
            '/guardians': (context) => const GuardianScreen(),
            '/recitations': (context) => const RecitationScreen(),
            '/activity-log': (context) => const ActivityLogScreen(),
          },
        );
      },
    );
  }

  /// Construit le thème clair (`isDark: false`) ou sombre (`isDark: true`).
  /// Les deux thèmes sont construits à l'avance (MaterialApp bascule entre
  /// les deux via `themeMode`), donc les couleurs sont ici des valeurs
  /// explicites et non les getters ambiants `AppColors.xxx` (qui ne
  /// reflètent que le mode *actuellement* actif — voir `AppColors` et
  /// `ThemeProvider`).
  ThemeData _buildTheme({required bool isDark}) {
    final background = isDark ? const Color(0xFF10201A) : const Color(0xFFF5F7F5);
    final surface = isDark ? const Color(0xFF17291F) : const Color(0xFFFFFFFF);
    final textDark = isDark ? const Color(0xFFECF3EE) : const Color(0xFF1A2E1F);
    final brightness = isDark ? Brightness.dark : Brightness.light;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: brightness,
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: surface,
      ),
      textTheme: GoogleFonts.cairoTextTheme(ThemeData(brightness: brightness).textTheme),
      scaffoldBackgroundColor: background,
      appBarTheme: AppBarTheme(
        backgroundColor: surface,
        elevation: 0,
        iconTheme: IconThemeData(color: textDark),
        titleTextStyle: GoogleFonts.cairo(
          color: textDark,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
        // Icônes de la barre système (heure/batterie) claires sur fond
        // sombre, sombres sur fond clair — sinon invisibles en mode sombre
        // (SystemChrome.setSystemUIOverlayStyle dans main() ne fixe la
        // valeur qu'une fois au démarrage, sans tenir compte du thème).
        systemOverlayStyle: isDark
            ? SystemUiOverlayStyle.light.copyWith(statusBarColor: Colors.transparent)
            : SystemUiOverlayStyle.dark.copyWith(statusBarColor: Colors.transparent),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: GoogleFonts.cairo(
              fontSize: 15, fontWeight: FontWeight.w700),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: GoogleFonts.cairo(
              fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: AppColors.primary.withValues(alpha: 0.08)),
        ),
      ),
    );
  }
}