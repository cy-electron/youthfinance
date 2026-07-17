from flask import Blueprint, request
from flask_jwt_extended import jwt_required, get_jwt_identity

from app.modules.auth.auth_schema import RegisterSchema, LoginSchema
from app.modules.auth.auth_service import AuthService

from app.common.responses import success_response
from app.common.validators import validate_schema
from app.common.exceptions import NotFoundException

from app.models.user import User


auth_bp = Blueprint(
    "auth",
    __name__,
    url_prefix="/api/auth"
)

register_schema = RegisterSchema()
login_schema = LoginSchema()


@auth_bp.route("/register", methods=["POST"])
def register():

    data = validate_schema(
        register_schema,
        request.get_json()
    )

    result = AuthService.register_user(data)

    return success_response(
        message=result["message"],
        status_code=201
    )


@auth_bp.route("/login", methods=["POST"])
def login():

    data = validate_schema(
        login_schema,
        request.get_json()
    )

    result = AuthService.login_user(data)

    return success_response(
        message=result["message"],
        data={
            "access_token": result["access_token"]
        }
    )


@auth_bp.route("/profile", methods=["GET"])
@jwt_required()
def profile():

    user_id = get_jwt_identity()

    user = User.query.get(user_id)

    if not user:
        raise NotFoundException("User not found.")

    return success_response(
        data={
            "id": user.id,
            "full_name": user.full_name,
            "email": user.email,
            "is_active": user.is_active
        }
    )