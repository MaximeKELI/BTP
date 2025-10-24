from flask import Blueprint, request, jsonify
from flask_jwt_extended import create_access_token, jwt_required, get_jwt_identity
from werkzeug.security import check_password_hash
from app import db
from app.models.user import User, UserProfile, UserSector, UserRole, SectorType
from app.utils.validators import validate_email, validate_phone, validate_password
from app.utils.helpers import generate_verification_code, send_verification_email
from datetime import datetime
import re

auth_bp = Blueprint('auth', __name__)

@auth_bp.route('/register', methods=['POST'])
def register():
    """Register a new user"""
    try:
        data = request.get_json()
        
        # Validate required fields
        required_fields = ['email', 'password', 'first_name', 'last_name']
        for field in required_fields:
            if not data.get(field):
                return jsonify({'error': f'{field} is required'}), 400
        
        # Validate email format
        if not validate_email(data['email']):
            return jsonify({'error': 'Invalid email format'}), 400
        
        # Validate password strength
        if not validate_password(data['password']):
            return jsonify({'error': 'Password must be at least 8 characters with uppercase, lowercase, number and special character'}), 400
        
        # Check if user already exists
        if User.query.filter_by(email=data['email']).first():
            return jsonify({'error': 'Email already registered'}), 409
        
        if data.get('phone') and User.query.filter_by(phone=data['phone']).first():
            return jsonify({'error': 'Phone number already registered'}), 409
        
        # Create user
        user = User(
            email=data['email'],
            first_name=data['first_name'],
            last_name=data['last_name'],
            phone=data.get('phone'),
            username=data.get('username'),
            role=UserRole(data.get('role', 'client')),
            platform=data.get('platform'),
            device_token=data.get('device_token')
        )
        user.set_password(data['password'])
        
        db.session.add(user)
        db.session.flush()  # Get user ID
        
        # Create user profile
        profile = UserProfile(
            user_id=user.id,
            language=data.get('language', 'fr'),
            timezone=data.get('timezone', 'UTC'),
            currency=data.get('currency', 'XOF')
        )
        db.session.add(profile)
        
        # Create user sectors if provided
        if data.get('sectors'):
            for sector_data in data['sectors']:
                sector = UserSector(
                    user_id=user.id,
                    sector=SectorType(sector_data['sector']),
                    specialization=sector_data.get('specialization'),
                    experience_level=sector_data.get('experience_level'),
                    hourly_rate=sector_data.get('hourly_rate'),
                    availability=sector_data.get('availability'),
                    service_radius=sector_data.get('service_radius', 50)
                )
                db.session.add(sector)
        
        db.session.commit()
        
        # Generate verification code (in production, send via email/SMS)
        verification_code = generate_verification_code()
        # Store verification code in Redis or database
        
        return jsonify({
            'message': 'User registered successfully',
            'user': user.to_dict(),
            'verification_required': True,
            'verification_code': verification_code  # Remove in production
        }), 201
        
    except Exception as e:
        db.session.rollback()
        return jsonify({'error': str(e)}), 500

@auth_bp.route('/login', methods=['POST'])
def login():
    """Authenticate user and return JWT token"""
    try:
        data = request.get_json()
        
        if not data.get('email') or not data.get('password'):
            return jsonify({'error': 'Email and password are required'}), 400
        
        # Find user by email
        user = User.query.filter_by(email=data['email']).first()
        
        if not user or not user.check_password(data['password']):
            return jsonify({'error': 'Invalid credentials'}), 401
        
        if not user.is_active:
            return jsonify({'error': 'Account is deactivated'}), 401
        
        # Update last login
        user.last_login = datetime.utcnow()
        if data.get('device_token'):
            user.device_token = data['device_token']
        if data.get('platform'):
            user.platform = data['platform']
        
        db.session.commit()
        
        # Create access token
        access_token = create_access_token(identity=user.id)
        
        return jsonify({
            'message': 'Login successful',
            'access_token': access_token,
            'user': user.to_dict(),
            'profile': user.profile.to_dict() if user.profile else None,
            'sectors': [sector.to_dict() for sector in user.sectors]
        }), 200
        
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@auth_bp.route('/verify-email', methods=['POST'])
def verify_email():
    """Verify user email with verification code"""
    try:
        data = request.get_json()
        
        if not data.get('email') or not data.get('code'):
            return jsonify({'error': 'Email and verification code are required'}), 400
        
        user = User.query.filter_by(email=data['email']).first()
        if not user:
            return jsonify({'error': 'User not found'}), 404
        
        # In production, verify code from Redis/database
        # For now, accept any 6-digit code
        if not re.match(r'^\d{6}$', data['code']):
            return jsonify({'error': 'Invalid verification code format'}), 400
        
        user.is_verified = True
        db.session.commit()
        
        return jsonify({'message': 'Email verified successfully'}), 200
        
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@auth_bp.route('/forgot-password', methods=['POST'])
def forgot_password():
    """Send password reset code"""
    try:
        data = request.get_json()
        
        if not data.get('email'):
            return jsonify({'error': 'Email is required'}), 400
        
        user = User.query.filter_by(email=data['email']).first()
        if not user:
            return jsonify({'error': 'User not found'}), 404
        
        # Generate reset code
        reset_code = generate_verification_code()
        # Store reset code in Redis with expiration
        
        # In production, send via email
        # send_password_reset_email(user.email, reset_code)
        
        return jsonify({
            'message': 'Password reset code sent',
            'reset_code': reset_code  # Remove in production
        }), 200
        
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@auth_bp.route('/reset-password', methods=['POST'])
def reset_password():
    """Reset password with verification code"""
    try:
        data = request.get_json()
        
        required_fields = ['email', 'code', 'new_password']
        for field in required_fields:
            if not data.get(field):
                return jsonify({'error': f'{field} is required'}), 400
        
        user = User.query.filter_by(email=data['email']).first()
        if not user:
            return jsonify({'error': 'User not found'}), 404
        
        # In production, verify reset code from Redis
        if not re.match(r'^\d{6}$', data['code']):
            return jsonify({'error': 'Invalid reset code format'}), 400
        
        # Validate new password
        if not validate_password(data['new_password']):
            return jsonify({'error': 'Password must be at least 8 characters with uppercase, lowercase, number and special character'}), 400
        
        user.set_password(data['new_password'])
        db.session.commit()
        
        return jsonify({'message': 'Password reset successfully'}), 200
        
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@auth_bp.route('/refresh', methods=['POST'])
@jwt_required()
def refresh():
    """Refresh JWT token"""
    try:
        current_user_id = get_jwt_identity()
        user = User.query.get(current_user_id)
        
        if not user or not user.is_active:
            return jsonify({'error': 'User not found or inactive'}), 404
        
        # Create new access token
        access_token = create_access_token(identity=user.id)
        
        return jsonify({
            'access_token': access_token,
            'user': user.to_dict()
        }), 200
        
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@auth_bp.route('/logout', methods=['POST'])
@jwt_required()
def logout():
    """Logout user (invalidate token on client side)"""
    try:
        # In production, add token to blacklist
        return jsonify({'message': 'Logout successful'}), 200
        
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@auth_bp.route('/me', methods=['GET'])
@jwt_required()
def get_current_user():
    """Get current user information"""
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
