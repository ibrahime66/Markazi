# 🎯 Configuration du Logo Markazi - Guide Complet

## ✅ Configuration effectuée

J'ai configuré l'application pour utiliser votre logo Markazi personnalisé aux emplacements suivants:

### 1️⃣ Splash Screen Flutter (ce que tu vois au démarrage)
- **Localisation**: `lib/screens/splash_screen.dart`  
- **Fichier attendu**: `assets/images/markazi_logo.png`

### 2️⃣ Splash Screen Natif Android
- **Localisation**: `android/app/src/main/res/drawable/`
- **Fichiers attendus**: 
  - `markazi_logo_splash.png` (image PNG du logo)
  - `splash_background.xml` (fond avec gradient vert)

### 3️⃣ Splash Screen Natif iOS  
- **Localisation**: `ios/Runner/LaunchScreen.storyboard` (optionnel)

---

## 📋 Étapes pour placer le logo

### **IMPORTANT: Formats d'image recommandés pour Android**

Crée plusieurs versions du logo aux dimensions suivantes:

```
logo_original.png (200x200px minimum)

Versions à créer:
├─ mdpi   → 48x48px   → markazi_logo_splash.png
├─ hdpi   → 72x72px   → markazi_logo_splash.png  
├─ xhdpi  → 96x96px   → markazi_logo_splash.png
├─ xxhdpi → 144x144px → markazi_logo_splash.png
└─ xxxhdpi→ 192x192px → markazi_logo_splash.png
```

Ou simplement place une seule version en haute résolution (192x192px) dans:
```
android/app/src/main/res/drawable/markazi_logo_splash.png
```

---

## 🚀 Instructions étape par étape

### 1. Prépare le logo
- [ ] Ouvre ton logo Markazi
- [ ] Exporte-le en PNG (de préférence 200x200px ou plus)
- [ ] Assure-toi qu'il a une transparence (optionnel mais recommandé)

### 2. Place le logo Flutter
```
C:\Users\HP\Downloads\markazi\assets\images\markazi_logo.png
```
- Crée le dossier `images` s'il n'existe pas
- Place le fichier PNG dedans

### 3. Place le logo Android (natif)
```
C:\Users\HP\Downloads\markazi\android\app\src\main\res\drawable\markazi_logo_splash.png
```
- Place le logo PNG directement dans ce dossier

### 4. (Optionnel) Place le logo iOS
```
C:\Users\HP\Downloads\markazi\ios\Runner\Assets.xcassets\
```
- Crée une image set pour iOS
- Ajoute les versions @1x, @2x, @3x

---

## 🔄 Après avoir placé les fichiers

Exécute ces commandes:

```bash
# Nettoie le cache Flutter
flutter clean

# Télécharge les dépendances  
flutter pub get

# Regénère les fichiers (si besoin)
flutter pub run build_runner build

# Lance l'app
flutter run
```

---

## 📸 Si tu besoin d'aide pour redimensionner

Outils en ligne gratuits:
- [ImageResizer.com](https://imageresizer.com)
- [Pixlr](https://pixlr.com)
- [Canva](https://canva.com)

Procédure:
1. Importe ton logo (200x200px+)
2. Crée une version 192x192px pour Android
3. Exporte en PNG

---

## ✨ Résultat final

Après avoir complété ces étapes, tu verras:

1. **Au démarrage** (splash screen Flutter):
   - Fond dégradé vert Markazi
   - Ton logo centré avec animation de zoom
   - Durée: ~3 secondes

2. **Écran de démarrage natif Android**:
   - Fond dégradé vert
   - Logo centré (s'affiche instantanément avant Flutter)

3. **Texte animation**:
   - "Markazi" s'affiche avec animation
   - Sous-titre: "Gérez votre markaz simplement et efficacement"
   - Spinner de chargement en bas

---

## 🆘 Dépannage

**Si le logo n'apparaît pas:**
- ✓ Vérifie le nom du fichier: `markazi_logo.png` (exactement)
- ✓ Vérifie l'extension: `.png` (pas `.jpg` ou autres)
- ✓ Redémarre Flutter: `flutter clean && flutter run`
- ✓ Vérifiez le pubspec.yaml inclut `assets/images/`

**Si Android affiche du blanc:**
- ✓ Vérifie que le fichier Android est bien dans: `drawable/`
- ✓ Redémarre l'émulateur ou le téléphone
- ✓ Récompile l'app: `flutter clean && flutter run`

---

## 📚 Fichiers modifiés

Voici tous les fichiers qu'on a configurés:

✅ `lib/screens/splash_screen.dart` - Affichage Flutter du logo  
✅ `android/app/src/main/res/drawable/launch_background.xml` - Splash natif Android  
✅ `android/app/src/main/res/drawable/splash_background.xml` - Fond gradient Android (CRÉÉ)  
✅ `pubspec.yaml` - Déclaration assets (déjà OK)  

---

## 🎨 Couleurs utilisées (pour référence)

```
Dégradé Markazi:
- Primaire: #0D5C3C (vert foncé)
- Secondaire: #1A7F55 (vert moyen)
- Tertiaire: #2EAA73 (vert clair)
```

---

**Prochaine étape:** Place le fichier `markazi_logo.png` et relance l'application! 🚀
