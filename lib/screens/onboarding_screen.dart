import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../l10n/app_localizations.dart';

/// Écran d'onboarding avec 4 pages swipables
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  /// Textes traduits (doc/audit.md K8).
  AppLocalizations get _l10n => AppLocalizations.of(context);

  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Données visuelles de chaque page
  // Getter (et non champ initialisé) : les textes traduits dépendent du
  // contexte (doc/audit.md K8).
  List<_OnboardingData> get _pages => [
    _OnboardingData(
      title: _l10n.onboardingTitle1,
      description:
          _l10n.onboardingBody1,
      icon: Icons.people_alt_rounded,
      gradientColors: [Color(0xFF1A7F55), Color(0xFF2EAA73)],
      illustrationIcon: Icons.school_rounded,
    ),
    _OnboardingData(
      title: _l10n.onboardingTitle2,
      description:
          _l10n.onboardingBody2,
      icon: Icons.payments_rounded,
      gradientColors: [Color(0xFF1565C0), Color(0xFF1976D2)],
      illustrationIcon: Icons.receipt_long_rounded,
    ),
    _OnboardingData(
      title: _l10n.onboardingTitle3,
      description:
          _l10n.onboardingBody3,
      icon: Icons.menu_book_rounded,
      gradientColors: [Color(0xFF7B1FA2), Color(0xFF9C27B0)],
      illustrationIcon: Icons.auto_stories_rounded,
    ),
    _OnboardingData(
      title: _l10n.onboardingTitle4,
      description:
          _l10n.onboardingBody4,
      icon: Icons.bar_chart_rounded,
      gradientColors: [Color(0xFFE65100), Color(0xFFF57C00)],
      illustrationIcon: Icons.analytics_rounded,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _goToHome();
    }
  }

  void _goToHome() {
    Navigator.pushReplacementNamed(context, '/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Pages
          PageView.builder(
            controller: _pageController,
            itemCount: _pages.length,
            onPageChanged: (index) => setState(() => _currentPage = index),
            itemBuilder: (context, index) {
              return _buildPage(_pages[index]);
            },
          ),

          // Bouton "Passer" en haut à droite
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            right: 20,
            child: TextButton(
              onPressed: _goToHome,
              child: Text(
                _l10n.onboardingSkip,
                style: GoogleFonts.cairo(
                  color: Colors.white.withValues(alpha: 0.85),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          // Bas de l'écran : indicateur + bouton
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.only(
                left: 32,
                right: 32,
                bottom: MediaQuery.of(context).padding.bottom + 32,
                top: 24,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.15),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Indicateur de pages
                  SmoothPageIndicator(
                    controller: _pageController,
                    count: _pages.length,
                    effect: const ExpandingDotsEffect(
                      dotHeight: 8,
                      dotWidth: 8,
                      expansionFactor: 3,
                      dotColor: Colors.white38,
                      activeDotColor: Colors.white,
                    ),
                  ),

                  // Bouton suivant / commencer
                  GestureDetector(
                    onTap: _nextPage,
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        _currentPage == _pages.length - 1
                            ? Icons.check_rounded
                            : Icons.arrow_forward_rounded,
                        color: _pages[_currentPage].gradientColors[0],
                        size: 26,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage(_OnboardingData data) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            data.gradientColors[0],
            data.gradientColors[1],
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 80),

            // Illustration centrale
            Expanded(
              flex: 5,
              child: Center(
                child: _buildIllustration(data),
              ),
            ),

            // Texte en bas
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.title,
                      style: GoogleFonts.cairo(
                        fontSize: 30,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      data.description,
                      style: GoogleFonts.cairo(
                        fontSize: 15,
                        color: Colors.white.withValues(alpha: 0.85),
                        height: 1.7,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 120),
          ],
        ),
      ),
    );
  }

  Widget _buildIllustration(_OnboardingData data) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Cercle de fond
        Container(
          width: 220,
          height: 220,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: 0.1),
          ),
        ),
        Container(
          width: 170,
          height: 170,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: 0.12),
          ),
        ),
        // Icône principale
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 30,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Icon(
            data.illustrationIcon,
            size: 60,
            color: data.gradientColors[0],
          ),
        ),

        // Petits éléments décoratifs flottants
        Positioned(
          top: 20,
          right: 30,
          child: _floatingBadge(Icons.check_circle_rounded, Colors.white),
        ),
        Positioned(
          bottom: 30,
          left: 20,
          child: _floatingBadge(Icons.star_rounded, Colors.white),
        ),
      ],
    );
  }

  Widget _floatingBadge(IconData icon, Color color) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: 0.2),
      ),
      child: Icon(icon, color: color.withValues(alpha: 0.7), size: 18),
    );
  }
}

class _OnboardingData {
  final String title;
  final String description;
  final IconData icon;
  final List<Color> gradientColors;
  final IconData illustrationIcon;

  const _OnboardingData({
    required this.title,
    required this.description,
    required this.icon,
    required this.gradientColors,
    required this.illustrationIcon,
  });
}
