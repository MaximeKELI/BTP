# 🚀 Guide de Développement Local - BTP Multi-Sector

## 📋 Prérequis

- **Python 3.8+** avec pip
- **Flutter 3.10+** avec Dart 3.0+
- **PostgreSQL 12+** avec PostGIS
- **Redis** (optionnel pour le développement)
- **Git**

## ⚡ Démarrage Rapide

### Option 1 : Configuration Automatique (Recommandé)

```bash
# 1. Cloner le projet
git clone <repository-url>
cd BTP

# 2. Configuration automatique
./scripts/setup_dev.sh

# 3. Validation
./scripts/validate_local.sh

# 4. Démarrer l'environnement
./scripts/start_all.sh
```

### Option 2 : Configuration Manuelle

#### Backend

```bash
cd backend

# 1. Créer l'environnement virtuel
python3 -m venv venv
source venv/bin/activate

# 2. Installer les dépendances
pip install -r requirements.txt

# 3. Configurer l'environnement
cp env.example .env
# Éditer .env avec vos paramètres

# 4. Configurer la base de données
sudo -u postgres psql -c "CREATE DATABASE btp_app;"
sudo -u postgres psql -c "CREATE DATABASE btp_app_dev;"
sudo -u postgres psql -c "CREATE USER btp_user WITH PASSWORD 'btp_password';"
sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE btp_app TO btp_user;"
sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE btp_app_dev TO btp_user;"

# 5. Initialiser la base de données
sudo -u postgres psql -d btp_app -f migrations/init.sql

# 6. Démarrer le serveur
python run.py
```

#### Frontend

```bash
cd frontend/btp

# 1. Installer les dépendances
flutter pub get

# 2. Configurer l'environnement
touch .env
# Éditer .env avec vos paramètres

# 3. Nettoyer les imports
dart fix --apply

# 4. Démarrer l'application
flutter run
```

## 🐳 Développement avec Docker

```bash
# Démarrer tous les services
./scripts/start_docker.sh

# Voir les logs
docker-compose -f docker-compose.dev.yml logs -f

# Arrêter les services
docker-compose -f docker-compose.dev.yml down
```

## 🧪 Tests

### Tests Flutter

```bash
cd frontend/btp
flutter test
flutter analyze
```

### Tests Backend

```bash
cd backend
source venv/bin/activate
python -m pytest tests/ -v --cov=app
```

### Tous les tests

```bash
./scripts/run_tests.sh
```

## 🔧 Scripts Utiles

| Script | Description |
|--------|-------------|
| `./scripts/setup_dev.sh` | Configuration automatique de l'environnement |
| `./scripts/validate_local.sh` | Validation complète de l'environnement |
| `./scripts/start_backend.sh` | Démarrer le backend |
| `./scripts/start_frontend.sh` | Démarrer le frontend |
| `./scripts/start_all.sh` | Démarrer backend + frontend |
| `./scripts/start_docker.sh` | Démarrer avec Docker |
| `./scripts/reset_db.sh` | Reset de la base de données |
| `./scripts/run_tests.sh` | Exécuter tous les tests |
| `./scripts/clean_imports.sh` | Nettoyer les imports Flutter |

## 📁 Structure du Projet

```
BTP/
├── backend/                 # API Flask
│   ├── app/                # Code source
│   ├── migrations/         # Scripts de base de données
│   ├── tests/              # Tests backend
│   ├── requirements.txt    # Dépendances Python
│   └── run.py             # Point d'entrée
├── frontend/btp/           # Application Flutter
│   ├── lib/               # Code source
│   ├── test/              # Tests Flutter
│   └── pubspec.yaml       # Dépendances Flutter
├── scripts/               # Scripts de développement
├── docker-compose.dev.yml # Configuration Docker
└── DEVELOPMENT.md         # Ce fichier
```

## 🔧 Configuration

### Variables d'Environnement Backend

```env
# backend/.env
FLASK_APP=run.py
FLASK_DEBUG=True
FLASK_HOST=0.0.0.0
FLASK_PORT=5000

DATABASE_URL=postgresql://btp_user:btp_password@localhost:5432/btp_app
DEV_DATABASE_URL=postgresql://btp_user:btp_password@localhost:5432/btp_app_dev

SECRET_KEY=your-secret-key-here
JWT_SECRET_KEY=your-jwt-secret-key-here

REDIS_HOST=localhost
REDIS_PORT=6379
```

### Variables d'Environnement Frontend

```env
# frontend/btp/.env
API_BASE_URL=http://localhost:5000/api
API_VERSION=v1

FIREBASE_PROJECT_ID=your-project-id
GOOGLE_MAPS_API_KEY=your-google-maps-key
```

## 🐛 Dépannage

### Problèmes Courants

1. **Erreur de connexion à la base de données**
   ```bash
   # Vérifier que PostgreSQL est démarré
   sudo systemctl start postgresql
   
   # Vérifier les permissions
   sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE btp_app TO btp_user;"
   ```

2. **Erreur Flutter "Target of URI doesn't exist"**
   ```bash
   cd frontend/btp
   flutter clean
   flutter pub get
   dart fix --apply
   ```

3. **Erreur d'imports inutilisés**
   ```bash
   cd frontend/btp
   dart fix --apply
   flutter analyze
   ```

4. **Problème de permissions Docker**
   ```bash
   sudo usermod -aG docker $USER
   # Redémarrer la session
   ```

### Logs et Debug

```bash
# Backend
cd backend
source venv/bin/activate
python run.py --debug

# Frontend
cd frontend/btp
flutter run --verbose

# Docker
docker-compose -f docker-compose.dev.yml logs -f
```

## 📊 Monitoring

### Backend
- **API**: http://localhost:5000
- **Health Check**: http://localhost:5000/health
- **Logs**: `tail -f backend/logs/app.log`

### Frontend
- **App**: Flutter app sur émulateur/appareil
- **Debug Console**: Voir la console Flutter

### Base de Données
```bash
# Connexion PostgreSQL
psql -h localhost -U btp_user -d btp_app

# Voir les tables
\dt

# Voir les données
SELECT * FROM users LIMIT 5;
```

## 🚀 Prochaines Étapes

1. **Développement** : Commencer à développer les nouvelles fonctionnalités
2. **Tests** : Ajouter plus de tests unitaires et d'intégration
3. **Documentation** : Documenter les APIs avec Swagger
4. **CI/CD** : Configurer GitHub Actions
5. **Production** : Préparer le déploiement

## 🤝 Contribution

1. Fork le projet
2. Créer une branche feature (`git checkout -b feature/AmazingFeature`)
3. Commit les changements (`git commit -m 'Add some AmazingFeature'`)
4. Push vers la branche (`git push origin feature/AmazingFeature`)
5. Ouvrir une Pull Request

## 📞 Support

- **Documentation** : Voir les README dans chaque dossier
- **Issues** : Créer une issue sur GitHub
- **Email** : support@btp-multisector.com

---

**🎉 Votre environnement de développement local est maintenant parfait !**
