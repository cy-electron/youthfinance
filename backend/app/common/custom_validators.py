from marshmallow import validate

positive_amount = validate.Range(
    min=0,
    min_inclusive=False,
    error="Value must be greater than 0."
)

non_negative_amount = validate.Range(
    min=0,
    min_inclusive=True,
    error="Value cannot be negative."
)