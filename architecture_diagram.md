# Architecture du Projet BTP Multi-Sector

## Vue d'ensemble de l'architecture

```mermaid
graph TB
    subgraph "Frontend (Flutter)"
        A[App Flutter] --> B[Core Layer]
        B --> C[Features Layer]
        C --> D[Presentation Layer]
        
        B --> B1[Config]
        B --> B2[Models]
        B --> B3[Providers]
        B --> B4[Services]
        
        C --> C1[Auth]
        C --> C2[Home]
        C --> C3[BTP]
        C --> C4[Agribusiness]
        C --> C5[Mining]
        C --> C6[Divers]
        C --> C7[Common]
        
        D --> D1[Pages]
        D --> D2[Widgets]
    end
    
    subgraph "Backend (Flask)"
        E[Flask App] --> F[Routes]
        E --> G[Models]
        E --> H[Utils]
        
        F --> F1[Auth Routes]
        F --> F2[BTP Routes]
        F --> F3[Agribusiness Routes]
        F --> F4[Mining Routes]
        F --> F5[Divers Routes]
        F --> F6[Common Routes]
        
        G --> G1[User Models]
        G --> G2[BTP Models]
        G --> G3[Agribusiness Models]
        G --> G4[Mining Models]
        G --> G5[Divers Models]
        G --> G6[Common Models]
    end
    
    subgraph "Base de Données"
        I[(PostgreSQL)]
        I --> I1[PostGIS Extension]
        I --> I2[Users Tables]
        I --> I3[BTP Tables]
        I --> I4[Agribusiness Tables]
        I --> I5[Mining Tables]
        I --> I6[Divers Tables]
    end
    
    subgraph "Services Externes"
        J[Redis Cache]
        K[Firebase]
        L[Google Maps]
        M[Stripe Payments]
    end
    
    A --> E
    E --> I
    E --> J
    A --> K
    A --> L
    A --> M
```

## Architecture détaillée du Backend

```mermaid
graph LR
    subgraph "Flask Application"
        A[app/__init__.py] --> B[Configuration]
        A --> C[Database]
        A --> D[JWT]
        A --> E[CORS]
        
        F[Routes] --> F1[auth.py]
        F --> F2[btp.py]
        F --> F3[agribusiness.py]
        F --> F4[mining.py]
        F --> F5[divers.py]
        F --> F6[common.py]
        
        G[Models] --> G1[user.py]
        G --> G2[btp.py]
        G --> G3[agribusiness.py]
        G --> G4[mining.py]
        G --> G5[divers.py]
        G --> G6[common.py]
        
        H[Utils] --> H1[helpers.py]
        H --> H2[validators.py]
    end
```

## Architecture détaillée du Frontend

```mermaid
graph TB
    subgraph "Flutter Application"
        A[main.dart] --> B[Core Layer]
        B --> C[Features Layer]
        
        B --> B1[Config]
        B1 --> B11[app_config.dart]
        B1 --> B12[theme_config.dart]
        B1 --> B13[route_config.dart]
        
        B --> B2[Models]
        B2 --> B21[user_model.dart]
        
        B --> B3[Providers]
        B3 --> B31[auth_provider.dart]
        B3 --> B32[theme_provider.dart]
        B3 --> B33[language_provider.dart]
        
        B --> B4[Services]
        B4 --> B41[api_service.dart]
        B4 --> B42[storage_service.dart]
        B4 --> B43[location_service.dart]
        B4 --> B44[notification_service.dart]
        
        C --> C1[Auth Feature]
        C1 --> C11[login_page.dart]
        C1 --> C12[register_page.dart]
        C1 --> C13[forgot_password_page.dart]
        
        C --> C2[Home Feature]
        C2 --> C21[home_page.dart]
        C2 --> C22[splash_page.dart]
        
        C --> C3[BTP Feature]
        C3 --> C31[btp_home_page.dart]
        
        C --> C4[Agribusiness Feature]
        C4 --> C41[agribusiness_home_page.dart]
        
        C --> C5[Mining Feature]
        C5 --> C51[mining_home_page.dart]
        
        C --> C6[Divers Feature]
        C6 --> C61[divers_home_page.dart]
        
        C --> C7[Common Features]
        C7 --> C71[search_page.dart]
        C7 --> C72[maps_page.dart]
        C7 --> C73[chat_page.dart]
        C7 --> C74[profile_page.dart]
    end
```

## Flux de données

```mermaid
sequenceDiagram
    participant U as User
    participant F as Flutter App
    participant B as Flask Backend
    participant D as PostgreSQL
    participant R as Redis
    participant E as External Services
    
    U->>F: User Action
    F->>B: API Request
    B->>D: Database Query
    D-->>B: Data Response
    B->>R: Cache Data
    B-->>F: API Response
    F->>E: External Service Call
    E-->>F: Service Response
    F-->>U: UI Update
```

## Modèles de données principaux

```mermaid
erDiagram
    User ||--o{ UserProfile : has
    User ||--o{ UserSector : has
    User ||--o{ Chantier : manages
    User ||--o{ Equipe : member_of
    User ||--o{ Parcelle : owns
    User ||--o{ Gisement : owns
    User ||--o{ Projet : manages
    User ||--o{ Client : manages
    
    Chantier ||--o{ Equipe : has
    Chantier ||--o{ Materiel : has
    Chantier ||--o{ PhotoChantier : has
    
    Parcelle ||--o{ Capteur : has
    Parcelle ||--o{ Recolte : has
    Parcelle ||--o{ Produit : produces
    
    Gisement ||--o{ Vehicule : has
    Gisement ||--o{ Production : has
    Gisement ||--o{ Incident : has
    
    Projet ||--o{ Facture : generates
    Client ||--o{ Projet : has
    Client ||--o{ Facture : receives
    Facture ||--o{ Paiement : has
```

## Technologies utilisées

### Backend
- **Flask** : Framework web Python
- **PostgreSQL** : Base de données relationnelle
- **PostGIS** : Extension géospatiale
- **Redis** : Cache et sessions
- **Celery** : Tâches asynchrones
- **JWT** : Authentification
- **SQLAlchemy** : ORM

### Frontend
- **Flutter** : Framework mobile
- **Dart** : Langage de programmation
- **Riverpod** : Gestion d'état
- **GoRouter** : Navigation
- **Hive** : Stockage local
- **Firebase** : Notifications push
- **Google Maps** : Cartographie

### Services externes
- **Firebase** : Notifications push
- **Google Maps** : Cartographie
- **Stripe** : Paiements
- **Redis** : Cache

