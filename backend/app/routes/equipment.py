from flask import Blueprint, request, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity
from sqlalchemy import and_, or_, desc
from app import db
from app.models import Equipment, EquipmentReview, EquipmentStatus, EquipmentCategory, User
from datetime import datetime
import json

equipment_bp = Blueprint('equipment', __name__)

@equipment_bp.route('/equipment', methods=['GET'])
def get_equipment():
    """Récupérer la liste des équipements avec filtres"""
    try:
        # Paramètres de filtrage
        page = request.args.get('page', 1, type=int)
        per_page = request.args.get('per_page', 20, type=int)
        category = request.args.get('category')
        min_rating = request.args.get('min_rating', type=float)
        max_daily_rate = request.args.get('max_daily_rate', type=float)
        is_available = request.args.get('is_available', type=bool)
        search = request.args.get('search')
        latitude = request.args.get('latitude', type=float)
        longitude = request.args.get('longitude', type=float)
        radius = request.args.get('radius', 50, type=float)  # km
        
        # Construction de la requête
        query = Equipment.query.filter(Equipment.is_available == True)
        
        # Filtres
        if category:
            query = query.filter(Equipment.category == EquipmentCategory(category))
        
        if min_rating:
            query = query.filter(Equipment.rating >= min_rating)
            
        if max_daily_rate:
            query = query.filter(Equipment.daily_rate <= max_daily_rate)
            
        if is_available is not None:
            query = query.filter(Equipment.is_available == is_available)
            
        if search:
            search_term = f"%{search}%"
            query = query.filter(
                or_(
                    Equipment.name.ilike(search_term),
                    Equipment.description.ilike(search_term),
                    Equipment.brand.ilike(search_term),
                    Equipment.model.ilike(search_term)
                )
            )
        
        # Tri par défaut
        query = query.order_by(desc(Equipment.rating), desc(Equipment.total_reviews))
        
        # Pagination
        equipment_list = query.paginate(
            page=page, 
            per_page=per_page, 
            error_out=False
        )
        
        return jsonify({
            'equipment': [eq.to_dict() for eq in equipment_list.items],
            'total': equipment_list.total,
            'page': page,
            'per_page': per_page,
            'pages': equipment_list.pages
        }), 200
        
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@equipment_bp.route('/equipment/<int:equipment_id>', methods=['GET'])
def get_equipment_item(equipment_id):
    """Récupérer un équipement spécifique"""
    try:
        equipment = Equipment.query.get_or_404(equipment_id)
        return jsonify(equipment.to_dict()), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@equipment_bp.route('/equipment', methods=['POST'])
@jwt_required()
def create_equipment():
    """Créer un équipement"""
    try:
        current_user_id = get_jwt_identity()
        data = request.get_json()
        
        # Créer l'équipement
        equipment = Equipment(
            name=data['name'],
            description=data.get('description'),
            category=EquipmentCategory(data['category']),
            brand=data.get('brand'),
            model=data.get('model'),
            serial_number=data.get('serial_number'),
            owner_id=current_user_id,
            specifications=data.get('specifications', {}),
            dimensions=data.get('dimensions'),
            weight=data.get('weight'),
            power_rating=data.get('power_rating'),
            fuel_type=data.get('fuel_type'),
            hourly_rate=data.get('hourly_rate'),
            daily_rate=data.get('daily_rate'),
            weekly_rate=data.get('weekly_rate'),
            monthly_rate=data.get('monthly_rate'),
            deposit_amount=data.get('deposit_amount'),
            latitude=data.get('latitude'),
            longitude=data.get('longitude'),
            address=data.get('address'),
            city=data.get('city'),
            country=data.get('country'),
            postal_code=data.get('postal_code'),
            images=data.get('images', []),
            documents=data.get('documents', [])
        )
        
        db.session.add(equipment)
        db.session.commit()
        
        return jsonify(equipment.to_dict()), 201
        
    except Exception as e:
        db.session.rollback()
        return jsonify({'error': str(e)}), 500

@equipment_bp.route('/equipment/<int:equipment_id>', methods=['PUT'])
@jwt_required()
def update_equipment(equipment_id):
    """Mettre à jour un équipement"""
    try:
        current_user_id = get_jwt_identity()
        equipment = Equipment.query.get_or_404(equipment_id)
        
        # Vérifier les permissions
        if equipment.owner_id != current_user_id:
            return jsonify({'error': 'Unauthorized'}), 403
        
        data = request.get_json()
        
        # Mettre à jour les champs
        for field in ['name', 'description', 'brand', 'model', 'serial_number',
                     'specifications', 'dimensions', 'weight', 'power_rating',
                     'fuel_type', 'hourly_rate', 'daily_rate', 'weekly_rate',
                     'monthly_rate', 'deposit_amount', 'latitude', 'longitude',
                     'address', 'city', 'country', 'postal_code', 'images',
                     'documents', 'is_available', 'availability_schedule']:
            if field in data:
                setattr(equipment, field, data[field])
        
        if 'category' in data:
            equipment.category = EquipmentCategory(data['category'])
        
        equipment.updated_at = datetime.utcnow()
        db.session.commit()
        
        return jsonify(equipment.to_dict()), 200
        
    except Exception as e:
        db.session.rollback()
        return jsonify({'error': str(e)}), 500

@equipment_bp.route('/equipment/<int:equipment_id>/reviews', methods=['GET'])
def get_equipment_reviews(equipment_id):
    """Récupérer les avis d'un équipement"""
    try:
        page = request.args.get('page', 1, type=int)
        per_page = request.args.get('per_page', 10, type=int)
        
        reviews = EquipmentReview.query.filter_by(equipment_id=equipment_id)\
            .order_by(desc(EquipmentReview.created_at))\
            .paginate(page=page, per_page=per_page, error_out=False)
        
        return jsonify({
            'reviews': [review.to_dict() for review in reviews.items],
            'total': reviews.total,
            'page': page,
            'per_page': per_page,
            'pages': reviews.pages
        }), 200
        
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@equipment_bp.route('/equipment/<int:equipment_id>/reviews', methods=['POST'])
@jwt_required()
def create_equipment_review(equipment_id):
    """Créer un avis pour un équipement"""
    try:
        current_user_id = get_jwt_identity()
        data = request.get_json()
        
        # Vérifier que l'équipement existe
        equipment = Equipment.query.get_or_404(equipment_id)
        
        # Créer l'avis
        review = EquipmentReview(
            equipment_id=equipment_id,
            client_id=current_user_id,
            rating=data['rating'],
            comment=data.get('comment'),
            condition_rating=data.get('condition_rating'),
            ease_of_use=data.get('ease_of_use'),
            value_for_money=data.get('value_for_money'),
            booking_id=data.get('booking_id')
        )
        
        db.session.add(review)
        
        # Mettre à jour les statistiques de l'équipement
        equipment.total_reviews += 1
        # Recalculer la note moyenne
        all_reviews = EquipmentReview.query.filter_by(equipment_id=equipment_id).all()
        if all_reviews:
            equipment.rating = sum(r.rating for r in all_reviews) / len(all_reviews)
        
        db.session.commit()
        
        return jsonify(review.to_dict()), 201
        
    except Exception as e:
        db.session.rollback()
        return jsonify({'error': str(e)}), 500

@equipment_bp.route('/equipment/categories', methods=['GET'])
def get_equipment_categories():
    """Récupérer les catégories d'équipements disponibles"""
    try:
        categories = [{'value': c.value, 'label': c.value.replace('_', ' ').title()} 
                     for c in EquipmentCategory]
        return jsonify({'categories': categories}), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 500
