from flask import Flask
from flask_sqlalchemy import SQLAlchemy
from flask_jwt_extended import JWTManager
from flask_cors import CORS
from flask_migrate import Migrate
try:
    from celery import Celery
except ImportError:
    Celery = None
try:
    import redis
except ImportError:
    redis = None
import os
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

# Initialize extensions
db = SQLAlchemy()
jwt = JWTManager()
migrate = Migrate()
redis_client = redis.Redis(host=os.getenv('REDIS_HOST', 'localhost'), port=6379, db=0) if redis else None

def create_celery_app(app=None):
    """Create Celery instance for background tasks"""
    if not Celery:
        return None
        
    celery = Celery(
        app.import_name if app else 'app',
        backend=os.getenv('CELERY_BROKER_URL', 'redis://localhost:6379/0'),
        broker=os.getenv('CELERY_BROKER_URL', 'redis://localhost:6379/0')
    )
    
    if app:
        celery.conf.update(app.config)
        
        class ContextTask(celery.Task):
            def __call__(self, *args, **kwargs):
                with app.app_context():
                    return self.run(*args, **kwargs)
        
        celery.Task = ContextTask
    
    return celery

def create_app(config_name='development'):
    """Application factory pattern"""
    app = Flask(__name__)
    
    # Configuration
    app.config['SECRET_KEY'] = os.getenv('SECRET_KEY', 'dev-secret-key-change-in-production')
    app.config['SQLALCHEMY_DATABASE_URI'] = os.getenv(
        'DATABASE_URL', 
        'sqlite:///btp_app.db'
    )
    app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
    app.config['JWT_SECRET_KEY'] = os.getenv('JWT_SECRET_KEY', 'jwt-secret-string')
    app.config['JWT_ACCESS_TOKEN_EXPIRES'] = False  # No expiration for mobile
    app.config['UPLOAD_FOLDER'] = os.getenv('UPLOAD_FOLDER', 'uploads')
    app.config['MAX_CONTENT_LENGTH'] = 16 * 1024 * 1024  # 16MB max file size
    
    # Initialize extensions
    db.init_app(app)
    jwt.init_app(app)
    migrate.init_app(app, db)
    # CORS configuration - restrict in production
    if config_name == 'production':
        CORS(app, origins=['https://yourdomain.com'])  # Configure for production
    else:
        CORS(app, origins=['*'])  # Allow all origins in development
    
    # Register blueprints
    from app.routes.auth import auth_bp
    from app.routes.users import users_bp
    from app.routes.btp import btp_bp
    from app.routes.agribusiness import agribusiness_bp
    from app.routes.mining import mining_bp
    from app.routes.divers import divers_bp
    from app.routes.common import common_bp
    
    app.register_blueprint(auth_bp, url_prefix='/api/auth')
    app.register_blueprint(users_bp, url_prefix='/api/users')
    app.register_blueprint(btp_bp, url_prefix='/api/btp')
    app.register_blueprint(agribusiness_bp, url_prefix='/api/agribusiness')
    app.register_blueprint(mining_bp, url_prefix='/api/mining')
    app.register_blueprint(divers_bp, url_prefix='/api/divers')
    app.register_blueprint(common_bp, url_prefix='/api/common')
    
    # Error handlers
    @app.errorhandler(404)
    def not_found(error):
        return {'message': 'Resource not found'}, 404
    
    @app.errorhandler(500)
    def internal_error(error):
        return {'message': 'Internal server error'}, 500
    
    return app

# Create Celery instance
celery = create_celery_app()
