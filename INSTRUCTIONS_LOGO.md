# Instructions pour remplacer le logo Flutter par le logo MARKAZI

## Étapes à suivre :

### 1. Préparez vos images
- **app_icon.png** : 1024x1024 pixels (icône de l'application)
- **splash_logo.png** : 300x300 pixels (splash screen)

### 2. Remplacez les fichiers placeholders
Placez vos images dans :
- `assets/logo/app_icon.png` 
- `assets/logo/splash_logo.png`

### 3. Générez les icônes et splash screen
```bash
# Générer l'icône de l'application
flutter pub run flutter_launcher_icons:main

# Générer le splash screen
flutter pub run flutter_native_splash:create
```

### 4. Nettoyez et relancez
```bash
flutter clean
flutter pub get
flutter run
```

## Résultat attendu :
- Plus de logo Flutter au démarrage
- Votre logo MARKAZI comme icône sur le téléphone
- Splash screen personnalisé avec votre logo

## Notes :
- Assurez-vous que vos images sont de bonne qualité
- Le fond doit être transparent pour l'icône
- Le splash screen peut avoir un fond blanc ou transparent
