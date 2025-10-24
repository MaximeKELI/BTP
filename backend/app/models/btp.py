from datetime import datetime
from app import db
from .common import BaseModel, LocationMixin, MetadataMixin
from sqlalchemy import Column, String, Text, Integer, ForeignKey, Numeric, DateTime, Boolean, Enum
import enum

class ChantierStatus(enum.Enum):
    PLANNED = "planned"
    IN_PROGRESS = "in_progress"
    ON_HOLD = "on_hold"
    COMPLETED = "completed"
    CANCELLED = "cancelled"

class Chantier(BaseModel, LocationMixin, MetadataMixin):
    """BTP Construction site model"""
    __tablename__ = 'chantiers'
    
    # Basic info
    name = Column(String(200), nullable=False)
    description = Column(Text, nullable=True)
    client_name = Column(String(100), nullable=True)
    client_contact = Column(String(100), nullable=True)
    
    # Project details
    project_type = Column(String(100), nullable=True)  # residential, commercial, infrastructure
    budget = Column(Numeric(15, 2), nullable=True)
    start_date = Column(DateTime, nullable=True)
    end_date = Column(DateTime, nullable=True)
    status = Column(Enum(ChantierStatus), default=ChantierStatus.PLANNED, nullable=False)
    
    # Progress tracking
    progress_percentage = Column(Integer, default=0, nullable=False)
    estimated_completion = Column(DateTime, nullable=True)
    
    # Team and resources
    manager_id = Column(Integer, ForeignKey('users.id'), nullable=True)
    team_size = Column(Integer, default=0, nullable=False)
    
    # Weather and conditions
    weather_conditions = Column(Text, nullable=True)  # JSON weather data
    safety_notes = Column(Text, nullable=True)
    
    # Relationships
    equipes = db.relationship('Equipe', backref='chantier', lazy='dynamic', cascade='all, delete-orphan')
    materiels = db.relationship('Materiel', backref='chantier', lazy='dynamic', cascade='all, delete-orphan')
    photos = db.relationship('PhotoChantier', backref='chantier', lazy='dynamic', cascade='all, delete-orphan')
    
    def to_dict(self):
        """Convert chantier to dictionary"""
        return {
            'id': self.id,
            'name': self.name,
            'description': self.description,
            'client_name': self.client_name,
            'client_contact': self.client_contact,
            'project_type': self.project_type,
            'budget': float(self.budget) if self.budget else None,
            'start_date': self.start_date.isoformat() if self.start_date else None,
            'end_date': self.end_date.isoformat() if self.end_date else None,
            'status': self.status.value if self.status else None,
            'progress_percentage': self.progress_percentage,
            'estimated_completion': self.estimated_completion.isoformat() if self.estimated_completion else None,
            'manager_id': self.manager_id,
            'team_size': self.team_size,
            'weather_conditions': self.weather_conditions,
            'safety_notes': self.safety_notes,
            'location': self.get_location_dict(),
            'metadata': self.metadata,
            'created_at': self.created_at.isoformat() if self.created_at else None,
            'updated_at': self.updated_at.isoformat() if self.updated_at else None
        }

class Equipe(BaseModel, MetadataMixin):
    """Construction team model"""
    __tablename__ = 'equipes'
    
    chantier_id = Column(Integer, ForeignKey('chantiers.id'), nullable=False)
    user_id = Column(Integer, ForeignKey('users.id'), nullable=False)
    
    # Team member info
    role = Column(String(100), nullable=False)  # chef, ouvrier, technicien, etc.
    hourly_rate = Column(Numeric(10, 2), nullable=True)
    start_date = Column(DateTime, nullable=True)
    end_date = Column(DateTime, nullable=True)
    
    # Work tracking
    hours_worked = Column(Numeric(8, 2), default=0, nullable=False)
    is_present = Column(Boolean, default=False, nullable=False)
    last_checkin = Column(DateTime, nullable=True)
    last_checkout = Column(DateTime, nullable=True)
    
    # Performance
    performance_rating = Column(Integer, nullable=True)  # 1-5 scale
    notes = Column(Text, nullable=True)
    
    def to_dict(self):
        """Convert equipe to dictionary"""
        return {
            'id': self.id,
            'chantier_id': self.chantier_id,
            'user_id': self.user_id,
            'role': self.role,
            'hourly_rate': float(self.hourly_rate) if self.hourly_rate else None,
            'start_date': self.start_date.isoformat() if self.start_date else None,
            'end_date': self.end_date.isoformat() if self.end_date else None,
            'hours_worked': float(self.hours_worked),
            'is_present': self.is_present,
            'last_checkin': self.last_checkin.isoformat() if self.last_checkin else None,
            'last_checkout': self.last_checkout.isoformat() if self.last_checkout else None,
            'performance_rating': self.performance_rating,
            'notes': self.notes,
            'metadata': self.metadata,
            'created_at': self.created_at.isoformat() if self.created_at else None,
            'updated_at': self.updated_at.isoformat() if self.updated_at else None
        }

class Materiel(BaseModel, LocationMixin, MetadataMixin):
    """Construction materials and equipment model"""
    __tablename__ = 'materiels'
    
    chantier_id = Column(Integer, ForeignKey('chantiers.id'), nullable=True)
    
    # Material info
    name = Column(String(200), nullable=False)
    description = Column(Text, nullable=True)
    category = Column(String(100), nullable=True)  # outillage, materiaux, engins
    brand = Column(String(100), nullable=True)
    model = Column(String(100), nullable=True)
    serial_number = Column(String(100), nullable=True)
    
    # Quantities and costs
    quantity = Column(Numeric(10, 2), nullable=True)
    unit = Column(String(20), nullable=True)  # pieces, kg, m3, etc.
    unit_price = Column(Numeric(10, 2), nullable=True)
    total_cost = Column(Numeric(15, 2), nullable=True)
    
    # Status and condition
    condition = Column(String(50), nullable=True)  # new, good, fair, poor
    status = Column(String(50), nullable=True)  # available, in_use, maintenance, retired
    supplier = Column(String(100), nullable=True)
    purchase_date = Column(DateTime, nullable=True)
    warranty_expiry = Column(DateTime, nullable=True)
    
    # Maintenance
    last_maintenance = Column(DateTime, nullable=True)
    next_maintenance = Column(DateTime, nullable=True)
    maintenance_notes = Column(Text, nullable=True)
    
    def to_dict(self):
        """Convert materiel to dictionary"""
        return {
            'id': self.id,
            'chantier_id': self.chantier_id,
            'name': self.name,
            'description': self.description,
            'category': self.category,
            'brand': self.brand,
            'model': self.model,
            'serial_number': self.serial_number,
            'quantity': float(self.quantity) if self.quantity else None,
            'unit': self.unit,
            'unit_price': float(self.unit_price) if self.unit_price else None,
            'total_cost': float(self.total_cost) if self.total_cost else None,
            'condition': self.condition,
            'status': self.status,
            'supplier': self.supplier,
            'purchase_date': self.purchase_date.isoformat() if self.purchase_date else None,
            'warranty_expiry': self.warranty_expiry.isoformat() if self.warranty_expiry else None,
            'last_maintenance': self.last_maintenance.isoformat() if self.last_maintenance else None,
            'next_maintenance': self.next_maintenance.isoformat() if self.next_maintenance else None,
            'maintenance_notes': self.maintenance_notes,
            'location': self.get_location_dict(),
            'metadata': self.metadata,
            'created_at': self.created_at.isoformat() if self.created_at else None,
            'updated_at': self.updated_at.isoformat() if self.updated_at else None
        }

class PhotoChantier(BaseModel, LocationMixin, MetadataMixin):
    """Construction site photos with geotagging"""
    __tablename__ = 'photo_chantiers'
    
    chantier_id = Column(Integer, ForeignKey('chantiers.id'), nullable=False)
    user_id = Column(Integer, ForeignKey('users.id'), nullable=False)
    
    # Photo info
    filename = Column(String(255), nullable=False)
    original_filename = Column(String(255), nullable=False)
    file_path = Column(Text, nullable=False)
    file_size = Column(Integer, nullable=True)
    mime_type = Column(String(100), nullable=True)
    
    # Photo details
    title = Column(String(200), nullable=True)
    description = Column(Text, nullable=True)
    category = Column(String(100), nullable=True)  # progress, safety, quality, before, after
    tags = Column(Text, nullable=True)  # JSON array of tags
    
    # Technical details
    width = Column(Integer, nullable=True)
    height = Column(Integer, nullable=True)
    camera_make = Column(String(100), nullable=True)
    camera_model = Column(String(100), nullable=True)
    taken_at = Column(DateTime, nullable=True)
    
    # Work progress
    work_phase = Column(String(100), nullable=True)
    progress_milestone = Column(String(100), nullable=True)
    is_before_photo = Column(Boolean, default=False, nullable=False)
    is_after_photo = Column(Boolean, default=False, nullable=False)
    
    def to_dict(self):
        """Convert photo to dictionary"""
        return {
            'id': self.id,
            'chantier_id': self.chantier_id,
            'user_id': self.user_id,
            'filename': self.filename,
            'original_filename': self.original_filename,
            'file_path': self.file_path,
            'file_size': self.file_size,
            'mime_type': self.mime_type,
            'title': self.title,
            'description': self.description,
            'category': self.category,
            'tags': self.tags,
            'width': self.width,
            'height': self.height,
            'camera_make': self.camera_make,
            'camera_model': self.camera_model,
            'taken_at': self.taken_at.isoformat() if self.taken_at else None,
            'work_phase': self.work_phase,
            'progress_milestone': self.progress_milestone,
            'is_before_photo': self.is_before_photo,
            'is_after_photo': self.is_after_photo,
            'location': self.get_location_dict(),
            'metadata': self.metadata,
            'created_at': self.created_at.isoformat() if self.created_at else None,
            'updated_at': self.updated_at.isoformat() if self.updated_at else None
        }
