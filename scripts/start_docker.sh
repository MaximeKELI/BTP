#!/bin/bash

# Script pour démarrer l'environnement de développement avec Docker
echo "🐳 Démarrage de l'environnement de développement avec Docker..."

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

# Vérifier si Docker est installé
if ! command -v docker &> /dev/null; then
    print_error "Docker n'est pas installé"
    exit 1
fi

if ! command -v docker-compose &> /dev/null; then
    print_error "Docker Compose n'est pas installé"
    exit 1
fi

# Arrêter les conteneurs existants
print_status "Arrêt des conteneurs existants..."
docker-compose -f docker-compose.dev.yml down

# Construire et démarrer les services
print_status "Construction et démarrage des services..."
docker-compose -f docker-compose.dev.yml up --build -d

# Attendre que les services soient prêts
print_status "Attente du démarrage des services..."
sleep 10

# Vérifier le statut des services
print_status "Vérification du statut des services..."
docker-compose -f docker-compose.dev.yml ps

# Afficher les logs
print_status "Affichage des logs..."
docker-compose -f docker-compose.dev.yml logs --tail=20

print_success "Environnement de développement démarré!"
echo ""
echo "📋 Services disponibles :"
echo "- Backend API: http://localhost:5000"
echo "- PostgreSQL: localhost:5432"
echo "- Redis: localhost:6379"
echo ""
echo "🔧 Commandes utiles :"
echo "- Voir les logs: docker-compose -f docker-compose.dev.yml logs -f"
echo "- Arrêter: docker-compose -f docker-compose.dev.yml down"
echo "- Redémarrer: docker-compose -f docker-compose.dev.yml restart"
echo ""
echo "📱 Pour démarrer le frontend Flutter :"
echo "cd frontend/btp && flutter run"
