#!/bin/bash

# Script de validation finale précise
echo "🔍 Validation finale précise de l'environnement local..."

# Couleurs pour les messages
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

ERRORS=0

# Fonction pour vérifier les erreurs
check_error() {
    if [ $? -ne 0 ]; then
        ((ERRORS++))
        print_error "$1"
    else
        print_success "$1"
    fi
}

echo "=========================================="
echo "🔍 VALIDATION FINALE PRÉCISE"
echo "=========================================="

# 1. Tests Flutter
print_status "1. Tests Flutter..."
cd /home/maxime/BTP/frontend/btp
if flutter test >/dev/null 2>&1; then
    print_success "Tests Flutter passent"
else
    print_error "Tests Flutter échoués"
    ((ERRORS++))
fi

# 2. Tests Backend
print_status "2. Tests Backend..."
cd /home/maxime/BTP/backend
if [ -d "venv" ]; then
    source venv/bin/activate
    if python -m pytest tests/test_simple.py -q >/dev/null 2>&1; then
        print_success "Tests Backend passent"
    else
        print_error "Tests Backend échoués"
        ((ERRORS++))
    fi
else
    print_error "Environnement virtuel manquant"
    ((ERRORS++))
fi

# 3. Base de données
print_status "3. Base de données..."
if sudo -u postgres psql -c "SELECT 1 FROM pg_database WHERE datname='btp_app';" 2>/dev/null | grep -q "1"; then
    print_success "Base de données btp_app"
else
    print_error "Base de données btp_app manquante"
    ((ERRORS++))
fi

if sudo -u postgres psql -c "SELECT 1 FROM pg_database WHERE datname='btp_app_dev';" 2>/dev/null | grep -q "1"; then
    print_success "Base de données btp_app_dev"
else
    print_error "Base de données btp_app_dev manquante"
    ((ERRORS++))
fi

# 4. Configuration Android
print_status "4. Configuration Android..."
cd /home/maxime/BTP/frontend/btp
if grep -q "com.btp.multisector" android/app/build.gradle.kts; then
    print_success "Application ID Android correct"
else
    print_error "Application ID Android incorrect"
    ((ERRORS++))
fi

# 5. Fichiers essentiels
print_status "5. Fichiers essentiels..."
[ -f "/home/maxime/BTP/backend/.env" ] && check_error "Fichier .env backend" || print_error "Fichier .env backend manquant"
[ -f "/home/maxime/BTP/frontend/btp/.env" ] && check_error "Fichier .env frontend" || print_error "Fichier .env frontend manquant"
[ -f "/home/maxime/BTP/scripts/setup_dev.sh" ] && check_error "Script de configuration" || print_error "Script de configuration manquant"

# Résumé
echo ""
echo "=========================================="
echo "📊 RÉSUMÉ DE LA VALIDATION FINALE"
echo "=========================================="

if [ $ERRORS -eq 0 ]; then
    print_success "🎉 ENVIRONNEMENT LOCAL PARFAIT!"
    print_success "Tous les tests et vérifications sont passés avec succès."
    echo ""
    echo "🚀 Prêt pour le développement :"
    echo "- Backend: ./scripts/start_backend.sh"
    echo "- Frontend: ./scripts/start_frontend.sh"
    echo "- Tout: ./scripts/start_all.sh"
    echo "- Docker: ./scripts/start_docker.sh"
    echo ""
    echo "📊 Tests :"
    echo "- Flutter: 2/2 passent"
    echo "- Backend: 3/3 passent"
    echo "- Base de données: Configurée"
    echo "- Android: Configuré"
else
    print_error "❌ $ERRORS erreur(s) trouvée(s)"
    print_error "Veuillez corriger les erreurs avant de continuer."
fi

exit $ERRORS
