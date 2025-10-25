from datetime import datetime
from sqlalchemy import Column, Integer, String, Float, Boolean, DateTime, Text, ForeignKey, Enum as SQLEnum, JSON
from sqlalchemy.orm import relationship
from .common import BaseModel, LocationMixin
import enum

class ProjectStatus(enum.Enum):
    DRAFT = "draft"
    PUBLISHED = "published"
    IN_PROGRESS = "in_progress"
    COMPLETED = "completed"
    CANCELLED = "cancelled"
    ON_HOLD = "on_hold"

class ProjectType(enum.Enum):
    RESIDENTIAL = "residential"  # Résidentiel
    COMMERCIAL = "commercial"  # Commercial
    INDUSTRIAL = "industrial"  # Industriel
    INFRASTRUCTURE = "infrastructure"  # Infrastructure
    RENOVATION = "renovation"  # Rénovation
    NEW_CONSTRUCTION = "new_construction"  # Construction neuve
    MAINTENANCE = "maintenance"  # Maintenance
    OTHER = "other"

class Project(BaseModel, LocationMixin):
    """Modèle pour les projets de construction"""
    __tablename__ = 'projects'
    
    # Informations de base
    title = Column(String(200), nullable=False)
    description = Column(Text, nullable=False)
    project_type = Column(SQLEnum(ProjectType), nullable=False)
    status = Column(SQLEnum(ProjectStatus), default=ProjectStatus.DRAFT)
    
    # Client/Propriétaire
    client_id = Column(Integer, ForeignKey('users.id'), nullable=False)
    
    # Budget et durée
    estimated_budget = Column(Float)  # Budget estimé
    actual_budget = Column(Float)  # Budget réel
    estimated_duration_days = Column(Integer)  # Durée estimée en jours
    start_date = Column(DateTime)
    end_date = Column(DateTime)
    actual_start_date = Column(DateTime)
    actual_end_date = Column(DateTime)
    
    # Spécifications techniques
    specifications = Column(JSON, default=dict)  # Spécifications détaillées
    required_skills = Column(JSON, default=list)  # Compétences requises
    required_equipment = Column(JSON, default=list)  # Équipements requis
    
    # Images et documents
    images = Column(JSON, default=list)  # Photos du projet
    documents = Column(JSON, default=list)  # Plans, devis, etc.
    
    # Équipe de travail
    assigned_workers = Column(JSON, default=list)  # Ouvriers assignés
    project_manager_id = Column(Integer, ForeignKey('users.id'))  # Chef de projet
    
    # Progression
    progress_percentage = Column(Float, default=0.0)  # Pourcentage de progression
    milestones = Column(JSON, default=list)  # Jalons du projet
    
    # Relations
    client = relationship("User", foreign_keys=[client_id])
    project_manager = relationship("User", foreign_keys=[project_manager_id])
    quotes = relationship("Quote", back_populates="project")
    bookings = relationship("Booking", back_populates="project")
    
    def to_dict(self):
        """Convertir en dictionnaire pour JSON"""
        return {
            'id': self.id,
            'title': self.title,
            'description': self.description,
            'project_type': self.project_type.value if self.project_type else None,
            'status': self.status.value if self.status else None,
            'client_id': self.client_id,
            'estimated_budget': self.estimated_budget,
            'actual_budget': self.actual_budget,
            'estimated_duration_days': self.estimated_duration_days,
            'start_date': self.start_date.isoformat() if self.start_date else None,
            'end_date': self.end_date.isoformat() if self.end_date else None,
            'actual_start_date': self.actual_start_date.isoformat() if self.actual_start_date else None,
            'actual_end_date': self.actual_end_date.isoformat() if self.actual_end_date else None,
            'specifications': self.specifications or {},
            'required_skills': self.required_skills or [],
            'required_equipment': self.required_equipment or [],
            'images': self.images or [],
            'documents': self.documents or [],
            'assigned_workers': self.assigned_workers or [],
            'project_manager_id': self.project_manager_id,
            'progress_percentage': self.progress_percentage,
            'milestones': self.milestones or [],
            'location': self.get_location_dict(),
            'created_at': self.created_at.isoformat() if self.created_at else None,
            'updated_at': self.updated_at.isoformat() if self.updated_at else None,
        }

class ProjectMilestone(BaseModel):
    """Modèle pour les jalons de projet"""
    __tablename__ = 'project_milestones'
    
    project_id = Column(Integer, ForeignKey('projects.id'), nullable=False)
    title = Column(String(200), nullable=False)
    description = Column(Text)
    due_date = Column(DateTime)
    completed_date = Column(DateTime)
    is_completed = Column(Boolean, default=False)
    completion_percentage = Column(Float, default=0.0)
    
    # Relations
    project = relationship("Project")
    
    def to_dict(self):
        return {
            'id': self.id,
            'project_id': self.project_id,
            'title': self.title,
            'description': self.description,
            'due_date': self.due_date.isoformat() if self.due_date else None,
            'completed_date': self.completed_date.isoformat() if self.completed_date else None,
            'is_completed': self.is_completed,
            'completion_percentage': self.completion_percentage,
            'created_at': self.created_at.isoformat() if self.created_at else None,
            'updated_at': self.updated_at.isoformat() if self.updated_at else None,
        }
