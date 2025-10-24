from flask import Blueprint, request, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity
from app import db
from app.models.user import User, UserProfile, UserSector, UserRole, SectorType
from app.utils.validators import validate_email, validate_phone
from app.utils.helpers import clean_filename
from werkzeug.utils import secure_filename
import os

users_bp = Blueprint('users', __name__)

@users_bp.route('/profile', methods=['GET'])
@jwt_required()
def get_profile():
    """Get current user profile"""
    try:
        current_user_id = get_jwt_identity()
        user = User.query.get(current_user_id)
        
        if not user:
            return jsonify({'error': 'User not found'}), 404
        
        return jsonify({
            'user': user.to_dict(),
            'profile': user.profile.to_dict() if user.profile else None,
            'sectors': [sector.to_dict() for sector in user.sectors]
        }), 200
        
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@users_bp.route('/profile', methods=['PUT'])
@jwt_required()
def update_profile():
    """Update user profile"""
    try:
        current_user_id = get_jwt_identity()
        user = User.query.get(current_user_id)
        
        if not user:
            return jsonify({'error': 'User not found'}), 404
        
        data = request.get_json()
        
        # Update basic user info
        if 'first_name' in data:
            user.first_name = data['first_name']
        if 'last_name' in data:
            user.last_name = data['last_name']
        if 'phone' in data:
            if data['phone'] and not validate_phone(data['phone']):
                return jsonify({'error': 'Invalid phone number format'}), 400
            user.phone = data['phone']
        if 'username' in data:
            user.username = data['username']
        
        # Update or create profile
        if not user.profile:
            user.profile = UserProfile(user_id=user.id)
        
        profile = user.profile
        if 'bio' in data:
            profile.bio = data['bio']
        if 'company' in data:
            profile.company = data['company']
        if 'job_title' in data:
            profile.job_title = data['job_title']
        if 'experience_years' in data:
            profile.experience_years = data['experience_years']
        if 'skills' in data:
            profile.skills = data['skills']
        if 'certifications' in data:
            profile.certifications = data['certifications']
        if 'language' in data:
            profile.language = data['language']
        if 'timezone' in data:
            profile.timezone = data['timezone']
        if 'currency' in data:
            profile.currency = data['currency']
        
        # Update location
        if 'latitude' in data and 'longitude' in data:
            user.set_location(
                data['latitude'], 
                data['longitude'], 
                data.get('address')
            )
        
        db.session.commit()
        
        return jsonify({
            'message': 'Profile updated successfully',
            'user': user.to_dict(),
            'profile': profile.to_dict()
        }), 200
        
    except Exception as e:
        db.session.rollback()
        return jsonify({'error': str(e)}), 500

@users_bp.route('/sectors', methods=['GET'])
@jwt_required()
def get_user_sectors():
    """Get user sectors"""
    try:
        current_user_id = get_jwt_identity()
        user = User.query.get(current_user_id)
        
        if not user:
            return jsonify({'error': 'User not found'}), 404
        
        sectors = [sector.to_dict() for sector in user.sectors]
        return jsonify({'sectors': sectors}), 200
        
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@users_bp.route('/sectors', methods=['POST'])
@jwt_required()
def add_user_sector():
    """Add user sector"""
    try:
        current_user_id = get_jwt_identity()
        user = User.query.get(current_user_id)
        
        if not user:
            return jsonify({'error': 'User not found'}), 404
        
        data = request.get_json()
        
        if not data.get('sector'):
            return jsonify({'error': 'Sector is required'}), 400
        
        # Check if sector already exists
        existing_sector = UserSector.query.filter_by(
            user_id=user.id, 
            sector=SectorType(data['sector'])
        ).first()
        
        if existing_sector:
            return jsonify({'error': 'Sector already exists'}), 409
        
        # Create new sector
        sector = UserSector(
            user_id=user.id,
            sector=SectorType(data['sector']),
            specialization=data.get('specialization'),
            experience_level=data.get('experience_level'),
            hourly_rate=data.get('hourly_rate'),
            availability=data.get('availability'),
            service_radius=data.get('service_radius', 50)
        )
        
        # Set location if provided
        if 'latitude' in data and 'longitude' in data:
            sector.set_location(
                data['latitude'], 
                data['longitude'], 
                data.get('address')
            )
        
        db.session.add(sector)
        db.session.commit()
        
        return jsonify({
            'message': 'Sector added successfully',
            'sector': sector.to_dict()
        }), 201
        
    except Exception as e:
        db.session.rollback()
        return jsonify({'error': str(e)}), 500

@users_bp.route('/sectors/<int:sector_id>', methods=['PUT'])
@jwt_required()
def update_user_sector(sector_id):
    """Update user sector"""
    try:
        current_user_id = get_jwt_identity()
        sector = UserSector.query.filter_by(
            id=sector_id, 
            user_id=current_user_id
        ).first()
        
        if not sector:
            return jsonify({'error': 'Sector not found'}), 404
        
        data = request.get_json()
        
        if 'specialization' in data:
            sector.specialization = data['specialization']
        if 'experience_level' in data:
            sector.experience_level = data['experience_level']
        if 'hourly_rate' in data:
            sector.hourly_rate = data['hourly_rate']
        if 'availability' in data:
            sector.availability = data['availability']
        if 'service_radius' in data:
            sector.service_radius = data['service_radius']
        if 'is_available' in data:
            sector.is_available = data['is_available']
        
        # Update location if provided
        if 'latitude' in data and 'longitude' in data:
            sector.set_location(
                data['latitude'], 
                data['longitude'], 
                data.get('address')
            )
        
        db.session.commit()
        
        return jsonify({
            'message': 'Sector updated successfully',
            'sector': sector.to_dict()
        }), 200
        
    except Exception as e:
        db.session.rollback()
        return jsonify({'error': str(e)}), 500

@users_bp.route('/sectors/<int:sector_id>', methods=['DELETE'])
@jwt_required()
def delete_user_sector(sector_id):
    """Delete user sector"""
    try:
        current_user_id = get_jwt_identity()
        sector = UserSector.query.filter_by(
            id=sector_id, 
            user_id=current_user_id
        ).first()
        
        if not sector:
            return jsonify({'error': 'Sector not found'}), 404
        
        sector.delete()
        
        return jsonify({'message': 'Sector deleted successfully'}), 200
        
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@users_bp.route('/avatar', methods=['POST'])
@jwt_required()
def upload_avatar():
    """Upload user avatar"""
    try:
        current_user_id = get_jwt_identity()
        user = User.query.get(current_user_id)
        
        if not user:
            return jsonify({'error': 'User not found'}), 404
        
        if 'avatar' not in request.files:
            return jsonify({'error': 'No file provided'}), 400
        
        file = request.files['avatar']
        if file.filename == '':
            return jsonify({'error': 'No file selected'}), 400
        
        if file and file.filename:
            # Secure filename
            filename = secure_filename(file.filename)
            filename = clean_filename(filename)
            
            # Generate unique filename
            from app.utils.helpers import generate_random_string
            file_extension = filename.rsplit('.', 1)[1].lower() if '.' in filename else 'jpg'
            unique_filename = f"avatar_{user.id}_{generate_random_string(8)}.{file_extension}"
            
            # Create upload directory if it doesn't exist
            upload_dir = os.path.join('uploads', 'avatars')
            os.makedirs(upload_dir, exist_ok=True)
            
            # Save file
            file_path = os.path.join(upload_dir, unique_filename)
            file.save(file_path)
            
            # Update user profile
            if not user.profile:
                user.profile = UserProfile(user_id=user.id)
            
            user.profile.avatar_url = f"/uploads/avatars/{unique_filename}"
            db.session.commit()
            
            return jsonify({
                'message': 'Avatar uploaded successfully',
                'avatar_url': user.profile.avatar_url
            }), 200
        
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@users_bp.route('/search', methods=['GET'])
@jwt_required()
def search_users():
    """Search users by sector and location"""
    try:
        current_user_id = get_jwt_identity()
        
        # Get query parameters
        sector = request.args.get('sector')
        specialization = request.args.get('specialization')
        latitude = request.args.get('latitude', type=float)
        longitude = request.args.get('longitude', type=float)
        radius = request.args.get('radius', 50, type=int)
        page = request.args.get('page', 1, type=int)
        per_page = request.args.get('per_page', 20, type=int)
        
        # Build query
        query = UserSector.query.filter_by(is_available=True)
        
        if sector:
            query = query.filter_by(sector=SectorType(sector))
        
        if specialization:
            query = query.filter(UserSector.specialization.ilike(f'%{specialization}%'))
        
        # Filter by location if provided
        if latitude and longitude:
            # This is a simplified distance filter
            # In production, use PostGIS spatial queries
            query = query.filter(
                UserSector.latitude.isnot(None),
                UserSector.longitude.isnot(None)
            )
        
        # Paginate results
        results = query.paginate(
            page=page, 
            per_page=per_page, 
            error_out=False
        )
        
        # Format results
        users = []
        for sector in results.items:
            user_data = sector.user.to_dict()
            user_data['sector_info'] = sector.to_dict()
            users.append(user_data)
        
        return jsonify({
            'users': users,
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
