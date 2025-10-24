from datetime import datetime
from app import db
from .common import BaseModel, LocationMixin, MetadataMixin
from sqlalchemy import Column, String, Text, Integer, ForeignKey, Numeric, DateTime, Boolean, Enum, Date
import enum

class GisementStatus(enum.Enum):
    EXPLORATION = "exploration"
    DEVELOPMENT = "development"
    PRODUCTION = "production"
    CLOSURE = "closure"
    RECLAMATION = "reclamation"

class VehiculeType(enum.Enum):
    EXCAVATOR = "excavator"
    TRUCK = "truck"
    BULLDOZER = "bulldozer"
    DRILL = "drill"
    CRANE = "crane"
    OTHER = "other"

class IncidentSeverity(enum.Enum):
    LOW = "low"
    MEDIUM = "medium"
    HIGH = "high"
    CRITICAL = "critical"

class Gisement(BaseModel, LocationMixin, MetadataMixin):
    """Mining deposit model"""
    __tablename__ = 'gisements'
    
    # Basic info
    name = Column(String(200), nullable=False)
    description = Column(Text, nullable=True)
    company_id = Column(Integer, ForeignKey('users.id'), nullable=False)
    
    # Mining details
    mineral_type = Column(String(100), nullable=False)  # gold, copper, iron, etc.
    deposit_type = Column(String(100), nullable=True)  # open_pit, underground, placer
    status = Column(Enum(GisementStatus), default=GisementStatus.EXPLORATION, nullable=False)
    
    # Geological data
    estimated_reserves = Column(Numeric(15, 2), nullable=True)
    reserves_unit = Column(String(20), nullable=True)  # tonnes, ounces, etc.
    ore_grade = Column(Numeric(8, 4), nullable=True)  # percentage or g/t
    depth_meters = Column(Numeric(10, 2), nullable=True)
    
    # Production data
    daily_production = Column(Numeric(10, 2), nullable=True)
    monthly_production = Column(Numeric(10, 2), nullable=True)
    annual_production = Column(Numeric(10, 2), nullable=True)
    production_unit = Column(String(20), nullable=True)
    
    # Environmental data
    environmental_impact = Column(Text, nullable=True)  # JSON environmental metrics
    reclamation_plan = Column(Text, nullable=True)
    water_usage = Column(Numeric(10, 2), nullable=True)  # liters per day
    energy_consumption = Column(Numeric(10, 2), nullable=True)  # kWh per day
    
    # Safety and compliance
    safety_rating = Column(Integer, nullable=True)  # 1-10 scale
    compliance_score = Column(Integer, nullable=True)  # 1-100 percentage
    last_inspection = Column(DateTime, nullable=True)
    next_inspection = Column(DateTime, nullable=True)
    
    # Relationships
    vehicules = db.relationship('Vehicule', backref='gisement', lazy='dynamic', cascade='all, delete-orphan')
    productions = db.relationship('Production', backref='gisement', lazy='dynamic', cascade='all, delete-orphan')
    incidents = db.relationship('Incident', backref='gisement', lazy='dynamic', cascade='all, delete-orphan')
    
    def to_dict(self):
        """Convert gisement to dictionary"""
        return {
            'id': self.id,
            'name': self.name,
            'description': self.description,
            'company_id': self.company_id,
            'mineral_type': self.mineral_type,
            'deposit_type': self.deposit_type,
            'status': self.status.value if self.status else None,
            'estimated_reserves': float(self.estimated_reserves) if self.estimated_reserves else None,
            'reserves_unit': self.reserves_unit,
            'ore_grade': float(self.ore_grade) if self.ore_grade else None,
            'depth_meters': float(self.depth_meters) if self.depth_meters else None,
            'daily_production': float(self.daily_production) if self.daily_production else None,
            'monthly_production': float(self.monthly_production) if self.monthly_production else None,
            'annual_production': float(self.annual_production) if self.annual_production else None,
            'production_unit': self.production_unit,
            'environmental_impact': self.environmental_impact,
            'reclamation_plan': self.reclamation_plan,
            'water_usage': float(self.water_usage) if self.water_usage else None,
            'energy_consumption': float(self.energy_consumption) if self.energy_consumption else None,
            'safety_rating': self.safety_rating,
            'compliance_score': self.compliance_score,
            'last_inspection': self.last_inspection.isoformat() if self.last_inspection else None,
            'next_inspection': self.next_inspection.isoformat() if self.next_inspection else None,
            'location': self.get_location_dict(),
            'metadata': self.metadata,
            'created_at': self.created_at.isoformat() if self.created_at else None,
            'updated_at': self.updated_at.isoformat() if self.updated_at else None
        }

class Vehicule(BaseModel, LocationMixin, MetadataMixin):
    """Mining vehicle and equipment model"""
    __tablename__ = 'vehicules'
    
    gisement_id = Column(Integer, ForeignKey('gisements.id'), nullable=True)
    
    # Vehicle info
    name = Column(String(200), nullable=False)
    type = Column(Enum(VehiculeType), nullable=False)
    brand = Column(String(100), nullable=True)
    model = Column(String(100), nullable=True)
    year = Column(Integer, nullable=True)
    serial_number = Column(String(100), nullable=True)
    license_plate = Column(String(50), nullable=True)
    
    # Specifications
    capacity = Column(Numeric(10, 2), nullable=True)  # tonnes, cubic meters
    capacity_unit = Column(String(20), nullable=True)
    fuel_type = Column(String(50), nullable=True)
    fuel_consumption = Column(Numeric(8, 2), nullable=True)  # liters per hour
    engine_power = Column(Numeric(8, 2), nullable=True)  # horsepower or kW
    
    # Status and maintenance
    status = Column(String(50), nullable=True)  # active, maintenance, retired
    condition = Column(String(50), nullable=True)  # excellent, good, fair, poor
    last_maintenance = Column(DateTime, nullable=True)
    next_maintenance = Column(DateTime, nullable=True)
    maintenance_hours = Column(Numeric(8, 2), default=0, nullable=False)
    
    # Operator and usage
    current_operator_id = Column(Integer, ForeignKey('users.id'), nullable=True)
    daily_usage_hours = Column(Numeric(8, 2), default=0, nullable=False)
    total_usage_hours = Column(Numeric(10, 2), default=0, nullable=False)
    
    # Safety and compliance
    safety_inspection_due = Column(DateTime, nullable=True)
    insurance_expiry = Column(Date, nullable=True)
    registration_expiry = Column(Date, nullable=True)
    
    def to_dict(self):
        """Convert vehicule to dictionary"""
        return {
            'id': self.id,
            'gisement_id': self.gisement_id,
            'name': self.name,
            'type': self.type.value if self.type else None,
            'brand': self.brand,
            'model': self.model,
            'year': self.year,
            'serial_number': self.serial_number,
            'license_plate': self.license_plate,
            'capacity': float(self.capacity) if self.capacity else None,
            'capacity_unit': self.capacity_unit,
            'fuel_type': self.fuel_type,
            'fuel_consumption': float(self.fuel_consumption) if self.fuel_consumption else None,
            'engine_power': float(self.engine_power) if self.engine_power else None,
            'status': self.status,
            'condition': self.condition,
            'last_maintenance': self.last_maintenance.isoformat() if self.last_maintenance else None,
            'next_maintenance': self.next_maintenance.isoformat() if self.next_maintenance else None,
            'maintenance_hours': float(self.maintenance_hours),
            'current_operator_id': self.current_operator_id,
            'daily_usage_hours': float(self.daily_usage_hours),
            'total_usage_hours': float(self.total_usage_hours),
            'safety_inspection_due': self.safety_inspection_due.isoformat() if self.safety_inspection_due else None,
            'insurance_expiry': self.insurance_expiry.isoformat() if self.insurance_expiry else None,
            'registration_expiry': self.registration_expiry.isoformat() if self.registration_expiry else None,
            'location': self.get_location_dict(),
            'metadata': self.metadata,
            'created_at': self.created_at.isoformat() if self.created_at else None,
            'updated_at': self.updated_at.isoformat() if self.updated_at else None
        }

class Production(BaseModel, LocationMixin, MetadataMixin):
    """Mining production record model"""
    __tablename__ = 'productions'
    
    gisement_id = Column(Integer, ForeignKey('gisements.id'), nullable=False)
    user_id = Column(Integer, ForeignKey('users.id'), nullable=False)
    
    # Production details
    production_date = Column(Date, nullable=False)
    shift = Column(String(20), nullable=True)  # day, night, morning, evening
    quantity = Column(Numeric(10, 2), nullable=False)
    unit = Column(String(20), nullable=False)
    
    # Quality metrics
    ore_grade = Column(Numeric(8, 4), nullable=True)
    moisture_content = Column(Numeric(5, 2), nullable=True)  # percentage
    impurities = Column(Numeric(5, 2), nullable=True)  # percentage
    quality_grade = Column(String(20), nullable=True)
    
    # Process details
    extraction_method = Column(String(100), nullable=True)
    processing_method = Column(String(100), nullable=True)
    equipment_used = Column(Text, nullable=True)  # JSON array of equipment IDs
    
    # Environmental impact
    water_used = Column(Numeric(10, 2), nullable=True)  # liters
    energy_consumed = Column(Numeric(10, 2), nullable=True)  # kWh
    waste_generated = Column(Numeric(10, 2), nullable=True)  # tonnes
    emissions = Column(Numeric(10, 2), nullable=True)  # CO2 equivalent
    
    # Economic data
    production_cost = Column(Numeric(15, 2), nullable=True)
    market_value = Column(Numeric(15, 2), nullable=True)
    profit_margin = Column(Numeric(5, 2), nullable=True)  # percentage
    
    # Notes and observations
    notes = Column(Text, nullable=True)
    weather_conditions = Column(Text, nullable=True)  # JSON weather data
    safety_incidents = Column(Text, nullable=True)  # JSON incident data
    
    def to_dict(self):
        """Convert production to dictionary"""
        return {
            'id': self.id,
            'gisement_id': self.gisement_id,
            'user_id': self.user_id,
            'production_date': self.production_date.isoformat() if self.production_date else None,
            'shift': self.shift,
            'quantity': float(self.quantity),
            'unit': self.unit,
            'ore_grade': float(self.ore_grade) if self.ore_grade else None,
            'moisture_content': float(self.moisture_content) if self.moisture_content else None,
            'impurities': float(self.impurities) if self.impurities else None,
            'quality_grade': self.quality_grade,
            'extraction_method': self.extraction_method,
            'processing_method': self.processing_method,
            'equipment_used': self.equipment_used,
            'water_used': float(self.water_used) if self.water_used else None,
            'energy_consumed': float(self.energy_consumed) if self.energy_consumed else None,
            'waste_generated': float(self.waste_generated) if self.waste_generated else None,
            'emissions': float(self.emissions) if self.emissions else None,
            'production_cost': float(self.production_cost) if self.production_cost else None,
            'market_value': float(self.market_value) if self.market_value else None,
            'profit_margin': float(self.profit_margin) if self.profit_margin else None,
            'notes': self.notes,
            'weather_conditions': self.weather_conditions,
            'safety_incidents': self.safety_incidents,
            'location': self.get_location_dict(),
            'metadata': self.metadata,
            'created_at': self.created_at.isoformat() if self.created_at else None,
            'updated_at': self.updated_at.isoformat() if self.updated_at else None
        }

class Incident(BaseModel, LocationMixin, MetadataMixin):
    """Mining safety incident model"""
    __tablename__ = 'incidents'
    
    gisement_id = Column(Integer, ForeignKey('gisements.id'), nullable=True)
    reporter_id = Column(Integer, ForeignKey('users.id'), nullable=False)
    
    # Incident details
    title = Column(String(200), nullable=False)
    description = Column(Text, nullable=False)
    incident_date = Column(DateTime, nullable=False)
    severity = Column(Enum(IncidentSeverity), nullable=False)
    
    # Classification
    incident_type = Column(String(100), nullable=True)  # injury, equipment, environmental, etc.
    category = Column(String(100), nullable=True)  # safety, environmental, operational
    subcategory = Column(String(100), nullable=True)
    
    # People involved
    people_involved = Column(Text, nullable=True)  # JSON array of user IDs
    injured_count = Column(Integer, default=0, nullable=False)
    fatalities_count = Column(Integer, default=0, nullable=False)
    
    # Response and resolution
    immediate_response = Column(Text, nullable=True)
    investigation_required = Column(Boolean, default=False, nullable=False)
    investigation_status = Column(String(50), nullable=True)  # pending, in_progress, completed
    corrective_actions = Column(Text, nullable=True)
    preventive_measures = Column(Text, nullable=True)
    
    # Follow-up
    resolution_date = Column(DateTime, nullable=True)
    resolution_notes = Column(Text, nullable=True)
    lessons_learned = Column(Text, nullable=True)
    
    # Regulatory compliance
    regulatory_notification = Column(Boolean, default=False, nullable=False)
    notification_date = Column(DateTime, nullable=True)
    regulatory_response = Column(Text, nullable=True)
    
    # Media and documentation
    media_files = Column(Text, nullable=True)  # JSON array of file URLs
    witness_statements = Column(Text, nullable=True)  # JSON array of statements
    
    def to_dict(self):
        """Convert incident to dictionary"""
        return {
            'id': self.id,
            'gisement_id': self.gisement_id,
            'reporter_id': self.reporter_id,
            'title': self.title,
            'description': self.description,
            'incident_date': self.incident_date.isoformat() if self.incident_date else None,
            'severity': self.severity.value if self.severity else None,
            'incident_type': self.incident_type,
            'category': self.category,
            'subcategory': self.subcategory,
            'people_involved': self.people_involved,
            'injured_count': self.injured_count,
            'fatalities_count': self.fatalities_count,
            'immediate_response': self.immediate_response,
            'investigation_required': self.investigation_required,
            'investigation_status': self.investigation_status,
            'corrective_actions': self.corrective_actions,
            'preventive_measures': self.preventive_measures,
            'resolution_date': self.resolution_date.isoformat() if self.resolution_date else None,
            'resolution_notes': self.resolution_notes,
            'lessons_learned': self.lessons_learned,
            'regulatory_notification': self.regulatory_notification,
            'notification_date': self.notification_date.isoformat() if self.notification_date else None,
            'regulatory_response': self.regulatory_response,
            'media_files': self.media_files,
            'witness_statements': self.witness_statements,
            'location': self.get_location_dict(),
            'metadata': self.metadata,
            'created_at': self.created_at.isoformat() if self.created_at else None,
            'updated_at': self.updated_at.isoformat() if self.updated_at else None
        }
