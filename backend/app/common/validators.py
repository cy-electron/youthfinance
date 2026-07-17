from marshmallow import Schema, ValidationError
from app.common.exceptions import ValidationException


def validate_schema(schema, data):
    try:
        # If it's a class, instantiate it
        if isinstance(schema, type):
            schema = schema()

        return schema.load(data)

    except ValidationError as err:
        raise ValidationException(err.messages)