#!/bin/bash

# Script simple pour démarrer le frontend Flutter sans Firebase
echo "🚀 Démarrage simple du frontend Flutter (sans Firebase)..."

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

cd /home/maxime/BTP/frontend/btp

# Vérifier que Flutter est installé
if ! command -v flutter &> /dev/null; then
    print_error "Flutter n'est pas installé"
    exit 1
fi

# Nettoyer et obtenir les dépendances
print_status "Nettoyage et installation des dépendances..."
flutter clean
flutter pub get

# Démarrer l'application avec la version de développement
print_status "Démarrage de l'application Flutter (version développement)..."
print_warning "Cette version évite Firebase pour éviter les erreurs de configuration"
print_warning "Appuyez sur 'r' pour recharger ou 'q' pour quitter"

flutter run -d linux -t lib/main_dev.dart --verbose

