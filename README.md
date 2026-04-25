# Markazi

**Markazi** est une application Flutter professionnelle pour la gestion digitale des écoles islamiques (Markaz).

## 📋 Fonctionnalités

- **Gestion des élèves** : Fiches complètes avec informations personnelles et parentales
- **Suivi des paiements** : Enregistrement et génération automatique de reçus PDF
- **Présence & Récitation** : Pointage quotidien et évaluation des élèves
- **Statistiques** : Tableaux de bord hebdomadaires avec graphiques
- **Rapports** : Export mensuels en PDF partageables directement aux parents
- **Gestion des absences** : Suivi de l'assiduité avec alertes

## 🎨 Design

L'application utilise un design moderne avec :
- Palette de couleurs verte (couleur islamique)
- Typographie Cairo et Amiri pour le support du français et arabe
- Composants Material Design 3
- Animations fluides et transitions agréables

## 📱 Technologies

- **Framework** : Flutter
- **Langage** : Dart
- **Police** : google_fonts (Cairo, Amiri)
- **Indicateurs** : smooth_page_indicator
- **Icônes** : flutter_svg, Material Icons

## 🚀 Getting Started

### Prérequis

- Flutter SDK (>= 3.0.0)
- Dart SDK (>= 3.0.0)

### Installation

1. Clonez le projet
```bash
git clone https://github.com/yourusername/markazi.git
cd markazi
```

2. Installez les dépendances
```bash
flutter pub get
```

3. Lancez l'application
```bash
flutter run
```

## 📁 Structure du Projet

```
lib/
├── main.dart              # Point d'entrée de l'application
├── screens/               # Écrans de l'app
│   ├── splash_screen.dart
│   ├── onboarding_screen.dart
│   ├── home_screen.dart
│   ├── features_screen.dart
│   └── about_screen.dart
├── widgets/               # Widgets réutilisables
│   └── common_widgets.dart
├── utils/                 # Utilitaires
│   ├── app_colors.dart
│   └── app_strings.dart
└── models/                # Modèles de données (à implémenter)

assets/
├── images/                # Images et ressources
```

## 🛠️ Configuration

### Dépendances

```yaml
dependencies:
  flutter:
    sdk: flutter
  google_fonts: ^6.1.0
  smooth_page_indicator: ^1.1.0
  flutter_svg: ^2.0.7
  lottie: ^2.7.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0
```

## 📖 Navigation

L'application utilise un système de routes nommées :
- `/splash` → Écran de démarrage
- `/onboarding` → Tutoriel d'introduction
- `/home` → Accueil principal
- `/features` → Fonctionnalités détaillées
- `/about` → À propos de Markazi

## 🎯 Fonctionnalités Futures

- [ ] Backend Firebase
- [ ] Authentification utilisateur
- [ ] Base de données Firestore
- [ ] Notifications push
- [ ] Intégration WhatsApp
- [ ] Rapports PDF avec intégration email
- [ ] Mode hors ligne
- [ ] Support multilingue (Français, Arabe, langues locales)

## 📝 Licence

Ce projet est sous licence MIT.

## 👤 Auteur

Créé pour les maîtres et écoles islamiques en Afrique.

## 📧 Contact

Pour toute question ou suggestion : contact@markazi.app

---

**Markazi** - La solution digitale pour la gestion moderne des markaz islamiques.
