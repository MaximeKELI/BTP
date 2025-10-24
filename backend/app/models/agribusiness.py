from datetime import datetime
from app import db
from .common import BaseModel, LocationMixin, MetadataMixin
from sqlalchemy import Column, String, Text, Integer, ForeignKey, Numeric, DateTime, Boolean, Enum, Date
import enum

class ParcelleStatus(enum.Enum):
    PREPARATION = "preparation"
    PLANTED = "planted"
    GROWING = "growing"
    HARVESTING = "harvesting"
    FALLOW = "fallow"
    ABANDONED = "abandoned"

class CapteurType(enum.Enum):
    TEMPERATURE = "temperature"
    HUMIDITY = "humidity"
    PH = "ph"
    NUTRIENTS = "nutrients"
    WEATHER = "weather"
    SOIL = "soil"

class Parcelle(BaseModel, LocationMixin, MetadataMixin):
    """Agricultural parcel model"""
    __tablename__ = 'parcelles'
    
    # Basic info
    name = Column(String(200), nullable=False)
    description = Column(Text, nullable=True)
    owner_id = Column(Integer, ForeignKey('users.id'), nullable=False)
    
    # Parcel details
    area_hectares = Column(Numeric(10, 4), nullable=False)
    soil_type = Column(String(100), nullable=True)
    crop_type = Column(String(100), nullable=True)
    variety = Column(String(100), nullable=True)
    planting_date = Column(Date, nullable=True)
    expected_harvest_date = Column(Date, nullable=True)
    status = Column(Enum(ParcelleStatus), default=ParcelleStatus.PREPARATION, nullable=False)
    
    # Agricultural data
    irrigation_system = Column(String(100), nullable=True)
    fertilizer_type = Column(String(100), nullable=True)
    last_fertilization = Column(Date, nullable=True)
    last_irrigation = Column(DateTime, nullable=True)
    
    # Weather and conditions
    climate_zone = Column(String(100), nullable=True)
    rainfall_mm = Column(Numeric(8, 2), nullable=True)
    temperature_avg = Column(Numeric(5, 2), nullable=True)
    
    # Production estimates
    expected_yield = Column(Numeric(10, 2), nullable=True)
    yield_unit = Column(String(20), nullable=True)  # kg, tonnes, etc.
    market_price = Column(Numeric(10, 2), nullable=True)
    
    # Relationships
    capteurs = db.relationship('Capteur', backref='parcelle', lazy='dynamic', cascade='all, delete-orphan')
    recoltes = db.relationship('Recolte', backref='parcelle', lazy='dynamic', cascade='all, delete-orphan')
    
    def to_dict(self):
        """Convert parcelle to dictionary"""
        return {
            'id': self.id,
            'name': self.name,
            'description': self.description,
            'owner_id': self.owner_id,
            'area_hectares': float(self.area_hectares),
            'soil_type': self.soil_type,
            'crop_type': self.crop_type,
            'variety': self.variety,
            'planting_date': self.planting_date.isoformat() if self.planting_date else None,
            'expected_harvest_date': self.expected_harvest_date.isoformat() if self.expected_harvest_date else None,
            'status': self.status.value if self.status else None,
            'irrigation_system': self.irrigation_system,
            'fertilizer_type': self.fertilizer_type,
            'last_fertilization': self.last_fertilization.isoformat() if self.last_fertilization else None,
            'last_irrigation': self.last_irrigation.isoformat() if self.last_irrigation else None,
            'climate_zone': self.climate_zone,
            'rainfall_mm': float(self.rainfall_mm) if self.rainfall_mm else None,
            'temperature_avg': float(self.temperature_avg) if self.temperature_avg else None,
            'expected_yield': float(self.expected_yield) if self.expected_yield else None,
            'yield_unit': self.yield_unit,
            'market_price': float(self.market_price) if self.market_price else None,
            'location': self.get_location_dict(),
            'metadata': self.metadata,
            'created_at': self.created_at.isoformat() if self.created_at else None,
            'updated_at': self.updated_at.isoformat() if self.updated_at else None
        }

class Capteur(BaseModel, LocationMixin, MetadataMixin):
    """IoT sensor model for agriculture"""
    __tablename__ = 'capteurs'
    
    parcelle_id = Column(Integer, ForeignKey('parcelles.id'), nullable=False)
    
    # Sensor info
    name = Column(String(200), nullable=False)
    type = Column(Enum(CapteurType), nullable=False)
    model = Column(String(100), nullable=True)
    serial_number = Column(String(100), nullable=True)
    
    # Installation
    installation_date = Column(DateTime, nullable=True)
    battery_level = Column(Integer, nullable=True)  # percentage
    is_active = Column(Boolean, default=True, nullable=False)
    
    # Calibration
    calibration_date = Column(DateTime, nullable=True)
    calibration_notes = Column(Text, nullable=True)
    min_value = Column(Numeric(10, 4), nullable=True)
    max_value = Column(Numeric(10, 4), nullable=True)
    
    # Data collection
    reading_frequency = Column(Integer, default=60, nullable=False)  # minutes
    last_reading = Column(DateTime, nullable=True)
    last_value = Column(Numeric(10, 4), nullable=True)
    unit = Column(String(20), nullable=True)
    
    def to_dict(self):
        """Convert capteur to dictionary"""
        return {
            'id': self.id,
            'parcelle_id': self.parcelle_id,
            'name': self.name,
            'type': self.type.value if self.type else None,
            'model': self.model,
            'serial_number': self.serial_number,
            'installation_date': self.installation_date.isoformat() if self.installation_date else None,
            'battery_level': self.battery_level,
            'is_active': self.is_active,
            'calibration_date': self.calibration_date.isoformat() if self.calibration_date else None,
            'calibration_notes': self.calibration_notes,
            'min_value': float(self.min_value) if self.min_value else None,
            'max_value': float(self.max_value) if self.max_value else None,
            'reading_frequency': self.reading_frequency,
            'last_reading': self.last_reading.isoformat() if self.last_reading else None,
            'last_value': float(self.last_value) if self.last_value else None,
            'unit': self.unit,
            'location': self.get_location_dict(),
            'metadata': self.metadata,
            'created_at': self.created_at.isoformat() if self.created_at else None,
            'updated_at': self.updated_at.isoformat() if self.updated_at else None
        }

class Recolte(BaseModel, LocationMixin, MetadataMixin):
    """Harvest record model"""
    __tablename__ = 'recoltes'
    
    parcelle_id = Column(Integer, ForeignKey('parcelles.id'), nullable=False)
    user_id = Column(Integer, ForeignKey('users.id'), nullable=False)
    
    # Harvest details
    harvest_date = Column(Date, nullable=False)
    quantity = Column(Numeric(10, 2), nullable=False)
    unit = Column(String(20), nullable=False)
    quality_grade = Column(String(20), nullable=True)  # A, B, C, etc.
    
    # Quality metrics
    moisture_content = Column(Numeric(5, 2), nullable=True)  # percentage
    protein_content = Column(Numeric(5, 2), nullable=True)  # percentage
    other_quality_metrics = Column(Text, nullable=True)  # JSON
    
    # Market info
    market_price = Column(Numeric(10, 2), nullable=True)
    total_value = Column(Numeric(15, 2), nullable=True)
    buyer = Column(String(100), nullable=True)
    sale_date = Column(Date, nullable=True)
    
    # Storage and processing
    storage_location = Column(String(200), nullable=True)
    processing_method = Column(String(100), nullable=True)
    packaging_type = Column(String(100), nullable=True)
    
    # Notes
    notes = Column(Text, nullable=True)
    weather_conditions = Column(Text, nullable=True)  # JSON weather data
    
    def to_dict(self):
        """Convert recolte to dictionary"""
        return {
            'id': self.id,
            'parcelle_id': self.parcelle_id,
            'user_id': self.user_id,
            'harvest_date': self.harvest_date.isoformat() if self.harvest_date else None,
            'quantity': float(self.quantity),
            'unit': self.unit,
            'quality_grade': self.quality_grade,
            'moisture_content': float(self.moisture_content) if self.moisture_content else None,
            'protein_content': float(self.protein_content) if self.protein_content else None,
            'other_quality_metrics': self.other_quality_metrics,
            'market_price': float(self.market_price) if self.market_price else None,
            'total_value': float(self.total_value) if self.total_value else None,
            'buyer': self.buyer,
            'sale_date': self.sale_date.isoformat() if self.sale_date else None,
            'storage_location': self.storage_location,
            'processing_method': self.processing_method,
            'packaging_type': self.packaging_type,
            'notes': self.notes,
            'weather_conditions': self.weather_conditions,
            'location': self.get_location_dict(),
            'metadata': self.metadata,
            'created_at': self.created_at.isoformat() if self.created_at else None,
            'updated_at': self.updated_at.isoformat() if self.updated_at else None
        }

class Produit(BaseModel, LocationMixin, MetadataMixin):
    """Agricultural product model for marketplace"""
    __tablename__ = 'produits'
    
    seller_id = Column(Integer, ForeignKey('users.id'), nullable=False)
    
    # Product info
    name = Column(String(200), nullable=False)
    description = Column(Text, nullable=True)
    category = Column(String(100), nullable=True)  # fruits, vegetables, grains, etc.
    variety = Column(String(100), nullable=True)
    
    # Pricing
    price_per_unit = Column(Numeric(10, 2), nullable=False)
    unit = Column(String(20), nullable=False)  # kg, piece, bag, etc.
    min_quantity = Column(Numeric(10, 2), nullable=True)
    max_quantity = Column(Numeric(10, 2), nullable=True)
    available_quantity = Column(Numeric(10, 2), nullable=False)
    
    # Quality and certification
    quality_grade = Column(String(20), nullable=True)
    organic_certified = Column(Boolean, default=False, nullable=False)
    certification_number = Column(String(100), nullable=True)
    harvest_date = Column(Date, nullable=True)
    expiry_date = Column(Date, nullable=True)
    
    # Marketplace
    is_available = Column(Boolean, default=True, nullable=False)
    featured = Column(Boolean, default=False, nullable=False)
    views_count = Column(Integer, default=0, nullable=False)
    orders_count = Column(Integer, default=0, nullable=False)
    
    # Images
    image_urls = Column(Text, nullable=True)  # JSON array of image URLs
    
    def to_dict(self):
        """Convert produit to dictionary"""
        return {
            'id': self.id,
            'seller_id': self.seller_id,
            'name': self.name,
            'description': self.description,
            'category': self.category,
            'variety': self.variety,
            'price_per_unit': float(self.price_per_unit),
            'unit': self.unit,
            'min_quantity': float(self.min_quantity) if self.min_quantity else None,
            'max_quantity': float(self.max_quantity) if self.max_quantity else None,
            'available_quantity': float(self.available_quantity),
            'quality_grade': self.quality_grade,
            'organic_certified': self.organic_certified,
            'certification_number': self.certification_number,
            'harvest_date': self.harvest_date.isoformat() if self.harvest_date else None,
            'expiry_date': self.expiry_date.isoformat() if self.expiry_date else None,
            'is_available': self.is_available,
            'featured': self.featured,
            'views_count': self.views_count,
            'orders_count': self.orders_count,
            'image_urls': self.image_urls,
            'location': self.get_location_dict(),
            'metadata': self.metadata,
            'created_at': self.created_at.isoformat() if self.created_at else None,
            'updated_at': self.updated_at.isoformat() if self.updated_at else None
        }
