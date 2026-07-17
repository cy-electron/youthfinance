from marshmallow import Schema, fields, validate


class CreateExpenseSchema(Schema):
    category = fields.Str(
        required=True,
        validate=validate.Length(min=2, max=100)
    )

    amount = fields.Decimal(
        required=True,
        validate=validate.Range(min=0.01)
    )

    date = fields.Date(required=True)

    description = fields.Str(
        required=False,
        allow_none=True,
        validate=validate.Length(max=500)
    )


class UpdateExpenseSchema(Schema):
    category = fields.Str(
        validate=validate.Length(min=2, max=100)
    )

    amount = fields.Decimal(
        validate=validate.Range(min=0.01)
    )

    date = fields.Date()

    description = fields.Str(
        allow_none=True,
        validate=validate.Length(max=500)
    )