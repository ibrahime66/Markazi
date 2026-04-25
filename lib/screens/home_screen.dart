import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_colors.dart';
import '../widgets/common_widgets.dart';
import 'login_screen.dart';

/// Page d'accueil / Landing screen de l'application Markazi
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeIn;
  late Animation<Offset> _slideUp;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );

    _fadeIn = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );
    _slideUp = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));

    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // Header hero
          SliverToBoxAdapter(child: _buildHeroSection()),

          // Section fonctionnalités
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20, 32, 20, 0),
              child: SectionTitle(
                title: 'Fonctionnalités principales',
                subtitle:
                    'Tout ce dont vous avez besoin pour gérer votre markaz',
              ),
            ),
          ),
          SliverToBoxAdapter(child: _buildFeaturesGrid()),

          // Section avantages
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20, 32, 20, 0),
              child: SectionTitle(
                title: 'Pourquoi choisir Markazi ?',
                subtitle: 'Les avantages qui font la différence',
              ),
            ),
          ),
          SliverToBoxAdapter(child: _buildAdvantages()),

          // CTA final
          SliverToBoxAdapter(child: _buildCTASection()),

          // Footer
          SliverToBoxAdapter(child: _buildFooter()),

          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }

  // ─── HERO SECTION ──────────────────────────────────────────────────
  Widget _buildHeroSection() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0D5C3C), Color(0xFF1A7F55), Color(0xFF2EAA73)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            // Éléments décoratifs
            Positioned(
              top: -30,
              right: -30,
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.05),
                ),
              ),
            ),
            Positioned(
              top: 60,
              right: 40,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.06),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
              child: FadeTransition(
                opacity: _fadeIn,
                child: SlideTransition(
                  position: _slideUp,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // AppBar personnalisée
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const MarkaziLogo(size: 44, lightMode: true),
                          Row(
                            children: [
                              _navButton('Fonctionnalités', '/features'),
                              const SizedBox(width: 8),
                              _navButton('À propos', '/about'),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 44),

                      // Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Color(0xFF7FFFD4),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Solution pour maîtres de markaz',
                              style: GoogleFonts.cairo(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Titre principal
                      Text(
                        'Gérez votre markaz\nde façon moderne',
                        style: GoogleFonts.cairo(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          height: 1.2,
                        ),
                      ),

                      const SizedBox(height: 14),

                      Text(
                        'Élèves, paiements, présences, récitation — tout centralisé dans une seule application simple et efficace.',
                        style: GoogleFonts.cairo(
                          fontSize: 15,
                          color: Colors.white.withOpacity(0.85),
                          height: 1.6,
                          fontWeight: FontWeight.w400,
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Boutons CTA
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => _goToLogin(isLogin: true),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: AppColors.primary,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                                elevation: 0,
                              ),
                              child: Text(
                                'Se connecter',
                                style: GoogleFonts.cairo(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => _goToLogin(isLogin: false),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.white,
                                side: const BorderSide(
                                    color: Colors.white70, width: 1.5),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                              ),
                              child: Text(
                                'Créer un compte',
                                style: GoogleFonts.cairo(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 36),

                      // Stats bar
                      _buildStatsRow(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _navButton(String label, String route) {
    return TextButton(
      onPressed: () => Navigator.pushNamed(context, route),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      ),
      child: Text(
        label,
        style: GoogleFonts.cairo(
          color: Colors.white.withOpacity(0.85),
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildStatsRow() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.15)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _statItem('100%', 'Gratuit'),
          _statDivider(),
          _statItem('5 min', 'Pour démarrer'),
          _statDivider(),
          _statItem('Multi', 'Markaz'),
        ],
      ),
    );
  }

  Widget _statItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.cairo(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.cairo(
            color: Colors.white.withOpacity(0.7),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _statDivider() {
    return Container(
      width: 1,
      height: 36,
      color: Colors.white.withOpacity(0.2),
    );
  }

  // ─── FONCTIONNALITÉS GRID ──────────────────────────────────────────
  Widget _buildFeaturesGrid() {
    final features = [
      _FeatureItem(
        icon: Icons.people_alt_rounded,
        title: 'Gestion élèves',
        cardColor: AppColors.cardGreen,
        iconColor: AppColors.iconGreen,
      ),
      _FeatureItem(
        icon: Icons.receipt_long_rounded,
        title: 'Paiements',
        cardColor: AppColors.cardBlue,
        iconColor: AppColors.iconBlue,
      ),
      _FeatureItem(
        icon: Icons.fact_check_rounded,
        title: 'Présences',
        cardColor: AppColors.cardPurple,
        iconColor: AppColors.iconPurple,
      ),
      _FeatureItem(
        icon: Icons.auto_stories_rounded,
        title: 'Récitation',
        cardColor: AppColors.cardOrange,
        iconColor: AppColors.iconOrange,
      ),
      _FeatureItem(
        icon: Icons.insights_rounded,
        title: 'Statistiques',
        cardColor: AppColors.cardTeal,
        iconColor: AppColors.iconTeal,
      ),
      _FeatureItem(
        icon: Icons.picture_as_pdf_rounded,
        title: 'Rapports PDF',
        cardColor: AppColors.cardRed,
        iconColor: AppColors.iconRed,
      ),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.95,
        ),
        itemCount: features.length,
        itemBuilder: (context, index) {
          final f = features[index];
          return _buildFeatureTile(f);
        },
      ),
    );
  }

  Widget _buildFeatureTile(_FeatureItem item) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: item.cardColor, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: item.cardColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(item.icon, color: item.iconColor, size: 26),
          ),
          const SizedBox(height: 10),
          Text(
            item.title,
            textAlign: TextAlign.center,
            style: GoogleFonts.cairo(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }

  // ─── AVANTAGES ─────────────────────────────────────────────────────
  Widget _buildAdvantages() {
    final advantages = [
      _AdvantageItem(
        icon: Icons.schedule_rounded,
        title: 'Gain de temps',
        description:
            'Réduisez le temps administratif de 80%. Concentrez-vous sur ce qui compte : l\'enseignement.',
      ),
      _AdvantageItem(
        icon: Icons.folder_special_rounded,
        title: 'Mieux organisé',
        description:
            'Toutes vos données centralisées, accessibles partout et à tout moment depuis votre téléphone.',
      ),
      _AdvantageItem(
        icon: Icons.family_restroom_rounded,
        title: 'Communication parents',
        description:
            'Envoyez des rapports et des notifications directement aux familles de vos élèves.',
      ),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Column(
        children: advantages
            .map((a) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: AdvantageBadge(
                    icon: a.icon,
                    title: a.title,
                    description: a.description,
                  ),
                ))
            .toList(),
      ),
    );
  }

  // ─── SECTION CTA ───────────────────────────────────────────────────
  Widget _buildCTASection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 32, 20, 0),
      child: Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              'Prêt à digitaliser votre markaz ?',
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Rejoignez les maîtres qui gèrent leur markaz avec Markazi.',
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(
                fontSize: 14,
                color: Colors.white.withOpacity(0.85),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _showComingSoon,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: Text(
                      'Commencer',
                      style: GoogleFonts.cairo(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pushNamed(context, '/features'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white60),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(
                      'En savoir plus',
                      style: GoogleFonts.cairo(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ─── FOOTER ────────────────────────────────────────────────────────
  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 32, 20, 0),
      child: Column(
        children: [
          const Divider(color: Color(0xFFE0E0E0)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const MarkaziLogo(size: 28, showText: false),
              const SizedBox(width: 10),
              Text(
                'Markazi',
                style: GoogleFonts.cairo(
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'La solution digitale pour les markaz islamiques',
            style: GoogleFonts.cairo(
              fontSize: 12,
              color: AppColors.textLight,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 20,
            children: [
              _footerLink('Fonctionnalités', '/features'),
              _footerLink('À propos', '/about'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _footerLink(String label, String route) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, route),
      child: Text(
        label,
        style: GoogleFonts.cairo(
          fontSize: 13,
          color: AppColors.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  void _goToLogin({bool isLogin = true}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LoginScreen(isLogin: isLogin),
      ),
    );
  }

  void _showComingSoon() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Bientôt disponible ! 🕌',
          style: GoogleFonts.cairo(color: Colors.white),
        ),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}

class _FeatureItem {
  final IconData icon;
  final String title;
  final Color cardColor;
  final Color iconColor;

  _FeatureItem({
    required this.icon,
    required this.title,
    required this.cardColor,
    required this.iconColor,
  });
}

class _AdvantageItem {
  final IconData icon;
  final String title;
  final String description;

  _AdvantageItem({
    required this.icon,
    required this.title,
    required this.description,
  });
}
