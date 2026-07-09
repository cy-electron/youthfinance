from flask import Blueprint, request
from flask_jwt_extended import jwt_required, get_jwt_identity
from marshmallow import ValidationError
from app.models.user import User

from app.auth.auth_schema import RegisterSchema, LoginSchema
from app.auth.auth_service import AuthService

auth_bp = Blueprint("auth", __name__, url_prefix="/api/auth")

register_schema = RegisterSchema()


@auth_bp.route("/register", methods=["POST"])
def register():

    try:
        data = register_schema.load(request.get_json())

    except ValidationError as err:
        return {
            "success": False,
            "errors": err.messages
        }, 400

    response, status = AuthService.register_user(data)

    return response, status


login_schema = LoginSchema()
@auth_bp.route("/login", methods=["POST"])
def login():

    try:
        data = login_schema.load(request.get_json())

    except ValidationError as err:
        return {
            "success": False,
            "errors": err.messages
        }, 400

    response, status = AuthService.login_user(data)

    return response, status

@auth_bp.route("/profile", methods=["GET"])
@jwt_required()
def profile():

    user_id = get_jwt_identity()

    user = User.query.get(user_id)

    if not user:
        return {
            "success": False,
            "message": "User not found."
        }, 404

    return {
        "success": True,
        "data": {
            "id": str(user.id),
            "full_name": user.full_name,
            "email": user.email,
            "is_active": user.is_active
        }
    }, 200