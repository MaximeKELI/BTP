from flask import Blueprint, request, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity
from sqlalchemy import and_, or_, desc
from app import db
from app.models import Worker, WorkerReview, WorkerStatus, WorkerType, User
from datetime import datetime
import json

workers_bp = Blueprint('workers', __name__)

@workers_bp.route('/workers', methods=['GET'])
def get_workers():
    """Récupérer la liste des ouvriers avec filtres"""
    try:
        # Paramètres de filtrage
        page = request.args.get('page', 1, type=int)
        per_page = request.args.get('per_page', 20, type=int)
        worker_type = request.args.get('type')
        min_rating = request.args.get('min_rating', type=float)
        max_hourly_rate = request.args.get('max_hourly_rate', type=float)
        is_available = request.args.get('is_available', type=bool)
        search = request.args.get('search')
        latitude = request.args.get('latitude', type=float)
        longitude = request.args.get('longitude', type=float)
        radius = request.args.get('radius', 50, type=float)  # km
        
        # Construction de la requête
        query = Worker.query.filter(Worker.is_available == True)
        
        # Filtres
        if worker_type:
            query = query.filter(Worker.worker_type == WorkerType(worker_type))
        
        if min_rating:
            query = query.filter(Worker.rating >= min_rating)
            
        if max_hourly_rate:
            query = query.filter(Worker.hourly_rate <= max_hourly_rate)
            
        if is_available is not None:
            query = query.filter(Worker.is_available == is_available)
            
        if search:
            search_term = f"%{search}%"
            query = query.filter(
                or_(
                    Worker.first_name.ilike(search_term),
                    Worker.last_name.ilike(search_term),
                    Worker.description.ilike(search_term),
                    Worker.skills.contains([search])
                )
            )
        
        # Tri par défaut
        query = query.order_by(desc(Worker.rating), desc(Worker.total_reviews))
        
        # Pagination
        workers = query.paginate(
            page=page, 
            per_page=per_page, 
            error_out=False
        )
        
        return jsonify({
            'workers': [worker.to_dict() for worker in workers.items],
            'total': workers.total,
            'page': page,
            'per_page': per_page,
            'pages': workers.pages
        }), 200
        
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@workers_bp.route('/workers/<int:worker_id>', methods=['GET'])
def get_worker(worker_id):
    """Récupérer un ouvrier spécifique"""
    try:
        worker = Worker.query.get_or_404(worker_id)
        return jsonify(worker.to_dict()), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@workers_bp.route('/workers', methods=['POST'])
@jwt_required()
def create_worker():
    """Créer un profil d'ouvrier"""
    try:
        current_user_id = get_jwt_identity()
        data = request.get_json()
        
        # Vérifier si l'utilisateur a déjà un profil ouvrier
        existing_worker = Worker.query.filter_by(user_id=current_user_id).first()
        if existing_worker:
            return jsonify({'error': 'User already has a worker profile'}), 400
        
        # Créer le profil ouvrier
        worker = Worker(
            user_id=current_user_id,
            first_name=data['first_name'],
            last_name=data['last_name'],
            phone=data['phone'],
            email=data['email'],
            worker_type=WorkerType(data['worker_type']),
            specializations=data.get('specializations', []),
            skills=data.get('skills', []),
            experience_years=data.get('experience_years', 0),
            hourly_rate=data['hourly_rate'],
            daily_rate=data.get('daily_rate'),
            description=data.get('description'),
            latitude=data.get('latitude'),
            longitude=data.get('longitude'),
            address=data.get('address'),
            city=data.get('city'),
            country=data.get('country'),
            postal_code=data.get('postal_code')
        )
        
        db.session.add(worker)
        db.session.commit()
        
        return jsonify(worker.to_dict()), 201
        
    except Exception as e:
        db.session.rollback()
        return jsonify({'error': str(e)}), 500

@workers_bp.route('/workers/<int:worker_id>', methods=['PUT'])
@jwt_required()
def update_worker(worker_id):
    """Mettre à jour un profil d'ouvrier"""
    try:
        current_user_id = get_jwt_identity()
        worker = Worker.query.get_or_404(worker_id)
        
        # Vérifier les permissions
        if worker.user_id != current_user_id:
            return jsonify({'error': 'Unauthorized'}), 403
        
        data = request.get_json()
        
        # Mettre à jour les champs
        for field in ['first_name', 'last_name', 'phone', 'email', 'description', 
                     'hourly_rate', 'daily_rate', 'latitude', 'longitude', 
                     'address', 'city', 'country', 'postal_code']:
            if field in data:
                setattr(worker, field, data[field])
        
        if 'worker_type' in data:
            worker.worker_type = WorkerType(data['worker_type'])
        
        if 'specializations' in data:
            worker.specializations = data['specializations']
            
        if 'skills' in data:
            worker.skills = data['skills']
            
        if 'experience_years' in data:
            worker.experience_years = data['experience_years']
            
        if 'is_available' in data:
            worker.is_available = data['is_available']
            
        if 'availability_schedule' in data:
            worker.availability_schedule = data['availability_schedule']
        
        worker.updated_at = datetime.utcnow()
        db.session.commit()
        
        return jsonify(worker.to_dict()), 200
        
    except Exception as e:
        db.session.rollback()
        return jsonify({'error': str(e)}), 500

@workers_bp.route('/workers/<int:worker_id>/reviews', methods=['GET'])
def get_worker_reviews(worker_id):
    """Récupérer les avis d'un ouvrier"""
    try:
        page = request.args.get('page', 1, type=int)
        per_page = request.args.get('per_page', 10, type=int)
        
        reviews = WorkerReview.query.filter_by(worker_id=worker_id)\
            .order_by(desc(WorkerReview.created_at))\
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

@workers_bp.route('/workers/<int:worker_id>/reviews', methods=['POST'])
@jwt_required()
def create_worker_review(worker_id):
    """Créer un avis pour un ouvrier"""
    try:
        current_user_id = get_jwt_identity()
        data = request.get_json()
        
        # Vérifier que l'ouvrier existe
        worker = Worker.query.get_or_404(worker_id)
        
        # Créer l'avis
        review = WorkerReview(
            worker_id=worker_id,
            client_id=current_user_id,
            rating=data['rating'],
            comment=data.get('comment'),
            work_quality=data.get('work_quality'),
            punctuality=data.get('punctuality'),
            communication=data.get('communication'),
            professionalism=data.get('professionalism'),
            project_id=data.get('project_id'),
            booking_id=data.get('booking_id')
        )
        
        db.session.add(review)
        
        # Mettre à jour les statistiques de l'ouvrier
        worker.total_reviews += 1
        # Recalculer la note moyenne
        all_reviews = WorkerReview.query.filter_by(worker_id=worker_id).all()
        if all_reviews:
            worker.rating = sum(r.rating for r in all_reviews) / len(all_reviews)
        
        db.session.commit()
        
        return jsonify(review.to_dict()), 201
        
    except Exception as e:
        db.session.rollback()
        return jsonify({'error': str(e)}), 500

@workers_bp.route('/workers/types', methods=['GET'])
def get_worker_types():
    """Récupérer les types d'ouvriers disponibles"""
    try:
        types = [{'value': t.value, 'label': t.value.replace('_', ' ').title()} 
                for t in WorkerType]
        return jsonify({'types': types}), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 500
