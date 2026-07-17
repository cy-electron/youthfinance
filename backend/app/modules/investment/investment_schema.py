from marshmallow import Schema, fields, validate


class InvestmentSchema(Schema):

    investment_type = fields.String(
        required=True,
        validate=validate.OneOf([
            "SIP",
            "Mutual Fund",
            "Fixed Deposit",
            "Gold",
            "Stocks",
            "PPF",
            "EPF",
            "Crypto",
            "Other"
        ])
    )

    investment_name = fields.String(required=True)

    amount = fields.Decimal(
    required=True,
    as_string=True,
    validate=validate.Range(
        min=0,
        min_inclusive=False,
        error="Investment amount must be greater than 0."
    )
)

    current_value = fields.Decimal(
    required=False,
    as_string=True,
    allow_none=True,
    validate=validate.Range(
        min=0,
        min_inclusive=True,
        error="Current value cannot be negative."
    )
)

    investment_date = fields.Date(required=True)

    notes = fields.String(
        required=False,
        allow_none=True
    )


investment_schema = InvestmentSchema()

investment_update_schema = InvestmentSchema(partial=True)