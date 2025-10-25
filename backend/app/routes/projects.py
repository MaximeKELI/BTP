from flask import Blueprint, request, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity
from sqlalchemy import and_, or_, desc
from app import db
from app.models import Project, ProjectMilestone, ProjectStatus, ProjectType, User
from datetime import datetime
import json

projects_bp = Blueprint('projects', __name__)

@projects_bp.route('/projects', methods=['GET'])
def get_projects():
    """Récupérer la liste des projets avec filtres"""
    try:
        # Paramètres de filtrage
        page = request.args.get('page', 1, type=int)
        per_page = request.args.get('per_page', 20, type=int)
        project_type = request.args.get('type')
        status = request.args.get('status')
        min_budget = request.args.get('min_budget', type=float)
        max_budget = request.args.get('max_budget', type=float)
        search = request.args.get('search')
        client_id = request.args.get('client_id', type=int)
        
        # Construction de la requête
        query = Project.query
        
        # Filtres
        if project_type:
            query = query.filter(Project.project_type == ProjectType(project_type))
        
        if status:
            query = query.filter(Project.status == ProjectStatus(status))
            
        if min_budget:
            query = query.filter(Project.estimated_budget >= min_budget)
            
        if max_budget:
            query = query.filter(Project.estimated_budget <= max_budget)
            
        if client_id:
            query = query.filter(Project.client_id == client_id)
            
        if search:
            search_term = f"%{search}%"
            query = query.filter(
                or_(
                    Project.title.ilike(search_term),
                    Project.description.ilike(search_term)
                )
            )
        
        # Tri par défaut
        query = query.order_by(desc(Project.created_at))
        
        # Pagination
        projects = query.paginate(
            page=page, 
            per_page=per_page, 
            error_out=False
        )
        
        return jsonify({
            'projects': [project.to_dict() for project in projects.items],
            'total': projects.total,
            'page': page,
            'per_page': per_page,
            'pages': projects.pages
        }), 200
        
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@projects_bp.route('/projects/<int:project_id>', methods=['GET'])
def get_project(project_id):
    """Récupérer un projet spécifique"""
    try:
        project = Project.query.get_or_404(project_id)
        return jsonify(project.to_dict()), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@projects_bp.route('/projects', methods=['POST'])
@jwt_required()
def create_project():
    """Créer un projet"""
    try:
        current_user_id = get_jwt_identity()
        data = request.get_json()
        
        # Créer le projet
        project = Project(
            title=data['title'],
            description=data['description'],
            project_type=ProjectType(data['project_type']),
            client_id=current_user_id,
            estimated_budget=data.get('estimated_budget'),
            estimated_duration_days=data.get('estimated_duration_days'),
            start_date=datetime.fromisoformat(data['start_date']) if data.get('start_date') else None,
            end_date=datetime.fromisoformat(data['end_date']) if data.get('end_date') else None,
            specifications=data.get('specifications', {}),
            required_skills=data.get('required_skills', []),
            required_equipment=data.get('required_equipment', []),
            images=data.get('images', []),
            documents=data.get('documents', []),
            latitude=data.get('latitude'),
            longitude=data.get('longitude'),
            address=data.get('address'),
            city=data.get('city'),
            country=data.get('country'),
            postal_code=data.get('postal_code'),
            project_manager_id=data.get('project_manager_id')
        )
        
        db.session.add(project)
        db.session.commit()
        
        return jsonify(project.to_dict()), 201
        
    except Exception as e:
        db.session.rollback()
        return jsonify({'error': str(e)}), 500

@projects_bp.route('/projects/<int:project_id>', methods=['PUT'])
@jwt_required()
def update_project(project_id):
    """Mettre à jour un projet"""
    try:
        current_user_id = get_jwt_identity()
        project = Project.query.get_or_404(project_id)
        
        # Vérifier les permissions
        if project.client_id != current_user_id and project.project_manager_id != current_user_id:
            return jsonify({'error': 'Unauthorized'}), 403
        
        data = request.get_json()
        
        # Mettre à jour les champs
        for field in ['title', 'description', 'estimated_budget', 'actual_budget',
                     'estimated_duration_days', 'specifications', 'required_skills',
                     'required_equipment', 'images', 'documents', 'assigned_workers',
                     'progress_percentage', 'milestones', 'latitude', 'longitude',
                     'address', 'city', 'country', 'postal_code']:
            if field in data:
                setattr(project, field, data[field])
        
        if 'project_type' in data:
            project.project_type = ProjectType(data['project_type'])
            
        if 'status' in data:
            project.status = ProjectStatus(data['status'])
            
        if 'start_date' in data and data['start_date']:
            project.start_date = datetime.fromisoformat(data['start_date'])
            
        if 'end_date' in data and data['end_date']:
            project.end_date = datetime.fromisoformat(data['end_date'])
            
        if 'actual_start_date' in data and data['actual_start_date']:
            project.actual_start_date = datetime.fromisoformat(data['actual_start_date'])
            
        if 'actual_end_date' in data and data['actual_end_date']:
            project.actual_end_date = datetime.fromisoformat(data['actual_end_date'])
        
        project.updated_at = datetime.utcnow()
        db.session.commit()
        
        return jsonify(project.to_dict()), 200
        
    except Exception as e:
        db.session.rollback()
        return jsonify({'error': str(e)}), 500

@projects_bp.route('/projects/<int:project_id>/milestones', methods=['GET'])
def get_project_milestones(project_id):
    """Récupérer les jalons d'un projet"""
    try:
        milestones = ProjectMilestone.query.filter_by(project_id=project_id)\
            .order_by(ProjectMilestone.due_date).all()
        
        return jsonify([milestone.to_dict() for milestone in milestones]), 200
        
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@projects_bp.route('/projects/<int:project_id>/milestones', methods=['POST'])
@jwt_required()
def create_project_milestone(project_id):
    """Créer un jalon pour un projet"""
    try:
        current_user_id = get_jwt_identity()
        project = Project.query.get_or_404(project_id)
        
        # Vérifier les permissions
        if project.client_id != current_user_id and project.project_manager_id != current_user_id:
            return jsonify({'error': 'Unauthorized'}), 403
        
        data = request.get_json()
        
        milestone = ProjectMilestone(
            project_id=project_id,
            title=data['title'],
            description=data.get('description'),
            due_date=datetime.fromisoformat(data['due_date']) if data.get('due_date') else None,
            completion_percentage=data.get('completion_percentage', 0.0)
        )
        
        db.session.add(milestone)
        db.session.commit()
        
        return jsonify(milestone.to_dict()), 201
        
    except Exception as e:
        db.session.rollback()
        return jsonify({'error': str(e)}), 500

@projects_bp.route('/projects/<int:project_id>/milestones/<int:milestone_id>', methods=['PUT'])
@jwt_required()
def update_project_milestone(project_id, milestone_id):
    """Mettre à jour un jalon de projet"""
    try:
        current_user_id = get_jwt_identity()
        milestone = ProjectMilestone.query.filter_by(
            id=milestone_id, 
            project_id=project_id
        ).first_or_404()
        
        project = Project.query.get(project_id)
        if project.client_id != current_user_id and project.project_manager_id != current_user_id:
            return jsonify({'error': 'Unauthorized'}), 403
        
        data = request.get_json()
        
        # Mettre à jour les champs
        for field in ['title', 'description', 'completion_percentage']:
            if field in data:
                setattr(milestone, field, data[field])
        
        if 'due_date' in data and data['due_date']:
            milestone.due_date = datetime.fromisoformat(data['due_date'])
            
        if 'is_completed' in data:
            milestone.is_completed = data['is_completed']
            if data['is_completed'] and not milestone.completed_date:
                milestone.completed_date = datetime.utcnow()
        
        milestone.updated_at = datetime.utcnow()
        db.session.commit()
        
        return jsonify(milestone.to_dict()), 200
        
    except Exception as e:
        db.session.rollback()
        return jsonify({'error': str(e)}), 500

@projects_bp.route('/projects/types', methods=['GET'])
def get_project_types():
    """Récupérer les types de projets disponibles"""
    try:
        types = [{'value': t.value, 'label': t.value.replace('_', ' ').title()} 
                for t in ProjectType]
        return jsonify({'types': types}), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 500
