import 'package:flutter/material.dart';

/// Palette de couleurs de l'application Markazi
class AppColors {
  AppColors._();

  // Couleurs principales
  static const Color primary = Color(0xFF1A7F55);      // Vert islamique profond
  static const Color primaryLight = Color(0xFF2EAA73);  // Vert clair
  static const Color primaryDark = Color(0xFF115C3C);   // Vert foncé
  static const Color secondary = Color(0xFFD4A853);     // Or doux (accent)

  // Fonds
  static const Color background = Color(0xFFF5F7F5);   // Gris très légèrement vert
  static const Color surface = Color(0xFFFFFFFF);

  // Textes
  static const Color textDark = Color(0xFF1A2E1F);
  static const Color textMedium = Color(0xFF4A6355);
  static const Color textLight = Color(0xFF8AA898);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF1A7F55), Color(0xFF0D5C3C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient softGradient = LinearGradient(
    colors: [Color(0xFFE8F5EE), Color(0xFFF5FAF7)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Couleurs des cartes de fonctionnalités
  static const Color cardBlue = Color(0xFFE8F0FE);
  static const Color cardGreen = Color(0xFFE6F4EA);
  static const Color cardOrange = Color(0xFFFFF3E0);
  static const Color cardPurple = Color(0xFFF3E5F5);
  static const Color cardTeal = Color(0xFFE0F2F1);
  static const Color cardRed = Color(0xFFFCE4EC);

  static const Color iconBlue = Color(0xFF4285F4);
  static const Color iconGreen = Color(0xFF34A853);
  static const Color iconOrange = Color(0xFFFB8C00);
  static const Color iconPurple = Color(0xFF9C27B0);
  static const Color iconTeal = Color(0xFF00897B);
  static const Color iconRed = Color(0xFFE91E63);
}
