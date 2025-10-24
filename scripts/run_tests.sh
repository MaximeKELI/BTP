#!/bin/bash

# Script pour exécuter tous les tests
echo "🧪 Exécution de tous les tests..."

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

# Tests Flutter
print_status "Exécution des tests Flutter..."
cd /home/maxime/BTP/frontend/btp

# Nettoyer et analyser
flutter clean
flutter pub get
flutter analyze

# Exécuter les tests
if flutter test; then
    print_success "Tests Flutter réussis"
else
    print_error "Tests Flutter échoués"
    exit 1
fi

# Tests Backend
print_status "Exécution des tests Backend..."
cd /home/maxime/BTP/backend

# Activer l'environnement virtuel
if [ -d "venv" ]; then
    source venv/bin/activate
else
    print_warning "Environnement virtuel non trouvé, création..."
    python3 -m venv venv
    source venv/bin/activate
    pip install -r requirements.txt
fi

# Installer pytest et coverage
pip install pytest pytest-cov

# Exécuter les tests
if python -m pytest tests/ -v --cov=app --cov-report=html --cov-report=term-missing; then
    print_success "Tests Backend réussis"
else
    print_error "Tests Backend échoués"
    exit 1
fi

print_success "Tous les tests sont passés avec succès!"
echo ""
echo "📊 Rapports de couverture :"
echo "- Backend: backend/htmlcov/index.html"
echo "- Flutter: Voir la sortie ci-dessus"