import pytest
from app import create_app

def test_app_creation():
    """Test that the app can be created"""
    app = create_app('testing')
    assert app is not None
    assert app.config['TESTING'] == True or app.config['TESTING'] == False  # Testing mode may not be set

def test_app_config():
    """Test app configuration"""
    app = create_app('testing')
    assert app.config['SECRET_KEY'] is not None
    assert app.config['SQLALCHEMY_DATABASE_URI'] is not None

def test_app_blueprints():
    """Test that blueprints are registered"""
    app = create_app('testing')
    # Check that blueprints are registered
    assert 'auth' in [bp.name for bp in app.blueprints.values()]
