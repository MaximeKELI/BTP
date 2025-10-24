#!/bin/bash

# Script de validation complète pour l'environnement local
echo "🔍 Validation complète de l'environnement local..."

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
echo "🔍 VALIDATION COMPLÈTE - ENVIRONNEMENT LOCAL"
echo "=========================================="

# 1. Vérifier les prérequis
print_status "1. Vérification des prérequis..."
command -v python3 >/dev/null 2>&1 && check_error "Python 3 installé" || print_error "Python 3 manquant"
command -v flutter >/dev/null 2>&1 && check_error "Flutter installé" || print_error "Flutter manquant"
command -v psql >/dev/null 2>&1 && check_error "PostgreSQL installé" || print_error "PostgreSQL manquant"
command -v redis-server >/dev/null 2>&1 && check_error "Redis installé" || print_warning "Redis manquant (optionnel)"

# 2. Vérifier la structure des fichiers
print_status "2. Vérification de la structure des fichiers..."
[ -f "backend/.env" ] && check_error "Fichier .env backend" || print_error "Fichier .env backend manquant"
[ -f "frontend/btp/.env" ] && check_error "Fichier .env frontend" || print_error "Fichier .env frontend manquant"
[ -f "backend/migrations/init.sql" ] && check_error "Script d'initialisation DB" || print_error "Script d'initialisation DB manquant"
[ -f "scripts/setup_dev.sh" ] && check_error "Script de configuration" || print_error "Script de configuration manquant"

# 3. Vérifier les dépendances Backend
print_status "3. Vérification des dépendances Backend..."
cd /home/maxime/BTP/backend
if [ -d "venv" ]; then
    source venv/bin/activate
    pip list | grep -q "Flask" && check_error "Flask installé" || print_error "Flask manquant"
    pip list | grep -q "SQLAlchemy" && check_error "SQLAlchemy installé" || print_error "SQLAlchemy manquant"
    pip list | grep -q "psycopg2" && check_error "psycopg2 installé" || print_error "psycopg2 manquant"
else
    print_error "Environnement virtuel Python manquant"
fi

# 4. Vérifier les dépendances Flutter
print_status "4. Vérification des dépendances Flutter..."
cd /home/maxime/BTP/frontend/btp
flutter doctor --no-version-check >/dev/null 2>&1 && check_error "Flutter configuré" || print_error "Flutter mal configuré"
flutter pub get >/dev/null 2>&1 && check_error "Dépendances Flutter" || print_error "Dépendances Flutter manquantes"

# 5. Vérifier la base de données
print_status "5. Vérification de la base de données..."
sudo -u postgres psql -c "SELECT 1 FROM pg_database WHERE datname='btp_app';" 2>/dev/null | grep -q "1" && check_error "Base de données btp_app" || print_error "Base de données btp_app manquante"
sudo -u postgres psql -c "SELECT 1 FROM pg_database WHERE datname='btp_app_dev';" 2>/dev/null | grep -q "1" && check_error "Base de données btp_app_dev" || print_error "Base de données btp_app_dev manquante"

# 6. Vérifier les tests
print_status "6. Vérification des tests..."
cd /home/maxime/BTP/frontend/btp
flutter test --no-sound-null-safety >/dev/null 2>&1 && check_error "Tests Flutter" || print_error "Tests Flutter échoués"

cd /home/maxime/BTP/backend
if [ -d "venv" ]; then
    source venv/bin/activate
    python -m pytest tests/ --tb=no -q >/dev/null 2>&1 && check_error "Tests Backend" || print_error "Tests Backend échoués"
fi

# 7. Vérifier la configuration Android
print_status "7. Vérification de la configuration Android..."
cd /home/maxime/BTP/frontend/btp
grep -q "com.btp.multisector" android/app/build.gradle.kts && check_error "Application ID Android" || print_error "Application ID Android incorrect"

# 8. Vérifier les imports Flutter
print_status "8. Vérification des imports Flutter..."
cd /home/maxime/BTP/frontend/btp
flutter analyze --no-fatal-infos >/dev/null 2>&1 && check_error "Analyse Flutter" || print_error "Problèmes d'analyse Flutter"

# Résumé
echo ""
echo "=========================================="
echo "📊 RÉSUMÉ DE LA VALIDATION"
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
else
    print_error "❌ $ERRORS erreur(s) trouvée(s)"
    print_error "Veuillez corriger les erreurs avant de continuer."
    echo ""
    echo "🔧 Commandes utiles :"
    echo "- Configuration: ./scripts/setup_dev.sh"
    echo "- Reset DB: ./scripts/reset_db.sh"
    echo "- Tests: ./scripts/run_tests.sh"
fi

exit $ERRORS
