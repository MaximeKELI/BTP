#!/bin/bash

# Script de configuration pour l'environnement de développement
echo "🚀 Configuration de l'environnement de développement BTP Multi-Sector..."

# Couleurs pour les messages
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Fonction pour afficher les messages colorés
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

# Vérifier les prérequis
print_status "Vérification des prérequis..."

# Vérifier Python
if ! command -v python3 &> /dev/null; then
    print_error "Python 3 n'est pas installé"
    exit 1
fi

# Vérifier Flutter
if ! command -v flutter &> /dev/null; then
    print_error "Flutter n'est pas installé"
    exit 1
fi

# Vérifier PostgreSQL
if ! command -v psql &> /dev/null; then
    print_error "PostgreSQL n'est pas installé"
    exit 1
fi

# Vérifier Redis
if ! command -v redis-server &> /dev/null; then
    print_warning "Redis n'est pas installé - optionnel pour le développement"
fi

print_success "Prérequis vérifiés"

# Configuration du backend
print_status "Configuration du backend..."

cd /home/maxime/BTP/backend

# Créer l'environnement virtuel Python
if [ ! -d "venv" ]; then
    print_status "Création de l'environnement virtuel Python..."
    python3 -m venv venv
fi

# Activer l'environnement virtuel
print_status "Activation de l'environnement virtuel..."
source venv/bin/activate

# Installer les dépendances
print_status "Installation des dépendances Python..."
pip install -r requirements.txt

# Créer le fichier .env s'il n'existe pas
if [ ! -f ".env" ]; then
    print_status "Création du fichier .env..."
    cp env.example .env
    print_warning "N'oubliez pas de configurer les variables d'environnement dans .env"
fi

# Créer les dossiers nécessaires
mkdir -p uploads
mkdir -p logs
mkdir -p instance

print_success "Backend configuré"

# Configuration du frontend
print_status "Configuration du frontend..."

cd /home/maxime/BTP/frontend/btp

# Installer les dépendances Flutter
print_status "Installation des dépendances Flutter..."
flutter pub get

# Créer le fichier .env s'il n'existe pas
if [ ! -f ".env" ]; then
    print_status "Création du fichier .env Flutter..."
    touch .env
    print_warning "N'oubliez pas de configurer les variables d'environnement dans .env"
fi

# Nettoyer les imports inutilisés
print_status "Nettoyage des imports inutilisés..."
dart fix --apply

print_success "Frontend configuré"

# Configuration de la base de données
print_status "Configuration de la base de données..."

# Créer la base de données PostgreSQL
sudo -u postgres psql -c "CREATE DATABASE btp_app;" 2>/dev/null || print_warning "Base de données btp_app existe déjà"
sudo -u postgres psql -c "CREATE DATABASE btp_app_dev;" 2>/dev/null || print_warning "Base de données btp_app_dev existe déjà"

# Créer l'utilisateur de la base de données
sudo -u postgres psql -c "CREATE USER btp_user WITH PASSWORD 'btp_password';" 2>/dev/null || print_warning "Utilisateur btp_user existe déjà"
sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE btp_app TO btp_user;" 2>/dev/null
sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE btp_app_dev TO btp_user;" 2>/dev/null

# Installer l'extension PostGIS
sudo -u postgres psql -d btp_app -c "CREATE EXTENSION IF NOT EXISTS postgis;" 2>/dev/null
sudo -u postgres psql -d btp_app_dev -c "CREATE EXTENSION IF NOT EXISTS postgis;" 2>/dev/null

print_success "Base de données configurée"

# Créer les scripts de démarrage
print_status "Création des scripts de démarrage..."

# Script de démarrage du backend
cat > /home/maxime/BTP/scripts/start_backend.sh << 'EOF'
#!/bin/bash
cd /home/maxime/BTP/backend
source venv/bin/activate
export FLASK_APP=run.py
export FLASK_ENV=development
python run.py
EOF

# Script de démarrage du frontend
cat > /home/maxime/BTP/scripts/start_frontend.sh << 'EOF'
#!/bin/bash
cd /home/maxime/BTP/frontend/btp
flutter run
EOF

# Script de démarrage complet
cat > /home/maxime/BTP/scripts/start_all.sh << 'EOF'
#!/bin/bash
# Démarrer Redis en arrière-plan
redis-server --daemonize yes

# Démarrer le backend en arrière-plan
cd /home/maxime/BTP/backend
source venv/bin/activate
export FLASK_APP=run.py
export FLASK_ENV=development
python run.py &
BACKEND_PID=$!

# Attendre que le backend démarre
sleep 5

# Démarrer le frontend
cd /home/maxime/BTP/frontend/btp
flutter run

# Nettoyer les processus en arrière-plan
trap "kill $BACKEND_PID" EXIT
EOF

# Rendre les scripts exécutables
chmod +x /home/maxime/BTP/scripts/*.sh

print_success "Scripts de démarrage créés"

# Afficher les instructions finales
echo ""
echo "🎉 Configuration terminée avec succès!"
echo ""
echo "📋 Prochaines étapes :"
echo "1. Configurez les variables d'environnement dans backend/.env"
echo "2. Configurez les variables d'environnement dans frontend/btp/.env"
echo "3. Démarrez Redis : redis-server"
echo "4. Démarrez le backend : ./scripts/start_backend.sh"
echo "5. Démarrez le frontend : ./scripts/start_frontend.sh"
echo "   ou utilisez : ./scripts/start_all.sh pour tout démarrer"
echo ""
echo "🔧 Commandes utiles :"
echo "- Nettoyer les imports : ./scripts/clean_imports.sh"
echo "- Tests Flutter : cd frontend/btp && flutter test"
echo "- Tests Backend : cd backend && python -m pytest"
echo ""

