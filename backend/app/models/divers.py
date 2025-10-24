from datetime import datetime
from app import db
from .common import BaseModel, LocationMixin, MetadataMixin
from sqlalchemy import Column, String, Text, Integer, ForeignKey, Numeric, DateTime, Boolean, Enum, Date
import enum

class ProjetStatus(enum.Enum):
    PLANNING = "planning"
    IN_PROGRESS = "in_progress"
    ON_HOLD = "on_hold"
    COMPLETED = "completed"
    CANCELLED = "cancelled"

class ClientType(enum.Enum):
    INDIVIDUAL = "individual"
    BUSINESS = "business"
    GOVERNMENT = "government"
    NGO = "ngo"

class FactureStatus(enum.Enum):
    DRAFT = "draft"
    SENT = "sent"
    PAID = "paid"
    OVERDUE = "overdue"
    CANCELLED = "cancelled"

class PaiementMethod(enum.Enum):
    CASH = "cash"
    BANK_TRANSFER = "bank_transfer"
    MOBILE_MONEY = "mobile_money"
    CREDIT_CARD = "credit_card"
    CRYPTOCURRENCY = "cryptocurrency"
    CHECK = "check"

class Projet(BaseModel, LocationMixin, MetadataMixin):
    """General project model for diverse sectors"""
    __tablename__ = 'projets'
    
    # Basic info
    name = Column(String(200), nullable=False)
    description = Column(Text, nullable=True)
    client_id = Column(Integer, ForeignKey('clients.id'), nullable=False)
    manager_id = Column(Integer, ForeignKey('users.id'), nullable=False)
    
    # Project details
    project_type = Column(String(100), nullable=True)  # consulting, development, maintenance, etc.
    sector = Column(String(100), nullable=True)  # technology, healthcare, education, etc.
    status = Column(Enum(ProjetStatus), default=ProjetStatus.PLANNING, nullable=False)
    
    # Timeline
    start_date = Column(DateTime, nullable=True)
    end_date = Column(DateTime, nullable=True)
    estimated_duration_days = Column(Integer, nullable=True)
    actual_duration_days = Column(Integer, nullable=True)
    
    # Budget and costs
    budget = Column(Numeric(15, 2), nullable=True)
    actual_cost = Column(Numeric(15, 2), nullable=True)
    hourly_rate = Column(Numeric(10, 2), nullable=True)
    currency = Column(String(3), default='XOF', nullable=False)
    
    # Progress tracking
    progress_percentage = Column(Integer, default=0, nullable=False)
    milestones = Column(Text, nullable=True)  # JSON array of milestones
    deliverables = Column(Text, nullable=True)  # JSON array of deliverables
    
    # Team and resources
    team_members = Column(Text, nullable=True)  # JSON array of user IDs
    required_skills = Column(Text, nullable=True)  # JSON array of skills
    equipment_needed = Column(Text, nullable=True)  # JSON array of equipment
    
    # Quality and satisfaction
    quality_rating = Column(Integer, nullable=True)  # 1-10 scale
    client_satisfaction = Column(Integer, nullable=True)  # 1-10 scale
    completion_notes = Column(Text, nullable=True)
    
    def to_dict(self):
        """Convert projet to dictionary"""
        return {
            'id': self.id,
            'name': self.name,
            'description': self.description,
            'client_id': self.client_id,
            'manager_id': self.manager_id,
            'project_type': self.project_type,
            'sector': self.sector,
            'status': self.status.value if self.status else None,
            'start_date': self.start_date.isoformat() if self.start_date else None,
            'end_date': self.end_date.isoformat() if self.end_date else None,
            'estimated_duration_days': self.estimated_duration_days,
            'actual_duration_days': self.actual_duration_days,
            'budget': float(self.budget) if self.budget else None,
            'actual_cost': float(self.actual_cost) if self.actual_cost else None,
            'hourly_rate': float(self.hourly_rate) if self.hourly_rate else None,
            'currency': self.currency,
            'progress_percentage': self.progress_percentage,
            'milestones': self.milestones,
            'deliverables': self.deliverables,
            'team_members': self.team_members,
            'required_skills': self.required_skills,
            'equipment_needed': self.equipment_needed,
            'quality_rating': self.quality_rating,
            'client_satisfaction': self.client_satisfaction,
            'completion_notes': self.completion_notes,
            'location': self.get_location_dict(),
            'metadata': self.metadata,
            'created_at': self.created_at.isoformat() if self.created_at else None,
            'updated_at': self.updated_at.isoformat() if self.updated_at else None
        }

class Client(BaseModel, LocationMixin, MetadataMixin):
    """Client model for diverse sectors"""
    __tablename__ = 'clients'
    
    # Basic info
    name = Column(String(200), nullable=False)
    contact_person = Column(String(100), nullable=True)
    email = Column(String(120), nullable=True)
    phone = Column(String(20), nullable=True)
    website = Column(String(200), nullable=True)
    
    # Business details
    client_type = Column(Enum(ClientType), nullable=False)
    industry = Column(String(100), nullable=True)
    company_size = Column(String(50), nullable=True)  # small, medium, large, enterprise
    tax_number = Column(String(50), nullable=True)
    registration_number = Column(String(50), nullable=True)
    
    # Financial info
    credit_limit = Column(Numeric(15, 2), nullable=True)
    payment_terms = Column(String(100), nullable=True)  # net_30, net_60, etc.
    preferred_payment_method = Column(String(50), nullable=True)
    currency = Column(String(3), default='XOF', nullable=False)
    
    # Relationship management
    account_manager_id = Column(Integer, ForeignKey('users.id'), nullable=True)
    client_since = Column(Date, nullable=True)
    last_contact = Column(DateTime, nullable=True)
    total_projects = Column(Integer, default=0, nullable=False)
    total_value = Column(Numeric(15, 2), default=0, nullable=False)
    
    # Preferences and notes
    communication_preferences = Column(Text, nullable=True)  # JSON preferences
    special_requirements = Column(Text, nullable=True)
    notes = Column(Text, nullable=True)
    
    # Status
    is_active = Column(Boolean, default=True, nullable=False)
    risk_level = Column(String(20), nullable=True)  # low, medium, high
    
    # Relationships
    projets = db.relationship('Projet', backref='client', lazy='dynamic', cascade='all, delete-orphan')
    factures = db.relationship('Facture', backref='client', lazy='dynamic', cascade='all, delete-orphan')
    
    def to_dict(self):
        """Convert client to dictionary"""
        return {
            'id': self.id,
            'name': self.name,
            'contact_person': self.contact_person,
            'email': self.email,
            'phone': self.phone,
            'website': self.website,
            'client_type': self.client_type.value if self.client_type else None,
            'industry': self.industry,
            'company_size': self.company_size,
            'tax_number': self.tax_number,
            'registration_number': self.registration_number,
            'credit_limit': float(self.credit_limit) if self.credit_limit else None,
            'payment_terms': self.payment_terms,
            'preferred_payment_method': self.preferred_payment_method,
            'currency': self.currency,
            'account_manager_id': self.account_manager_id,
            'client_since': self.client_since.isoformat() if self.client_since else None,
            'last_contact': self.last_contact.isoformat() if self.last_contact else None,
            'total_projects': self.total_projects,
            'total_value': float(self.total_value),
            'communication_preferences': self.communication_preferences,
            'special_requirements': self.special_requirements,
            'notes': self.notes,
            'is_active': self.is_active,
            'risk_level': self.risk_level,
            'location': self.get_location_dict(),
            'metadata': self.metadata,
            'created_at': self.created_at.isoformat() if self.created_at else None,
            'updated_at': self.updated_at.isoformat() if self.updated_at else None
        }

class Facture(BaseModel, MetadataMixin):
    """Invoice model for diverse sectors"""
    __tablename__ = 'factures'
    
    client_id = Column(Integer, ForeignKey('clients.id'), nullable=False)
    projet_id = Column(Integer, ForeignKey('projets.id'), nullable=True)
    created_by_id = Column(Integer, ForeignKey('users.id'), nullable=False)
    
    # Invoice details
    invoice_number = Column(String(100), unique=True, nullable=False)
    title = Column(String(200), nullable=False)
    description = Column(Text, nullable=True)
    status = Column(Enum(FactureStatus), default=FactureStatus.DRAFT, nullable=False)
    
    # Dates
    invoice_date = Column(Date, nullable=False)
    due_date = Column(Date, nullable=True)
    sent_date = Column(DateTime, nullable=True)
    paid_date = Column(DateTime, nullable=True)
    
    # Financial details
    subtotal = Column(Numeric(15, 2), nullable=False)
    tax_rate = Column(Numeric(5, 2), nullable=True)  # percentage
    tax_amount = Column(Numeric(15, 2), nullable=True)
    discount_rate = Column(Numeric(5, 2), nullable=True)  # percentage
    discount_amount = Column(Numeric(15, 2), nullable=True)
    total_amount = Column(Numeric(15, 2), nullable=False)
    paid_amount = Column(Numeric(15, 2), default=0, nullable=False)
    balance_due = Column(Numeric(15, 2), nullable=False)
    currency = Column(String(3), default='XOF', nullable=False)
    
    # Payment terms
    payment_terms = Column(String(100), nullable=True)
    late_fee_rate = Column(Numeric(5, 2), nullable=True)  # percentage
    late_fee_amount = Column(Numeric(15, 2), nullable=True)
    
    # Line items
    line_items = Column(Text, nullable=True)  # JSON array of line items
    notes = Column(Text, nullable=True)
    terms_conditions = Column(Text, nullable=True)
    
    # Attachments
    attachments = Column(Text, nullable=True)  # JSON array of file URLs
    
    def to_dict(self):
        """Convert facture to dictionary"""
        return {
            'id': self.id,
            'client_id': self.client_id,
            'projet_id': self.projet_id,
            'created_by_id': self.created_by_id,
            'invoice_number': self.invoice_number,
            'title': self.title,
            'description': self.description,
            'status': self.status.value if self.status else None,
            'invoice_date': self.invoice_date.isoformat() if self.invoice_date else None,
            'due_date': self.due_date.isoformat() if self.due_date else None,
            'sent_date': self.sent_date.isoformat() if self.sent_date else None,
            'paid_date': self.paid_date.isoformat() if self.paid_date else None,
            'subtotal': float(self.subtotal),
            'tax_rate': float(self.tax_rate) if self.tax_rate else None,
            'tax_amount': float(self.tax_amount) if self.tax_amount else None,
            'discount_rate': float(self.discount_rate) if self.discount_rate else None,
            'discount_amount': float(self.discount_amount) if self.discount_amount else None,
            'total_amount': float(self.total_amount),
            'paid_amount': float(self.paid_amount),
            'balance_due': float(self.balance_due),
            'currency': self.currency,
            'payment_terms': self.payment_terms,
            'late_fee_rate': float(self.late_fee_rate) if self.late_fee_rate else None,
            'late_fee_amount': float(self.late_fee_amount) if self.late_fee_amount else None,
            'line_items': self.line_items,
            'notes': self.notes,
            'terms_conditions': self.terms_conditions,
            'attachments': self.attachments,
            'metadata': self.metadata,
            'created_at': self.created_at.isoformat() if self.created_at else None,
            'updated_at': self.updated_at.isoformat() if self.updated_at else None
        }

class Paiement(BaseModel, MetadataMixin):
    """Payment model for diverse sectors"""
    __tablename__ = 'paiements'
    
    facture_id = Column(Integer, ForeignKey('factures.id'), nullable=False)
    client_id = Column(Integer, ForeignKey('clients.id'), nullable=False)
    processed_by_id = Column(Integer, ForeignKey('users.id'), nullable=False)
    
    # Payment details
    payment_number = Column(String(100), unique=True, nullable=False)
    amount = Column(Numeric(15, 2), nullable=False)
    currency = Column(String(3), default='XOF', nullable=False)
    payment_date = Column(DateTime, nullable=False)
    method = Column(Enum(PaiementMethod), nullable=False)
    
    # Payment method specific info
    reference_number = Column(String(100), nullable=True)  # transaction ID, check number, etc.
    bank_name = Column(String(100), nullable=True)
    account_number = Column(String(100), nullable=True)
    mobile_money_provider = Column(String(100), nullable=True)  # Orange Money, MTN Money, etc.
    card_last_four = Column(String(4), nullable=True)
    card_type = Column(String(50), nullable=True)  # Visa, Mastercard, etc.
    
    # Status and processing
    status = Column(String(50), nullable=True)  # pending, completed, failed, refunded
    processing_fee = Column(Numeric(10, 2), nullable=True)
    exchange_rate = Column(Numeric(10, 6), nullable=True)
    notes = Column(Text, nullable=True)
    
    # Reconciliation
    bank_reconciliation_date = Column(DateTime, nullable=True)
    reconciled_by_id = Column(Integer, ForeignKey('users.id'), nullable=True)
    reconciliation_notes = Column(Text, nullable=True)
    
    def to_dict(self):
        """Convert paiement to dictionary"""
        return {
            'id': self.id,
            'facture_id': self.facture_id,
            'client_id': self.client_id,
            'processed_by_id': self.processed_by_id,
            'payment_number': self.payment_number,
            'amount': float(self.amount),
            'currency': self.currency,
            'payment_date': self.payment_date.isoformat() if self.payment_date else None,
            'method': self.method.value if self.method else None,
            'reference_number': self.reference_number,
            'bank_name': self.bank_name,
            'account_number': self.account_number,
            'mobile_money_provider': self.mobile_money_provider,
            'card_last_four': self.card_last_four,
            'card_type': self.card_type,
            'status': self.status,
            'processing_fee': float(self.processing_fee) if self.processing_fee else None,
            'exchange_rate': float(self.exchange_rate) if self.exchange_rate else None,
            'notes': self.notes,
            'bank_reconciliation_date': self.bank_reconciliation_date.isoformat() if self.bank_reconciliation_date else None,
            'reconciled_by_id': self.reconciled_by_id,
            'reconciliation_notes': self.reconciliation_notes,
            'metadata': self.metadata,
            'created_at': self.created_at.isoformat() if self.created_at else None,
            'updated_at': self.updated_at.isoformat() if self.updated_at else None
        }
