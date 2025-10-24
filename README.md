# BTP Multi-Sector Mobile Application

Application mobile multiplateforme couvrant quatre secteurs d'activités stratégiques : Bâtiments et Travaux Publics, Agribusiness, Exploitation Minière, et Divers.

## 🏗️ Architecture du Projet

### Backend (Flask + PostgreSQL)
```
backend/
├── app/
│   ├── __init__.py              # Configuration Flask
│   ├── config.py                # Configuration par environnement
│   ├── models/                  # Modèles de données
│   │   ├── common.py           # Modèles de base
│   │   ├── user.py             # Modèles utilisateur
│   │   ├── btp.py              # Modèles BTP
│   │   ├── agribusiness.py     # Modèles Agriculture
│   │   ├── mining.py           # Modèles Mining
│   │   └── divers.py           # Modèles Divers
│   ├── routes/                  # Routes API
│   │   ├── auth.py             # Authentification
│   │   ├── users.py            # Gestion utilisateurs
│   │   ├── btp.py              # API BTP
│   │   ├── agribusiness.py     # API Agriculture
│   │   ├── mining.py           # API Mining
│   │   ├── divers.py           # API Divers
│   │   └── common.py           # API communes
│   ├── services/                # Services métier
│   │   ├── api_service.py      # Service API
│   │   ├── storage_service.py  # Service stockage
│   │   ├── notification_service.py # Notifications
│   │   └── location_service.py # Géolocalisation
│   └── utils/                   # Utilitaires
│       ├── validators.py       # Validateurs
│       └── helpers.py          # Fonctions utilitaires
├── requirements.txt             # Dépendances Python
├── run.py                      # Point d'entrée
└── env.example                 # Variables d'environnement
```

### Frontend (Flutter)
```
mobile/
├── lib/
│   ├── main.dart               # Point d'entrée
│   ├── core/                   # Architecture core
│   │   ├── config/             # Configuration
│   │   ├── models/             # Modèles de données
│   │   ├── providers/          # Gestion d'état
│   │   └── services/           # Services
│   └── features/               # Fonctionnalités
│       ├── auth/               # Authentification
│       ├── home/               # Page d'accueil
│       ├── sectors/            # Secteurs d'activités
│       ├── btp/                # Module BTP
│       ├── agribusiness/       # Module Agriculture
│       ├── mining/             # Module Mining
│       ├── divers/             # Module Divers
│       ├── search/             # Recherche
│       ├── maps/               # Cartes
│       ├── chat/               # Messagerie
│       ├── notifications/      # Notifications
│       ├── profile/            # Profil utilisateur
│       └── settings/           # Paramètres
├── assets/                     # Ressources
└── pubspec.yaml               # Configuration Flutter
```

## 🚀 Installation et Démarrage

### Prérequis
- Python 3.8+
- PostgreSQL 12+ avec PostGIS
- Flutter 3.10+
- Redis (optionnel)
- Node.js (pour les outils de développement)

### Backend

1. **Cloner le projet**
```bash
cd /home/maxime/BTP
```

2. **Créer un environnement virtuel**
```bash
cd backend
python -m venv venv
source venv/bin/activate  # Linux/Mac
# ou
venv\Scripts\activate     # Windows
```

3. **Installer les dépendances**
```bash
pip install -r requirements.txt
```

4. **Configurer PostgreSQL**
```sql
-- Créer la base de données
CREATE DATABASE btp_app;
CREATE EXTENSION postgis;
```

5. **Configurer les variables d'environnement**
```bash
cp env.example .env
# Éditer .env avec vos paramètres
```

6. **Initialiser la base de données**
```bash
flask db init
flask db migrate -m "Initial migration"
flask db upgrade
```

7. **Démarrer le serveur**
```bash
python run.py
```

### Frontend

1. **Installer Flutter**
```bash
# Suivre les instructions officielles Flutter
# https://flutter.dev/docs/get-started/install
```

2. **Installer les dépendances**
```bash
cd mobile
flutter pub get
```

3. **Générer les fichiers de code**
```bash
flutter packages pub run build_runner build
```

4. **Démarrer l'application**
```bash
flutter run
```

## 📱 Fonctionnalités Principales

### 🔐 Authentification
- Inscription/Connexion
- Vérification email
- Réinitialisation mot de passe
- Authentification biométrique
- Connexion sociale (Google, Facebook)

### 🏗️ Module BTP
- Gestion des chantiers
- Suivi des équipes
- Gestion du matériel
- Photos géolocalisées
- Rapports d'avancement

### 🌾 Module Agribusiness
- Gestion des parcelles
- Capteurs IoT
- Suivi des récoltes
- Marketplace agricole
- Calendrier agricole

### ⛏️ Module Mining
- Gestion des gisements
- Suivi des véhicules
- Rapports de production
- Gestion des incidents
- Cartographie 3D

### 💼 Module Divers
- Gestion de projets
- CRM client
- Facturation
- Paiements
- Analytics

### 🗺️ Fonctionnalités Communes
- Géolocalisation
- Recherche avancée
- Notifications push
- Messagerie
- Cartes interactives
- Mode hors-ligne

## 🛠️ Technologies Utilisées

### Backend
- **Flask** - Framework web Python
- **PostgreSQL** - Base de données relationnelle
- **PostGIS** - Extension géospatiale
- **Redis** - Cache et sessions
- **Celery** - Tâches asynchrones
- **JWT** - Authentification
- **SQLAlchemy** - ORM

### Frontend
- **Flutter** - Framework mobile
- **Dart** - Langage de programmation
- **Provider/Riverpod** - Gestion d'état
- **GoRouter** - Navigation
- **Hive** - Stockage local
- **Firebase** - Notifications push
- **Google Maps** - Cartographie

## 📊 Base de Données

### Modèles Principaux

#### Utilisateurs
- `users` - Informations utilisateur
- `user_profiles` - Profils étendus
- `user_sectors` - Spécialisations sectorielles

#### BTP
- `chantiers` - Chantiers de construction
- `equipes` - Équipes de travail
- `materiels` - Matériel et équipements
- `photo_chantiers` - Photos géolocalisées

#### Agribusiness
- `parcelles` - Parcelles agricoles
- `capteurs` - Capteurs IoT
- `recoltes` - Récoltes
- `produits` - Produits marketplace

#### Mining
- `gisements` - Gisements miniers
- `vehicules` - Véhicules miniers
- `productions` - Rapports de production
- `incidents` - Incidents de sécurité

#### Divers
- `projets` - Projets divers
- `clients` - Clients
- `factures` - Factures
- `paiements` - Paiements

## 🔧 Configuration

### Variables d'Environnement Backend
```env
# Flask
FLASK_APP=run.py
FLASK_DEBUG=True
FLASK_HOST=0.0.0.0
FLASK_PORT=5000

# Database
DATABASE_URL=postgresql://user:password@localhost:5432/btp_app

# Security
SECRET_KEY=your-secret-key
JWT_SECRET_KEY=your-jwt-secret

# Redis
REDIS_HOST=localhost
REDIS_PORT=6379

# Firebase
FIREBASE_CREDENTIALS_PATH=path/to/credentials.json

# Email
MAIL_SERVER=smtp.gmail.com
MAIL_PORT=587
MAIL_USERNAME=your-email@gmail.com
MAIL_PASSWORD=your-app-password
```

### Configuration Flutter
```yaml
# pubspec.yaml
dependencies:
  flutter:
    sdk: flutter
  # ... autres dépendances
```

## 🚀 Déploiement

### Backend (Production)
1. **Serveur Ubuntu/CentOS**
2. **Nginx** - Reverse proxy
3. **Gunicorn** - Serveur WSGI
4. **PostgreSQL** - Base de données
5. **Redis** - Cache
6. **SSL/TLS** - Certificats

### Frontend (Production)
1. **Android** - Google Play Store
2. **iOS** - Apple App Store
3. **CI/CD** - GitHub Actions
4. **Code Signing** - Certificats

## 📱 Captures d'Écran

*À ajouter lors du développement*

## 🤝 Contribution

1. Fork le projet
2. Créer une branche feature (`git checkout -b feature/AmazingFeature`)
3. Commit les changements (`git commit -m 'Add some AmazingFeature'`)
4. Push vers la branche (`git push origin feature/AmazingFeature`)
5. Ouvrir une Pull Request

## 📄 Licence

Ce projet est sous licence MIT. Voir le fichier `LICENSE` pour plus de détails.

## 📞 Support

Pour toute question ou problème :
- Email : support@btp-multisector.com
- Documentation : [docs.btp-multisector.com](https://docs.btp-multisector.com)
- Issues : [GitHub Issues](https://github.com/btp-multisector/issues)

## 🗺️ Roadmap

### Phase 1 (Q1 2024)
- [x] Architecture backend
- [x] Modèles de données
- [x] API de base
- [x] Authentification
- [ ] Interface mobile de base

### Phase 2 (Q2 2024)
- [ ] Modules sectoriels complets
- [ ] Géolocalisation avancée
- [ ] Notifications push
- [ ] Mode hors-ligne

### Phase 3 (Q3 2024)
- [ ] Analytics avancées
- [ ] Intégrations tierces
- [ ] Optimisations performance
- [ ] Tests complets

### Phase 4 (Q4 2024)
- [ ] Déploiement production
- [ ] Formation utilisateurs
- [ ] Support client
- [ ] Évolutions futures

---

**Développé avec ❤️ pour l'Afrique et le monde**
# BTP
