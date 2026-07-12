from flask import Flask
from dotenv import load_dotenv
import os
import app.models
from sqlalchemy import text
from app.config.config import Config 
from app.auth.auth_routes import auth_bp
from app.income.income_routes import income_bp
from app.expense.expense_routes import expense_bp
from app.budget.budget_routes import budget_bp
from app.goal.goal_routes import goal_bp

from app.common.error_handlers import register_error_handlers
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
    app.register_blueprint(income_bp)
    app.register_blueprint(expense_bp)
    app.register_blueprint(budget_bp)
    app.register_blueprint(goal_bp)

    
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
        

   
    register_error_handlers(app)
    
    return app

