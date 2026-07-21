from marshmallow import Schema, fields, validate
from app.common.custom_validators import positive_amount, non_negative_amount

class CreateIncomeSchema(Schema):

    source = fields.String(
        required=True,
        validate=validate.Length(min=2, max=100)
    )

    amount = fields.Decimal(
        required=True,
        as_string=True,
        validate=positive_amount
    )

    date = fields.Date(
        required=True
    )

    description = fields.String(
        required=False,
        allow_none=True,
        validate=validate.Length(max=255)
    )


class UpdateIncomeSchema(Schema):

    source = fields.String(
        validate=validate.Length(min=2, max=100)
    )

    amount = fields.Decimal(
    as_string=True,
    validate=positive_amount
)

    date = fields.Date()

    description = fields.String(
        allow_none=True,
        validate=validate.Length(max=255)
    )