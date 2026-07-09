from app.extensions import db, bcrypt
from app.models.user import User
from flask_jwt_extended import create_access_token


class AuthService:

    @staticmethod
    def register_user(data):
        """
        Register a new user.
        """

        # Check if email already exists
        existing_user = User.query.filter_by(email=data["email"]).first()

        if existing_user:
            return {
                "success": False,
                "message": "Email already registered."
            }, 409

        # Create new user
        user = User(
            full_name=data["full_name"],
            email=data["email"]
        )

        # Hash password
        hashed_password = bcrypt.generate_password_hash(
            data["password"]
        ).decode("utf-8")

        user.password_hash = hashed_password

        db.session.add(user)
        db.session.commit()

        return {
            "success": True,
            "message": "User registered successfully."
        }, 201
    
    @staticmethod
    def login_user(data):

        user = User.query.filter_by(email=data["email"]).first()

        if not user:
            return {
                "success": False,
                "message": "Invalid email or password."
            }, 401

        if not bcrypt.check_password_hash(
            user.password_hash,
            data["password"]
        ):
            return {
                "success": False,
                "message": "Invalid email or password."
            }, 401

        if not user.is_active:
            return {
                "success": False,
                "message": "Account is inactive."
            }, 403

        access_token = create_access_token(
            identity=str(user.id)
        )

        return {
            "success": True,
            "message": "Login successful.",
            "access_token": access_token
        }, 200