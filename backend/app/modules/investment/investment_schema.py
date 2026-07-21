from marshmallow import Schema, fields, validate
from app.common.custom_validators import positive_amount, non_negative_amount

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
    validate=positive_amount
)

    current_value = fields.Decimal(
    required=False,
    as_string=True,
    allow_none=True,
    validate=non_negative_amount
)

    investment_date = fields.Date(required=True)

    notes = fields.String(
        required=False,
        allow_none=True
    )


investment_schema = InvestmentSchema()

investment_update_schema = InvestmentSchema(partial=True)