from marshmallow import ValidationError

from app.common.exceptions import APIException
from app.common.responses import error_response


def register_error_handlers(app):

    @app.errorhandler(APIException)
    def handle_api_exception(error):
        return error_response(
            message=error.message,
            status_code=error.status_code
        )

    @app.errorhandler(ValidationError)
    def handle_validation_error(error):
        return error_response(
            message="Validation failed.",
            errors=error.messages,
            status_code=400
        )

    @app.errorhandler(404)
    def handle_not_found(error):
        return error_response(
            message="Resource not found.",
            status_code=404
        )

    @app.errorhandler(500)
    def handle_server_error(error):
        return error_response(
            message="Internal server error.",
            status_code=500
        )