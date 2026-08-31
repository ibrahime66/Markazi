import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_colors.dart';
import '../widgets/common_widgets.dart';

/// Page À propos de Markazi
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const MarkaziAppBar(title: 'À propos'),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header avec logo
            _buildHeader(),

            // Objectif
            _buildSection(
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
              child: _buildObjectifSection(),
            ),

            // Vision
            _buildSection(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: _buildVisionSection(),
            ),

            // Notre approche
            _buildSection(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: _buildApproacSection(),
            ),

            // Valeurs
            _buildSection(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: _buildValeursSection(),
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

  Widget _buildHeader() {
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
            'La solution digitale pour les markaz islamiques',
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
              _badge(Icons.mosque_rounded, 'Islamique'),
              _badge(Icons.phone_iphone_rounded, 'Mobile First'),
              _badge(Icons.public_rounded, 'Afrique'),
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

  Widget _buildObjectifSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle(title: 'Notre objectif'),
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
                      'Digitaliser les markaz',
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
                'Markazi est né d\'un constat simple : les maîtres de markaz gèrent encore leur école avec des cahiers, des notes manuscrites et de la mémoire.',
                style: GoogleFonts.cairo(
                  fontSize: 14,
                  color: AppColors.textMedium,
                  height: 1.7,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Notre objectif est de leur offrir un outil numérique moderne, simple et adapté à leurs besoins, pour qu\'ils puissent se concentrer sur l\'essentiel : transmettre le savoir islamique.',
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

  Widget _buildVisionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle(title: 'Notre vision'),
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
                'Solution moderne',
                'Une application pensée pour les réalités des maîtres africains : simple, rapide et fonctionnant même avec une connexion limitée.',
              ),
              const Divider(height: 24),
              _visionItem(
                Icons.hub_rounded,
                'Écosystème connecté',
                'À terme, relier les maîtres, les élèves et les parents dans un seul écosystème pour une meilleure communication et suivi.',
              ),
              const Divider(height: 24),
              _visionItem(
                Icons.public_rounded,
                'Impact continental',
                'Devenir la référence en gestion de markaz à travers l\'Afrique francophone et au-delà.',
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

  Widget _buildApproacSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle(title: 'Notre approche'),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _approachCard(
                Icons.center_focus_strong_rounded,
                'Centré utilisateur',
                'Conçu avec et pour les maîtres de markaz',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _approachCard(
                Icons.wifi_off_rounded,
                'Hors ligne',
                'Fonctionne sans connexion internet permanente',
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
                'Sécurisé',
                'Vos données protégées et confidentielles',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _approachCard(
                Icons.language_rounded,
                'Multilingue',
                'Français, Arabe et langues locales',
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

  Widget _buildValeursSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle(title: 'Nos valeurs'),
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
              _valeurItem('Simplicité',
                  'Un outil qui ne demande pas de formation. Intuitif dès le premier jour.'),
              const SizedBox(height: 16),
              _valeurItem('Respect',
                  'Respectueux des valeurs islamiques et des pratiques des communautés.'),
              const SizedBox(height: 16),
              _valeurItem('Impact',
                  'Chaque fonctionnalité est conçue pour avoir un impact réel sur le quotidien du maître.'),
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
            'Contactez-nous',
            style: GoogleFonts.cairo(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Une question, une suggestion ou un partenariat ?\nNous sommes à votre écoute.',
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
              'Nous contacter',
              style: GoogleFonts.cairo(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}
