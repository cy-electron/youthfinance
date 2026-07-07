from flask import Flask
from dotenv import load_dotenv
import os

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

    app.config["SQLALCHEMY_DATABASE_URI"] = os.getenv("DATABASE_URL")
    app.config["SQLALCHEMY_TRACK_MODIFICATIONS"] = False
    app.config["SECRET_KEY"] = os.getenv("SECRET_KEY")
    app.config["JWT_SECRET_KEY"] = os.getenv("JWT_SECRET_KEY")
    app.config["UPLOAD_FOLDER"] = os.getenv("UPLOAD_FOLDER")

    db.init_app(app)
    migrate.init_app(app, db)
    jwt.init_app(app)
    bcrypt.init_app(app)
    cors.init_app(app)

    @app.route("/")
    def home():
        return {
            "message": "YouthFinance Backend Running 🚀"
        }

    return app