from datetime import datetime
from werkzeug.security import generate_password_hash, check_password_hash
from app import db
from .common import BaseModel, LocationMixin, MetadataMixin
from sqlalchemy import Column, String, Text, Boolean, Integer, ForeignKey, Enum, DateTime
import enum

class UserRole(enum.Enum):
    ADMIN = "admin"
    MANAGER = "manager"
    WORKER = "worker"
    CLIENT = "client"
    SUPPLIER = "supplier"
    INVESTOR = "investor"

class SectorType(enum.Enum):
    BTP = "btp"
    AGRIBUSINESS = "agribusiness"
    MINING = "mining"
    DIVERS = "divers"

class User(BaseModel, LocationMixin, MetadataMixin):
    """User model for authentication and basic info"""
    __tablename__ = 'users'
    
    # Basic info
    email = Column(String(120), unique=True, nullable=False, index=True)
    phone = Column(String(20), unique=True, nullable=True, index=True)
    password_hash = Column(String(255), nullable=False)
    
    # Profile info
    first_name = Column(String(50), nullable=False)
    last_name = Column(String(50), nullable=False)
    username = Column(String(50), unique=True, nullable=True)
    
    # Authentication
    is_verified = Column(Boolean, default=False, nullable=False)
    is_active = Column(Boolean, default=True, nullable=False)
    last_login = Column(DateTime, nullable=True)
    
    # Role and permissions
    role = Column(Enum(UserRole), default=UserRole.CLIENT, nullable=False)
    
    # Device info for mobile
    device_token = Column(Text, nullable=True)
    platform = Column(String(20), nullable=True)  # android, ios
    app_version = Column(String(20), nullable=True)
    
    # Relationships
    profile = db.relationship('UserProfile', backref='user', uselist=False, cascade='all, delete-orphan')
    sectors = db.relationship('UserSector', backref='user', lazy='dynamic', cascade='all, delete-orphan')
    
    def set_password(self, password):
        """Hash and set password"""
        self.password_hash = generate_password_hash(password)
    
    def check_password(self, password):
        """Check password against hash"""
        return check_password_hash(self.password_hash, password)
    
    def to_dict(self, include_sensitive=False):
        """Convert user to dictionary"""
        data = {
            'id': self.id,
            'email': self.email,
            'phone': self.phone,
            'first_name': self.first_name,
            'last_name': self.last_name,
            'username': self.username,
            'role': self.role.value if self.role else None,
            'is_verified': self.is_verified,
            'is_active': self.is_active,
            'created_at': self.created_at.isoformat() if self.created_at else None,
            'last_login': self.last_login.isoformat() if self.last_login else None,
            'location': self.get_location_dict(),
            'metadata': self.metadata if isinstance(self.metadata, dict) else {}
        }
        
        if include_sensitive:
            data.update({
                'device_token': self.device_token,
                'platform': self.platform,
                'app_version': self.app_version
            })
        
        return data

class UserProfile(BaseModel, MetadataMixin):
    """Extended user profile information"""
    __tablename__ = 'user_profiles'
    
    user_id = Column(Integer, ForeignKey('users.id'), nullable=False)
    
    # Personal info
    bio = Column(Text, nullable=True)
    avatar_url = Column(Text, nullable=True)
    birth_date = Column(db.Date, nullable=True)
    gender = Column(String(20), nullable=True)
    
    # Professional info
    company = Column(String(100), nullable=True)
    job_title = Column(String(100), nullable=True)
    experience_years = Column(Integer, nullable=True)
    skills = Column(Text, nullable=True)  # JSON array of skills
    certifications = Column(Text, nullable=True)  # JSON array of certifications
    
    # Contact preferences
    email_notifications = Column(Boolean, default=True, nullable=False)
    push_notifications = Column(Boolean, default=True, nullable=False)
    sms_notifications = Column(Boolean, default=False, nullable=False)
    
    # Language and region
    language = Column(String(10), default='fr', nullable=False)
    timezone = Column(String(50), default='UTC', nullable=False)
    currency = Column(String(3), default='XOF', nullable=False)
    
    def to_dict(self):
        """Convert profile to dictionary"""
        return {
            'id': self.id,
            'user_id': self.user_id,
            'bio': self.bio,
            'avatar_url': self.avatar_url,
            'birth_date': self.birth_date.isoformat() if self.birth_date else None,
            'gender': self.gender,
            'company': self.company,
            'job_title': self.job_title,
            'experience_years': self.experience_years,
            'skills': self.skills,
            'certifications': self.certifications,
            'email_notifications': self.email_notifications,
            'push_notifications': self.push_notifications,
            'sms_notifications': self.sms_notifications,
            'language': self.language,
            'timezone': self.timezone,
            'currency': self.currency,
            'metadata': self.metadata if isinstance(self.metadata, dict) else {},
            'created_at': self.created_at.isoformat() if self.created_at else None,
            'updated_at': self.updated_at.isoformat() if self.updated_at else None
        }

class UserSector(BaseModel, LocationMixin, MetadataMixin):
    """User sector specialization and location"""
    __tablename__ = 'user_sectors'
    
    user_id = Column(Integer, ForeignKey('users.id'), nullable=False)
    sector = Column(Enum(SectorType), nullable=False)
    
    # Sector-specific info
    specialization = Column(String(100), nullable=True)
    experience_level = Column(String(20), nullable=True)  # beginner, intermediate, expert
    hourly_rate = Column(db.Numeric(10, 2), nullable=True)
    availability = Column(String(20), nullable=True)  # full-time, part-time, freelance
    
    # Service area
    service_radius = Column(Integer, default=50, nullable=False)  # km
    is_available = Column(Boolean, default=True, nullable=False)
    
    def to_dict(self):
        """Convert user sector to dictionary"""
        return {
            'id': self.id,
            'user_id': self.user_id,
            'sector': self.sector.value if self.sector else None,
            'specialization': self.specialization,
            'experience_level': self.experience_level,
            'hourly_rate': float(self.hourly_rate) if self.hourly_rate else None,
            'availability': self.availability,
            'service_radius': self.service_radius,
            'is_available': self.is_available,
            'location': self.get_location_dict(),
            'metadata': self.metadata if isinstance(self.metadata, dict) else {},
            'created_at': self.created_at.isoformat() if self.created_at else None,
            'updated_at': self.updated_at.isoformat() if self.updated_at else None
        }
