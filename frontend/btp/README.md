# BTP Multi-Sector Mobile App

Application mobile multi-secteurs d'activités développée avec Flutter pour Android et iOS.

## 🏗️ Secteurs d'Activités

- **Bâtiments et Travaux Publics (BTP)** - Construction, infrastructure, travaux publics
- **Agribusiness** - Agriculture, élevage, transformation alimentaire
- **Exploitation Minière** - Extraction, géologie, ressources naturelles
- **Divers** - Services généraux, consulting, autres secteurs

## 🚀 Fonctionnalités Principales

### Authentification & Sécurité
- Inscription/Connexion avec email et mot de passe
- Authentification biométrique (Touch ID, Face ID, empreinte)
- Gestion des rôles utilisateur (Admin, Manager, Ouvrier, Client, Fournisseur, Investisseur)
- Chiffrement des données sensibles

### Interface Utilisateur
- Design Material 3 avec thèmes clair/sombre
- Interface responsive pour smartphones et tablettes
- Navigation intuitive avec GoRouter
- Animations fluides avec Rive et Lottie

### Fonctionnalités Sectorielles
- **BTP**: Géolocalisation des chantiers, photos géotaggées, suivi des équipes
- **Agribusiness**: Cartographie des parcelles, capteurs IoT, calendrier agricole
- **Mining**: Cartographie géologique 3D, mesures de sécurité, rapports de production
- **Divers**: Modules configurables, e-commerce, CRM mobile

### Services Intégrés
- Géolocalisation haute précision avec PostGIS
- Notifications push Firebase
- Stockage local avec synchronisation
- Paiements mobiles multi-devises
- Chat en temps réel
- Scanner QR/Barcode

## 🛠️ Technologies Utilisées

### Frontend (Flutter)
- **Framework**: Flutter 3.x (Dart)
- **State Management**: Riverpod
- **Navigation**: GoRouter
- **UI**: Material Design 3
- **Animations**: Rive, Lottie
- **Maps**: Google Maps, Mapbox
- **Storage**: Hive, SharedPreferences
- **HTTP**: Dio, Retrofit
- **Notifications**: Firebase Messaging

### Backend (Flask)
- **Framework**: Flask (Python)
- **Database**: PostgreSQL avec PostGIS
- **Cache**: Redis
- **Tasks**: Celery
- **Auth**: JWT
- **API**: REST avec Swagger

## 📱 Installation

### Prérequis
- Flutter SDK 3.10.0+
- Dart 3.0.0+
- Android Studio / Xcode
- Node.js (pour les dépendances)

### Installation des dépendances
```bash
# Installer les dépendances Flutter
flutter pub get

# Générer les fichiers de code
flutter packages pub run build_runner build
```

### Configuration
1. Copier `env.example` vers `.env` et configurer les variables
2. Configurer Firebase pour les notifications
3. Configurer les clés API pour les cartes

### Lancement
```bash
# Mode debug
flutter run

# Mode release
flutter run --release
```

## 🏗️ Architecture

### Structure du Projet
```
lib/
├── core/                    # Code partagé
│   ├── config/             # Configuration
│   ├── models/             # Modèles de données
│   ├── providers/          # Gestion d'état
│   └── services/           # Services
├── features/               # Fonctionnalités
│   ├── auth/              # Authentification
│   ├── home/              # Page d'accueil
│   ├── profile/           # Profil utilisateur
│   ├── sectors/           # Secteurs d'activités
│   ├── btp/               # Module BTP
│   ├── agribusiness/      # Module Agribusiness
│   ├── mining/            # Module Mining
│   ├── divers/            # Module Divers
│   └── common/            # Fonctionnalités communes
└── main.dart              # Point d'entrée
```

### Patterns Utilisés
- **Clean Architecture**: Séparation des couches
- **Feature-First**: Organisation par fonctionnalités
- **Provider Pattern**: Gestion d'état avec Riverpod
- **Repository Pattern**: Abstraction des données
- **Dependency Injection**: Injection de dépendances

## 🔧 Configuration

### Variables d'Environnement
```env
# API
API_BASE_URL=http://localhost:5000/api
API_VERSION=v1

# Firebase
FIREBASE_PROJECT_ID=your-project-id
FIREBASE_API_KEY=your-api-key

# Maps
GOOGLE_MAPS_API_KEY=your-google-maps-key
MAPBOX_ACCESS_TOKEN=your-mapbox-token

# Payments
STRIPE_PUBLISHABLE_KEY=your-stripe-key
```

### Thèmes
Les thèmes sont configurables dans `core/config/theme_config.dart`:
- Couleurs sectorielles
- Thèmes clair/sombre
- Typographie
- Espacements

## 📊 Fonctionnalités Avancées

### Mode Hors-ligne
- Synchronisation automatique des données
- Cache intelligent
- Queue de synchronisation

### Géolocalisation
- Suivi GPS haute précision
- Cartes offline
- Géofencing
- Navigation intégrée

### Notifications
- Push notifications Firebase
- Notifications locales
- Notifications sectorielles
- Gestion des permissions

### Paiements
- Mobile Money (Orange Money, MTN Money)
- Cartes bancaires
- Wallets digitaux
- Multi-devises

## 🧪 Tests

```bash
# Tests unitaires
flutter test

# Tests d'intégration
flutter test integration_test/

# Tests de performance
flutter test --coverage
```

## 🚀 Déploiement

### Android
```bash
# Build APK
flutter build apk --release

# Build App Bundle
flutter build appbundle --release
```

### iOS
```bash
# Build iOS
flutter build ios --release
```

## 📈 Performance

- **Temps de lancement**: < 3 secondes
- **FPS**: 60 FPS garanti
- **Taille APK**: < 50MB
- **Mémoire**: Optimisée pour les appareils bas de gamme

## 🔒 Sécurité

- Chiffrement AES-256 pour les données sensibles
- Certificate Pinning
- OWASP Mobile compliance
- RGPD mobile
- Détection de jailbreak/root

## 🤝 Contribution

1. Fork le projet
2. Créer une branche feature (`git checkout -b feature/AmazingFeature`)
3. Commit les changements (`git commit -m 'Add some AmazingFeature'`)
4. Push vers la branche (`git push origin feature/AmazingFeature`)
5. Ouvrir une Pull Request

## 📄 Licence

Ce projet est sous licence MIT. Voir le fichier `LICENSE` pour plus de détails.

## 📞 Support

Pour toute question ou support:
- Email: support@btp-multisector.com
- Documentation: [docs.btp-multisector.com](https://docs.btp-multisector.com)
- Issues: [GitHub Issues](https://github.com/btp-multisector/mobile/issues)

## 🗺️ Roadmap

### Version 1.1
- [ ] Intégration complète des modules sectoriels
- [ ] Système de messagerie avancé
- [ ] Analytics détaillés
- [ ] Mode hors-ligne complet

### Version 1.2
- [ ] Réalité augmentée pour BTP
- [ ] Intelligence artificielle
- [ ] Support multi-langues
- [ ] Intégrations tierces

### Version 2.0
- [ ] Version web
- [ ] API publique
- [ ] Marketplace
- [ ] Blockchain integration