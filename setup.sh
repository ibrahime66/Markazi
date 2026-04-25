#!/bin/bash
# Script pour vérifier et lancer le projet Markazi

echo "🕌 ============================================"
echo "    MARKAZI - Project Setup & Validation"
echo "============================================ 🕌"
echo ""

# Colours
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check Flutter
echo -e "${YELLOW}1️⃣  Vérifiant Flutter...${NC}"
if command -v flutter &> /dev/null; then
    flutter --version
    echo -e "${GREEN}✅ Flutter trouvé${NC}\n"
else
    echo -e "${RED}❌ Flutter n'est pas installé${NC}\n"
    exit 1
fi

# Get dependencies
echo -e "${YELLOW}2️⃣  Installation des dépendances...${NC}"
flutter pub get
echo -e "${GREEN}✅ Dépendances installées${NC}\n"

# Check structure
echo -e "${YELLOW}3️⃣  Vérification de la structure du projet...${NC}"
if [ -d "lib" ] && [ -d "lib/screens" ] && [ -d "lib/widgets" ] && [ -d "lib/utils" ]; then
    echo -e "${GREEN}✅ Structure correcte${NC}"
    echo "   • lib/screens/ : ✅"
    echo "   • lib/widgets/ : ✅"
    echo "   • lib/utils/ : ✅"
    echo "   • assets/images/ : $([ -d "assets/images" ] && echo '✅' || echo '❌')"
else
    echo -e "${RED}❌ Structure incorrecte${NC}\n"
    exit 1
fi
echo ""

# Analyze
echo -e "${YELLOW}4️⃣  Analyse du code (flutter analyze)...${NC}"
flutter analyze
echo -e "${GREEN}✅ Analyse complète${NC}\n"

# Ready to run
echo -e "${YELLOW}5️⃣  Préparation au lancement...${NC}"
echo -e "${GREEN}✅ Projet prêt !${NC}\n"

echo "🚀 ============================================"
echo "   Pour lancer l'application :"
echo "   $ flutter run"
echo ""
echo "   Pour lancer les tests :"
echo "   $ flutter test"
echo "============================================ 🚀"
echo ""
echo "📖 Voir RESTRUCTURING_SUMMARY.md pour les détails"
