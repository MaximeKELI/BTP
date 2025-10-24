#!/bin/bash

# Script pour reset la base de données
echo "🗑️ Reset de la base de données BTP Multi-Sector..."

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

# Demander confirmation
read -p "Êtes-vous sûr de vouloir reset la base de données ? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    print_warning "Annulé par l'utilisateur"
    exit 1
fi

# Supprimer les bases de données existantes
print_status "Suppression des bases de données existantes..."
sudo -u postgres psql -c "DROP DATABASE IF EXISTS btp_app;" 2>/dev/null
sudo -u postgres psql -c "DROP DATABASE IF EXISTS btp_app_dev;" 2>/dev/null

# Recréer les bases de données
print_status "Création des nouvelles bases de données..."
sudo -u postgres psql -c "CREATE DATABASE btp_app;"
sudo -u postgres psql -c "CREATE DATABASE btp_app_dev;"

# Créer l'utilisateur s'il n'existe pas
print_status "Création de l'utilisateur de base de données..."
sudo -u postgres psql -c "CREATE USER btp_user WITH PASSWORD 'btp_password';" 2>/dev/null || print_warning "Utilisateur btp_user existe déjà"

# Donner les permissions
print_status "Attribution des permissions..."
sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE btp_app TO btp_user;"
sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE btp_app_dev TO btp_user;"

# Exécuter le script d'initialisation
print_status "Exécution du script d'initialisation..."
sudo -u postgres psql -d btp_app -f /home/maxime/BTP/backend/migrations/init.sql

# Copier la structure vers la base de dev
print_status "Copie vers la base de données de développement..."
sudo -u postgres psql -d btp_app_dev -f /home/maxime/BTP/backend/migrations/init.sql

print_success "Base de données resetée avec succès!"
print_status "Bases de données créées :"
print_status "- btp_app (production)"
print_status "- btp_app_dev (développement)"
print_status "Utilisateur : btp_user"
print_status "Mot de passe : btp_password"

