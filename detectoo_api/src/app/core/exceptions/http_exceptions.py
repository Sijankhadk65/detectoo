"""Re-export the HTTP exception classes used by the routers.

These come from FastCRUD so they integrate cleanly with the FastCRUD-generated
behaviour and produce consistent error payloads.
"""

# ruff: noqa
from fastcrud.exceptions.http_exceptions import (
    BadRequestException,
    CustomException,
    DuplicateValueException,
    ForbiddenException,
    NotFoundException,
    UnauthorizedException,
    UnprocessableEntityException,
)
