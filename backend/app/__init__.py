from flask import Flask
from dotenv import load_dotenv
import os
import app.models
from sqlalchemy import text
from app.config.config import Config 
from app.modules.auth.auth_routes import auth_bp
from app.modules.income.income_routes import income_bp
from app.modules.expense.expense_routes import expense_bp
from app.modules.budget.budget_routes import budget_bp
from app.modules.goal.goal_routes import goal_bp
from app.analytics.financial_health.financial_health_routes import financial_health_bp
from app.analytics.dashboard.dashboard_routes import dashboard_bp
from app.common.error_handlers import register_error_handlers
from app.analytics.goal_readiness.goal_readiness_routes import goal_readiness_bp
from app.analytics.spending_analysis.spending_analysis_routes import analysis_bp
from app.analytics.financial_planner.planner_routes import planner_bp
from app.modules.savings.savings_routes import saving_bp
from app.modules.investment.investment_routes import investment_bp
from app.modules.fun_fund.fun_fund_routes import fun_fund_bp
from app.modules.emergency.emergency_routes import emergency_bp
from app.modules.notification.notification_routes import notification_bp
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
    app.register_blueprint(investment_bp)
    app.register_blueprint(fun_fund_bp)
    app.register_blueprint(emergency_bp)
    app.register_blueprint(notification_bp)
    app.register_blueprint(saving_bp)   
    app.register_blueprint(goal_bp)
    app.register_blueprint(dashboard_bp)
    app.register_blueprint(financial_health_bp)
    app.register_blueprint(goal_readiness_bp)
    app.register_blueprint(analysis_bp)
    app.register_blueprint(planner_bp)
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

