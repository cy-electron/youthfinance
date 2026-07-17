from marshmallow import Schema, fields, validate


class CreateIncomeSchema(Schema):

    source = fields.String(
        required=True,
        validate=validate.Length(min=2, max=100)
    )

    amount = fields.Decimal(
        required=True,
        as_string=True,
        validate=validate.Range(min=0, min_inclusive=False, error="Amount must be greater than 0."),
        
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
    validate=validate.Range(
        min=0,
        min_inclusive=False
    )
)

    date = fields.Date()

    description = fields.String(
        allow_none=True,
        validate=validate.Length(max=255)
    )