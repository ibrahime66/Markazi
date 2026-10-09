import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../utils/app_colors.dart';
import '../services/auth_service.dart';
import '../l10n/app_localizations.dart';

/// Splash screen avec animation d'entrée
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _sloganController;

  late Animation<double> _logoScale;
  late Animation<double> _logoFade;
  late Animation<double> _textFade;
  late Animation<Offset> _textSlide;
  late Animation<double> _sloganFade;

  @override
  void initState() {
    super.initState();

    // Contrôleur pour le logo
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Contrôleur pour le texte
    _textController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    // Contrôleur pour le slogan
    _sloganController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    // Animations logo
    _logoScale = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );
    _logoFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeIn),
    );

    // Animations texte
    _textFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeIn),
    );
    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _textController, curve: Curves.easeOut));

    // Animation slogan
    _sloganFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _sloganController, curve: Curves.easeIn),
    );

    // Séquence d'animations
    _startAnimations();
  }

  Future<void> _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _logoController.forward();

    await Future.delayed(const Duration(milliseconds: 600));
    _textController.forward();

    await Future.delayed(const Duration(milliseconds: 400));
    _sloganController.forward();

    // Naviguer vers la bonne page après 3 secondes
    await Future.delayed(const Duration(milliseconds: 1500));

    if (mounted) {
      // Vérifier si l'utilisateur est authentifié
      final authService = context.read<AuthService>();

      if (authService.isAuthenticated) {
        // Utilisateur connecté → aller au dashboard. On vide toute la pile
        // (pas juste un pushReplacement) pour qu'un retour arrière depuis le
        // dashboard ne puisse jamais retomber sur l'onboarding/accueil/login.
        Navigator.pushNamedAndRemoveUntil(context, '/dashboard', (route) => false);
      } else {
        // Utilisateur non connecté → aller à onboarding/login
        Navigator.pushReplacementNamed(context, '/onboarding');
      }
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _sloganController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0D5C3C), Color(0xFF1A7F55), Color(0xFF2EAA73)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Motif décoratif en fond
              Positioned(
                top: -60,
                right: -60,
                child: _buildDecoCircle(200, Colors.white.withValues(alpha: 0.05)),
              ),
              Positioned(
                bottom: -100,
                left: -80,
                child: _buildDecoCircle(280, Colors.white.withValues(alpha: 0.05)),
              ),
              Positioned(
                top: 120,
                left: -40,
                child: _buildDecoCircle(120, Colors.white.withValues(alpha: 0.04)),
              ),

              // Contenu centré
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo animé
                    AnimatedBuilder(
                      animation: _logoController,
                      builder: (context, child) {
                        return FadeTransition(
                          opacity: _logoFade,
                          child: ScaleTransition(
                            scale: _logoScale,
                            child: _buildLogo(),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 24),

                    // Nom de l'app
                    SlideTransition(
                      position: _textSlide,
                      child: FadeTransition(
                        opacity: _textFade,
                        child: Text(
                          'Markazi',
                          style: GoogleFonts.cairo(
                            fontSize: 40,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Slogan
                    FadeTransition(
                      opacity: _sloganFade,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 48),
                        child: Text(
                          AppLocalizations.of(context).splashTagline,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.cairo(
                            fontSize: 16,
                            color: Colors.white.withValues(alpha: 0.85),
                            height: 1.6,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Indicateur de chargement en bas
              Positioned(
                bottom: 48,
                left: 0,
                right: 0,
                child: FadeTransition(
                  opacity: _sloganFade,
                  child: Column(
                    children: [
                      SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white.withValues(alpha: 0.6),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        AppLocalizations.of(context).commonLoading,
                        style: GoogleFonts.cairo(
                          color: Colors.white.withValues(alpha: 0.5),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 30,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Center(
        child: Image.asset(
          'assets/images/markazi_logo.png',
          width: 100,
          height: 100,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            // Fallback si l'image n'existe pas
            return Text(
              'م',
              style: GoogleFonts.amiri(
                fontSize: 52,
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildDecoCircle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: color, width: 1),
        color: color,
      ),
    );
  }
}
