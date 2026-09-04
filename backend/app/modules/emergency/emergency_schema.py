from marshmallow import Schema, fields, validate


class EmergencyMoneySchema(Schema):

    amount = fields.Decimal(
        required=True,
        validate=validate.Range(min=0.01)
    )

    description = fields.Str(
        required=False,
        allow_none=True,
        validate=validate.Length(max=500)
    )