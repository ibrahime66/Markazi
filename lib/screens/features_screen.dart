import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_colors.dart';
import '../widgets/common_widgets.dart';
import 'login_screen.dart';
import '../l10n/app_localizations.dart';

/// Page des fonctionnalités détaillées de Markazi
class FeaturesScreen extends StatelessWidget {
  const FeaturesScreen({super.key});

  /// Fonctionnalités présentées (textes traduits — doc/audit.md K8).
  static List<_DetailedFeature> _features(BuildContext context) => [
    _DetailedFeature(
      icon: Icons.people_alt_rounded,
      title: AppLocalizations.of(context).featStudentsTitle,
      description:
          AppLocalizations.of(context).featStudentsBody,
      cardColor: AppColors.cardGreen,
      iconColor: AppColors.iconGreen,
      highlights: [
        AppLocalizations.of(context).featStudentsH1,
        AppLocalizations.of(context).featStudentsH2,
        AppLocalizations.of(context).featStudentsH3,
        AppLocalizations.of(context).featStudentsH4,
      ],
    ),
    _DetailedFeature(
      icon: Icons.receipt_long_rounded,
      title: AppLocalizations.of(context).featPaymentsTitle,
      description:
          AppLocalizations.of(context).featPaymentsBody,
      cardColor: AppColors.cardBlue,
      iconColor: AppColors.iconBlue,
      highlights: [
        AppLocalizations.of(context).featPaymentsH1,
        AppLocalizations.of(context).featPaymentsH2,
        AppLocalizations.of(context).featPaymentsH3,
        AppLocalizations.of(context).featPaymentsH4,
      ],
    ),
    _DetailedFeature(
      icon: Icons.fact_check_rounded,
      title: AppLocalizations.of(context).featAttendanceTitle,
      description:
          AppLocalizations.of(context).featAttendanceBody,
      cardColor: AppColors.cardPurple,
      iconColor: AppColors.iconPurple,
      highlights: [
        AppLocalizations.of(context).featAttendanceH1,
        AppLocalizations.of(context).featAttendanceH2,
        AppLocalizations.of(context).featAttendanceH3,
        AppLocalizations.of(context).featAttendanceH4,
      ],
    ),
    _DetailedFeature(
      icon: Icons.insights_rounded,
      title: AppLocalizations.of(context).featStatsTitle,
      description:
          AppLocalizations.of(context).featStatsBody,
      cardColor: AppColors.cardTeal,
      iconColor: AppColors.iconTeal,
      highlights: [
        AppLocalizations.of(context).featStatsH1,
        AppLocalizations.of(context).featStatsH2,
        AppLocalizations.of(context).featStatsH3,
        AppLocalizations.of(context).featStatsH4,
      ],
    ),
    _DetailedFeature(
      icon: Icons.picture_as_pdf_rounded,
      title: AppLocalizations.of(context).featReportTitle,
      description:
          AppLocalizations.of(context).featReportBody,
      cardColor: AppColors.cardRed,
      iconColor: AppColors.iconRed,
      highlights: [
        AppLocalizations.of(context).featReportH1,
        AppLocalizations.of(context).featReportH2,
        AppLocalizations.of(context).featReportH3,
        AppLocalizations.of(context).featReportH4,
      ],
    ),
    _DetailedFeature(
      icon: Icons.event_busy_rounded,
      title: AppLocalizations.of(context).featAbsenceTitle,
      description:
          AppLocalizations.of(context).featAbsenceBody,
      cardColor: AppColors.cardOrange,
      iconColor: AppColors.iconOrange,
      highlights: [
        AppLocalizations.of(context).featAbsenceH1,
        AppLocalizations.of(context).featAbsenceH2,
        AppLocalizations.of(context).featAbsenceH3,
        AppLocalizations.of(context).featAbsenceH4,
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: MarkaziAppBar(title: AppLocalizations.of(context).navFeatures),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header
            _buildHeader(context),

            // Liste des fonctionnalités
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: _features(context).map((f) {
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

  Widget _buildHeader(BuildContext context) {
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
              AppLocalizations.of(context).featHeaderBadge,
              style: GoogleFonts.cairo(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            AppLocalizations.of(context).featHeaderTitle,
            style: GoogleFonts.cairo(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            AppLocalizations.of(context).featHeaderBody,
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
              AppLocalizations.of(context).featCtaTitle,
              style: GoogleFonts.cairo(
                fontWeight: FontWeight.w800,
                fontSize: 18,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              AppLocalizations.of(context).featCtaBody,
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(
                fontSize: 13,
                color: AppColors.textMedium,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),
            PrimaryButton(
              text: AppLocalizations.of(context).featCtaButton,
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
