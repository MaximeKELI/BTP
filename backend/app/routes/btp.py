from flask import Blueprint, request, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity
from app import db
from app.models.btp import Chantier, Equipe, Materiel, PhotoChantier, ChantierStatus
from app.models.user import User
from app.utils.validators import validate_coordinates
from app.utils.helpers import clean_filename, generate_project_code
from werkzeug.utils import secure_filename
import os
from datetime import datetime

btp_bp = Blueprint('btp', __name__)

# ===== CHANTIERS (Construction Sites) =====

@btp_bp.route('/chantiers', methods=['GET'])
@jwt_required()
def get_chantiers():
    """Get all chantiers for current user"""
    try:
        current_user_id = get_jwt_identity()
        
        # Get query parameters
        status = request.args.get('status')
        page = request.args.get('page', 1, type=int)
        per_page = request.args.get('per_page', 20, type=int)
        
        # Build query
        query = Chantier.query.filter_by(is_active=True)
        
        # Filter by manager or team member
        query = query.filter(
            (Chantier.manager_id == current_user_id) |
            (Chantier.equipes.any(Equipe.user_id == current_user_id))
        )
        
        if status:
            query = query.filter_by(status=ChantierStatus(status))
        
        # Paginate results
        results = query.paginate(
            page=page, 
            per_page=per_page, 
            error_out=False
        )
        
        chantiers = [chantier.to_dict() for chantier in results.items]
        
        return jsonify({
            'chantiers': chantiers,
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

@btp_bp.route('/chantiers', methods=['POST'])
@jwt_required()
def create_chantier():
    """Create a new chantier"""
    try:
        current_user_id = get_jwt_identity()
        data = request.get_json()
        
        # Validate required fields
        if not data.get('name'):
            return jsonify({'error': 'Name is required'}), 400
        
        # Validate coordinates if provided
        if 'latitude' in data and 'longitude' in data:
            if not validate_coordinates(data['latitude'], data['longitude']):
                return jsonify({'error': 'Invalid coordinates'}), 400
        
        # Create chantier
        chantier = Chantier(
            name=data['name'],
            description=data.get('description'),
            client_name=data.get('client_name'),
            client_contact=data.get('client_contact'),
            project_type=data.get('project_type'),
            budget=data.get('budget'),
            start_date=datetime.fromisoformat(data['start_date']) if data.get('start_date') else None,
            end_date=datetime.fromisoformat(data['end_date']) if data.get('end_date') else None,
            status=ChantierStatus(data.get('status', 'planned')),
            manager_id=current_user_id
        )
        
        # Set location if provided
        if 'latitude' in data and 'longitude' in data:
            chantier.set_location(
                data['latitude'], 
                data['longitude'], 
                data.get('address')
            )
        
        db.session.add(chantier)
        db.session.commit()
        
        return jsonify({
            'message': 'Chantier created successfully',
            'chantier': chantier.to_dict()
        }), 201
        
    except Exception as e:
        db.session.rollback()
        return jsonify({'error': str(e)}), 500

@btp_bp.route('/chantiers/<int:chantier_id>', methods=['GET'])
@jwt_required()
def get_chantier(chantier_id):
    """Get specific chantier"""
    try:
        current_user_id = get_jwt_identity()
        
        chantier = Chantier.query.filter_by(
            id=chantier_id, 
            is_active=True
        ).first()
        
        if not chantier:
            return jsonify({'error': 'Chantier not found'}), 404
        
        # Check if user has access
        has_access = (
            chantier.manager_id == current_user_id or
            chantier.equipes.filter_by(user_id=current_user_id).first()
        )
        
        if not has_access:
            return jsonify({'error': 'Access denied'}), 403
        
        return jsonify({'chantier': chantier.to_dict()}), 200
        
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@btp_bp.route('/chantiers/<int:chantier_id>', methods=['PUT'])
@jwt_required()
def update_chantier(chantier_id):
    """Update chantier"""
    try:
        current_user_id = get_jwt_identity()
        
        chantier = Chantier.query.filter_by(
            id=chantier_id, 
            is_active=True
        ).first()
        
        if not chantier:
            return jsonify({'error': 'Chantier not found'}), 404
        
        # Check if user is manager
        if chantier.manager_id != current_user_id:
            return jsonify({'error': 'Only manager can update chantier'}), 403
        
        data = request.get_json()
        
        # Update fields
        if 'name' in data:
            chantier.name = data['name']
        if 'description' in data:
            chantier.description = data['description']
        if 'client_name' in data:
            chantier.client_name = data['client_name']
        if 'client_contact' in data:
            chantier.client_contact = data['client_contact']
        if 'project_type' in data:
            chantier.project_type = data['project_type']
        if 'budget' in data:
            chantier.budget = data['budget']
        if 'start_date' in data:
            chantier.start_date = datetime.fromisoformat(data['start_date']) if data['start_date'] else None
        if 'end_date' in data:
            chantier.end_date = datetime.fromisoformat(data['end_date']) if data['end_date'] else None
        if 'status' in data:
            chantier.status = ChantierStatus(data['status'])
        if 'progress_percentage' in data:
            chantier.progress_percentage = data['progress_percentage']
        if 'weather_conditions' in data:
            chantier.weather_conditions = data['weather_conditions']
        if 'safety_notes' in data:
            chantier.safety_notes = data['safety_notes']
        
        # Update location if provided
        if 'latitude' in data and 'longitude' in data:
            chantier.set_location(
                data['latitude'], 
                data['longitude'], 
                data.get('address')
            )
        
        db.session.commit()
        
        return jsonify({
            'message': 'Chantier updated successfully',
            'chantier': chantier.to_dict()
        }), 200
        
    except Exception as e:
        db.session.rollback()
        return jsonify({'error': str(e)}), 500

# ===== EQUIPES (Teams) =====

@btp_bp.route('/chantiers/<int:chantier_id>/equipes', methods=['GET'])
@jwt_required()
def get_chantier_equipes(chantier_id):
    """Get equipes for a chantier"""
    try:
        current_user_id = get_jwt_identity()
        
        chantier = Chantier.query.filter_by(
            id=chantier_id, 
            is_active=True
        ).first()
        
        if not chantier:
            return jsonify({'error': 'Chantier not found'}), 404
        
        # Check access
        has_access = (
            chantier.manager_id == current_user_id or
            chantier.equipes.filter_by(user_id=current_user_id).first()
        )
        
        if not has_access:
            return jsonify({'error': 'Access denied'}), 403
        
        equipes = [equipe.to_dict() for equipe in chantier.equipes]
        
        return jsonify({'equipes': equipes}), 200
        
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@btp_bp.route('/chantiers/<int:chantier_id>/equipes', methods=['POST'])
@jwt_required()
def add_equipe_member(chantier_id):
    """Add team member to chantier"""
    try:
        current_user_id = get_jwt_identity()
        data = request.get_json()
        
        chantier = Chantier.query.filter_by(
            id=chantier_id, 
            is_active=True
        ).first()
        
        if not chantier:
            return jsonify({'error': 'Chantier not found'}), 404
        
        # Check if user is manager
        if chantier.manager_id != current_user_id:
            return jsonify({'error': 'Only manager can add team members'}), 403
        
        if not data.get('user_id') or not data.get('role'):
            return jsonify({'error': 'User ID and role are required'}), 400
        
        # Check if user exists
        user = User.query.get(data['user_id'])
        if not user:
            return jsonify({'error': 'User not found'}), 404
        
        # Check if user is already in team
        existing_equipe = Equipe.query.filter_by(
            chantier_id=chantier_id,
            user_id=data['user_id']
        ).first()
        
        if existing_equipe:
            return jsonify({'error': 'User already in team'}), 409
        
        # Create equipe
        equipe = Equipe(
            chantier_id=chantier_id,
            user_id=data['user_id'],
            role=data['role'],
            hourly_rate=data.get('hourly_rate'),
            start_date=datetime.fromisoformat(data['start_date']) if data.get('start_date') else None,
            end_date=datetime.fromisoformat(data['end_date']) if data.get('end_date') else None
        )
        
        db.session.add(equipe)
        db.session.commit()
        
        return jsonify({
            'message': 'Team member added successfully',
            'equipe': equipe.to_dict()
        }), 201
        
    except Exception as e:
        db.session.rollback()
        return jsonify({'error': str(e)}), 500

@btp_bp.route('/equipes/<int:equipe_id>/checkin', methods=['POST'])
@jwt_required()
def checkin_equipe(equipe_id):
    """Check in team member"""
    try:
        current_user_id = get_jwt_identity()
        
        equipe = Equipe.query.filter_by(
            id=equipe_id, 
            user_id=current_user_id,
            is_active=True
        ).first()
        
        if not equipe:
            return jsonify({'error': 'Equipe not found'}), 404
        
        if equipe.is_present:
            return jsonify({'error': 'Already checked in'}), 400
        
        equipe.is_present = True
        equipe.last_checkin = datetime.utcnow()
        
        db.session.commit()
        
        return jsonify({
            'message': 'Checked in successfully',
            'equipe': equipe.to_dict()
        }), 200
        
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@btp_bp.route('/equipes/<int:equipe_id>/checkout', methods=['POST'])
@jwt_required()
def checkout_equipe(equipe_id):
    """Check out team member"""
    try:
        current_user_id = get_jwt_identity()
        
        equipe = Equipe.query.filter_by(
            id=equipe_id, 
            user_id=current_user_id,
            is_active=True
        ).first()
        
        if not equipe:
            return jsonify({'error': 'Equipe not found'}), 404
        
        if not equipe.is_present:
            return jsonify({'error': 'Not checked in'}), 400
        
        equipe.is_present = False
        equipe.last_checkout = datetime.utcnow()
        
        # Calculate hours worked
        if equipe.last_checkin:
            time_diff = equipe.last_checkout - equipe.last_checkin
            hours_worked = time_diff.total_seconds() / 3600
            equipe.hours_worked += hours_worked
        
        db.session.commit()
        
        return jsonify({
            'message': 'Checked out successfully',
            'equipe': equipe.to_dict()
        }), 200
        
    except Exception as e:
        return jsonify({'error': str(e)}), 500

# ===== MATERIELS (Materials/Equipment) =====

@btp_bp.route('/chantiers/<int:chantier_id>/materiels', methods=['GET'])
@jwt_required()
def get_chantier_materiels(chantier_id):
    """Get materiels for a chantier"""
    try:
        current_user_id = get_jwt_identity()
        
        chantier = Chantier.query.filter_by(
            id=chantier_id, 
            is_active=True
        ).first()
        
        if not chantier:
            return jsonify({'error': 'Chantier not found'}), 404
        
        # Check access
        has_access = (
            chantier.manager_id == current_user_id or
            chantier.equipes.filter_by(user_id=current_user_id).first()
        )
        
        if not has_access:
            return jsonify({'error': 'Access denied'}), 403
        
        materiels = [materiel.to_dict() for materiel in chantier.materiels]
        
        return jsonify({'materiels': materiels}), 200
        
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@btp_bp.route('/materiels', methods=['POST'])
@jwt_required()
def create_materiel():
    """Create new materiel"""
    try:
        current_user_id = get_jwt_identity()
        data = request.get_json()
        
        if not data.get('name'):
            return jsonify({'error': 'Name is required'}), 400
        
        # Create materiel
        materiel = Materiel(
            name=data['name'],
            description=data.get('description'),
            category=data.get('category'),
            brand=data.get('brand'),
            model=data.get('model'),
            serial_number=data.get('serial_number'),
            quantity=data.get('quantity'),
            unit=data.get('unit'),
            unit_price=data.get('unit_price'),
            total_cost=data.get('total_cost'),
            condition=data.get('condition'),
            status=data.get('status'),
            supplier=data.get('supplier'),
            purchase_date=datetime.fromisoformat(data['purchase_date']) if data.get('purchase_date') else None,
            warranty_expiry=datetime.fromisoformat(data['warranty_expiry']) if data.get('warranty_expiry') else None,
            chantier_id=data.get('chantier_id')
        )
        
        # Set location if provided
        if 'latitude' in data and 'longitude' in data:
            materiel.set_location(
                data['latitude'], 
                data['longitude'], 
                data.get('address')
            )
        
        db.session.add(materiel)
        db.session.commit()
        
        return jsonify({
            'message': 'Materiel created successfully',
            'materiel': materiel.to_dict()
        }), 201
        
    except Exception as e:
        db.session.rollback()
        return jsonify({'error': str(e)}), 500

# ===== PHOTOS =====

@btp_bp.route('/chantiers/<int:chantier_id>/photos', methods=['GET'])
@jwt_required()
def get_chantier_photos(chantier_id):
    """Get photos for a chantier"""
    try:
        current_user_id = get_jwt_identity()
        
        chantier = Chantier.query.filter_by(
            id=chantier_id, 
            is_active=True
        ).first()
        
        if not chantier:
            return jsonify({'error': 'Chantier not found'}), 404
        
        # Check access
        has_access = (
            chantier.manager_id == current_user_id or
            chantier.equipes.filter_by(user_id=current_user_id).first()
        )
        
        if not has_access:
            return jsonify({'error': 'Access denied'}), 403
        
        photos = [photo.to_dict() for photo in chantier.photos]
        
        return jsonify({'photos': photos}), 200
        
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@btp_bp.route('/chantiers/<int:chantier_id>/photos', methods=['POST'])
@jwt_required()
def upload_chantier_photo(chantier_id):
    """Upload photo for chantier"""
    try:
        current_user_id = get_jwt_identity()
        
        chantier = Chantier.query.filter_by(
            id=chantier_id, 
            is_active=True
        ).first()
        
        if not chantier:
            return jsonify({'error': 'Chantier not found'}), 404
        
        # Check access
        has_access = (
            chantier.manager_id == current_user_id or
            chantier.equipes.filter_by(user_id=current_user_id).first()
        )
        
        if not has_access:
            return jsonify({'error': 'Access denied'}), 403
        
        if 'photo' not in request.files:
            return jsonify({'error': 'No file provided'}), 400
        
        file = request.files['photo']
        if file.filename == '':
            return jsonify({'error': 'No file selected'}), 400
        
        if file and file.filename:
            # Secure filename
            filename = secure_filename(file.filename)
            filename = clean_filename(filename)
            
            # Generate unique filename
            from app.utils.helpers import generate_random_string
            file_extension = filename.rsplit('.', 1)[1].lower() if '.' in filename else 'jpg'
            unique_filename = f"chantier_{chantier_id}_{generate_random_string(8)}.{file_extension}"
            
            # Create upload directory
            upload_dir = os.path.join('uploads', 'chantiers', str(chantier_id))
            os.makedirs(upload_dir, exist_ok=True)
            
            # Save file
            file_path = os.path.join(upload_dir, unique_filename)
            file.save(file_path)
            
            # Get form data
            title = request.form.get('title')
            description = request.form.get('description')
            category = request.form.get('category')
            work_phase = request.form.get('work_phase')
            progress_milestone = request.form.get('progress_milestone')
            
            # Create photo record
            photo = PhotoChantier(
                chantier_id=chantier_id,
                user_id=current_user_id,
                filename=unique_filename,
                original_filename=file.filename,
                file_path=file_path,
                file_size=os.path.getsize(file_path),
                mime_type=file.content_type,
                title=title,
                description=description,
                category=category,
                work_phase=work_phase,
                progress_milestone=progress_milestone,
                taken_at=datetime.utcnow()
            )
            
            # Set location if provided
            latitude = request.form.get('latitude', type=float)
            longitude = request.form.get('longitude', type=float)
            if latitude and longitude:
                photo.set_location(latitude, longitude)
            
            db.session.add(photo)
            db.session.commit()
            
            return jsonify({
                'message': 'Photo uploaded successfully',
                'photo': photo.to_dict()
            }), 201
        
    except Exception as e:
        db.session.rollback()
        return jsonify({'error': str(e)}), 500
