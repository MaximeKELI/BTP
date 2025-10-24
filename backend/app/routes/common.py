from flask import Blueprint, request, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity
from app import db
from app.models.user import User, UserSector, SectorType
from app.utils.helpers import calculate_distance, get_time_ago
from sqlalchemy import func
import json

common_bp = Blueprint('common', __name__)

@common_bp.route('/search', methods=['GET'])
@jwt_required()
def search():
    """Global search across all sectors"""
    try:
        current_user_id = get_jwt_identity()
        
        # Get query parameters
        query = request.args.get('q', '')
        sector = request.args.get('sector')
        latitude = request.args.get('latitude', type=float)
        longitude = request.args.get('longitude', type=float)
        radius = request.args.get('radius', 50, type=int)
        page = request.args.get('page', 1, type=int)
        per_page = request.args.get('per_page', 20, type=int)
        
        if not query:
            return jsonify({'error': 'Search query is required'}), 400
        
        results = {
            'users': [],
            'total': 0
        }
        
        # Search users by sector
        user_query = UserSector.query.filter_by(is_available=True, is_active=True)
        
        if sector:
            user_query = user_query.filter_by(sector=SectorType(sector))
        
        # Search by specialization, skills, etc.
        user_query = user_query.filter(
            (UserSector.specialization.ilike(f'%{query}%')) |
            (UserSector.user.has(User.first_name.ilike(f'%{query}%'))) |
            (UserSector.user.has(User.last_name.ilike(f'%{query}%'))) |
            (UserSector.user.has(User.username.ilike(f'%{query}%')))
        )
        
        # Filter by location if provided
        if latitude and longitude:
            user_query = user_query.filter(
                UserSector.latitude.isnot(None),
                UserSector.longitude.isnot(None)
            )
        
        # Paginate results
        user_results = user_query.paginate(
            page=page, 
            per_page=per_page, 
            error_out=False
        )
        
        # Format user results
        users = []
        for user_sector in user_results.items:
            user_data = user_sector.user.to_dict()
            user_data['sector_info'] = user_sector.to_dict()
            
            # Calculate distance if coordinates provided
            if latitude and longitude and user_sector.latitude and user_sector.longitude:
                distance = calculate_distance(
                    latitude, longitude,
                    user_sector.latitude, user_sector.longitude
                )
                user_data['distance_km'] = round(distance, 2)
            
            users.append(user_data)
        
        results['users'] = users
        results['total'] = user_results.total
        results['pagination'] = {
            'page': user_results.page,
            'pages': user_results.pages,
            'per_page': user_results.per_page,
            'total': user_results.total,
            'has_next': user_results.has_next,
            'has_prev': user_results.has_prev
        }
        
        return jsonify(results), 200
        
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@common_bp.route('/nearby', methods=['GET'])
@jwt_required()
def get_nearby_services():
    """Get nearby services by sector"""
    try:
        current_user_id = get_jwt_identity()
        
        # Get query parameters
        latitude = request.args.get('latitude', type=float)
        longitude = request.args.get('longitude', type=float)
        radius = request.args.get('radius', 50, type=int)
        sector = request.args.get('sector')
        page = request.args.get('page', 1, type=int)
        per_page = request.args.get('per_page', 20, type=int)
        
        if not latitude or not longitude:
            return jsonify({'error': 'Latitude and longitude are required'}), 400
        
        # Build query for nearby users
        query = UserSector.query.filter_by(is_available=True, is_active=True)
        
        if sector:
            query = query.filter_by(sector=SectorType(sector))
        
        # Filter by location
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
        
        # Calculate distances and filter by radius
        nearby_services = []
        for user_sector in results.items:
            if user_sector.latitude and user_sector.longitude:
                distance = calculate_distance(
                    latitude, longitude,
                    user_sector.latitude, user_sector.longitude
                )
                
                if distance <= radius:
                    user_data = user_sector.user.to_dict()
                    user_data['sector_info'] = user_sector.to_dict()
                    user_data['distance_km'] = round(distance, 2)
                    nearby_services.append(user_data)
        
        return jsonify({
            'services': nearby_services,
            'pagination': {
                'page': results.page,
                'pages': results.pages,
                'per_page': results.per_page,
                'total': len(nearby_services),
                'has_next': results.has_next,
                'has_prev': results.has_prev
            }
        }), 200
        
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@common_bp.route('/stats', methods=['GET'])
@jwt_required()
def get_stats():
    """Get platform statistics"""
    try:
        current_user_id = get_jwt_identity()
        
        # Get user stats
        total_users = User.query.filter_by(is_active=True).count()
        verified_users = User.query.filter_by(is_active=True, is_verified=True).count()
        
        # Get sector stats
        sector_stats = db.session.query(
            UserSector.sector,
            func.count(UserSector.id).label('count')
        ).filter_by(is_active=True, is_available=True).group_by(UserSector.sector).all()
        
        sectors = {sector.value: count for sector, count in sector_stats}
        
        # Get recent activity (last 7 days)
        from datetime import datetime, timedelta
        week_ago = datetime.utcnow() - timedelta(days=7)
        
        recent_users = User.query.filter(
            User.created_at >= week_ago,
            User.is_active == True
        ).count()
        
        return jsonify({
            'total_users': total_users,
            'verified_users': verified_users,
            'recent_users': recent_users,
            'sectors': sectors,
            'verification_rate': round((verified_users / total_users * 100), 2) if total_users > 0 else 0
        }), 200
        
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@common_bp.route('/sectors', methods=['GET'])
def get_sectors():
    """Get available sectors"""
    try:
        sectors = [
            {
                'value': sector.value,
                'label': sector.value.title(),
                'description': get_sector_description(sector.value)
            }
            for sector in SectorType
        ]
        
        return jsonify({'sectors': sectors}), 200
        
    except Exception as e:
        return jsonify({'error': str(e)}), 500

def get_sector_description(sector):
    """Get sector description"""
    descriptions = {
        'btp': 'Bâtiments et Travaux Publics - Construction, infrastructure, travaux publics',
        'agribusiness': 'Agribusiness - Agriculture, élevage, transformation alimentaire',
        'mining': 'Exploitation Minière - Extraction, géologie, ressources naturelles',
        'divers': 'Divers - Services généraux, consulting, autres secteurs'
    }
    return descriptions.get(sector, 'Secteur d\'activité')

@common_bp.route('/health', methods=['GET'])
def health_check():
    """Health check endpoint"""
    try:
        # Check database connection
        db.session.execute('SELECT 1')
        
        return jsonify({
            'status': 'healthy',
            'timestamp': datetime.utcnow().isoformat(),
            'database': 'connected'
        }), 200
        
    except Exception as e:
        return jsonify({
            'status': 'unhealthy',
            'timestamp': datetime.utcnow().isoformat(),
            'error': str(e)
        }), 500

@common_bp.route('/notifications', methods=['GET'])
@jwt_required()
def get_notifications():
    """Get user notifications (placeholder)"""
    try:
        current_user_id = get_jwt_identity()
        
        # In production, implement real notification system
        notifications = [
            {
                'id': 1,
                'title': 'Bienvenue sur la plateforme',
                'message': 'Votre compte a été créé avec succès',
                'type': 'info',
                'read': False,
                'created_at': get_time_ago(datetime.utcnow())
            }
        ]
        
        return jsonify({'notifications': notifications}), 200
        
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@common_bp.route('/notifications/<int:notification_id>/read', methods=['POST'])
@jwt_required()
def mark_notification_read(notification_id):
    """Mark notification as read (placeholder)"""
    try:
        current_user_id = get_jwt_identity()
        
        # In production, implement real notification system
        return jsonify({'message': 'Notification marked as read'}), 200
        
    except Exception as e:
        return jsonify({'error': str(e)}), 500
