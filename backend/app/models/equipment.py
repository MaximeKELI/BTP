from datetime import datetime
from sqlalchemy import Column, Integer, String, Float, Boolean, DateTime, Text, ForeignKey, Enum as SQLEnum, JSON
from sqlalchemy.orm import relationship
from .common import BaseModel, LocationMixin
import enum

class EquipmentStatus(enum.Enum):
    AVAILABLE = "available"
    RENTED = "rented"
    MAINTENANCE = "maintenance"
    OUT_OF_SERVICE = "out_of_service"

class EquipmentCategory(enum.Enum):
    EXCAVATION = "excavation"  # Terrassement
    CONCRETE = "concrete"  # Béton
    LIFTING = "lifting"  # Levage
    TRANSPORT = "transport"  # Transport
    ELECTRICAL = "electrical"  # Électrique
    PLUMBING = "plumbing"  # Plomberie
    PAINTING = "painting"  # Peinture
    WELDING = "welding"  # Soudure
    MEASUREMENT = "measurement"  # Mesure
    SAFETY = "safety"  # Sécurité
    OTHER = "other"

class Equipment(BaseModel, LocationMixin):
    """Modèle pour les matériels/équipements"""
    __tablename__ = 'equipment'
    
    # Informations de base
    name = Column(String(200), nullable=False)
    description = Column(Text)
    category = Column(SQLEnum(EquipmentCategory), nullable=False)
    brand = Column(String(100))
    model = Column(String(100))
    serial_number = Column(String(100), unique=True)
    
    # Propriétaire
    owner_id = Column(Integer, ForeignKey('users.id'), nullable=False)
    
    # Spécifications techniques
    specifications = Column(JSON, default=dict)  # Détails techniques
    dimensions = Column(JSON)  # Dimensions (longueur, largeur, hauteur)
    weight = Column(Float)  # Poids en kg
    power_rating = Column(String(50))  # Puissance si applicable
    fuel_type = Column(String(50))  # Type de carburant
    
    # Tarification
    hourly_rate = Column(Float)  # Tarif horaire
    daily_rate = Column(Float)  # Tarif journalier
    weekly_rate = Column(Float)  # Tarif hebdomadaire
    monthly_rate = Column(Float)  # Tarif mensuel
    deposit_amount = Column(Float)  # Montant de la caution
    
    # Statut et disponibilité
    status = Column(SQLEnum(EquipmentStatus), default=EquipmentStatus.AVAILABLE)
    is_available = Column(Boolean, default=True)
    availability_schedule = Column(JSON)  # Planning de disponibilité
    
    # Images et documents
    images = Column(JSON, default=list)  # Photos de l'équipement
    documents = Column(JSON, default=list)  # Documents (manuel, certificat, etc.)
    
    # Maintenance
    last_maintenance_date = Column(DateTime)
    next_maintenance_date = Column(DateTime)
    maintenance_notes = Column(Text)
    
    # Évaluations
    rating = Column(Float, default=0.0)  # Note moyenne
    total_reviews = Column(Integer, default=0)
    total_rentals = Column(Integer, default=0)
    
    # Relations
    owner = relationship("User", foreign_keys=[owner_id])
    bookings = relationship("EquipmentBooking", back_populates="equipment")
    reviews = relationship("EquipmentReview", back_populates="equipment")
    
    def to_dict(self):
        """Convertir en dictionnaire pour JSON"""
        return {
            'id': self.id,
            'name': self.name,
            'description': self.description,
            'category': self.category.value if self.category else None,
            'brand': self.brand,
            'model': self.model,
            'serial_number': self.serial_number,
            'owner_id': self.owner_id,
            'specifications': self.specifications or {},
            'dimensions': self.dimensions or {},
            'weight': self.weight,
            'power_rating': self.power_rating,
            'fuel_type': self.fuel_type,
            'hourly_rate': self.hourly_rate,
            'daily_rate': self.daily_rate,
            'weekly_rate': self.weekly_rate,
            'monthly_rate': self.monthly_rate,
            'deposit_amount': self.deposit_amount,
            'status': self.status.value if self.status else None,
            'is_available': self.is_available,
            'availability_schedule': self.availability_schedule or {},
            'images': self.images or [],
            'documents': self.documents or [],
            'last_maintenance_date': self.last_maintenance_date.isoformat() if self.last_maintenance_date else None,
            'next_maintenance_date': self.next_maintenance_date.isoformat() if self.next_maintenance_date else None,
            'maintenance_notes': self.maintenance_notes,
            'rating': self.rating,
            'total_reviews': self.total_reviews,
            'total_rentals': self.total_rentals,
            'location': self.get_location_dict(),
            'created_at': self.created_at.isoformat() if self.created_at else None,
            'updated_at': self.updated_at.isoformat() if self.updated_at else None,
        }

class EquipmentReview(BaseModel):
    """Modèle pour les avis sur les équipements"""
    __tablename__ = 'equipment_reviews'
    
    equipment_id = Column(Integer, ForeignKey('equipment.id'), nullable=False)
    client_id = Column(Integer, ForeignKey('users.id'), nullable=False)
    booking_id = Column(Integer, ForeignKey('equipment_bookings.id'))
    
    rating = Column(Integer, nullable=False)  # Note de 1 à 5
    comment = Column(Text)
    condition_rating = Column(Integer)  # Note état de l'équipement (1-5)
    ease_of_use = Column(Integer)  # Note facilité d'utilisation (1-5)
    value_for_money = Column(Integer)  # Note rapport qualité/prix (1-5)
    
    # Relations
    equipment = relationship("Equipment", back_populates="reviews")
    client = relationship("User", foreign_keys=[client_id])
    booking = relationship("EquipmentBooking")
    
    def to_dict(self):
        return {
            'id': self.id,
            'equipment_id': self.equipment_id,
            'client_id': self.client_id,
            'booking_id': self.booking_id,
            'rating': self.rating,
            'comment': self.comment,
            'condition_rating': self.condition_rating,
            'ease_of_use': self.ease_of_use,
            'value_for_money': self.value_for_money,
            'created_at': self.created_at.isoformat() if self.created_at else None,
            'updated_at': self.updated_at.isoformat() if self.updated_at else None,
        }
