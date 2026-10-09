import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_colors.dart';
import '../widgets/common_widgets.dart';
import '../l10n/app_localizations.dart';

/// Page À propos de Markazi
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: MarkaziAppBar(title: AppLocalizations.of(context).navAbout),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header avec logo
            _buildHeader(context),

            // Objectif
            _buildSection(
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
              child: _buildObjectifSection(context),
            ),

            // Vision
            _buildSection(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: _buildVisionSection(context),
            ),

            // Notre approche
            _buildSection(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: _buildApproacSection(context),
            ),

            // Valeurs
            _buildSection(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: _buildValeursSection(context),
            ),

            // Contact
            _buildSection(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
              child: _buildContactSection(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({required EdgeInsets padding, required Widget child}) {
    return Padding(padding: padding, child: child);
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 36, 24, 40),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0D5C3C), Color(0xFF1A7F55)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        children: [
          // Logo
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Center(
              child: Text(
                'م',
                style: GoogleFonts.amiri(
                  fontSize: 48,
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          Text(
            'Markazi',
            style: GoogleFonts.cairo(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: 1.5,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            AppLocalizations.of(context).appTagline,
            textAlign: TextAlign.center,
            style: GoogleFonts.cairo(
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.85),
              height: 1.5,
            ),
          ),

          const SizedBox(height: 24),

          // Badges
          Wrap(
            spacing: 10,
            runSpacing: 10,
            alignment: WrapAlignment.center,
            children: [
              _badge(Icons.mosque_rounded, AppLocalizations.of(context).aboutBadgeIslamic),
              _badge(Icons.phone_iphone_rounded, AppLocalizations.of(context).aboutBadgeMobile),
              _badge(Icons.public_rounded, AppLocalizations.of(context).aboutBadgeAfrica),
            ],
          ),
        ],
      ),
    );
  }

  Widget _badge(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 15),
          const SizedBox(width: 6),
          Text(
            text,
            style: GoogleFonts.cairo(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildObjectifSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(title: AppLocalizations.of(context).aboutGoalTitle),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.cardGreen, width: 1.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.cardGreen,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.flag_rounded,
                        color: AppColors.iconGreen, size: 24),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      AppLocalizations.of(context).aboutGoalSubtitle,
                      style: GoogleFonts.cairo(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textDark,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                AppLocalizations.of(context).aboutGoalBody1,
                style: GoogleFonts.cairo(
                  fontSize: 14,
                  color: AppColors.textMedium,
                  height: 1.7,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                AppLocalizations.of(context).aboutGoalBody2,
                style: GoogleFonts.cairo(
                  fontSize: 14,
                  color: AppColors.textMedium,
                  height: 1.7,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVisionSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(title: AppLocalizations.of(context).aboutVisionTitle),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.cardBlue, width: 1.5),
          ),
          child: Column(
            children: [
              _visionItem(
                Icons.auto_awesome_rounded,
                AppLocalizations.of(context).aboutVisionModernTitle,
                AppLocalizations.of(context).aboutVisionModernBody,
              ),
              const Divider(height: 24),
              _visionItem(
                Icons.hub_rounded,
                AppLocalizations.of(context).aboutVisionEcosystemTitle,
                AppLocalizations.of(context).aboutVisionEcosystemBody,
              ),
              const Divider(height: 24),
              _visionItem(
                Icons.public_rounded,
                AppLocalizations.of(context).aboutVisionImpactTitle,
                AppLocalizations.of(context).aboutVisionImpactBody,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _visionItem(IconData icon, String title, String desc) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.cardBlue,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.iconBlue, size: 20),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.cairo(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                desc,
                style: GoogleFonts.cairo(
                  fontSize: 13,
                  color: AppColors.textMedium,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildApproacSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(title: AppLocalizations.of(context).aboutApproachTitle),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _approachCard(
                Icons.center_focus_strong_rounded,
                AppLocalizations.of(context).aboutApproachUserTitle,
                AppLocalizations.of(context).aboutApproachUserBody,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _approachCard(
                Icons.wifi_off_rounded,
                AppLocalizations.of(context).syncOffline,
                AppLocalizations.of(context).aboutApproachOfflineBody,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _approachCard(
                Icons.lock_rounded,
                AppLocalizations.of(context).aboutApproachSecureTitle,
                AppLocalizations.of(context).aboutApproachSecureBody,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _approachCard(
                Icons.language_rounded,
                AppLocalizations.of(context).aboutApproachLangTitle,
                AppLocalizations.of(context).aboutApproachLangBody,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _approachCard(IconData icon, String title, String desc) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.cardGreen,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.iconGreen, size: 20),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: GoogleFonts.cairo(
              fontWeight: FontWeight.w700,
              fontSize: 13,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            desc,
            style: GoogleFonts.cairo(
              fontSize: 12,
              color: AppColors.textMedium,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildValeursSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(title: AppLocalizations.of(context).aboutValuesTitle),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: AppColors.softGradient,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.1), width: 1),
          ),
          child: Column(
            children: [
              _valeurItem(AppLocalizations.of(context).aboutValueSimplicityTitle,
                  AppLocalizations.of(context).aboutValueSimplicityBody),
              const SizedBox(height: 16),
              _valeurItem(AppLocalizations.of(context).aboutValueRespectTitle,
                  AppLocalizations.of(context).aboutValueRespectBody),
              const SizedBox(height: 16),
              _valeurItem(AppLocalizations.of(context).aboutValueImpactTitle,
                  AppLocalizations.of(context).aboutValueImpactBody),
            ],
          ),
        ),
      ],
    );
  }

  Widget _valeurItem(String title, String desc) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 6,
          height: 6,
          margin: const EdgeInsets.only(top: 7),
          decoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.cairo(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                desc,
                style: GoogleFonts.cairo(
                  fontSize: 13,
                  color: AppColors.textMedium,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContactSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const Icon(Icons.email_rounded, color: Colors.white, size: 36),
          const SizedBox(height: 12),
          Text(
            AppLocalizations.of(context).aboutContactTitle,
            style: GoogleFonts.cairo(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context).aboutContactBody,
            textAlign: TextAlign.center,
            style: GoogleFonts.cairo(
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.85),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          OutlinedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'contact@markazi.app',
                    style: GoogleFonts.cairo(color: Colors.white),
                  ),
                  backgroundColor: AppColors.primaryDark,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  margin: const EdgeInsets.all(16),
                ),
              );
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: const BorderSide(color: Colors.white60, width: 1.5),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            icon: const Icon(Icons.send_rounded, size: 18),
            label: Text(
              AppLocalizations.of(context).aboutContactButton,
              style: GoogleFonts.cairo(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}
