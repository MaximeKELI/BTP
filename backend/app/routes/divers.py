from flask import Blueprint, request, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity
from app import db
from app.models.divers import Projet, Client, Facture, Paiement, ProjetStatus, ClientType, FactureStatus, PaiementMethod
from app.models.user import User
from app.utils.validators import validate_coordinates, validate_currency_code
from app.utils.helpers import clean_filename, generate_invoice_number, generate_random_string
from werkzeug.utils import secure_filename
import os
from datetime import datetime, date

divers_bp = Blueprint('divers', __name__)

# ===== CLIENTS =====

@divers_bp.route('/clients', methods=['GET'])
@jwt_required()
def get_clients():
    """Get all clients for current user"""
    try:
        current_user_id = get_jwt_identity()
        
        # Get query parameters
        client_type = request.args.get('client_type')
        industry = request.args.get('industry')
        is_active = request.args.get('is_active', 'true').lower() == 'true'
        page = request.args.get('page', 1, type=int)
        per_page = request.args.get('per_page', 20, type=int)
        
        # Build query
        query = Client.query.filter_by(is_active=is_active)
        
        # Filter by account manager or projects
        query = query.filter(
            (Client.account_manager_id == current_user_id) |
            (Client.projets.any(Projet.manager_id == current_user_id))
        )
        
        if client_type:
            query = query.filter_by(client_type=ClientType(client_type))
        
        if industry:
            query = query.filter(Client.industry.ilike(f'%{industry}%'))
        
        # Paginate results
        results = query.paginate(
            page=page, 
            per_page=per_page, 
            error_out=False
        )
        
        clients = [client.to_dict() for client in results.items]
        
        return jsonify({
            'clients': clients,
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

@divers_bp.route('/clients', methods=['POST'])
@jwt_required()
def create_client():
    """Create a new client"""
    try:
        current_user_id = get_jwt_identity()
        data = request.get_json()
        
        # Validate required fields
        if not data.get('name') or not data.get('client_type'):
            return jsonify({'error': 'Name and client_type are required'}), 400
        
        # Validate currency code if provided
        if data.get('currency') and not validate_currency_code(data['currency']):
            return jsonify({'error': 'Invalid currency code'}), 400
        
        # Create client
        client = Client(
            name=data['name'],
            contact_person=data.get('contact_person'),
            email=data.get('email'),
            phone=data.get('phone'),
            website=data.get('website'),
            client_type=ClientType(data['client_type']),
            industry=data.get('industry'),
            company_size=data.get('company_size'),
            tax_number=data.get('tax_number'),
            registration_number=data.get('registration_number'),
            credit_limit=data.get('credit_limit'),
            payment_terms=data.get('payment_terms'),
            preferred_payment_method=data.get('preferred_payment_method'),
            currency=data.get('currency', 'XOF'),
            account_manager_id=current_user_id,
            client_since=datetime.fromisoformat(data['client_since']).date() if data.get('client_since') else date.today(),
            communication_preferences=data.get('communication_preferences'),
            special_requirements=data.get('special_requirements'),
            notes=data.get('notes'),
            risk_level=data.get('risk_level')
        )
        
        # Set location if provided
        if 'latitude' in data and 'longitude' in data:
            client.set_location(
                data['latitude'], 
                data['longitude'], 
                data.get('address')
            )
        
        db.session.add(client)
        db.session.commit()
        
        return jsonify({
            'message': 'Client created successfully',
            'client': client.to_dict()
        }), 201
        
    except Exception as e:
        db.session.rollback()
        return jsonify({'error': str(e)}), 500

@divers_bp.route('/clients/<int:client_id>', methods=['GET'])
@jwt_required()
def get_client(client_id):
    """Get specific client"""
    try:
        current_user_id = get_jwt_identity()
        
        client = Client.query.filter_by(
            id=client_id, 
            is_active=True
        ).first()
        
        if not client:
            return jsonify({'error': 'Client not found'}), 404
        
        # Check access
        has_access = (
            client.account_manager_id == current_user_id or
            client.projets.filter_by(manager_id=current_user_id).first()
        )
        
        if not has_access:
            return jsonify({'error': 'Access denied'}), 403
        
        return jsonify({'client': client.to_dict()}), 200
        
    except Exception as e:
        return jsonify({'error': str(e)}), 500

# ===== PROJETS =====

@divers_bp.route('/projets', methods=['GET'])
@jwt_required()
def get_projets():
    """Get all projets for current user"""
    try:
        current_user_id = get_jwt_identity()
        
        # Get query parameters
        status = request.args.get('status')
        project_type = request.args.get('project_type')
        sector = request.args.get('sector')
        page = request.args.get('page', 1, type=int)
        per_page = request.args.get('per_page', 20, type=int)
        
        # Build query
        query = Projet.query.filter_by(is_active=True)
        
        # Filter by manager or team member
        query = query.filter(
            (Projet.manager_id == current_user_id) |
            (Projet.team_members.contains(str(current_user_id)))
        )
        
        if status:
            query = query.filter_by(status=ProjetStatus(status))
        
        if project_type:
            query = query.filter(Projet.project_type.ilike(f'%{project_type}%'))
        
        if sector:
            query = query.filter(Projet.sector.ilike(f'%{sector}%'))
        
        # Paginate results
        results = query.paginate(
            page=page, 
            per_page=per_page, 
            error_out=False
        )
        
        projets = [projet.to_dict() for projet in results.items]
        
        return jsonify({
            'projets': projets,
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

@divers_bp.route('/projets', methods=['POST'])
@jwt_required()
def create_projet():
    """Create a new projet"""
    try:
        current_user_id = get_jwt_identity()
        data = request.get_json()
        
        # Validate required fields
        if not data.get('name') or not data.get('client_id'):
            return jsonify({'error': 'Name and client_id are required'}), 400
        
        # Validate currency code if provided
        if data.get('currency') and not validate_currency_code(data['currency']):
            return jsonify({'error': 'Invalid currency code'}), 400
        
        # Verify client exists and user has access
        client = Client.query.filter_by(
            id=data['client_id'], 
            is_active=True
        ).first()
        
        if not client:
            return jsonify({'error': 'Client not found'}), 404
        
        has_client_access = (
            client.account_manager_id == current_user_id or
            client.projets.filter_by(manager_id=current_user_id).first()
        )
        
        if not has_client_access:
            return jsonify({'error': 'Access denied to client'}), 403
        
        # Create projet
        projet = Projet(
            name=data['name'],
            description=data.get('description'),
            client_id=data['client_id'],
            manager_id=current_user_id,
            project_type=data.get('project_type'),
            sector=data.get('sector'),
            status=ProjetStatus(data.get('status', 'planning')),
            start_date=datetime.fromisoformat(data['start_date']) if data.get('start_date') else None,
            end_date=datetime.fromisoformat(data['end_date']) if data.get('end_date') else None,
            estimated_duration_days=data.get('estimated_duration_days'),
            budget=data.get('budget'),
            actual_cost=data.get('actual_cost'),
            hourly_rate=data.get('hourly_rate'),
            currency=data.get('currency', 'XOF'),
            progress_percentage=data.get('progress_percentage', 0),
            milestones=data.get('milestones'),
            deliverables=data.get('deliverables'),
            team_members=data.get('team_members'),
            required_skills=data.get('required_skills'),
            equipment_needed=data.get('equipment_needed')
        )
        
        # Set location if provided
        if 'latitude' in data and 'longitude' in data:
            projet.set_location(
                data['latitude'], 
                data['longitude'], 
                data.get('address')
            )
        
        db.session.add(projet)
        db.session.commit()
        
        return jsonify({
            'message': 'Projet created successfully',
            'projet': projet.to_dict()
        }), 201
        
    except Exception as e:
        db.session.rollback()
        return jsonify({'error': str(e)}), 500

@divers_bp.route('/projets/<int:projet_id>', methods=['GET'])
@jwt_required()
def get_projet(projet_id):
    """Get specific projet"""
    try:
        current_user_id = get_jwt_identity()
        
        projet = Projet.query.filter_by(
            id=projet_id, 
            is_active=True
        ).first()
        
        if not projet:
            return jsonify({'error': 'Projet not found'}), 404
        
        # Check access
        has_access = (
            projet.manager_id == current_user_id or
            str(current_user_id) in (projet.team_members or '')
        )
        
        if not has_access:
            return jsonify({'error': 'Access denied'}), 403
        
        return jsonify({'projet': projet.to_dict()}), 200
        
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@divers_bp.route('/projets/<int:projet_id>', methods=['PUT'])
@jwt_required()
def update_projet(projet_id):
    """Update projet"""
    try:
        current_user_id = get_jwt_identity()
        
        projet = Projet.query.filter_by(
            id=projet_id, 
            is_active=True
        ).first()
        
        if not projet:
            return jsonify({'error': 'Projet not found'}), 404
        
        # Check if user is manager
        if projet.manager_id != current_user_id:
            return jsonify({'error': 'Only manager can update projet'}), 403
        
        data = request.get_json()
        
        # Update fields
        if 'name' in data:
            projet.name = data['name']
        if 'description' in data:
            projet.description = data['description']
        if 'project_type' in data:
            projet.project_type = data['project_type']
        if 'sector' in data:
            projet.sector = data['sector']
        if 'status' in data:
            projet.status = ProjetStatus(data['status'])
        if 'start_date' in data:
            projet.start_date = datetime.fromisoformat(data['start_date']) if data['start_date'] else None
        if 'end_date' in data:
            projet.end_date = datetime.fromisoformat(data['end_date']) if data['end_date'] else None
        if 'estimated_duration_days' in data:
            projet.estimated_duration_days = data['estimated_duration_days']
        if 'budget' in data:
            projet.budget = data['budget']
        if 'actual_cost' in data:
            projet.actual_cost = data['actual_cost']
        if 'hourly_rate' in data:
            projet.hourly_rate = data['hourly_rate']
        if 'currency' in data:
            projet.currency = data['currency']
        if 'progress_percentage' in data:
            projet.progress_percentage = data['progress_percentage']
        if 'milestones' in data:
            projet.milestones = data['milestones']
        if 'deliverables' in data:
            projet.deliverables = data['deliverables']
        if 'team_members' in data:
            projet.team_members = data['team_members']
        if 'required_skills' in data:
            projet.required_skills = data['required_skills']
        if 'equipment_needed' in data:
            projet.equipment_needed = data['equipment_needed']
        if 'quality_rating' in data:
            projet.quality_rating = data['quality_rating']
        if 'client_satisfaction' in data:
            projet.client_satisfaction = data['client_satisfaction']
        if 'completion_notes' in data:
            projet.completion_notes = data['completion_notes']
        
        # Update location if provided
        if 'latitude' in data and 'longitude' in data:
            projet.set_location(
                data['latitude'], 
                data['longitude'], 
                data.get('address')
            )
        
        db.session.commit()
        
        return jsonify({
            'message': 'Projet updated successfully',
            'projet': projet.to_dict()
        }), 200
        
    except Exception as e:
        db.session.rollback()
        return jsonify({'error': str(e)}), 500

# ===== FACTURES (Invoices) =====

@divers_bp.route('/factures', methods=['GET'])
@jwt_required()
def get_factures():
    """Get all factures for current user"""
    try:
        current_user_id = get_jwt_identity()
        
        # Get query parameters
        status = request.args.get('status')
        client_id = request.args.get('client_id')
        page = request.args.get('page', 1, type=int)
        per_page = request.args.get('per_page', 20, type=int)
        
        # Build query
        query = Facture.query.filter_by(is_active=True)
        
        # Filter by creator or related projet manager
        query = query.filter(
            (Facture.created_by_id == current_user_id) |
            (Facture.projet.has(Projet.manager_id == current_user_id))
        )
        
        if status:
            query = query.filter_by(status=FactureStatus(status))
        
        if client_id:
            query = query.filter_by(client_id=client_id)
        
        # Paginate results
        results = query.paginate(
            page=page, 
            per_page=per_page, 
            error_out=False
        )
        
        factures = [facture.to_dict() for facture in results.items]
        
        return jsonify({
            'factures': factures,
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

@divers_bp.route('/factures', methods=['POST'])
@jwt_required()
def create_facture():
    """Create a new facture"""
    try:
        current_user_id = get_jwt_identity()
        data = request.get_json()
        
        # Validate required fields
        if not data.get('client_id') or not data.get('title') or not data.get('subtotal'):
            return jsonify({'error': 'Client ID, title and subtotal are required'}), 400
        
        # Validate currency code if provided
        if data.get('currency') and not validate_currency_code(data['currency']):
            return jsonify({'error': 'Invalid currency code'}), 400
        
        # Verify client exists and user has access
        client = Client.query.filter_by(
            id=data['client_id'], 
            is_active=True
        ).first()
        
        if not client:
            return jsonify({'error': 'Client not found'}), 404
        
        has_client_access = (
            client.account_manager_id == current_user_id or
            client.projets.filter_by(manager_id=current_user_id).first()
        )
        
        if not has_client_access:
            return jsonify({'error': 'Access denied to client'}), 403
        
        # Generate invoice number
        invoice_number = generate_invoice_number()
        
        # Calculate totals
        subtotal = float(data['subtotal'])
        tax_rate = float(data.get('tax_rate', 0))
        tax_amount = subtotal * (tax_rate / 100) if tax_rate > 0 else 0
        discount_rate = float(data.get('discount_rate', 0))
        discount_amount = subtotal * (discount_rate / 100) if discount_rate > 0 else 0
        total_amount = subtotal + tax_amount - discount_amount
        
        # Create facture
        facture = Facture(
            client_id=data['client_id'],
            projet_id=data.get('projet_id'),
            created_by_id=current_user_id,
            invoice_number=invoice_number,
            title=data['title'],
            description=data.get('description'),
            status=FactureStatus(data.get('status', 'draft')),
            invoice_date=datetime.fromisoformat(data['invoice_date']).date() if data.get('invoice_date') else date.today(),
            due_date=datetime.fromisoformat(data['due_date']).date() if data.get('due_date') else None,
            subtotal=subtotal,
            tax_rate=tax_rate,
            tax_amount=tax_amount,
            discount_rate=discount_rate,
            discount_amount=discount_amount,
            total_amount=total_amount,
            balance_due=total_amount,
            currency=data.get('currency', 'XOF'),
            payment_terms=data.get('payment_terms'),
            late_fee_rate=data.get('late_fee_rate'),
            late_fee_amount=data.get('late_fee_amount'),
            line_items=data.get('line_items'),
            notes=data.get('notes'),
            terms_conditions=data.get('terms_conditions'),
            attachments=data.get('attachments')
        )
        
        db.session.add(facture)
        db.session.commit()
        
        return jsonify({
            'message': 'Facture created successfully',
            'facture': facture.to_dict()
        }), 201
        
    except Exception as e:
        db.session.rollback()
        return jsonify({'error': str(e)}), 500

@divers_bp.route('/factures/<int:facture_id>', methods=['GET'])
@jwt_required()
def get_facture(facture_id):
    """Get specific facture"""
    try:
        current_user_id = get_jwt_identity()
        
        facture = Facture.query.filter_by(
            id=facture_id, 
            is_active=True
        ).first()
        
        if not facture:
            return jsonify({'error': 'Facture not found'}), 404
        
        # Check access
        has_access = (
            facture.created_by_id == current_user_id or
            (facture.projet and facture.projet.manager_id == current_user_id)
        )
        
        if not has_access:
            return jsonify({'error': 'Access denied'}), 403
        
        return jsonify({'facture': facture.to_dict()}), 200
        
    except Exception as e:
        return jsonify({'error': str(e)}), 500

# ===== PAIEMENTS (Payments) =====

@divers_bp.route('/factures/<int:facture_id>/paiements', methods=['GET'])
@jwt_required()
def get_facture_paiements(facture_id):
    """Get paiements for a facture"""
    try:
        current_user_id = get_jwt_identity()
        
        facture = Facture.query.filter_by(
            id=facture_id, 
            is_active=True
        ).first()
        
        if not facture:
            return jsonify({'error': 'Facture not found'}), 404
        
        # Check access
        has_access = (
            facture.created_by_id == current_user_id or
            (facture.projet and facture.projet.manager_id == current_user_id)
        )
        
        if not has_access:
            return jsonify({'error': 'Access denied'}), 403
        
        paiements = [paiement.to_dict() for paiement in facture.paiements]
        
        return jsonify({'paiements': paiements}), 200
        
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@divers_bp.route('/paiements', methods=['POST'])
@jwt_required()
def create_paiement():
    """Create a new paiement"""
    try:
        current_user_id = get_jwt_identity()
        data = request.get_json()
        
        # Validate required fields
        if not data.get('facture_id') or not data.get('amount') or not data.get('method'):
            return jsonify({'error': 'Facture ID, amount and method are required'}), 400
        
        # Verify facture exists and user has access
        facture = Facture.query.filter_by(
            id=data['facture_id'], 
            is_active=True
        ).first()
        
        if not facture:
            return jsonify({'error': 'Facture not found'}), 404
        
        has_facture_access = (
            facture.created_by_id == current_user_id or
            (facture.projet and facture.projet.manager_id == current_user_id)
        )
        
        if not has_facture_access:
            return jsonify({'error': 'Access denied to facture'}), 403
        
        # Generate payment number
        payment_number = f"PAY-{generate_random_string(8)}"
        
        # Create paiement
        paiement = Paiement(
            facture_id=data['facture_id'],
            client_id=facture.client_id,
            processed_by_id=current_user_id,
            payment_number=payment_number,
            amount=data['amount'],
            currency=data.get('currency', facture.currency),
            payment_date=datetime.fromisoformat(data['payment_date']) if data.get('payment_date') else datetime.utcnow(),
            method=PaiementMethod(data['method']),
            reference_number=data.get('reference_number'),
            bank_name=data.get('bank_name'),
            account_number=data.get('account_number'),
            mobile_money_provider=data.get('mobile_money_provider'),
            card_last_four=data.get('card_last_four'),
            card_type=data.get('card_type'),
            status=data.get('status', 'completed'),
            processing_fee=data.get('processing_fee'),
            exchange_rate=data.get('exchange_rate'),
            notes=data.get('notes')
        )
        
        db.session.add(paiement)
        
        # Update facture paid amount and balance
        facture.paid_amount += paiement.amount
        facture.balance_due = facture.total_amount - facture.paid_amount
        
        # Update facture status if fully paid
        if facture.balance_due <= 0:
            facture.status = FactureStatus('paid')
            facture.paid_date = datetime.utcnow()
        
        db.session.commit()
        
        return jsonify({
            'message': 'Paiement recorded successfully',
            'paiement': paiement.to_dict()
        }), 201
        
    except Exception as e:
        db.session.rollback()
        return jsonify({'error': str(e)}), 500
