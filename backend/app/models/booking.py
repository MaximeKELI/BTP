from datetime import datetime
from sqlalchemy import Column, Integer, String, Float, Boolean, DateTime, Text, ForeignKey, Enum as SQLEnum, JSON
from sqlalchemy.orm import relationship
from .common import BaseModel
import enum

class BookingStatus(enum.Enum):
    PENDING = "pending"
    CONFIRMED = "confirmed"
    IN_PROGRESS = "in_progress"
    COMPLETED = "completed"
    CANCELLED = "cancelled"
    REJECTED = "rejected"

class PaymentStatus(enum.Enum):
    PENDING = "pending"
    PARTIAL = "partial"
    PAID = "paid"
    REFUNDED = "refunded"
    FAILED = "failed"

class BookingType(enum.Enum):
    WORKER = "worker"
    EQUIPMENT = "equipment"
    BOTH = "both"

class Quote(BaseModel):
    """Modèle pour les devis"""
    __tablename__ = 'quotes'
    
    # Informations de base
    project_id = Column(Integer, ForeignKey('projects.id'), nullable=False)
    client_id = Column(Integer, ForeignKey('users.id'), nullable=False)
    title = Column(String(200), nullable=False)
    description = Column(Text)
    
    # Détails du devis
    total_amount = Column(Float, nullable=False)
    currency = Column(String(3), default='XOF')
    valid_until = Column(DateTime)
    is_accepted = Column(Boolean, default=False)
    accepted_at = Column(DateTime)
    
    # Détail des services
    services = Column(JSON, default=list)  # Liste des services proposés
    worker_requirements = Column(JSON, default=list)  # Besoins en ouvriers
    equipment_requirements = Column(JSON, default=list)  # Besoins en équipements
    
    # Conditions
    terms_and_conditions = Column(Text)
    payment_terms = Column(Text)
    warranty_period = Column(Integer)  # Période de garantie en jours
    
    # Relations
    project = relationship("Project", back_populates="quotes")
    client = relationship("User", foreign_keys=[client_id])
    bookings = relationship("Booking", back_populates="quote")
    
    def to_dict(self):
        return {
            'id': self.id,
            'project_id': self.project_id,
            'client_id': self.client_id,
            'title': self.title,
            'description': self.description,
            'total_amount': self.total_amount,
            'currency': self.currency,
            'valid_until': self.valid_until.isoformat() if self.valid_until else None,
            'is_accepted': self.is_accepted,
            'accepted_at': self.accepted_at.isoformat() if self.accepted_at else None,
            'services': self.services or [],
            'worker_requirements': self.worker_requirements or [],
            'equipment_requirements': self.equipment_requirements or [],
            'terms_and_conditions': self.terms_and_conditions,
            'payment_terms': self.payment_terms,
            'warranty_period': self.warranty_period,
            'created_at': self.created_at.isoformat() if self.created_at else None,
            'updated_at': self.updated_at.isoformat() if self.updated_at else None,
        }

class Booking(BaseModel):
    """Modèle pour les réservations"""
    __tablename__ = 'bookings'
    
    # Informations de base
    booking_type = Column(SQLEnum(BookingType), nullable=False)
    client_id = Column(Integer, ForeignKey('users.id'), nullable=False)
    project_id = Column(Integer, ForeignKey('projects.id'))
    quote_id = Column(Integer, ForeignKey('quotes.id'))
    
    # Dates
    start_date = Column(DateTime, nullable=False)
    end_date = Column(DateTime, nullable=False)
    actual_start_date = Column(DateTime)
    actual_end_date = Column(DateTime)
    
    # Statut
    status = Column(SQLEnum(BookingStatus), default=BookingStatus.PENDING)
    payment_status = Column(SQLEnum(PaymentStatus), default=PaymentStatus.PENDING)
    
    # Montants
    total_amount = Column(Float, nullable=False)
    paid_amount = Column(Float, default=0.0)
    deposit_amount = Column(Float, default=0.0)
    currency = Column(String(3), default='XOF')
    
    # Ouvrier assigné
    worker_id = Column(Integer, ForeignKey('workers.id'))
    
    # Détails
    description = Column(Text)
    special_requirements = Column(Text)
    notes = Column(Text)
    
    # Évaluations
    client_rating = Column(Integer)  # Note du client (1-5)
    client_review = Column(Text)
    worker_rating = Column(Integer)  # Note de l'ouvrier (1-5)
    worker_review = Column(Text)
    
    # Relations
    client = relationship("User", foreign_keys=[client_id])
    project = relationship("Project", back_populates="bookings")
    quote = relationship("Quote", back_populates="bookings")
    worker = relationship("Worker", back_populates="bookings")
    equipment_bookings = relationship("EquipmentBooking", back_populates="booking")
    payments = relationship("Payment", back_populates="booking")
    
    def to_dict(self):
        return {
            'id': self.id,
            'booking_type': self.booking_type.value if self.booking_type else None,
            'client_id': self.client_id,
            'project_id': self.project_id,
            'quote_id': self.quote_id,
            'start_date': self.start_date.isoformat() if self.start_date else None,
            'end_date': self.end_date.isoformat() if self.end_date else None,
            'actual_start_date': self.actual_start_date.isoformat() if self.actual_start_date else None,
            'actual_end_date': self.actual_end_date.isoformat() if self.actual_end_date else None,
            'status': self.status.value if self.status else None,
            'payment_status': self.payment_status.value if self.payment_status else None,
            'total_amount': self.total_amount,
            'paid_amount': self.paid_amount,
            'deposit_amount': self.deposit_amount,
            'currency': self.currency,
            'worker_id': self.worker_id,
            'description': self.description,
            'special_requirements': self.special_requirements,
            'notes': self.notes,
            'client_rating': self.client_rating,
            'client_review': self.client_review,
            'worker_rating': self.worker_rating,
            'worker_review': self.worker_review,
            'created_at': self.created_at.isoformat() if self.created_at else None,
            'updated_at': self.updated_at.isoformat() if self.updated_at else None,
        }

class EquipmentBooking(BaseModel):
    """Modèle pour les réservations d'équipements"""
    __tablename__ = 'equipment_bookings'
    
    booking_id = Column(Integer, ForeignKey('bookings.id'), nullable=False)
    equipment_id = Column(Integer, ForeignKey('equipment.id'), nullable=False)
    
    # Dates spécifiques pour cet équipement
    start_date = Column(DateTime, nullable=False)
    end_date = Column(DateTime, nullable=False)
    actual_start_date = Column(DateTime)
    actual_end_date = Column(DateTime)
    
    # Tarification
    daily_rate = Column(Float)
    total_amount = Column(Float, nullable=False)
    
    # Statut
    status = Column(SQLEnum(BookingStatus), default=BookingStatus.PENDING)
    
    # Relations
    booking = relationship("Booking", back_populates="equipment_bookings")
    equipment = relationship("Equipment", back_populates="bookings")
    
    def to_dict(self):
        return {
            'id': self.id,
            'booking_id': self.booking_id,
            'equipment_id': self.equipment_id,
            'start_date': self.start_date.isoformat() if self.start_date else None,
            'end_date': self.end_date.isoformat() if self.end_date else None,
            'actual_start_date': self.actual_start_date.isoformat() if self.actual_start_date else None,
            'actual_end_date': self.actual_end_date.isoformat() if self.actual_end_date else None,
            'daily_rate': self.daily_rate,
            'total_amount': self.total_amount,
            'status': self.status.value if self.status else None,
            'created_at': self.created_at.isoformat() if self.created_at else None,
            'updated_at': self.updated_at.isoformat() if self.updated_at else None,
        }

class Payment(BaseModel):
    """Modèle pour les paiements"""
    __tablename__ = 'payments'
    
    booking_id = Column(Integer, ForeignKey('bookings.id'), nullable=False)
    amount = Column(Float, nullable=False)
    currency = Column(String(3), default='XOF')
    payment_method = Column(String(50))  # mobile_money, bank_transfer, cash, etc.
    payment_reference = Column(String(100))  # Référence du paiement
    status = Column(SQLEnum(PaymentStatus), default=PaymentStatus.PENDING)
    paid_at = Column(DateTime)
    
    # Relations
    booking = relationship("Booking", back_populates="payments")
    
    def to_dict(self):
        return {
            'id': self.id,
            'booking_id': self.booking_id,
            'amount': self.amount,
            'currency': self.currency,
            'payment_method': self.payment_method,
            'payment_reference': self.payment_reference,
            'status': self.status.value if self.status else None,
            'paid_at': self.paid_at.isoformat() if self.paid_at else None,
            'created_at': self.created_at.isoformat() if self.created_at else None,
            'updated_at': self.updated_at.isoformat() if self.updated_at else None,
        }
