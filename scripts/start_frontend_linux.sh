#!/bin/bash

# Script pour démarrer le frontend Flutter sur Linux
echo "🚀 Démarrage du frontend Flutter sur Linux..."

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

# Vérifier les appareils disponibles
print_status "Vérification des appareils disponibles..."
flutter devices

# Démarrer l'application
print_status "Démarrage de l'application Flutter..."
print_warning "Si l'interface est noire, c'est normal - l'application se charge..."
print_warning "Appuyez sur 'r' pour recharger ou 'q' pour quitter"

flutter run -d linux --verbose

