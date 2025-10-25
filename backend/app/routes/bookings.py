from flask import Blueprint, request, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity
from sqlalchemy import and_, or_, desc
from app import db
from app.models import Quote, Booking, EquipmentBooking, Payment, BookingStatus, PaymentStatus, BookingType, Project, Worker, Equipment
from datetime import datetime
import json

bookings_bp = Blueprint('bookings', __name__)

# ========== QUOTES ==========

@bookings_bp.route('/quotes', methods=['GET'])
@jwt_required()
def get_quotes():
    """Récupérer les devis de l'utilisateur"""
    try:
        current_user_id = get_jwt_identity()
        page = request.args.get('page', 1, type=int)
        per_page = request.args.get('per_page', 20, type=int)
        
        quotes = Quote.query.filter_by(client_id=current_user_id)\
            .order_by(desc(Quote.created_at))\
            .paginate(page=page, per_page=per_page, error_out=False)
        
        return jsonify({
            'quotes': [quote.to_dict() for quote in quotes.items],
            'total': quotes.total,
            'page': page,
            'per_page': per_page,
            'pages': quotes.pages
        }), 200
        
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@bookings_bp.route('/quotes', methods=['POST'])
@jwt_required()
def create_quote():
    """Créer un devis"""
    try:
        current_user_id = get_jwt_identity()
        data = request.get_json()
        
        quote = Quote(
            project_id=data['project_id'],
            client_id=current_user_id,
            title=data['title'],
            description=data.get('description'),
            total_amount=data['total_amount'],
            currency=data.get('currency', 'XOF'),
            valid_until=datetime.fromisoformat(data['valid_until']) if data.get('valid_until') else None,
            services=data.get('services', []),
            worker_requirements=data.get('worker_requirements', []),
            equipment_requirements=data.get('equipment_requirements', []),
            terms_and_conditions=data.get('terms_and_conditions'),
            payment_terms=data.get('payment_terms'),
            warranty_period=data.get('warranty_period')
        )
        
        db.session.add(quote)
        db.session.commit()
        
        return jsonify(quote.to_dict()), 201
        
    except Exception as e:
        db.session.rollback()
        return jsonify({'error': str(e)}), 500

@bookings_bp.route('/quotes/<int:quote_id>/accept', methods=['POST'])
@jwt_required()
def accept_quote(quote_id):
    """Accepter un devis"""
    try:
        current_user_id = get_jwt_identity()
        quote = Quote.query.get_or_404(quote_id)
        
        if quote.client_id != current_user_id:
            return jsonify({'error': 'Unauthorized'}), 403
        
        quote.is_accepted = True
        quote.accepted_at = datetime.utcnow()
        db.session.commit()
        
        return jsonify(quote.to_dict()), 200
        
    except Exception as e:
        db.session.rollback()
        return jsonify({'error': str(e)}), 500

# ========== BOOKINGS ==========

@bookings_bp.route('/bookings', methods=['GET'])
@jwt_required()
def get_bookings():
    """Récupérer les réservations de l'utilisateur"""
    try:
        current_user_id = get_jwt_identity()
        page = request.args.get('page', 1, type=int)
        per_page = request.args.get('per_page', 20, type=int)
        status = request.args.get('status')
        
        query = Booking.query.filter_by(client_id=current_user_id)
        
        if status:
            query = query.filter(Booking.status == BookingStatus(status))
        
        bookings = query.order_by(desc(Booking.created_at))\
            .paginate(page=page, per_page=per_page, error_out=False)
        
        return jsonify({
            'bookings': [booking.to_dict() for booking in bookings.items],
            'total': bookings.total,
            'page': page,
            'per_page': per_page,
            'pages': bookings.pages
        }), 200
        
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@bookings_bp.route('/bookings', methods=['POST'])
@jwt_required()
def create_booking():
    """Créer une réservation"""
    try:
        current_user_id = get_jwt_identity()
        data = request.get_json()
        
        booking = Booking(
            booking_type=BookingType(data['booking_type']),
            client_id=current_user_id,
            project_id=data.get('project_id'),
            quote_id=data.get('quote_id'),
            start_date=datetime.fromisoformat(data['start_date']),
            end_date=datetime.fromisoformat(data['end_date']),
            total_amount=data['total_amount'],
            currency=data.get('currency', 'XOF'),
            deposit_amount=data.get('deposit_amount', 0),
            worker_id=data.get('worker_id'),
            description=data.get('description'),
            special_requirements=data.get('special_requirements'),
            notes=data.get('notes')
        )
        
        db.session.add(booking)
        db.session.flush()  # Pour obtenir l'ID de la réservation
        
        # Créer les réservations d'équipements si nécessaire
        if data.get('equipment_bookings'):
            for eq_booking_data in data['equipment_bookings']:
                equipment_booking = EquipmentBooking(
                    booking_id=booking.id,
                    equipment_id=eq_booking_data['equipment_id'],
                    start_date=datetime.fromisoformat(eq_booking_data['start_date']),
                    end_date=datetime.fromisoformat(eq_booking_data['end_date']),
                    daily_rate=eq_booking_data.get('daily_rate'),
                    total_amount=eq_booking_data['total_amount']
                )
                db.session.add(equipment_booking)
        
        db.session.commit()
        
        return jsonify(booking.to_dict()), 201
        
    except Exception as e:
        db.session.rollback()
        return jsonify({'error': str(e)}), 500

@bookings_bp.route('/bookings/<int:booking_id>', methods=['GET'])
@jwt_required()
def get_booking(booking_id):
    """Récupérer une réservation spécifique"""
    try:
        current_user_id = get_jwt_identity()
        booking = Booking.query.get_or_404(booking_id)
        
        if booking.client_id != current_user_id:
            return jsonify({'error': 'Unauthorized'}), 403
        
        return jsonify(booking.to_dict()), 200
        
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@bookings_bp.route('/bookings/<int:booking_id>', methods=['PUT'])
@jwt_required()
def update_booking(booking_id):
    """Mettre à jour une réservation"""
    try:
        current_user_id = get_jwt_identity()
        booking = Booking.query.get_or_404(booking_id)
        
        if booking.client_id != current_user_id:
            return jsonify({'error': 'Unauthorized'}), 403
        
        data = request.get_json()
        
        # Mettre à jour les champs
        for field in ['description', 'special_requirements', 'notes']:
            if field in data:
                setattr(booking, field, data[field])
        
        if 'status' in data:
            booking.status = BookingStatus(data['status'])
            
        if 'start_date' in data and data['start_date']:
            booking.start_date = datetime.fromisoformat(data['start_date'])
            
        if 'end_date' in data and data['end_date']:
            booking.end_date = datetime.fromisoformat(data['end_date'])
        
        booking.updated_at = datetime.utcnow()
        db.session.commit()
        
        return jsonify(booking.to_dict()), 200
        
    except Exception as e:
        db.session.rollback()
        return jsonify({'error': str(e)}), 500

@bookings_bp.route('/bookings/<int:booking_id>/cancel', methods=['POST'])
@jwt_required()
def cancel_booking(booking_id):
    """Annuler une réservation"""
    try:
        current_user_id = get_jwt_identity()
        booking = Booking.query.get_or_404(booking_id)
        
        if booking.client_id != current_user_id:
            return jsonify({'error': 'Unauthorized'}), 403
        
        booking.status = BookingStatus.CANCELLED
        booking.updated_at = datetime.utcnow()
        db.session.commit()
        
        return jsonify(booking.to_dict()), 200
        
    except Exception as e:
        db.session.rollback()
        return jsonify({'error': str(e)}), 500

# ========== PAYMENTS ==========

@bookings_bp.route('/bookings/<int:booking_id>/payments', methods=['GET'])
@jwt_required()
def get_booking_payments(booking_id):
    """Récupérer les paiements d'une réservation"""
    try:
        current_user_id = get_jwt_identity()
        booking = Booking.query.get_or_404(booking_id)
        
        if booking.client_id != current_user_id:
            return jsonify({'error': 'Unauthorized'}), 403
        
        payments = Payment.query.filter_by(booking_id=booking_id)\
            .order_by(desc(Payment.created_at)).all()
        
        return jsonify([payment.to_dict() for payment in payments]), 200
        
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@bookings_bp.route('/bookings/<int:booking_id>/payments', methods=['POST'])
@jwt_required()
def create_payment(booking_id):
    """Créer un paiement pour une réservation"""
    try:
        current_user_id = get_jwt_identity()
        booking = Booking.query.get_or_404(booking_id)
        
        if booking.client_id != current_user_id:
            return jsonify({'error': 'Unauthorized'}), 403
        
        data = request.get_json()
        
        payment = Payment(
            booking_id=booking_id,
            amount=data['amount'],
            currency=data.get('currency', 'XOF'),
            payment_method=data['payment_method'],
            payment_reference=data.get('payment_reference'),
            status=PaymentStatus(data.get('status', 'pending'))
        )
        
        if data.get('status') == 'paid':
            payment.paid_at = datetime.utcnow()
            booking.paid_amount += payment.amount
            if booking.paid_amount >= booking.total_amount:
                booking.payment_status = PaymentStatus.PAID
        
        db.session.add(payment)
        db.session.commit()
        
        return jsonify(payment.to_dict()), 201
        
    except Exception as e:
        db.session.rollback()
        return jsonify({'error': str(e)}), 500

@bookings_bp.route('/bookings/statuses', methods=['GET'])
def get_booking_statuses():
    """Récupérer les statuts de réservation disponibles"""
    try:
        statuses = [{'value': s.value, 'label': s.value.replace('_', ' ').title()} 
                   for s in BookingStatus]
        return jsonify({'statuses': statuses}), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 500
