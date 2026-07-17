from flask_jwt_extended import create_access_token

from app.extensions import db, bcrypt
from app.models.user import User
from app.common.exceptions import (
    ConflictException,
    UnauthorizedException,
    ForbiddenException
)


class AuthService:

    @staticmethod
    def register_user(data):

        existing_user = User.query.filter_by(
            email=data["email"]
        ).first()

        if existing_user:
            raise ConflictException("Email already registered.")

        user = User(
            full_name=data["full_name"],
            email=data["email"]
        )

        user.password_hash = bcrypt.generate_password_hash(
            data["password"]
        ).decode("utf-8")

        db.session.add(user)
        db.session.commit()

        return {
            "message": "User registered successfully."
        }

    @staticmethod
    def login_user(data):

        user = User.query.filter_by(
            email=data["email"]
        ).first()

        if not user:
            raise UnauthorizedException(
                "Invalid email or password."
            )

        if not bcrypt.check_password_hash(
            user.password_hash,
            data["password"]
        ):
            raise UnauthorizedException(
                "Invalid email or password."
            )

        if not user.is_active:
            raise ForbiddenException(
                "Account is inactive."
            )

        access_token = create_access_token(
            identity=str(user.id)
        )

        return {
            "message": "Login successful.",
            "access_token": access_token
        }