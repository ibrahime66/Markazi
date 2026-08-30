import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_colors.dart';
import '../widgets/common_widgets.dart';
import 'login_screen.dart';

/// Page des fonctionnalités détaillées de Markazi
class FeaturesScreen extends StatelessWidget {
  const FeaturesScreen({super.key});

  static const List<_DetailedFeature> _features = [
    _DetailedFeature(
      icon: Icons.people_alt_rounded,
      title: 'Gestion des élèves',
      description:
          'Créez une fiche complète pour chaque élève : nom, prénom, date de naissance, informations des parents, niveau en Coran, date d\'inscription. Recherchez, filtrez et gérez facilement tous vos élèves depuis une seule page.',
      cardColor: AppColors.cardGreen,
      iconColor: AppColors.iconGreen,
      highlights: [
        'Fiche individuelle complète',
        'Informations des parents',
        'Historique de progression',
        'Recherche et filtrage rapides',
      ],
    ),
    _DetailedFeature(
      icon: Icons.receipt_long_rounded,
      title: 'Paiements & Reçus',
      description:
          'Gérez les mensualités de chaque élève. Enregistrez les paiements reçus et générez automatiquement des reçus PDF professionnels. Consultez l\'historique des paiements et identifiez facilement les retards.',
      cardColor: AppColors.cardBlue,
      iconColor: AppColors.iconBlue,
      highlights: [
        'Suivi des mensualités',
        'Génération de reçus PDF',
        'Historique des paiements',
        'Alertes de retard',
      ],
    ),
    _DetailedFeature(
      icon: Icons.fact_check_rounded,
      title: 'Présence & Récitation',
      description:
          'Pointez les présences et les absences chaque jour en quelques secondes. Évaluez la récitation de chaque élève à chaque séance. Un historique complet pour suivre l\'assiduité et la progression.',
      cardColor: AppColors.cardPurple,
      iconColor: AppColors.iconPurple,
      highlights: [
        'Pointage quotidien rapide',
        'Évaluation de récitation',
        'Historique de présence',
        'Notes personnalisées',
      ],
    ),
    _DetailedFeature(
      icon: Icons.insights_rounded,
      title: 'Statistiques hebdomadaires',
      description:
          'Obtenez une vue d\'ensemble de votre classe chaque semaine. Taux d\'assiduité, progression en récitation, paiements reçus — toutes les métriques importantes visualisées clairement.',
      cardColor: AppColors.cardTeal,
      iconColor: AppColors.iconTeal,
      highlights: [
        'Tableau de bord hebdomadaire',
        'Graphiques de progression',
        'Taux d\'assiduité',
        'Comparaison des élèves',
      ],
    ),
    _DetailedFeature(
      icon: Icons.picture_as_pdf_rounded,
      title: 'Rapport mensuel PDF',
      description:
          'Générez un rapport mensuel complet pour chaque élève ou pour toute la classe. Partagez-le directement avec les parents par WhatsApp ou email. Rapport professionnel avec toutes les informations importantes.',
      cardColor: AppColors.cardRed,
      iconColor: AppColors.iconRed,
      highlights: [
        'Rapport élève individuel',
        'Rapport de classe complet',
        'Partage direct WhatsApp',
        'Format PDF professionnel',
      ],
    ),
    _DetailedFeature(
      icon: Icons.event_busy_rounded,
      title: "Gestion des absences",
      description:
          'Suivez le taux d\'absentéisme de chaque élève. Définissez un seuil d\'alerte et recevez une notification quand un élève dépasse ce seuil. Informez les parents automatiquement en cas d\'absences répétées.',
      cardColor: AppColors.cardOrange,
      iconColor: AppColors.iconOrange,
      highlights: [
        'Taux d\'absentéisme par élève',
        'Alertes personnalisables',
        'Notifications aux parents',
        'Justifications d\'absence',
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const MarkaziAppBar(title: 'Fonctionnalités'),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header
            _buildHeader(),

            // Liste des fonctionnalités
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: _features.map((f) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _FeatureDetailCard(feature: f),
                  );
                }).toList(),
              ),
            ),

            // CTA
            _buildCTA(context),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
      decoration: const BoxDecoration(
        gradient: AppColors.primaryGradient,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '6 fonctionnalités essentielles',
              style: GoogleFonts.cairo(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Tout ce qu\'il vous faut\npour gérer votre markaz',
            style: GoogleFonts.cairo(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Markazi regroupe tous les outils nécessaires à la gestion quotidienne de votre markaz dans une application simple et intuitive.',
            style: GoogleFonts.cairo(
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.85),
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCTA(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
        ),
        child: Column(
          children: [
            const Icon(Icons.rocket_launch_rounded,
                color: AppColors.primary, size: 36),
            const SizedBox(height: 12),
            Text(
              'Essayez Markazi gratuitement',
              style: GoogleFonts.cairo(
                fontWeight: FontWeight.w800,
                fontSize: 18,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Créez votre compte et démarrez en moins de 5 minutes.',
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(
                fontSize: 13,
                color: AppColors.textMedium,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),
            PrimaryButton(
              text: 'Créer mon compte',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LoginScreen(isLogin: false),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// Carte détaillée pour chaque fonctionnalité
class _FeatureDetailCard extends StatefulWidget {
  final _DetailedFeature feature;

  const _FeatureDetailCard({required this.feature});

  @override
  State<_FeatureDetailCard> createState() => _FeatureDetailCardState();
}

class _FeatureDetailCardState extends State<_FeatureDetailCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: widget.feature.cardColor,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => setState(() => _expanded = !_expanded),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: widget.feature.cardColor,
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: Icon(
                        widget.feature.icon,
                        color: widget.feature.iconColor,
                        size: 27,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        widget.feature.title,
                        style: GoogleFonts.cairo(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textDark,
                        ),
                      ),
                    ),
                    Icon(
                      _expanded
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      color: AppColors.textLight,
                    ),
                  ],
                ),

                // Description (toujours visible, courte)
                const SizedBox(height: 12),
                Text(
                  _expanded
                      ? widget.feature.description
                      : '${widget.feature.description.substring(0, widget.feature.description.length > 80 ? 80 : widget.feature.description.length)}...',
                  style: GoogleFonts.cairo(
                    fontSize: 13,
                    color: AppColors.textMedium,
                    height: 1.6,
                  ),
                ),

                // Points détaillés (visible quand développé)
                if (_expanded) ...[
                  const SizedBox(height: 16),
                  const Divider(color: Color(0xFFEEEEEE)),
                  const SizedBox(height: 12),
                  ...widget.feature.highlights.map(
                    (h) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              color: widget.feature.cardColor,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.check_rounded,
                              size: 12,
                              color: widget.feature.iconColor,
                            ),
                          ),
                          const SizedBox(width: 10),
                          // Expanded : certains points listés sont longs
                          // ("Taux d'absentéisme par élève") et débordaient
                          // sur les écrans les plus étroits.
                          Expanded(
                            child: Text(
                              h,
                              style: GoogleFonts.cairo(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textDark,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DetailedFeature {
  final IconData icon;
  final String title;
  final String description;
  final Color cardColor;
  final Color iconColor;
  final List<String> highlights;

  const _DetailedFeature({
    required this.icon,
    required this.title,
    required this.description,
    required this.cardColor,
    required this.iconColor,
    required this.highlights,
  });
}
