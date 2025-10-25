from datetime import datetime
from sqlalchemy import Column, Integer, String, Float, Boolean, DateTime, Text, ForeignKey, Enum as SQLEnum, JSON
from sqlalchemy.orm import relationship
from .common import BaseModel, LocationMixin
import enum

class WorkerStatus(enum.Enum):
    AVAILABLE = "available"
    BUSY = "busy"
    OFFLINE = "offline"
    SUSPENDED = "suspended"

class WorkerType(enum.Enum):
    MASON = "mason"
    CARPENTER = "carpenter"
    ELECTRICIAN = "electrician"
    PLUMBER = "plumber"
    PAINTER = "painter"
    WELDER = "welder"
    LABORER = "laborer"
    ARCHITECT = "architect"
    ENGINEER = "engineer"
    OTHER = "other"

class Worker(BaseModel, LocationMixin):
    """Modèle pour les ouvriers/artisans"""
    __tablename__ = 'workers'
    
    # Informations personnelles
    user_id = Column(Integer, ForeignKey('users.id'), nullable=False, unique=True)
    first_name = Column(String(100), nullable=False)
    last_name = Column(String(100), nullable=False)
    phone = Column(String(20), nullable=False)
    email = Column(String(255), nullable=False)
    avatar_url = Column(String(500))
    
    # Informations professionnelles
    worker_type = Column(SQLEnum(WorkerType), nullable=False)
    specializations = Column(JSON, default=list)  # Liste des spécialisations
    skills = Column(JSON, default=list)  # Compétences techniques
    experience_years = Column(Integer, default=0)
    hourly_rate = Column(Float, nullable=False)  # Tarif horaire
    daily_rate = Column(Float)  # Tarif journalier
    description = Column(Text)
    
    # Statut et disponibilité
    status = Column(SQLEnum(WorkerStatus), default=WorkerStatus.AVAILABLE)
    is_available = Column(Boolean, default=True)
    availability_schedule = Column(JSON)  # Planning de disponibilité
    
    # Évaluations et réputation
    rating = Column(Float, default=0.0)  # Note moyenne (0-5)
    total_reviews = Column(Integer, default=0)
    completed_projects = Column(Integer, default=0)
    
    # Documents et certifications
    certifications = Column(JSON, default=list)
    portfolio_images = Column(JSON, default=list)
    identity_document = Column(String(500))  # URL du document d'identité
    
    # Informations bancaires (pour les paiements)
    bank_account = Column(String(100))
    bank_name = Column(String(100))
    
    # Relations
    user = relationship("User", back_populates="worker_profile")
    bookings = relationship("Booking", back_populates="worker")
    reviews = relationship("WorkerReview", back_populates="worker")
    
    def to_dict(self):
        """Convertir en dictionnaire pour JSON"""
        return {
            'id': self.id,
            'user_id': self.user_id,
            'first_name': self.first_name,
            'last_name': self.last_name,
            'phone': self.phone,
            'email': self.email,
            'avatar_url': self.avatar_url,
            'worker_type': self.worker_type.value if self.worker_type else None,
            'specializations': self.specializations or [],
            'skills': self.skills or [],
            'experience_years': self.experience_years,
            'hourly_rate': self.hourly_rate,
            'daily_rate': self.daily_rate,
            'description': self.description,
            'status': self.status.value if self.status else None,
            'is_available': self.is_available,
            'availability_schedule': self.availability_schedule or {},
            'rating': self.rating,
            'total_reviews': self.total_reviews,
            'completed_projects': self.completed_projects,
            'certifications': self.certifications or [],
            'portfolio_images': self.portfolio_images or [],
            'identity_document': self.identity_document,
            'bank_account': self.bank_account,
            'bank_name': self.bank_name,
            'location': self.get_location_dict(),
            'created_at': self.created_at.isoformat() if self.created_at else None,
            'updated_at': self.updated_at.isoformat() if self.updated_at else None,
        }

class WorkerReview(BaseModel):
    """Modèle pour les avis sur les ouvriers"""
    __tablename__ = 'worker_reviews'
    
    worker_id = Column(Integer, ForeignKey('workers.id'), nullable=False)
    client_id = Column(Integer, ForeignKey('users.id'), nullable=False)
    project_id = Column(Integer, ForeignKey('projects.id'))
    booking_id = Column(Integer, ForeignKey('bookings.id'))
    
    rating = Column(Integer, nullable=False)  # Note de 1 à 5
    comment = Column(Text)
    work_quality = Column(Integer)  # Note qualité du travail (1-5)
    punctuality = Column(Integer)  # Note ponctualité (1-5)
    communication = Column(Integer)  # Note communication (1-5)
    professionalism = Column(Integer)  # Note professionnalisme (1-5)
    
    # Relations
    worker = relationship("Worker", back_populates="reviews")
    client = relationship("User", foreign_keys=[client_id])
    project = relationship("Project")
    booking = relationship("Booking")
    
    def to_dict(self):
        return {
            'id': self.id,
            'worker_id': self.worker_id,
            'client_id': self.client_id,
            'project_id': self.project_id,
            'booking_id': self.booking_id,
            'rating': self.rating,
            'comment': self.comment,
            'work_quality': self.work_quality,
            'punctuality': self.punctuality,
            'communication': self.communication,
            'professionalism': self.professionalism,
            'created_at': self.created_at.isoformat() if self.created_at else None,
            'updated_at': self.updated_at.isoformat() if self.updated_at else None,
        }
