from flask import Blueprint, request, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity
from app import db
from app.models.agribusiness import Parcelle, Capteur, Recolte, Produit, ParcelleStatus, CapteurType
from app.models.user import User
from app.utils.validators import validate_coordinates
from app.utils.helpers import clean_filename, generate_random_string
from werkzeug.utils import secure_filename
import os
from datetime import datetime, date

agribusiness_bp = Blueprint('agribusiness', __name__)

# ===== PARCELLES (Agricultural Parcels) =====

@agribusiness_bp.route('/parcelles', methods=['GET'])
@jwt_required()
def get_parcelles():
    """Get all parcelles for current user"""
    try:
        current_user_id = get_jwt_identity()
        
        # Get query parameters
        status = request.args.get('status')
        crop_type = request.args.get('crop_type')
        page = request.args.get('page', 1, type=int)
        per_page = request.args.get('per_page', 20, type=int)
        
        # Build query
        query = Parcelle.query.filter_by(
            owner_id=current_user_id, 
            is_active=True
        )
        
        if status:
            query = query.filter_by(status=ParcelleStatus(status))
        
        if crop_type:
            query = query.filter(Parcelle.crop_type.ilike(f'%{crop_type}%'))
        
        # Paginate results
        results = query.paginate(
            page=page, 
            per_page=per_page, 
            error_out=False
        )
        
        parcelles = [parcelle.to_dict() for parcelle in results.items]
        
        return jsonify({
            'parcelles': parcelles,
            'pagination': {
                'page': results.page,
                'pages': results.pages,
                'per_page': results.per_page,
                'total': results.total,
                'has_next': results.has_next,
                'has_prev': results.has_prev
            }
        }), 200
        
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@agribusiness_bp.route('/parcelles', methods=['POST'])
@jwt_required()
def create_parcelle():
    """Create a new parcelle"""
    try:
        current_user_id = get_jwt_identity()
        data = request.get_json()
        
        # Validate required fields
        if not data.get('name') or not data.get('area_hectares'):
            return jsonify({'error': 'Name and area are required'}), 400
        
        # Validate coordinates if provided
        if 'latitude' in data and 'longitude' in data:
            if not validate_coordinates(data['latitude'], data['longitude']):
                return jsonify({'error': 'Invalid coordinates'}), 400
        
        # Create parcelle
        parcelle = Parcelle(
            name=data['name'],
            description=data.get('description'),
            owner_id=current_user_id,
            area_hectares=data['area_hectares'],
            soil_type=data.get('soil_type'),
            crop_type=data.get('crop_type'),
            variety=data.get('variety'),
            planting_date=datetime.fromisoformat(data['planting_date']).date() if data.get('planting_date') else None,
            expected_harvest_date=datetime.fromisoformat(data['expected_harvest_date']).date() if data.get('expected_harvest_date') else None,
            status=ParcelleStatus(data.get('status', 'preparation')),
            irrigation_system=data.get('irrigation_system'),
            fertilizer_type=data.get('fertilizer_type'),
            climate_zone=data.get('climate_zone'),
            expected_yield=data.get('expected_yield'),
            yield_unit=data.get('yield_unit'),
            market_price=data.get('market_price')
        )
        
        # Set location if provided
        if 'latitude' in data and 'longitude' in data:
            parcelle.set_location(
                data['latitude'], 
                data['longitude'], 
                data.get('address')
            )
        
        db.session.add(parcelle)
        db.session.commit()
        
        return jsonify({
            'message': 'Parcelle created successfully',
            'parcelle': parcelle.to_dict()
        }), 201
        
    except Exception as e:
        db.session.rollback()
        return jsonify({'error': str(e)}), 500

@agribusiness_bp.route('/parcelles/<int:parcelle_id>', methods=['GET'])
@jwt_required()
def get_parcelle(parcelle_id):
    """Get specific parcelle"""
    try:
        current_user_id = get_jwt_identity()
        
        parcelle = Parcelle.query.filter_by(
            id=parcelle_id, 
            owner_id=current_user_id,
            is_active=True
        ).first()
        
        if not parcelle:
            return jsonify({'error': 'Parcelle not found'}), 404
        
        return jsonify({'parcelle': parcelle.to_dict()}), 200
        
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@agribusiness_bp.route('/parcelles/<int:parcelle_id>', methods=['PUT'])
@jwt_required()
def update_parcelle(parcelle_id):
    """Update parcelle"""
    try:
        current_user_id = get_jwt_identity()
        
        parcelle = Parcelle.query.filter_by(
            id=parcelle_id, 
            owner_id=current_user_id,
            is_active=True
        ).first()
        
        if not parcelle:
            return jsonify({'error': 'Parcelle not found'}), 404
        
        data = request.get_json()
        
        # Update fields
        if 'name' in data:
            parcelle.name = data['name']
        if 'description' in data:
            parcelle.description = data['description']
        if 'area_hectares' in data:
            parcelle.area_hectares = data['area_hectares']
        if 'soil_type' in data:
            parcelle.soil_type = data['soil_type']
        if 'crop_type' in data:
            parcelle.crop_type = data['crop_type']
        if 'variety' in data:
            parcelle.variety = data['variety']
        if 'planting_date' in data:
            parcelle.planting_date = datetime.fromisoformat(data['planting_date']).date() if data['planting_date'] else None
        if 'expected_harvest_date' in data:
            parcelle.expected_harvest_date = datetime.fromisoformat(data['expected_harvest_date']).date() if data['expected_harvest_date'] else None
        if 'status' in data:
            parcelle.status = ParcelleStatus(data['status'])
        if 'irrigation_system' in data:
            parcelle.irrigation_system = data['irrigation_system']
        if 'fertilizer_type' in data:
            parcelle.fertilizer_type = data['fertilizer_type']
        if 'last_fertilization' in data:
            parcelle.last_fertilization = datetime.fromisoformat(data['last_fertilization']).date() if data['last_fertilization'] else None
        if 'last_irrigation' in data:
            parcelle.last_irrigation = datetime.fromisoformat(data['last_irrigation']) if data['last_irrigation'] else None
        if 'climate_zone' in data:
            parcelle.climate_zone = data['climate_zone']
        if 'rainfall_mm' in data:
            parcelle.rainfall_mm = data['rainfall_mm']
        if 'temperature_avg' in data:
            parcelle.temperature_avg = data['temperature_avg']
        if 'expected_yield' in data:
            parcelle.expected_yield = data['expected_yield']
        if 'yield_unit' in data:
            parcelle.yield_unit = data['yield_unit']
        if 'market_price' in data:
            parcelle.market_price = data['market_price']
        
        # Update location if provided
        if 'latitude' in data and 'longitude' in data:
            parcelle.set_location(
                data['latitude'], 
                data['longitude'], 
                data.get('address')
            )
        
        db.session.commit()
        
        return jsonify({
            'message': 'Parcelle updated successfully',
            'parcelle': parcelle.to_dict()
        }), 200
        
    except Exception as e:
        db.session.rollback()
        return jsonify({'error': str(e)}), 500

# ===== CAPTEURS (IoT Sensors) =====

@agribusiness_bp.route('/parcelles/<int:parcelle_id>/capteurs', methods=['GET'])
@jwt_required()
def get_parcelle_capteurs(parcelle_id):
    """Get capteurs for a parcelle"""
    try:
        current_user_id = get_jwt_identity()
        
        parcelle = Parcelle.query.filter_by(
            id=parcelle_id, 
            owner_id=current_user_id,
            is_active=True
        ).first()
        
        if not parcelle:
            return jsonify({'error': 'Parcelle not found'}), 404
        
        capteurs = [capteur.to_dict() for capteur in parcelle.capteurs]
        
        return jsonify({'capteurs': capteurs}), 200
        
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@agribusiness_bp.route('/capteurs', methods=['POST'])
@jwt_required()
def create_capteur():
    """Create new capteur"""
    try:
        current_user_id = get_jwt_identity()
        data = request.get_json()
        
        if not data.get('name') or not data.get('type') or not data.get('parcelle_id'):
            return jsonify({'error': 'Name, type and parcelle_id are required'}), 400
        
        # Verify parcelle ownership
        parcelle = Parcelle.query.filter_by(
            id=data['parcelle_id'], 
            owner_id=current_user_id,
            is_active=True
        ).first()
        
        if not parcelle:
            return jsonify({'error': 'Parcelle not found'}), 404
        
        # Create capteur
        capteur = Capteur(
            name=data['name'],
            type=CapteurType(data['type']),
            model=data.get('model'),
            serial_number=data.get('serial_number'),
            parcelle_id=data['parcelle_id'],
            installation_date=datetime.fromisoformat(data['installation_date']) if data.get('installation_date') else None,
            battery_level=data.get('battery_level'),
            is_active=data.get('is_active', True),
            calibration_date=datetime.fromisoformat(data['calibration_date']) if data.get('calibration_date') else None,
            calibration_notes=data.get('calibration_notes'),
            min_value=data.get('min_value'),
            max_value=data.get('max_value'),
            reading_frequency=data.get('reading_frequency', 60),
            unit=data.get('unit')
        )
        
        # Set location if provided
        if 'latitude' in data and 'longitude' in data:
            capteur.set_location(
                data['latitude'], 
                data['longitude'], 
                data.get('address')
            )
        
        db.session.add(capteur)
        db.session.commit()
        
        return jsonify({
            'message': 'Capteur created successfully',
            'capteur': capteur.to_dict()
        }), 201
        
    except Exception as e:
        db.session.rollback()
        return jsonify({'error': str(e)}), 500

@agribusiness_bp.route('/capteurs/<int:capteur_id>/reading', methods=['POST'])
@jwt_required()
def record_capteur_reading(capteur_id):
    """Record sensor reading"""
    try:
        current_user_id = get_jwt_identity()
        data = request.get_json()
        
        capteur = Capteur.query.filter_by(
            id=capteur_id, 
            is_active=True
        ).first()
        
        if not capteur:
            return jsonify({'error': 'Capteur not found'}), 404
        
        # Verify parcelle ownership
        parcelle = Parcelle.query.filter_by(
            id=capteur.parcelle_id, 
            owner_id=current_user_id,
            is_active=True
        ).first()
        
        if not parcelle:
            return jsonify({'error': 'Access denied'}), 403
        
        if not data.get('value'):
            return jsonify({'error': 'Value is required'}), 400
        
        # Update capteur reading
        capteur.last_reading = datetime.utcnow()
        capteur.last_value = data['value']
        
        db.session.commit()
        
        return jsonify({
            'message': 'Reading recorded successfully',
            'capteur': capteur.to_dict()
        }), 200
        
    except Exception as e:
        return jsonify({'error': str(e)}), 500

# ===== RECOLTES (Harvests) =====

@agribusiness_bp.route('/parcelles/<int:parcelle_id>/recoltes', methods=['GET'])
@jwt_required()
def get_parcelle_recoltes(parcelle_id):
    """Get recoltes for a parcelle"""
    try:
        current_user_id = get_jwt_identity()
        
        parcelle = Parcelle.query.filter_by(
            id=parcelle_id, 
            owner_id=current_user_id,
            is_active=True
        ).first()
        
        if not parcelle:
            return jsonify({'error': 'Parcelle not found'}), 404
        
        recoltes = [recolte.to_dict() for recolte in parcelle.recoltes]
        
        return jsonify({'recoltes': recoltes}), 200
        
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@agribusiness_bp.route('/recoltes', methods=['POST'])
@jwt_required()
def create_recolte():
    """Create new recolte"""
    try:
        current_user_id = get_jwt_identity()
        data = request.get_json()
        
        if not data.get('parcelle_id') or not data.get('quantity') or not data.get('unit'):
            return jsonify({'error': 'Parcelle ID, quantity and unit are required'}), 400
        
        # Verify parcelle ownership
        parcelle = Parcelle.query.filter_by(
            id=data['parcelle_id'], 
            owner_id=current_user_id,
            is_active=True
        ).first()
        
        if not parcelle:
            return jsonify({'error': 'Parcelle not found'}), 404
        
        # Create recolte
        recolte = Recolte(
            parcelle_id=data['parcelle_id'],
            user_id=current_user_id,
            harvest_date=datetime.fromisoformat(data['harvest_date']).date() if data.get('harvest_date') else date.today(),
            quantity=data['quantity'],
            unit=data['unit'],
            quality_grade=data.get('quality_grade'),
            moisture_content=data.get('moisture_content'),
            protein_content=data.get('protein_content'),
            other_quality_metrics=data.get('other_quality_metrics'),
            market_price=data.get('market_price'),
            total_value=data.get('total_value'),
            buyer=data.get('buyer'),
            sale_date=datetime.fromisoformat(data['sale_date']).date() if data.get('sale_date') else None,
            storage_location=data.get('storage_location'),
            processing_method=data.get('processing_method'),
            packaging_type=data.get('packaging_type'),
            notes=data.get('notes'),
            weather_conditions=data.get('weather_conditions')
        )
        
        # Set location if provided
        if 'latitude' in data and 'longitude' in data:
            recolte.set_location(
                data['latitude'], 
                data['longitude'], 
                data.get('address')
            )
        
        db.session.add(recolte)
        db.session.commit()
        
        return jsonify({
            'message': 'Recolte created successfully',
            'recolte': recolte.to_dict()
        }), 201
        
    except Exception as e:
        db.session.rollback()
        return jsonify({'error': str(e)}), 500

# ===== PRODUITS (Marketplace Products) =====

@agribusiness_bp.route('/produits', methods=['GET'])
@jwt_required()
def get_produits():
    """Get all produits (marketplace)"""
    try:
        # Get query parameters
        category = request.args.get('category')
        seller_id = request.args.get('seller_id')
        latitude = request.args.get('latitude', type=float)
        longitude = request.args.get('longitude', type=float)
        radius = request.args.get('radius', 50, type=int)
        page = request.args.get('page', 1, type=int)
        per_page = request.args.get('per_page', 20, type=int)
        
        # Build query
        query = Produit.query.filter_by(is_available=True, is_active=True)
        
        if category:
            query = query.filter(Produit.category.ilike(f'%{category}%'))
        
        if seller_id:
            query = query.filter_by(seller_id=seller_id)
        
        # Filter by location if provided
        if latitude and longitude:
            # This is a simplified distance filter
            # In production, use PostGIS spatial queries
            query = query.filter(
                Produit.latitude.isnot(None),
                Produit.longitude.isnot(None)
            )
        
        # Paginate results
        results = query.paginate(
            page=page, 
            per_page=per_page, 
            error_out=False
        )
        
        produits = [produit.to_dict() for produit in results.items]
        
        return jsonify({
            'produits': produits,
            'pagination': {
                'page': results.page,
                'pages': results.pages,
                'per_page': results.per_page,
                'total': results.total,
                'has_next': results.has_next,
                'has_prev': results.has_prev
            }
        }), 200
        
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@agribusiness_bp.route('/produits', methods=['POST'])
@jwt_required()
def create_produit():
    """Create new produit for marketplace"""
    try:
        current_user_id = get_jwt_identity()
        data = request.get_json()
        
        if not data.get('name') or not data.get('price_per_unit') or not data.get('unit'):
            return jsonify({'error': 'Name, price_per_unit and unit are required'}), 400
        
        # Create produit
        produit = Produit(
            name=data['name'],
            description=data.get('description'),
            category=data.get('category'),
            variety=data.get('variety'),
            seller_id=current_user_id,
            price_per_unit=data['price_per_unit'],
            unit=data['unit'],
            min_quantity=data.get('min_quantity'),
            max_quantity=data.get('max_quantity'),
            available_quantity=data.get('available_quantity', 0),
            quality_grade=data.get('quality_grade'),
            organic_certified=data.get('organic_certified', False),
            certification_number=data.get('certification_number'),
            harvest_date=datetime.fromisoformat(data['harvest_date']).date() if data.get('harvest_date') else None,
            expiry_date=datetime.fromisoformat(data['expiry_date']).date() if data.get('expiry_date') else None,
            featured=data.get('featured', False),
            image_urls=data.get('image_urls')
        )
        
        # Set location if provided
        if 'latitude' in data and 'longitude' in data:
            produit.set_location(
                data['latitude'], 
                data['longitude'], 
                data.get('address')
            )
        
        db.session.add(produit)
        db.session.commit()
        
        return jsonify({
            'message': 'Produit created successfully',
            'produit': produit.to_dict()
        }), 201
        
    except Exception as e:
        db.session.rollback()
        return jsonify({'error': str(e)}), 500

@agribusiness_bp.route('/produits/<int:produit_id>', methods=['GET'])
@jwt_required()
def get_produit(produit_id):
    """Get specific produit"""
    try:
        produit = Produit.query.filter_by(
            id=produit_id, 
            is_active=True
        ).first()
        
        if not produit:
            return jsonify({'error': 'Produit not found'}), 404
        
        # Increment view count
        produit.views_count += 1
        db.session.commit()
        
        return jsonify({'produit': produit.to_dict()}), 200
        
    except Exception as e:
        return jsonify({'error': str(e)}), 500
