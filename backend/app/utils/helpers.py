import random
import string
import hashlib
import secrets
from datetime import datetime, timedelta
from typing import Optional, Dict, Any
import json

def generate_verification_code(length: int = 6) -> str:
    """Generate a random verification code"""
    return ''.join(random.choices(string.digits, k=length))

def generate_random_string(length: int = 32) -> str:
    """Generate a random string"""
    return ''.join(random.choices(string.ascii_letters + string.digits, k=length))

def generate_api_key() -> str:
    """Generate a secure API key"""
    return secrets.token_urlsafe(32)

def hash_string(text: str) -> str:
    """Hash a string using SHA-256"""
    return hashlib.sha256(text.encode()).hexdigest()

def generate_invoice_number(prefix: str = "INV") -> str:
    """Generate a unique invoice number"""
    timestamp = datetime.now().strftime("%Y%m%d%H%M%S")
    random_suffix = ''.join(random.choices(string.digits, k=4))
    return f"{prefix}-{timestamp}-{random_suffix}"

def generate_project_code(sector: str, year: int = None) -> str:
    """Generate a project code"""
    if year is None:
        year = datetime.now().year
    
    sector_code = sector.upper()[:3]
    random_code = ''.join(random.choices(string.ascii_uppercase + string.digits, k=4))
    return f"{sector_code}-{year}-{random_code}"

def calculate_distance(lat1: float, lon1: float, lat2: float, lon2: float) -> float:
    """Calculate distance between two GPS coordinates in kilometers"""
    from math import radians, cos, sin, asin, sqrt
    
    # Convert decimal degrees to radians
    lat1, lon1, lat2, lon2 = map(radians, [lat1, lon1, lat2, lon2])
    
    # Haversine formula
    dlat = lat2 - lat1
    dlon = lon2 - lon1
    a = sin(dlat/2)**2 + cos(lat1) * cos(lat2) * sin(dlon/2)**2
    c = 2 * asin(sqrt(a))
    
    # Radius of earth in kilometers
    r = 6371
    return c * r

def format_currency(amount: float, currency: str = "XOF") -> str:
    """Format currency amount"""
    currency_symbols = {
        'XOF': 'FCFA',
        'USD': '$',
        'EUR': '€',
        'GBP': '£'
    }
    
    symbol = currency_symbols.get(currency, currency)
    return f"{amount:,.2f} {symbol}"

def format_phone_number(phone: str, country_code: str = "+225") -> str:
    """Format phone number with country code"""
    # Remove all non-digit characters
    digits = ''.join(filter(str.isdigit, phone))
    
    # Add country code if not present
    if not phone.startswith('+'):
        return f"{country_code}{digits}"
    
    return phone

def parse_json_safe(data: str, default: Any = None) -> Any:
    """Safely parse JSON string"""
    try:
        return json.loads(data) if data else default
    except (json.JSONDecodeError, TypeError):
        return default

def serialize_json_safe(data: Any) -> str:
    """Safely serialize data to JSON string"""
    try:
        return json.dumps(data, default=str)
    except (TypeError, ValueError):
        return "{}"

def get_file_extension(filename: str) -> str:
    """Get file extension from filename"""
    return filename.rsplit('.', 1)[1].lower() if '.' in filename else ''

def is_image_file(filename: str) -> bool:
    """Check if file is an image"""
    image_extensions = {'jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp', 'svg'}
    return get_file_extension(filename) in image_extensions

def is_document_file(filename: str) -> bool:
    """Check if file is a document"""
    doc_extensions = {'pdf', 'doc', 'docx', 'xls', 'xlsx', 'ppt', 'pptx', 'txt'}
    return get_file_extension(filename) in doc_extensions

def generate_otp(length: int = 6) -> str:
    """Generate a one-time password"""
    return ''.join(random.choices(string.digits, k=length))

def is_valid_otp(otp: str, length: int = 6) -> bool:
    """Validate OTP format"""
    return len(otp) == length and otp.isdigit()

def calculate_age(birth_date: datetime) -> int:
    """Calculate age from birth date"""
    today = datetime.now()
    return today.year - birth_date.year - ((today.month, today.day) < (birth_date.month, birth_date.day))

def get_time_ago(dt: datetime) -> str:
    """Get human-readable time ago string"""
    now = datetime.now()
    diff = now - dt
    
    if diff.days > 0:
        return f"{diff.days} day{'s' if diff.days > 1 else ''} ago"
    elif diff.seconds > 3600:
        hours = diff.seconds // 3600
        return f"{hours} hour{'s' if hours > 1 else ''} ago"
    elif diff.seconds > 60:
        minutes = diff.seconds // 60
        return f"{minutes} minute{'s' if minutes > 1 else ''} ago"
    else:
        return "Just now"

def clean_filename(filename: str) -> str:
    """Clean filename for safe storage"""
    # Remove or replace invalid characters
    invalid_chars = '<>:"/\\|?*'
    for char in invalid_chars:
        filename = filename.replace(char, '_')
    
    # Limit length
    if len(filename) > 255:
        name, ext = filename.rsplit('.', 1) if '.' in filename else (filename, '')
        filename = name[:255-len(ext)-1] + ('.' + ext if ext else '')
    
    return filename

def send_verification_email(email: str, code: str) -> bool:
    """Send verification email (placeholder)"""
    # In production, integrate with email service (SendGrid, AWS SES, etc.)
    print(f"Verification code for {email}: {code}")
    return True

def send_password_reset_email(email: str, code: str) -> bool:
    """Send password reset email (placeholder)"""
    # In production, integrate with email service
    print(f"Password reset code for {email}: {code}")
    return True

def send_notification(user_id: int, title: str, message: str, data: Dict = None) -> bool:
    """Send push notification (placeholder)"""
    # In production, integrate with Firebase Cloud Messaging
    print(f"Notification to user {user_id}: {title} - {message}")
    return True
