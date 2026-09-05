from marshmallow import Schema, fields, validate


class CreateSavingSchema(Schema):
    goal_id = fields.Integer(
        required=False,
        allow_none=True,
    )

    amount = fields.Decimal(
        required=True,
        validate=validate.Range(min=0.01),
    )

    date = fields.Date(
        required=True,
    )

    description = fields.Str(
        required=False,
        allow_none=True,
        validate=validate.Length(max=500),
    )

    saving_type = fields.Str(
        required=False,
        load_default="general",
        validate=validate.OneOf(
            ["general", "goal", "emergency"]
        ),
    )