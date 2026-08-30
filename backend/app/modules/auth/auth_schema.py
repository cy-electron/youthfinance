from marshmallow import Schema, fields, validate


# ============================================================
# Registration
# ============================================================

class RegisterSchema(Schema):
    full_name = fields.String(
        required=True,
        validate=validate.Length(min=2, max=100)
    )

    email = fields.Email(
        required=True
    )

    password = fields.String(
        required=True,
        validate=validate.Length(min=8)
    )


# ============================================================
# Login
# ============================================================

class LoginSchema(Schema):
    email = fields.Email(
        required=True
    )

    password = fields.String(
        required=True
    )


# ============================================================
# Profile Update
# ============================================================

class ProfileUpdateSchema(Schema):
    full_name = fields.String(
        required=True,
        validate=validate.Length(min=2, max=100)
    )

    age = fields.Integer(
        required=True,
        validate=validate.Range(min=13, max=100)
    )

    gender = fields.String(
        required=True,
        validate=validate.Length(min=1, max=30)
    )

    region = fields.String(
        required=True,
        validate=validate.Length(min=1, max=100)
    )

    occupation = fields.String(
        required=True,
        validate=validate.Length(min=1, max=100)
    )