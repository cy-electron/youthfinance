from flask import Flask
from dotenv import load_dotenv
import os
from sqlalchemy import text
from app.config.config import Config
from app.models import User
from app.auth.auth_routes import auth_bp
from app.extensions import (
    db,
    migrate,
    jwt,
    bcrypt,
    cors,
)

load_dotenv()


def create_app():
    app = Flask(__name__)
    app.config.from_object(Config)

    db.init_app(app)
    migrate.init_app(app, db)
    jwt.init_app(app)
    bcrypt.init_app(app)
    cors.init_app(app)
    app.register_blueprint(auth_bp)
    
    @app.route("/")
    def home():
        return {
            "message": "YouthFinance Backend Running 🚀"
        }
    @app.route("/db-test")
    def db_test():
        from sqlalchemy import text

        try:
            db.session.execute(text("SELECT 1"))
            return {"status": "Database Connected ✅"}

        except Exception as e:
            return {
                "status": "Connection Failed",
                "error": str(e)
            }, 500
    
    return app

