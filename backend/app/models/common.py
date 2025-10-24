from datetime import datetime
from app import db
try:
    from geoalchemy2 import Geometry
except ImportError:
    Geometry = None
from sqlalchemy.dialects.postgresql import JSONB
from sqlalchemy import Column, Integer, DateTime, String, Text, Boolean

class BaseModel(db.Model):
    """Base model with common fields"""
    __abstract__ = True
    
    id = Column(Integer, primary_key=True)
    created_at = Column(DateTime, default=datetime.utcnow, nullable=False)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow, nullable=False)
    is_active = Column(Boolean, default=True, nullable=False)
    
    def to_dict(self):
        """Convert model to dictionary"""
        return {
            column.name: getattr(self, column.name)
            for column in self.__table__.columns
        }
    
    def save(self):
        """Save model to database"""
        db.session.add(self)
        db.session.commit()
        return self
    
    def delete(self):
        """Soft delete model"""
        self.is_active = False
        self.updated_at = datetime.utcnow()
        db.session.commit()
        return self
    
    @classmethod
    def get_by_id(cls, id):
        """Get model by ID"""
        return cls.query.filter_by(id=id, is_active=True).first()
    
    @classmethod
    def get_all(cls, page=1, per_page=20):
        """Get all active models with pagination"""
        return cls.query.filter_by(is_active=True).paginate(
            page=page, per_page=per_page, error_out=False
        )

class LocationMixin:
    """Mixin for models with geographic location"""
    latitude = Column(db.Float, nullable=True)
    longitude = Column(db.Float, nullable=True)
    address = Column(Text, nullable=True)
    city = Column(String(100), nullable=True)
    country = Column(String(100), nullable=True)
    postal_code = Column(String(20), nullable=True)
    
    # PostGIS geometry field (if available)
    location = Column(Geometry('POINT', srid=4326), nullable=True) if Geometry else None
    
    def set_location(self, lat, lng, address=None):
        """Set location coordinates"""
        self.latitude = lat
        self.longitude = lng
        self.address = address
        if lat and lng:
            self.location = f'POINT({lng} {lat})'
    
    def get_location_dict(self):
        """Get location as dictionary"""
        return {
            'latitude': self.latitude,
            'longitude': self.longitude,
            'address': self.address,
            'city': self.city,
            'country': self.country,
            'postal_code': self.postal_code
        }

class MetadataMixin:
    """Mixin for models with JSON metadata"""
    metadata = Column(JSONB, nullable=True)
    
    def set_metadata(self, key, value):
        """Set metadata value"""
        if self.metadata is None:
            self.metadata = {}
        self.metadata[key] = value
    
    def get_metadata(self, key, default=None):
        """Get metadata value"""
        if self.metadata is None:
            return default
        return self.metadata.get(key, default)
    
    def update_metadata(self, data):
        """Update metadata with dictionary"""
        if self.metadata is None:
            self.metadata = {}
        self.metadata.update(data)
