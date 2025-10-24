from flask import Blueprint, request, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity
from app import db
from app.models.mining import Gisement, Vehicule, Production, Incident, GisementStatus, VehiculeType, IncidentSeverity
from app.models.user import User
from app.utils.validators import validate_coordinates
from app.utils.helpers import clean_filename, generate_random_string
from werkzeug.utils import secure_filename
import os
from datetime import datetime, date

mining_bp = Blueprint('mining', __name__)

# ===== GISEMENTS (Mining Deposits) =====

@mining_bp.route('/gisements', methods=['GET'])
@jwt_required()
def get_gisements():
    """Get all gisements for current user"""
    try:
        current_user_id = get_jwt_identity()
        
        # Get query parameters
        status = request.args.get('status')
        mineral_type = request.args.get('mineral_type')
        page = request.args.get('page', 1, type=int)
        per_page = request.args.get('per_page', 20, type=int)
        
        # Build query
        query = Gisement.query.filter_by(
            company_id=current_user_id, 
            is_active=True
        )
        
        if status:
            query = query.filter_by(status=GisementStatus(status))
        
        if mineral_type:
            query = query.filter(Gisement.mineral_type.ilike(f'%{mineral_type}%'))
        
        # Paginate results
        results = query.paginate(
            page=page, 
            per_page=per_page, 
            error_out=False
        )
        
        gisements = [gisement.to_dict() for gisement in results.items]
        
        return jsonify({
            'gisements': gisements,
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

@mining_bp.route('/gisements', methods=['POST'])
@jwt_required()
def create_gisement():
    """Create a new gisement"""
    try:
        current_user_id = get_jwt_identity()
        data = request.get_json()
        
        # Validate required fields
        if not data.get('name') or not data.get('mineral_type'):
            return jsonify({'error': 'Name and mineral_type are required'}), 400
        
        # Validate coordinates if provided
        if 'latitude' in data and 'longitude' in data:
            if not validate_coordinates(data['latitude'], data['longitude']):
                return jsonify({'error': 'Invalid coordinates'}), 400
        
        # Create gisement
        gisement = Gisement(
            name=data['name'],
            description=data.get('description'),
            company_id=current_user_id,
            mineral_type=data['mineral_type'],
            deposit_type=data.get('deposit_type'),
            status=GisementStatus(data.get('status', 'exploration')),
            estimated_reserves=data.get('estimated_reserves'),
            reserves_unit=data.get('reserves_unit'),
            ore_grade=data.get('ore_grade'),
            depth_meters=data.get('depth_meters'),
            daily_production=data.get('daily_production'),
            monthly_production=data.get('monthly_production'),
            annual_production=data.get('annual_production'),
            production_unit=data.get('production_unit'),
            environmental_impact=data.get('environmental_impact'),
            reclamation_plan=data.get('reclamation_plan'),
            water_usage=data.get('water_usage'),
            energy_consumption=data.get('energy_consumption'),
            safety_rating=data.get('safety_rating'),
            compliance_score=data.get('compliance_score'),
            last_inspection=datetime.fromisoformat(data['last_inspection']) if data.get('last_inspection') else None,
            next_inspection=datetime.fromisoformat(data['next_inspection']) if data.get('next_inspection') else None
        )
        
        # Set location if provided
        if 'latitude' in data and 'longitude' in data:
            gisement.set_location(
                data['latitude'], 
                data['longitude'], 
                data.get('address')
            )
        
        db.session.add(gisement)
        db.session.commit()
        
        return jsonify({
            'message': 'Gisement created successfully',
            'gisement': gisement.to_dict()
        }), 201
        
    except Exception as e:
        db.session.rollback()
        return jsonify({'error': str(e)}), 500

@mining_bp.route('/gisements/<int:gisement_id>', methods=['GET'])
@jwt_required()
def get_gisement(gisement_id):
    """Get specific gisement"""
    try:
        current_user_id = get_jwt_identity()
        
        gisement = Gisement.query.filter_by(
            id=gisement_id, 
            company_id=current_user_id,
            is_active=True
        ).first()
        
        if not gisement:
            return jsonify({'error': 'Gisement not found'}), 404
        
        return jsonify({'gisement': gisement.to_dict()}), 200
        
    except Exception as e:
        return jsonify({'error': str(e)}), 500

# ===== VEHICULES (Mining Vehicles) =====

@mining_bp.route('/gisements/<int:gisement_id>/vehicules', methods=['GET'])
@jwt_required()
def get_gisement_vehicules(gisement_id):
    """Get vehicules for a gisement"""
    try:
        current_user_id = get_jwt_identity()
        
        gisement = Gisement.query.filter_by(
            id=gisement_id, 
            company_id=current_user_id,
            is_active=True
        ).first()
        
        if not gisement:
            return jsonify({'error': 'Gisement not found'}), 404
        
        vehicules = [vehicule.to_dict() for vehicule in gisement.vehicules]
        
        return jsonify({'vehicules': vehicules}), 200
        
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@mining_bp.route('/vehicules', methods=['POST'])
@jwt_required()
def create_vehicule():
    """Create new vehicule"""
    try:
        current_user_id = get_jwt_identity()
        data = request.get_json()
        
        if not data.get('name') or not data.get('type'):
            return jsonify({'error': 'Name and type are required'}), 400
        
        # Create vehicule
        vehicule = Vehicule(
            name=data['name'],
            type=VehiculeType(data['type']),
            brand=data.get('brand'),
            model=data.get('model'),
            year=data.get('year'),
            serial_number=data.get('serial_number'),
            license_plate=data.get('license_plate'),
            capacity=data.get('capacity'),
            capacity_unit=data.get('capacity_unit'),
            fuel_type=data.get('fuel_type'),
            fuel_consumption=data.get('fuel_consumption'),
            engine_power=data.get('engine_power'),
            status=data.get('status'),
            condition=data.get('condition'),
            last_maintenance=datetime.fromisoformat(data['last_maintenance']) if data.get('last_maintenance') else None,
            next_maintenance=datetime.fromisoformat(data['next_maintenance']) if data.get('next_maintenance') else None,
            current_operator_id=data.get('current_operator_id'),
            safety_inspection_due=datetime.fromisoformat(data['safety_inspection_due']) if data.get('safety_inspection_due') else None,
            insurance_expiry=datetime.fromisoformat(data['insurance_expiry']).date() if data.get('insurance_expiry') else None,
            registration_expiry=datetime.fromisoformat(data['registration_expiry']).date() if data.get('registration_expiry') else None,
            gisement_id=data.get('gisement_id')
        )
        
        # Set location if provided
        if 'latitude' in data and 'longitude' in data:
            vehicule.set_location(
                data['latitude'], 
                data['longitude'], 
                data.get('address')
            )
        
        db.session.add(vehicule)
        db.session.commit()
        
        return jsonify({
            'message': 'Vehicule created successfully',
            'vehicule': vehicule.to_dict()
        }), 201
        
    except Exception as e:
        db.session.rollback()
        return jsonify({'error': str(e)}), 500

@mining_bp.route('/vehicules/<int:vehicule_id>/usage', methods=['POST'])
@jwt_required()
def record_vehicule_usage(vehicule_id):
    """Record vehicule usage"""
    try:
        current_user_id = get_jwt_identity()
        data = request.get_json()
        
        vehicule = Vehicule.query.filter_by(
            id=vehicule_id, 
            is_active=True
        ).first()
        
        if not vehicule:
            return jsonify({'error': 'Vehicule not found'}), 404
        
        if not data.get('hours_used'):
            return jsonify({'error': 'Hours used is required'}), 400
        
        # Update vehicule usage
        vehicule.daily_usage_hours += data['hours_used']
        vehicule.total_usage_hours += data['hours_used']
        vehicule.current_operator_id = current_user_id
        
        db.session.commit()
        
        return jsonify({
            'message': 'Usage recorded successfully',
            'vehicule': vehicule.to_dict()
        }), 200
        
    except Exception as e:
        return jsonify({'error': str(e)}), 500

# ===== PRODUCTION =====

@mining_bp.route('/gisements/<int:gisement_id>/productions', methods=['GET'])
@jwt_required()
def get_gisement_productions(gisement_id):
    """Get productions for a gisement"""
    try:
        current_user_id = get_jwt_identity()
        
        gisement = Gisement.query.filter_by(
            id=gisement_id, 
            company_id=current_user_id,
            is_active=True
        ).first()
        
        if not gisement:
            return jsonify({'error': 'Gisement not found'}), 404
        
        # Get query parameters
        start_date = request.args.get('start_date')
        end_date = request.args.get('end_date')
        page = request.args.get('page', 1, type=int)
        per_page = request.args.get('per_page', 20, type=int)
        
        # Build query
        query = Production.query.filter_by(gisement_id=gisement_id, is_active=True)
        
        if start_date:
            query = query.filter(Production.production_date >= datetime.fromisoformat(start_date).date())
        
        if end_date:
            query = query.filter(Production.production_date <= datetime.fromisoformat(end_date).date())
        
        # Paginate results
        results = query.paginate(
            page=page, 
            per_page=per_page, 
            error_out=False
        )
        
        productions = [production.to_dict() for production in results.items]
        
        return jsonify({
            'productions': productions,
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

@mining_bp.route('/productions', methods=['POST'])
@jwt_required()
def create_production():
    """Create new production record"""
    try:
        current_user_id = get_jwt_identity()
        data = request.get_json()
        
        if not data.get('gisement_id') or not data.get('quantity') or not data.get('unit'):
            return jsonify({'error': 'Gisement ID, quantity and unit are required'}), 400
        
        # Verify gisement ownership
        gisement = Gisement.query.filter_by(
            id=data['gisement_id'], 
            company_id=current_user_id,
            is_active=True
        ).first()
        
        if not gisement:
            return jsonify({'error': 'Gisement not found'}), 404
        
        # Create production
        production = Production(
            gisement_id=data['gisement_id'],
            user_id=current_user_id,
            production_date=datetime.fromisoformat(data['production_date']).date() if data.get('production_date') else date.today(),
            shift=data.get('shift'),
            quantity=data['quantity'],
            unit=data['unit'],
            ore_grade=data.get('ore_grade'),
            moisture_content=data.get('moisture_content'),
            impurities=data.get('impurities'),
            quality_grade=data.get('quality_grade'),
            extraction_method=data.get('extraction_method'),
            processing_method=data.get('processing_method'),
            equipment_used=data.get('equipment_used'),
            water_used=data.get('water_used'),
            energy_consumed=data.get('energy_consumed'),
            waste_generated=data.get('waste_generated'),
            emissions=data.get('emissions'),
            production_cost=data.get('production_cost'),
            market_value=data.get('market_value'),
            profit_margin=data.get('profit_margin'),
            notes=data.get('notes'),
            weather_conditions=data.get('weather_conditions'),
            safety_incidents=data.get('safety_incidents')
        )
        
        # Set location if provided
        if 'latitude' in data and 'longitude' in data:
            production.set_location(
                data['latitude'], 
                data['longitude'], 
                data.get('address')
            )
        
        db.session.add(production)
        db.session.commit()
        
        return jsonify({
            'message': 'Production recorded successfully',
            'production': production.to_dict()
        }), 201
        
    except Exception as e:
        db.session.rollback()
        return jsonify({'error': str(e)}), 500

# ===== INCIDENTS (Safety Incidents) =====

@mining_bp.route('/gisements/<int:gisement_id>/incidents', methods=['GET'])
@jwt_required()
def get_gisement_incidents(gisement_id):
    """Get incidents for a gisement"""
    try:
        current_user_id = get_jwt_identity()
        
        gisement = Gisement.query.filter_by(
            id=gisement_id, 
            company_id=current_user_id,
            is_active=True
        ).first()
        
        if not gisement:
            return jsonify({'error': 'Gisement not found'}), 404
        
        # Get query parameters
        severity = request.args.get('severity')
        incident_type = request.args.get('incident_type')
        page = request.args.get('page', 1, type=int)
        per_page = request.args.get('per_page', 20, type=int)
        
        # Build query
        query = Incident.query.filter_by(gisement_id=gisement_id, is_active=True)
        
        if severity:
            query = query.filter_by(severity=IncidentSeverity(severity))
        
        if incident_type:
            query = query.filter(Incident.incident_type.ilike(f'%{incident_type}%'))
        
        # Paginate results
        results = query.paginate(
            page=page, 
            per_page=per_page, 
            error_out=False
        )
        
        incidents = [incident.to_dict() for incident in results.items]
        
        return jsonify({
            'incidents': incidents,
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

@mining_bp.route('/incidents', methods=['POST'])
@jwt_required()
def create_incident():
    """Create new incident report"""
    try:
        current_user_id = get_jwt_identity()
        data = request.get_json()
        
        if not data.get('title') or not data.get('description') or not data.get('severity'):
            return jsonify({'error': 'Title, description and severity are required'}), 400
        
        # Create incident
        incident = Incident(
            gisement_id=data.get('gisement_id'),
            reporter_id=current_user_id,
            title=data['title'],
            description=data['description'],
            incident_date=datetime.fromisoformat(data['incident_date']) if data.get('incident_date') else datetime.utcnow(),
            severity=IncidentSeverity(data['severity']),
            incident_type=data.get('incident_type'),
            category=data.get('category'),
            subcategory=data.get('subcategory'),
            people_involved=data.get('people_involved'),
            injured_count=data.get('injured_count', 0),
            fatalities_count=data.get('fatalities_count', 0),
            immediate_response=data.get('immediate_response'),
            investigation_required=data.get('investigation_required', False),
            investigation_status=data.get('investigation_status'),
            corrective_actions=data.get('corrective_actions'),
            preventive_measures=data.get('preventive_measures'),
            regulatory_notification=data.get('regulatory_notification', False),
            media_files=data.get('media_files'),
            witness_statements=data.get('witness_statements')
        )
        
        # Set location if provided
        if 'latitude' in data and 'longitude' in data:
            incident.set_location(
                data['latitude'], 
                data['longitude'], 
                data.get('address')
            )
        
        db.session.add(incident)
        db.session.commit()
        
        return jsonify({
            'message': 'Incident reported successfully',
            'incident': incident.to_dict()
        }), 201
        
    except Exception as e:
        db.session.rollback()
        return jsonify({'error': str(e)}), 500

@mining_bp.route('/incidents/<int:incident_id>', methods=['PUT'])
@jwt_required()
def update_incident(incident_id):
    """Update incident report"""
    try:
        current_user_id = get_jwt_identity()
        
        incident = Incident.query.filter_by(
            id=incident_id, 
            reporter_id=current_user_id,
            is_active=True
        ).first()
        
        if not incident:
            return jsonify({'error': 'Incident not found'}), 404
        
        data = request.get_json()
        
        # Update fields
        if 'title' in data:
            incident.title = data['title']
        if 'description' in data:
            incident.description = data['description']
        if 'severity' in data:
            incident.severity = IncidentSeverity(data['severity'])
        if 'incident_type' in data:
            incident.incident_type = data['incident_type']
        if 'category' in data:
            incident.category = data['category']
        if 'subcategory' in data:
            incident.subcategory = data['subcategory']
        if 'people_involved' in data:
            incident.people_involved = data['people_involved']
        if 'injured_count' in data:
            incident.injured_count = data['injured_count']
        if 'fatalities_count' in data:
            incident.fatalities_count = data['fatalities_count']
        if 'immediate_response' in data:
            incident.immediate_response = data['immediate_response']
        if 'investigation_required' in data:
            incident.investigation_required = data['investigation_required']
        if 'investigation_status' in data:
            incident.investigation_status = data['investigation_status']
        if 'corrective_actions' in data:
            incident.corrective_actions = data['corrective_actions']
        if 'preventive_measures' in data:
            incident.preventive_measures = data['preventive_measures']
        if 'resolution_date' in data:
            incident.resolution_date = datetime.fromisoformat(data['resolution_date']) if data['resolution_date'] else None
        if 'resolution_notes' in data:
            incident.resolution_notes = data['resolution_notes']
        if 'lessons_learned' in data:
            incident.lessons_learned = data['lessons_learned']
        if 'regulatory_notification' in data:
            incident.regulatory_notification = data['regulatory_notification']
        if 'regulatory_response' in data:
            incident.regulatory_response = data['regulatory_response']
        
        db.session.commit()
        
        return jsonify({
            'message': 'Incident updated successfully',
            'incident': incident.to_dict()
        }), 200
        
    except Exception as e:
        db.session.rollback()
        return jsonify({'error': str(e)}), 500
