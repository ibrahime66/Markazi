# Configuration du Logo Markazi

## 📦 Comment placer le logo

Le splash screen de l'application a été configuré pour utiliser votre logo Markazi. 

### ✅ Étapes à suivre:

1. **Sauvegardez le logo en PNG** dans le dossier:
   ```
   /assets/images/markazi_logo.png
   ```

2. **Dossier à créer** (s'il n'existe pas):
   - Naviguez vers: `c:\Users\HP\Downloads\markazi\assets\images\`
   - Placez le fichier `markazi_logo.png` à cet endroit

3. **Après avoir placé le logo**:
   - Exécutez: `flutter pub get`
   - Redémarrez l'application

### 📋 Spécifications recommandées pour le logo:

- **Format**: PNG avec transparence (optionnel)
- **Taille recommandée**: 200x200px ou plus (sera redimensionné à 100x100px)
- **Ratio**: Carré ou rectangle (le conteneur s'adapte)
- **Couleur de fond**: Blanc (le conteneur fournit le fond blanc)

### 🎨 A propos de la configuration:

- Le logo s'affichera dans un carré blanc avec ombre douce
- Durée d'animation: 0.8 secondes (effet de grossissement)
- Position: Centré au-dessus du texte "Markazi"
- Si l'image ne charge pas, un logo par défaut s'affichera (lettre arabe)

### ✨ Configuration du splash screen natif (optionnel):

Pour un splash screen véritablement natif à démarrage rapide:
- Android: Modifiez `/android/app/src/main/AndroidManifest.xml`
- iOS: Modifiez `/ios/Runner/LaunchScreen.storyboard`

Pour cela, vous pouvez utiliser la dépendance `flutter_native_splash` (recommandé).

---

**Status**: ✅ Configuration Flutter complétée  
**Prochaine étape**: Placer le fichier logo PNG
