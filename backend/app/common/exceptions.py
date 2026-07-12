class APIException(Exception):
    """
    Base API Exception
    """

    status_code = 400

    def __init__(self, message):
        super().__init__(message)
        self.message = message


class ValidationException(APIException):
    status_code = 400


class UnauthorizedException(APIException):
    status_code = 401


class ForbiddenException(APIException):
    status_code = 403


class NotFoundException(APIException):
    status_code = 404


class ConflictException(APIException):
    status_code = 409