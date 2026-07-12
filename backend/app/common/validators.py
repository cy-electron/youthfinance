from marshmallow import ValidationError


def validate_schema(schema, data):
    """
    Validate request data using a Marshmallow schema.
    Returns validated data or raises ValidationError.
    """
    return schema.load(data)