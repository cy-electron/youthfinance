from marshmallow import Schema, fields, validate


class CreateBudgetSchema(Schema):

    category = fields.Str(
        required=True,
        validate=validate.Length(min=2, max=100)
    )

    amount = fields.Decimal(
        required=True,
        validate=validate.Range(min=1)
    )

    month = fields.Int(
        required=True,
        validate=validate.Range(min=1, max=12)
    )

    year = fields.Int(
        required=True,
        validate=validate.Range(min=2024, max=2100)
    )


class UpdateBudgetSchema(Schema):

    category = fields.Str(
        validate=validate.Length(min=2, max=100)
    )

    amount = fields.Decimal(
        validate=validate.Range(min=1)
    )

    month = fields.Int(
        validate=validate.Range(min=1, max=12)
    )

    year = fields.Int(
        validate=validate.Range(min=2024, max=2100)
    )