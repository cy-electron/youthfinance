from marshmallow import Schema, fields, validate


class CreateIncomeSchema(Schema):

    source = fields.String(
        required=True,
        validate=validate.Length(min=2, max=100)
    )

    amount = fields.Decimal(
        required=True,
        as_string=True,
        validate=validate.Range(min=-1, min_inclusive=False)
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
        as_string=True
    )

    date = fields.Date()

    description = fields.String(
        allow_none=True,
        validate=validate.Length(max=255)
    )