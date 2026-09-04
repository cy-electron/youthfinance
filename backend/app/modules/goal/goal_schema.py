from marshmallow import Schema, fields, validate


class CreateGoalSchema(Schema):

    title = fields.Str(
        required=True,
        validate=validate.Length(min=2, max=150)
    )

    target_amount = fields.Decimal(
        required=True,
        validate=validate.Range(min=1)
    )

    initial_saving_amount = fields.Decimal(
        load_default=0,
        validate=validate.Range(min=0)
    )

    target_date = fields.Date(
        required=True
    )

    description = fields.Str(
        allow_none=True,
        validate=validate.Length(max=500)
    )


class UpdateGoalSchema(Schema):

    title = fields.Str(
        validate=validate.Length(min=2, max=150)
    )

    target_amount = fields.Decimal(
        validate=validate.Range(min=1)
    )

    target_date = fields.Date()

    description = fields.Str(
        allow_none=True,
        validate=validate.Length(max=500)
    )