from marshmallow import Schema, fields, validate

from app.common.custom_validators import positive_amount


class CreateFunFundSchema(Schema):

    budget_id = fields.Integer(
        required=True
    )

    title = fields.String(
        required=True,
        validate=validate.Length(min=2, max=100)
    )

    target_amount = fields.Decimal(
        required=True,
        as_string=True,
        validate=positive_amount
    )

    target_date = fields.Date(
        required=False,
        allow_none=True
    )

    notes = fields.String(
        required=False,
        allow_none=True
    )


class UpdateFunFundSchema(Schema):

    title = fields.String(
        validate=validate.Length(min=2, max=100)
    )

    target_amount = fields.Decimal(
        as_string=True,
        validate=positive_amount
    )

    target_date = fields.Date(
        allow_none=True
    )

    notes = fields.String(
        allow_none=True
    )