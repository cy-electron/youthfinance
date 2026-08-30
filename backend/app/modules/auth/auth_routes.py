from flask import Blueprint, request
from flask_jwt_extended import jwt_required, get_jwt_identity

from app.extensions import db

from app.modules.auth.auth_schema import (
    RegisterSchema,
    LoginSchema,
    ProfileUpdateSchema,
)

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


# ============================================================
# Schemas
# ============================================================

register_schema = RegisterSchema()
login_schema = LoginSchema()
profile_update_schema = ProfileUpdateSchema()


# ============================================================
# Register
# ============================================================

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


# ============================================================
# Login
# ============================================================

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


# ============================================================
# Profile
# GET    → Fetch current profile
# PATCH  → Update current profile
# ============================================================

@auth_bp.route("/profile", methods=["GET", "PATCH"])
@jwt_required()
def profile():

    user_id = get_jwt_identity()

    user = User.query.get(user_id)

    if not user:
        raise NotFoundException("User not found.")

    # --------------------------------------------------------
    # Update profile
    # --------------------------------------------------------

    if request.method == "PATCH":

        data = validate_schema(
            profile_update_schema,
            request.get_json()
        )

        user.full_name = data["full_name"]
        user.age = data["age"]
        user.gender = data["gender"]
        user.region = data["region"]
        user.occupation = data["occupation"]

        db.session.commit()

    # --------------------------------------------------------
    # Return current profile
    # --------------------------------------------------------

    return success_response(
        data={
            "id": user.id,
            "full_name": user.full_name,
            "email": user.email,
            "age": user.age,
            "gender": user.gender,
            "region": user.region,
            "occupation": user.occupation,
            "is_active": user.is_active,
        }
    )