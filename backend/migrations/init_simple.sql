-- Initialisation simple de la base de données BTP Multi-Sector

-- Activer l'extension PostGIS
CREATE EXTENSION IF NOT EXISTS postgis;

-- Table des utilisateurs
CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    email VARCHAR(120) UNIQUE NOT NULL,
    phone VARCHAR(20) UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    username VARCHAR(50) UNIQUE,
    is_verified BOOLEAN DEFAULT FALSE,
    is_active BOOLEAN DEFAULT TRUE,
    last_login TIMESTAMP,
    role VARCHAR(20) DEFAULT 'client',
    device_token TEXT,
    platform VARCHAR(20),
    app_version VARCHAR(20),
    latitude FLOAT,
    longitude FLOAT,
    address TEXT,
    city VARCHAR(100),
    country VARCHAR(100),
    postal_code VARCHAR(20),
    location GEOMETRY(POINT, 4326),
    metadata JSONB,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Table des profils utilisateur
CREATE TABLE IF NOT EXISTS user_profiles (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    bio TEXT,
    avatar_url TEXT,
    birth_date DATE,
    gender VARCHAR(20),
    company VARCHAR(100),
    job_title VARCHAR(100),
    experience_years INTEGER,
    skills TEXT,
    certifications TEXT,
    email_notifications BOOLEAN DEFAULT TRUE,
    push_notifications BOOLEAN DEFAULT TRUE,
    sms_notifications BOOLEAN DEFAULT FALSE,
    language VARCHAR(10) DEFAULT 'fr',
    timezone VARCHAR(50) DEFAULT 'UTC',
    currency VARCHAR(3) DEFAULT 'XOF',
    metadata JSONB,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Table des secteurs utilisateur
CREATE TABLE IF NOT EXISTS user_sectors (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    sector VARCHAR(20) NOT NULL,
    specialization VARCHAR(100),
    experience_level VARCHAR(20),
    hourly_rate DECIMAL(10,2),
    availability VARCHAR(20),
    service_radius INTEGER DEFAULT 50,
    is_available BOOLEAN DEFAULT TRUE,
    latitude FLOAT,
    longitude FLOAT,
    address TEXT,
    city VARCHAR(100),
    country VARCHAR(100),
    postal_code VARCHAR(20),
    location GEOMETRY(POINT, 4326),
    metadata JSONB,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Créer les index pour améliorer les performances
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_users_phone ON users(phone);
CREATE INDEX IF NOT EXISTS idx_users_location ON users USING GIST(location);

-- Insérer des données de test
INSERT INTO users (email, password_hash, first_name, last_name, role, is_verified) VALUES
('admin@btp.com', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewdBPj4J/8QzKz2', 'Admin', 'System', 'admin', true),
('manager@btp.com', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewdBPj4J/8QzKz2', 'Manager', 'Test', 'manager', true),
('worker@btp.com', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewdBPj4J/8QzKz2', 'Worker', 'Test', 'worker', true);

-- Créer les profils pour les utilisateurs de test
INSERT INTO user_profiles (user_id, bio, company, job_title, experience_years) VALUES
(1, 'Administrateur système', 'BTP Multi-Sector', 'Administrateur', 5),
(2, 'Manager de projet', 'BTP Multi-Sector', 'Chef de projet', 3),
(3, 'Ouvrier spécialisé', 'BTP Multi-Sector', 'Ouvrier', 2);
