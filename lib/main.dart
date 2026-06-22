import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'services/firebase_helper.dart';
import 'models/index.dart';
import 'repositories/index.dart';
import 'providers/index.dart';
import 'services/index.dart';
import 'screens/splash_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/home_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/login_screen.dart';
import 'screens/features_screen.dart';
import 'screens/about_screen.dart';
import 'utils/app_colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  // Initialiser Firebase (graceful degradation si non disponible/configuré)
  await FirebaseHelper.init();

  // Initialiser Hive
  await Hive.initFlutter();

  // Enregistrer les adapters Hive
  Hive.registerAdapter(StudentAdapter());
  Hive.registerAdapter(PaymentAdapter());
  Hive.registerAdapter(AttendanceAdapter());
  Hive.registerAdapter(PaymentStatusAdapter());
  Hive.registerAdapter(AttendanceStatusAdapter());
  Hive.registerAdapter(ClassModelAdapter());

  // Initialiser les repositories
  final studentRepository = StudentRepository();
  final paymentRepository = PaymentRepository();
  final attendanceRepository = AttendanceRepository();
  final classRepository = ClassRepository();

  await studentRepository.init();
  await paymentRepository.init();
  await attendanceRepository.init();
  await classRepository.init();

  // Initialiser AuthService
  final authService = AuthService();

  // Initialiser les services (couche métier)
  final studentService = StudentService(studentRepository, authService);
  final classService = ClassService(classRepository, authService, studentService);
  final paymentService =
      PaymentService(paymentRepository, studentRepository, authService);
  final attendanceService = AttendanceService(
    attendanceRepository,
    studentRepository,
    authService,
  );

  // Initialiser la session utilisateur (Firebase)
  // Phase 5: Authentification réelle
  await authService.initializeUser();

  runApp(
    MultiProvider(
      providers: [
        // Service providers
        Provider<AuthService>(create: (_) => authService),
        Provider<StudentService>(create: (_) => studentService),
        Provider<PaymentService>(create: (_) => paymentService),
        Provider<AttendanceService>(create: (_) => attendanceService),
        Provider<ClassService>(create: (_) => classService),

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
      ],
      child: const MarkaziApp(),
    ),
  );
}

class MarkaziApp extends StatelessWidget {
  const MarkaziApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Markazi',
      debugShowCheckedModeBanner: false,
      theme: _buildTheme(),
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/onboarding': (context) => const OnboardingScreen(),
        '/login': (context) => const LoginScreen(isLogin: true),
        '/home': (context) => const HomeScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        '/features': (context) => const FeaturesScreen(),
        '/about': (context) => const AboutScreen(),
      },
    );
  }

  ThemeData _buildTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.surface,
        background: AppColors.background,
      ),
      textTheme: GoogleFonts.cairoTextTheme(),
      scaffoldBackgroundColor: AppColors.background,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textDark),
        titleTextStyle: GoogleFonts.cairo(
          color: AppColors.textDark,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle:
              GoogleFonts.cairo(fontSize: 15, fontWeight: FontWeight.w700),
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
          textStyle:
              GoogleFonts.cairo(fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: AppColors.primary.withValues(alpha: 0.08)),
        ),
      ),
    );
  }
}
